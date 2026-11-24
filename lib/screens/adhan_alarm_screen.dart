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

  bool _swipedReady = false;
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
                  duration: const Duration(milliseconds: 950),
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
                              SizedBox(height: compact ? 38 : 56),
                              _buildPrayerHeading(compact),
                              SizedBox(height: compact ? 30 : 42),
                              _buildAdhanPhrasePanel(compact),
                              const SizedBox(height: 22),
                              _buildDuaAfterAdhan(),
                              SizedBox(height: compact ? 28 : 38),
                              _buildStopControls(compact),
                              const SizedBox(height: 18),
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
    return Semantics(
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
    );
  }

  Widget _buildAdhanPhrasePanel(bool compact) {
    final phrase = _phrases[_phraseIndex];
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 38,
        vertical: compact ? 26 : 34,
      ),
      decoration: BoxDecoration(
        color: const Color(0xD80B2022),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _warmGold.withOpacity(.42), width: 1.1),
        boxShadow: const [
          BoxShadow(
              color: Colors.black38, blurRadius: 30, offset: Offset(0, 15)),
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
            duration: const Duration(milliseconds: 720),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (index) {
        final active = index == _phraseIndex;
        final passed = index < _phraseIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
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
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: Container(
        key: const ValueKey<String>('dua-after-adhan'),
        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _warmGold.withOpacity(.8)),
        ),
        child: const Column(
          children: [
            Text(
              'الدعاء بعد الأذان',
              style: TextStyle(
                color: Color(0xFF173C39),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 11),
            Text(
              'اللهم رب هذه الدعوة التامة، والصلاة القائمة، آتِ محمدًا الوسيلة والفضيلة، وابعثه مقامًا محمودًا الذي وعدته.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF233A39),
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

  Widget _buildStopControls(bool compact) {
    if (!_swipedReady) {
      return Dismissible(
        key: const ValueKey<String>('adhan_swipe_unlock'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (_) async {
          if (!mounted) return false;
          setState(() => _swipedReady = true);
          return false;
        },
        background: _swipeBackground(Alignment.centerLeft),
        secondaryBackground: _swipeBackground(Alignment.centerRight),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.32),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.22)),
          ),
          child: Row(
            children: [
              const Icon(Icons.swipe_rounded, color: _warmGold, size: 27),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'اسحب هنا لإظهار زر إيقاف الأذان',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              Icon(Icons.swap_horiz_rounded,
                  color: Colors.white.withOpacity(.8)),
            ],
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: () => _stopAndClose(reason: 'تم إيقاف الأذان'),
      icon: const Icon(Icons.stop_circle_outlined),
      label: const Text('إلغاء وإيقاف الأذان'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF6B292C),
        foregroundColor: Colors.white,
        minimumSize: Size.fromHeight(compact ? 56 : 62),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _swipeBackground(Alignment alignment) => Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF294E47),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.lock_open_rounded, color: Colors.white),
      );

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
