import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/islamic_audio_data.dart';
import '../services/firdaws_native_service.dart';
import '../widgets/calm_ui.dart';
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';

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

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen> {
  final FocusNode _focusNode = FocusNode();
  AudioPlayer? _fallbackPlayer;
  bool _swipedReady = false;
  bool _isClosing = false;
  bool _isAudioStarting = true;
  bool _audioStartFailed = false;
  String _statusBanner =
      'الأذان يصدح الآن — اضغط زر رفع الصوت (+) أو اسحب للإلغاء';

  late final AdhanVoiceInfo _voice =
      IslamicAudioLibrary.getAdhanVoiceById(widget.voiceId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _startAudio();
    });
  }

  Future<void> _startAudio() async {
    try {
      final native = FirdawsNativeService();
      if (widget.useNativeService && native.isAndroid) {
        native.onVolumeUpPressed = () {
          _stopAndClose(reason: 'تم إيقاف الأذان بزر رفع الصوت ');
        };
        native.onAdhanStateChanged = (isRinging, _, __) {
          if (!isRinging && mounted && !_isClosing) {
            _stopAndClose(reason: 'تم إيقاف الأذان ');
          }
        };
        await native.startAdhanAlarm(
          voiceId: _voice.id,
          prayerName: widget.prayerName,
        );
      } else {
        // تشغيل متواصل في بيئة الويب / سطح المكتب أو التجربة المباشرة
        final player = AudioPlayer();
        _fallbackPlayer = player;
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setVolume(1.0);
        await player.play(AssetSource(_voice.assetPath));
      }
      if (mounted && !_isClosing) {
        setState(() => _isAudioStarting = false);
      }
    } catch (e) {
      debugPrint('Adhan alarm start error: $e');
      if (mounted && !_isClosing) {
        setState(() {
          _isAudioStarting = false;
          _audioStartFailed = true;
        });
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
    _focusNode.dispose();
    try {
      _fallbackPlayer?.stop();
      _fallbackPlayer?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
            _stopAndClose(reason: 'تم إيقاف الأذان بزر رفع الصوت');
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(child: BotanicalBackdrop()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;
                    final horizontalPadding = compact ? 16.0 : 28.0;
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        compact ? 14 : 24,
                        horizontalPadding,
                        36,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1040),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ParadiseHero(
                                title: 'حان وقت الصلاة',
                                subtitle: widget.prayerName.trim().isEmpty
                                    ? 'بدأ منبه الأذان. تظهر أدناه تفاصيل الصوت ووسائل الإيقاف.'
                                    : 'نداء ${widget.prayerName} بصوت المؤذن الذي اخترته.',
                                footer: _buildAudioStatus(theme),
                                minHeight: compact ? 236 : 250,
                              ),
                              const SizedBox(height: 28),
                              _buildCallDetails(theme),
                              const SizedBox(height: 30),
                              _buildStopOptions(theme),
                              const SizedBox(height: 24),
                              _buildClosingReminder(theme),
                            ],
                          ),
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

  Widget _buildAudioStatus(ThemeData theme) {
    final failed = _audioStartFailed;
    final starting = _isAudioStarting;
    final status = failed
        ? 'تعذرت تهيئة الصوت'
        : starting
            ? 'جارٍ تجهيز صوت الأذان'
            : 'الأذان يعمل الآن';
    final iconColor =
        failed ? const Color(0xFFFFC1B8) : const Color(0xFFE8D6A7);

    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (starting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8D6A7)),
                ),
              )
            else
              Icon(
                failed ? Icons.error_outline_rounded : Icons.graphic_eq_rounded,
                size: 19,
                color: iconColor,
              ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                status,
                softWrap: true,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallDetails(ThemeData theme) => ParadiseSection(
        title: 'تفاصيل النداء',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final prayer = _buildPrayerCard(theme);
            final voice = _buildVoiceCard(theme);
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  prayer,
                  const SizedBox(height: 14),
                  voice,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: prayer),
                const SizedBox(width: 16),
                Expanded(child: voice),
              ],
            );
          },
        ),
      );

  Widget _buildPrayerCard(ThemeData theme) {
    final name = widget.prayerName.trim();
    final scheme = theme.colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CalmIconBadge(Icons.notifications_active_outlined,
                  size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'الصلاة الحالية',
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          if (name.isEmpty) ...[
            Text(
              'لم يرد اسم الصلاة',
              softWrap: true,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'يعمل منبه الأذان، ويمكن إيقافه من الخيارات أدناه.',
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ] else
            Text(
              name,
              softWrap: true,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 31,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard(ThemeData theme) {
    final scheme = theme.colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CalmIconBadge(Icons.record_voice_over_outlined, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'صوت الأذان',
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Text(
            _voice.title,
            softWrap: true,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _voice.muezzin,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopOptions(ThemeData theme) => ParadiseSection(
        title: 'طرق إيقاف الأذان',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 780;
            final swipeAction = _buildSwipeAction(theme);
            final volumeAction = _buildVolumeAction(theme);
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: swipeAction),
                  const SizedBox(width: 16),
                  Expanded(child: volumeAction),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                swipeAction,
                const SizedBox(height: 14),
                volumeAction,
              ],
            );
          },
        ),
      );

  Widget _buildSwipeAction(ThemeData theme) {
    final scheme = theme.colorScheme;
    if (!_swipedReady) {
      return Dismissible(
        key: const ValueKey('adhan_swipe_unlock'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (_) async {
          setState(() {
            _swipedReady = true;
            _statusBanner = 'اضغط زر الإلغاء لإيقاف الأذان';
          });
          return false;
        },
        background: _swipeBg(Alignment.centerLeft),
        secondaryBackground: _swipeBg(Alignment.centerRight),
        child: CalmCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CalmIconBadge(Icons.swipe_outlined, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أظهر زر الإيقاف',
                      softWrap: true,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'اسحب هذه المساحة يمينًا أو يسارًا.',
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.swap_horiz_rounded, color: scheme.primary),
            ],
          ),
        ),
      );
    }

    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CalmIconBadge(Icons.lock_open_outlined, size: 46),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  _statusBanner,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _stopAndClose(reason: 'تم إيقاف الأذان'),
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('إلغاء وإيقاف الأذان'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeAction(ThemeData theme) {
    final scheme = theme.colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CalmIconBadge(Icons.volume_up_outlined, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'زر رفع الصوت',
                  softWrap: true,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'يمكنك إيقافه بزر رفع الصوت على الأجهزة المدعومة.',
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingReminder(ThemeData theme) {
    final failed = _audioStartFailed;
    final starting = _isAudioStarting;
    final message = failed
        ? 'واجه التطبيق مشكلة أثناء تهيئة الصوت. لا يزال بإمكانك إغلاق المنبه بإحدى الطريقتين أعلاه.'
        : starting
            ? 'يتم تجهيز تشغيل الصوت؛ ستظهر حالة البدء في أعلى الصفحة.'
            : 'يبقى الأذان مستمرًا حتى تستخدم إحدى طريقتي الإيقاف الموضحتين.';
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.75)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            failed ? Icons.info_outline_rounded : Icons.info_outline_rounded,
            color: scheme.primary,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeBg(Alignment alignment) => Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_open_outlined),
            const SizedBox(width: 8),
            Text(
              'أظهر زر الإيقاف',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
}
