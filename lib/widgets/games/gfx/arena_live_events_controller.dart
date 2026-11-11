import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/events_missions_catalog.dart';
import '../../../providers/hasanat_provider.dart';
import '../arena_3d_backdrop.dart';
import 'arena_stage_fx.dart';

class _LivePrizeCrate {
  final int id;
  final double normalizedX; // 0.14..0.86
  final double speed;
  final int rewardHasanat;
  final bool isJackpot;
  double yFraction = 0.16; // 0.16..0.76

  _LivePrizeCrate({
    required this.id,
    required this.normalizedX,
    required this.speed,
    required this.rewardHasanat,
    required this.isJackpot,
  });
}

class _HasanatFloatingToast {
  final int id;
  final double normalizedX;
  final double yFraction;
  final int amount;
  final Color color;
  double life = 1.0;

  _HasanatFloatingToast({
    required this.id,
    required this.normalizedX,
    required this.yFraction,
    required this.amount,
    required this.color,
  });
}

/// طبقة تفاعلية حيّة للأحداث المباشرة وصناديق الجوائز فوق جميع ألعاب الـ 30
class ArenaLiveEventsOverlay extends StatefulWidget {
  final ArenaMatchConfig config;

  const ArenaLiveEventsOverlay({
    super.key,
    required this.config,
  });

  @override
  State<ArenaLiveEventsOverlay> createState() => _ArenaLiveEventsOverlayState();
}

class _ArenaLiveEventsOverlayState extends State<ArenaLiveEventsOverlay> {
  final math.Random _rng = math.Random();
  final List<_LivePrizeCrate> _crates = [];
  final List<_HasanatFloatingToast> _toasts = [];

  Timer? _tickTimer;
  int _idCounter = 0;
  double _elapsedSec = 0;
  double _nextCrateAtSec = 4.5;
  double _nextWaveAtSec = 11.0;
  String? _activeWaveBanner;
  double _waveBannerRemain = 0;

