import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/adhan_skin_catalog.dart';
import '../models/islamic_audio_data.dart';
import '../screens/adhan_skin_gallery_screen.dart';
import '../services/firdaws_native_service.dart';

/// شاشة أذان كاملة؛ تشغيل الصوت مرة واحدة، مع الإيقاف اليدوي فقط.
class AdhanAlarmScreen extends StatefulWidget {
  final String voiceId;
  final String prayerName;
  final bool useNativeService;
  final String skinId;
  final ValueChanged<String>? onSkinSelected;

  const AdhanAlarmScreen({
    super.key,
    required this.voiceId,
    required this.prayerName,
    this.useNativeService = true,
    this.skinId = 'fajr_sapphire_garden',
    this.onSkinSelected,
  });

  @override
  State<AdhanAlarmScreen> createState() => _AdhanAlarmScreenState();
}

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen> {
  static const Color _warmGold = Color(0xFFE9D6A6);
  static const Color _deepNight = Color(0xFF071A1D);

  final FocusNode _focusNode = FocusNode();
  AudioPlayer? _fallbackPlayer;
  StreamSubscription<void>? _playerCompleteSubscription;
  Timer? _phraseTimer;

  late final AdhanVoiceInfo _voice =
      IslamicAudioLibrary.getAdhanVoiceById(widget.voiceId);
  late String _skinId;

  bool _isClosing = false;
  bool _isAudioStarting = true;
  bool _audioStartFailed = false;
  bool _audioCompleted = false;
  int _phraseIndex = 0;

  List<String> get _phrases {
    final isFajr = widget.prayerName.contains('الفجر') ||
        widget.prayerName.toLowerCase().contains('fajr');
    return <String>[
      'الله أكبر، الله أكبر',
      'أشهد أن لا إله إلا الله',
      'أشهد أن محمدًا رسول الله',
      if (isFajr) 'الصلاة خير من النوم',
      'حي على الصلاة',
      'حي على الفلاح',
      'الله أكبر، الله أكبر',
      'لا إله إلا الله',
    ];
  }

  @override
  void initState() {
    super.initState();
    _skinId = AdhanSkinCatalog.byId(widget.skinId).id;
    _startPhraseSequence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _startAudio();
    });
  }

  @override
  void didUpdateWidget(covariant AdhanAlarmScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skinId != widget.skinId) {
      _skinId = AdhanSkinCatalog.byId(widget.skinId).id;
    }
  }

  void _startPhraseSequence() {
    _phraseTimer?.cancel();
    _phraseTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || _audioCompleted || _isClosing) return;
      if (_phraseIndex < _phrases.length - 1) {
        setState(() => _phraseIndex += 1);
      } else {
        _phraseTimer?.cancel();
      }
    });
  }

  Future<void> _startAudio() async {
    try {
      final native = FirdawsNativeService();
      if (widget.useNativeService && native.isAndroid) {
        native.onVolumeUpPressed = () {
          _stopAndClose(reason: 'تم إيقاف الأذان بزر رفع الصوت');
        };
        native.onAdhanStateChanged = (isRinging, _, __) {
          if (!isRinging && mounted && !_isClosing) {
            _stopAndClose(reason: 'تم إيقاف الأذان');
          }
        };
        native.onAdhanPlaybackCompleted = _markAudioCompleted;
        final started = await native.startAdhanAlarm(
          voiceId: _voice.id,
          prayerName: widget.prayerName,
        );
        if (!started) throw StateError('تعذر بدء خدمة الأذان الأصلية');
      } else {
        // المعاينة على المنصات الأخرى لا تعيد تشغيل المقطع تلقائيًا.
        final player = AudioPlayer();
        _fallbackPlayer = player;
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(1.0);
        _playerCompleteSubscription =
            player.onPlayerComplete.listen((_) => _markAudioCompleted());
        await player.play(AssetSource(_voice.assetPath));
      }
      if (mounted && !_isClosing) {
        setState(() => _isAudioStarting = false);
      }
    } catch (error) {
      debugPrint('Adhan alarm start error: $error');
      if (mounted && !_isClosing) {
        setState(() {
          _isAudioStarting = false;
          _audioStartFailed = true;
        });
      }
    }
  }

  void _markAudioCompleted() {
    if (!mounted || _isClosing || _audioCompleted) return;
    setState(() => _audioCompleted = true);
    _phraseTimer?.cancel();
  }

  Future<void> _chooseSkin() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AdhanSkinGalleryScreen(selectedSkinId: _skinId),
      ),
    );
    if (selected == null || !mounted) return;
    final validId = AdhanSkinCatalog.byId(selected).id;
    setState(() => _skinId = validId);
    widget.onSkinSelected?.call(validId);
  }

  Future<void> _stopAndClose({required String reason}) async {
    if (_isClosing) return;
    _isClosing = true;
    _phraseTimer?.cancel();
    await _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;
    try {
      await _fallbackPlayer?.stop();
      await _fallbackPlayer?.dispose();
    } catch (_) {}
    _fallbackPlayer = null;

    final native = FirdawsNativeService();
    native.onAdhanStateChanged = null;
    native.onVolumeUpPressed = null;
    native.onAdhanPlaybackCompleted = null;
    await native.stopAdhanAlarm();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(reason), behavior: SnackBarBehavior.floating),
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    _focusNode.dispose();
    final native = FirdawsNativeService();
    native.onAdhanStateChanged = null;
    native.onVolumeUpPressed = null;
    native.onAdhanPlaybackCompleted = null;
    _playerCompleteSubscription?.cancel();
    _fallbackPlayer?.stop();
    _fallbackPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = AdhanSkinCatalog.byId(_skinId);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final skinAsset = skin.imageAsset.startsWith('/')
        ? skin.imageAsset.substring(1)
        : skin.imageAsset;
    final size = MediaQuery.of(context).size;
    final pixelWidth = (size.width * MediaQuery.of(context).devicePixelRatio)
        .round()
        .clamp(720, 1080)
        .toInt();

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
          backgroundColor: _deepNight,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 620),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Image.asset(
                    skinAsset,
                    key: ValueKey<String>(skin.id),
                    fit: BoxFit.cover,
                    cacheWidth: pixelWidth,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFF143A3A),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xAA061317),
                        Color(0x37111D22),
                        Color(0xC9071418),
                      ],
                      stops: [0, .46, 1],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;
                    final shortScreen = constraints.maxHeight < 740;
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 18 : 30,
                        compact ? 12 : 24,
                        compact ? 18 : 30,
                        26,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTopBar(),
                              SizedBox(
                                height: compact ? (shortScreen ? 14 : 24) : 48,
                              ),
                              _buildPrayerHeading(compact),
                              SizedBox(
                                height: compact ? (shortScreen ? 14 : 24) : 32,
                              ),
                              _buildAdhanPhrasePanel(compact),
                              const SizedBox(height: 16),
                              _buildDuaAfterAdhan(),
                              SizedBox(
                                height: compact ? (shortScreen ? 18 : 26) : 32,
                              ),
                              _buildStopControls(compact),
                              const SizedBox(height: 14),
                              _buildFooterNote(),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.26),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(.22)),
            ),
            child: const Row(
              children: [
                Icon(Icons.mosque_outlined, color: _warmGold, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الفردوس · نداء الصلاة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'تغيير خلفية الأذان',
          onPressed: _chooseSkin,
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black.withOpacity(.28),
            side: BorderSide(color: Colors.white.withOpacity(.28)),
          ),
          icon: const Icon(Icons.wallpaper_outlined),
        ),
      ],
    );
  }

  Widget _buildPrayerHeading(bool compact) {
    final name =
        widget.prayerName.trim().isEmpty ? 'حان وقت الصلاة' : widget.prayerName;
    return Column(
      children: [
        Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _warmGold.withOpacity(.94),
            fontSize: compact ? 14 : 16,
            letterSpacing: .3,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 31 : 42,
            height: 1.2,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                  color: Colors.black54, blurRadius: 18, offset: Offset(0, 3)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'بصوت ${_voice.title} · ${AdhanSkinCatalog.byId(_skinId).name}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.83),
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 23),
        _buildAudioStatus(),
      ],
    );
  }

  Widget _buildAudioStatus() {
    final label = _audioStartFailed
        ? 'تعذر بدء صوت الأذان'
        : _isAudioStarting
            ? 'جارٍ تجهيز النداء'
            : _audioCompleted
                ? 'انتهى الأذان · تقبّل الله'
                : 'الأذان يعمل مرة واحدة';
    final icon = _audioStartFailed
        ? Icons.error_outline_rounded
        : _isAudioStarting
            ? Icons.hourglass_top_rounded
            : _audioCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.graphic_eq_rounded;
    return AnimatedSwitcher(
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 240),
      child: Semantics(
        key: ValueKey<String>(label),
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.30),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: _warmGold),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdhanPhrasePanel(bool compact) {
    final phrase = _phrases[_phraseIndex];
    return Container(
      constraints: const BoxConstraints(minHeight: 194),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 34,
        vertical: compact ? 22 : 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xB40B2022),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _warmGold.withOpacity(.32)),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 24, offset: Offset(0, 11)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _audioCompleted ? Icons.favorite_rounded : Icons.waves_rounded,
            color: _warmGold,
            size: 30,
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: MediaQuery.of(context).disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 560),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .16),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              phrase,
              key: ValueKey<String>('adhan-phrase-$_phraseIndex'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 27 : 36,
                height: 1.45,
                fontWeight: FontWeight.w700,
                shadows: const [
                  Shadow(color: Colors.black45, blurRadius: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _audioCompleted
                ? 'اللهم تقبّل هذا النداء واجعلنا من أهل الصلاة'
                : 'نداءٌ يملأ القلب سكينةً وطمأنينة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _warmGold.withOpacity(.94),
              fontSize: compact ? 13 : 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          _buildPhraseProgress(),
        ],
      ),
    );
  }

  Widget _buildPhraseProgress() {
    final count = _phrases.length;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (index) {
        final active = index == _phraseIndex;
        final passed = index < _phraseIndex;
        return AnimatedContainer(
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
          width: active ? 22 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active || passed ? _warmGold : Colors.white.withOpacity(.34),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildDuaAfterAdhan() {
    if (!_audioCompleted) return const SizedBox.shrink();
    return AnimatedSize(
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: Container(
        key: const ValueKey<String>('dua-after-adhan'),
        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: const Color(0xD80B2022),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _warmGold.withOpacity(.32)),
        ),
        child: const Column(
          children: [
            Text(
              'الدعاء بعد الأذان',
              style: TextStyle(
                color: _warmGold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 11),
            Text(
              'اللهم رب هذه الدعوة التامة، والصلاة القائمة، آتِ محمدًا الوسيلة والفضيلة، وابعثه مقامًا محمودًا الذي وعدته.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAccessibleStop() async {
    if (_isClosing || !mounted) return;
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_audioCompleted ? 'إغلاق شاشة الأذان؟' : 'إيقاف الأذان؟'),
        content: Text(
          _audioCompleted
              ? 'انتهى المقطع. هل تريد إغلاق شاشة الأذان؟'
              : 'سيتم إيقاف صوت الأذان وإغلاق الشاشة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('متابعة'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_audioCompleted ? 'إغلاق الشاشة' : 'إيقاف الأذان'),
          ),
        ],
      ),
    );
    if (shouldStop == true && mounted) {
      await _stopAndClose(
        reason: _audioCompleted ? 'تم إغلاق شاشة الأذان' : 'تم إيقاف الأذان',
      );
    }
  }

  Widget _buildStopControls(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _confirmAccessibleStop,
          icon: Icon(
            _audioCompleted ? Icons.close_rounded : Icons.stop_circle_outlined,
          ),
          label: Text(_audioCompleted ? 'إغلاق شاشة الأذان' : 'إيقاف الأذان'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6B292C),
            foregroundColor: Colors.white,
            minimumSize: Size.fromHeight(compact ? 54 : 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: _warmGold.withOpacity(.34)),
            ),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _audioCompleted
              ? 'يمكنك إغلاق الشاشة بعد قراءة الدعاء.'
              : 'يمكنك إيقاف الصوت في أي وقت؛ لن يُعاد تشغيله تلقائيًا.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.78),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    final message = _audioStartFailed
        ? 'تعذرت تهيئة الصوت. يمكنك المحاولة من جديد أو إغلاق هذه الشاشة.'
        : _audioCompleted
            ? 'انتهى مقطع الأذان دون تكرار؛ بقيت الشاشة مفتوحة للدعاء.'
            : 'يُشغَّل الأذان مرة واحدة. زر رفع الصوت يوقفه على الأجهزة المدعومة.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _warmGold, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
