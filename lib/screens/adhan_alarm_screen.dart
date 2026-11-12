import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/islamic_audio_data.dart';
import '../services/firdaws_native_service.dart';
import '../widgets/firdaws_resilient_image.dart';

/// شاشة منبه الأذان المتواصل بصوت المؤذن المختار
/// لا تتوقف إلا عند:
/// 1) الضغط على زر رفع الصوت من جانب الهاتف (Volume Up)
/// 2) السحب ثم الضغط على "إلغاء وإيقاف الأذان"
class AdhanAlarmScreen extends StatefulWidget {
  final String voiceId;
  final String prayerName;
  final bool useNativeService;

  const AdhanAlarmScreen({
    super.key,
    required this.voiceId,
    required this.prayerName,
    this.useNativeService = true,
  });

  @override
  State<AdhanAlarmScreen> createState() => _AdhanAlarmScreenState();
}

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  final FocusNode _focusNode = FocusNode();
  AudioPlayer? _fallbackPlayer;
  bool _swipedReady = false;
  bool _isClosing = false;
  String _statusBanner = 'الأذان يصدح الآن — اضغط زر رفع الصوت (+) أو اسحب للإلغاء';

  late final AdhanVoiceInfo _voice =
      IslamicAudioLibrary.getAdhanVoiceById(widget.voiceId);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _startAudio();
    });
  }

  Future<void> _startAudio() async {
    final native = FirdawsNativeService();
    if (widget.useNativeService && native.isAndroid) {
      native.onVolumeUpPressed = () {
        _stopAndClose(reason: 'تم إيقاف الأذان بزر رفع الصوت 🔊');
      };
      native.onAdhanStateChanged = (isRinging, _, __) {
        if (!isRinging && mounted && !_isClosing) {
          _stopAndClose(reason: 'تم إيقاف الأذان 🕌');
        }
      };
      await native.startAdhanAlarm(
        voiceId: _voice.id,
        prayerName: widget.prayerName,
      );
    } else {
      // تشغيل متواصل في بيئة الويب / سطح المكتب أو التجربة المباشرة
      try {
        final player = AudioPlayer();
        _fallbackPlayer = player;
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setVolume(1.0);
        await player.play(AssetSource(_voice.assetPath));
      } catch (e) {
        debugPrint('Adhan fallback player error: $e');
      }
    }
  }

  Future<void> _stopAndClose({required String reason}) async {
    if (_isClosing) return;
    _isClosing = true;
    try {
      await _fallbackPlayer?.stop();
      await _fallbackPlayer?.dispose();
    } catch (_) {}
    _fallbackPlayer = null;

    await FirdawsNativeService().stopAdhanAlarm();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reason),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _focusNode.dispose();
    try {
      _fallbackPlayer?.stop();
      _fallbackPlayer?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // منع زر الرجوع أو أي إغلاق عشوائي — لا يغلق إلا برفع الصوت أو السحب + زر إلغاء
      canPop: false,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
            _stopAndClose(reason: 'تم إيقاف الأذان عبر زر رفع الصوت (+) 🔊');
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF041410),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // خلفية تخيلية نقية للجنة تختلف باختلاف كل صلاة دون أي صور مساجد أو بشر
              Builder(
                builder: (ctx) {
                  final p = widget.prayerName;
                  final String paradiseAsset;
                  if (p.contains('الفجر') || p.toLowerCase().contains('fajr')) {
                    paradiseAsset = 'assets/images/garden/garden_sidrat_sunbeams.jpg';
                  } else if (p.contains('الشروق') || p.toLowerCase().contains('sunrise')) {
                    paradiseAsset = 'assets/images/themes/celestial_rayyan.jpg';
                  } else if (p.contains('الظهر') || p.toLowerCase().contains('dhuhr')) {
                    paradiseAsset = 'assets/images/garden/garden_day_paradise.jpg';
                  } else if (p.contains('العصر') || p.toLowerCase().contains('asr')) {
                    paradiseAsset = 'assets/images/themes/paradise_glade_firdaws.jpg';
                  } else if (p.contains('المغرب') || p.toLowerCase().contains('maghrib')) {
                    paradiseAsset = 'assets/images/garden/garden_sunset_eden.jpg';
                  } else if (p.contains('العشاء') || p.toLowerCase().contains('isha')) {
                    paradiseAsset = 'assets/images/garden/garden_night_starlight.jpg';
                  } else {
                    paradiseAsset = 'assets/images/themes/kawthar_fountain_pure.jpg';
                  }
                  return Image.asset(
                    paradiseAsset,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                    color: Colors.black.withOpacity(0.28),
                    colorBlendMode: BlendMode.darken,
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF03120E).withOpacity(0.45),
                      const Color(0xFF06251C).withOpacity(0.40),
                      const Color(0xFF020907).withOpacity(0.76),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (constraints.maxHeight - 28).clamp(0, 4000),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 6),
                            Firdaws4KCardShell(
                              backdrop: Background500Catalog.forExtraSection(35),
                              isDark: true,
                              borderRadius: 24,
                              borderColor: const Color(0xFF38BDF8).withOpacity(0.55),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              imageOpacity: 0.45,
                              child: const Text(
                                '🕌 منبه الأذان المتواصل • حيّ على الفلاح',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFE0F2FE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseCtrl,
                                  builder: (context, _) {
                                    final scale = 0.94 + (_pulseCtrl.value * 0.10);
                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFD4AF37),
                                              Color(0xFF059669),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFD4AF37)
                                                  .withOpacity(0.45),
                                              blurRadius: 36,
                                              spreadRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '🕌',
                                            style: TextStyle(fontSize: 60),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  widget.prayerName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_voice.title}\n(${_voice.muezzin})',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFA7F3D0),
                                    fontSize: 15.5,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Firdaws4KCardShell(
                                  backdrop: Background500Catalog.forExtraSection(36),
                                  isDark: true,
                                  borderRadius: 16,
                                  borderColor: Colors.white.withOpacity(0.28),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  imageOpacity: 0.42,
                                  child: Text(
                                    _statusBanner,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // شريط السحب + تفعيل زر الإلغاء الإلزامي بخلفية 4K إسلامية
                                if (!_swipedReady)
                                  Dismissible(
                                    key: const ValueKey('adhan_swipe_unlock'),
                                    direction: DismissDirection.horizontal,
                                    confirmDismiss: (_) async {
                                      setState(() {
                                        _swipedReady = true;
                                        _statusBanner =
                                            'الآن اضغط على زر «إلغاء وإيقاف الأذان» بالأسفل';
                                      });
                                      return false;
                                    },
                                    background: _swipeBg(Alignment.centerLeft),
                                    secondaryBackground: _swipeBg(Alignment.centerRight),
                                    child: Firdaws4KCardShell(
                                      backdrop: Background500Catalog.forExtraSection(37),
                                      isDark: true,
                                      borderRadius: 22,
                                      borderWidth: 1.5,
                                      borderColor: const Color(0xFFD4AF37),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      imageOpacity: 0.55,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.swipe_rounded,
                                              color: Color(0xFF38BDF8)),
                                          SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              'اسحب هذا الشريط يميناً أو يساراً لإظهار زر الإلغاء ↔️',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _stopAndClose(
                                        reason: 'تم إيقاف الأذان بعد السحب والإلغاء ✅',
                                      ),
                                      icon: const Icon(Icons.cancel_rounded, size: 26),
                                      label: const Text(
                                        '🛑 إلغاء وإيقاف الأذان الآن',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDC2626),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  '🔊 تلميح سريع: الضغط على زر رفع الصوت من جانب الهاتف (+) يوقف الأذان فوراً حتى والشاشة مقفلة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.72),
                                    fontSize: 11.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swipeBg(Alignment align) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withOpacity(0.78),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'جاري فتح زر الإلغاء 🔓',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