  @override
  void initState() {
    super.initState();
    final event = widget.config.activeEvent;
    if (event != null &&
        (event.id == 'event_treasure_rain' ||
            event.id == 'event_firdaws_championship')) {
      _nextCrateAtSec = 2.6;
    }

    _tickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      const dt = 0.05;
      _elapsedSec += dt;

      final ev = widget.config.activeEvent;
      final crateInterval = ev != null ? 5.8 : 8.5;

      if (_elapsedSec >= _nextCrateAtSec && _crates.length < 3) {
        _nextCrateAtSec = _elapsedSec + crateInterval;
        final jackpot = ev != null
            ? _rng.nextDouble() < 0.42
            : _rng.nextDouble() < 0.22;
        final xSide = _rng.nextBool()
            ? (0.12 + _rng.nextDouble() * 0.18)
            : (0.70 + _rng.nextDouble() * 0.18);
        _crates.add(
          _LivePrizeCrate(
            id: ++_idCounter,
            normalizedX: xSide,
            speed: jackpot ? 0.085 : 0.072,
            rewardHasanat: jackpot ? 45 : (25 + _rng.nextInt(14)),
            isJackpot: jackpot,
          ),
        );
      }

      if (_elapsedSec >= _nextWaveAtSec) {
        _nextWaveAtSec = _elapsedSec + 14.0;
        _triggerMidGameEventWave();
      }

      for (final c in _crates) {
        c.yFraction += c.speed * dt;
      }
      _crates.removeWhere((c) => c.yFraction > 0.76);

      for (final toast in _toasts) {
        toast.life -= dt * 1.15;
      }
      _toasts.removeWhere((t) => t.life <= 0);

      if (_waveBannerRemain > 0) {
        _waveBannerRemain -= dt;
        if (_waveBannerRemain <= 0) {
          _activeWaveBanner = null;
        }
      }

      setState(() {});
    });
  }

  void _triggerMidGameEventWave() {
    final ev = widget.config.activeEvent;
    final phrases = [
      if (ev != null) '⚡ حدث «${ev.title}» يمطر الحسنات الآن!',
      '🎁 صندوق جائزة هبط في ساحة المنافسة — التقطه سريعاً!',
      '🚀 موجة تسارع ثلاثية الأبعاد — واصل الصدارة!',
      '🌟 بريق الفوز يضاعف رصيدك عند خط النهاية!',
    ];
    _activeWaveBanner = phrases[_rng.nextInt(phrases.length)];
    _waveBannerRemain = 3.2;

    if (_crates.isEmpty) {
      _crates.add(
        _LivePrizeCrate(
          id: ++_idCounter,
          normalizedX: _rng.nextBool() ? 0.16 : 0.84,
          speed: 0.078,
          rewardHasanat: 35,
          isJackpot: true,
        ),
      );
    }
  }

  Future<void> _openCrate(_LivePrizeCrate crate) async {
    _crates.removeWhere((c) => c.id == crate.id);
    HapticFeedback.mediumImpact();

    int awarded = crate.rewardHasanat;
    try {
      final hasanat = context.read<HasanatProvider>();
      awarded = await hasanat.earnHasanat(
        crate.rewardHasanat,
        reason: 'صندوق جائزة داخل ${widget.config.game.title}',
        sourceTag: 'صندوق جائزة',
      );
      await hasanat.recordMetric(EventMissionMetric.prizeCratesOpened);
    } catch (_) {}

    if (!mounted) return;
    ArenaStageFxScope.maybeOf(context)?.emitCrate(
      Offset(crate.normalizedX, crate.yFraction),
      awarded,
    );
    setState(() {
      _toasts.add(
        _HasanatFloatingToast(
          id: ++_idCounter,
          normalizedX: crate.normalizedX,
          yFraction: crate.yFraction,
          amount: awarded,
          color: crate.isJackpot
              ? const Color(0xFFFBBF24)
              : const Color(0xFF10B981),
        ),
      );
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Stack(
          children: [
            // شريط إشعار الحدث المتوسط (غير مانع للمس)
            if (_activeWaveBanner != null)
              Positioned(
                top: 98,
                left: 24,
                right: 24,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            widget.config.world.glowColor.withOpacity(0.90),
                            const Color(0xFF0F172A).withOpacity(0.92),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.45),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.config.world.glowColor
                                .withOpacity(0.45),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Text(
                        _activeWaveBanner!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // صناديق الجوائز التفاعلية القابلة للنقر
            ..._crates.map((crate) {
              final cx = (crate.normalizedX * w).clamp(32.0, w - 32.0);
              final cy = (crate.yFraction * h).clamp(96.0, h - 120.0);
              final col = crate.isJackpot
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFF10B981);
              final bob = math.sin(_elapsedSec * 5.0 + crate.id) * 4.0;
              return Positioned(
                left: cx - 28,
                top: cy - 28 + bob,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openCrate(crate),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          col,
                          Color.lerp(col, Colors.black, 0.45)!,
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: col.withOpacity(0.70),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          crate.isJackpot
                              ? Icons.card_giftcard_rounded
                              : Icons.redeem_rounded,
                          color: const Color(0xFF09111E),
                          size: 23,
                        ),
                        Text(
                          '+${crate.rewardHasanat}',
                          style: const TextStyle(
                            color: Color(0xFF09111E),
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // إشعارات جمع الحسنات الفورية
            ..._toasts.map((toast) {
              final cx = (toast.normalizedX * w).clamp(48.0, w - 48.0);
              final cy = (toast.yFraction * h - (1.0 - toast.life) * 42)
                  .clamp(60.0, h - 100.0);
              return Positioned(
                left: cx - 50,
                top: cy - 16,
                width: 100,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: toast.life.clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF09111E).withOpacity(0.90),
                        border: Border.all(color: toast.color, width: 1.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on_rounded,
                              color: toast.color, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            '+${toast.amount}',
                            style: TextStyle(
                              color: toast.color,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
