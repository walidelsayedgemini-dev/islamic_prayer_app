import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/islamic_audio_data.dart';
import '../utils/audio_cache_helper.dart';

enum AudioCategory {
  quran,
  ruqyah,
  ibtihalat,
}

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer? _player;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;
  bool _listenersAttached = false;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isOfflineSource = false;
  bool _hasLoadedSource = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5);

  String _currentTitle = "سورة الفاتحة";
  String _currentSubTitle = "الشيخ ناصر القطامي";
  String? _currentAudioId;
  String? _currentCacheKey;
  int? _currentSurahNumber;
  SurahAudioItem? _currentSurah;
  String? _errorMessage;

  AudioCategory _activeCategory = AudioCategory.quran;
  ReciterInfo _selectedReciter = IslamicAudioLibrary.reciters.first;
  bool _isLooping = false;
  int _playRequestToken = 0;

  final Set<String> _downloadedKeys = <String>{};
  final Map<String, double> _downloadingProgress = <String, double>{};
  Future<void> Function()? _replayLastTrack;

  AudioPlayerProvider() {
    if (!kIsWeb && AudioCacheHelper.supportsOfflineFileCache) {
      unawaited(refreshDownloadedKeys());
    }
  }

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isOfflineSource => _isOfflineSource;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentSubTitle => _currentSubTitle;
  String? get currentAudioId => _currentAudioId;
  int? get currentSurahNumber => _currentSurahNumber;
  AudioCategory get activeCategory => _activeCategory;
  ReciterInfo get selectedReciter => _selectedReciter;
  bool get isLooping => _isLooping;
  String? get errorMessage => _errorMessage;
  bool get supportsOfflineDownload => AudioCacheHelper.supportsOfflineFileCache;

  double get progressRatio {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  bool isTrackDownloaded(String cacheKey) => _downloadedKeys.contains(cacheKey);

  bool isSurahOfflineReady(int surahNumber) {
    if (IslamicAudioLibrary.getBundledSurahAsset(_selectedReciter.id, surahNumber) != null) {
      return true;
    }
    final key = IslamicAudioLibrary.surahCacheKey(_selectedReciter.id, surahNumber);
    return _downloadedKeys.contains(key);
  }

  bool isItemOfflineReady(String id, String? localAsset) {
    if (localAsset != null && localAsset.isNotEmpty) return true;
    return _downloadedKeys.contains(id);
  }

  double? downloadProgressFor(String cacheKey) => _downloadingProgress[cacheKey];

  Future<void> refreshDownloadedKeys() async {
    try {
      final keys = await AudioCacheHelper.listCachedTrackKeys();
      _downloadedKeys
        ..clear()
        ..addAll(keys);
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  AudioPlayer? _ensurePlayer() {
    try {
      _player ??= AudioPlayer();
      if (!_listenersAttached) {
        _listenersAttached = true;
        _posSub = _player!.onPositionChanged.listen((pos) {
          _position = pos;
          notifyListeners();
        });
        _durSub = _player!.onDurationChanged.listen((dur) {
          if (dur > Duration.zero) {
            _duration = dur;
            notifyListeners();
          }
        });
        _stateSub = _player!.onPlayerStateChanged.listen((state) {
          final playingNow = state == PlayerState.playing;
          if (playingNow) {
            _isLoading = false;
            _errorMessage = null;
          }
          _isPlaying = playingNow;
          notifyListeners();
        });
        _completeSub = _player!.onPlayerComplete.listen((_) {
          if (!_isLooping) {
            _isPlaying = false;
            _position = _duration;
            notifyListeners();
          }
        });
      }
      return _player;
    } catch (e) {
      debugPrint('AudioPlayer init skipped: $e');
      return null;
    }
  }

  Future<void> selectReciter(ReciterInfo reciter) async {
    _selectedReciter = reciter;
    if (_activeCategory == AudioCategory.quran && _currentSurah != null) {
      await playSurah(_currentSurah!);
    } else {
      notifyListeners();
    }
  }

  Future<void> playSurah(SurahAudioItem surah) async {
    _activeCategory = AudioCategory.quran;
    _currentSurah = surah;
    _currentSurahNumber = surah.number;
    _currentAudioId = "surah_${surah.number}";
    _currentTitle = "سورة ${surah.nameArabic}";
    _currentSubTitle =
        "${_selectedReciter.name} • ${surah.isMakki ? 'مكية' : 'مدنية'} (${surah.versesCount} آية)";

    final cacheKey = IslamicAudioLibrary.surahCacheKey(_selectedReciter.id, surah.number);
    final localAsset = IslamicAudioLibrary.getBundledSurahAsset(_selectedReciter.id, surah.number);
    final streamUrl = IslamicAudioLibrary.getSurahUrl(_selectedReciter.id, surah.number);
    final estDur = _parseDuration(surah.defaultDuration);

    _replayLastTrack = () => playSurah(surah);
    await _playResolvedTrack(
      cacheKey: cacheKey,
      localAsset: localAsset,
      streamUrl: streamUrl,
      estimatedDuration: estDur,
    );
  }

  Future<void> playSurahByNumber(int surahNumber) async {
    final surah = IslamicAudioLibrary.getSurahByNumber(surahNumber);
    if (surah != null) {
      await playSurah(surah);
    }
  }

  Future<void> playRuqyah(RuqyahAudioItem ruqyah) async {
    _activeCategory = AudioCategory.ruqyah;
    _currentSurah = null;
    _currentSurahNumber = null;
    _currentAudioId = ruqyah.id;
    _currentTitle = ruqyah.title;
    _currentSubTitle = "${ruqyah.reciter} • ${ruqyah.purpose}";
    _replayLastTrack = () => playRuqyah(ruqyah);

    await _playResolvedTrack(
      cacheKey: ruqyah.id,
      localAsset: ruqyah.localAsset,
      streamUrl: ruqyah.streamUrl,
      estimatedDuration: _parseDuration(ruqyah.duration),
    );
  }

  Future<void> playIbtihal(IbtihalAudioItem ibtihal) async {
    _activeCategory = AudioCategory.ibtihalat;
    _currentSurah = null;
    _currentSurahNumber = null;
    _currentAudioId = ibtihal.id;
    _currentTitle = ibtihal.title;
    _currentSubTitle = "${ibtihal.reciter} • ${ibtihal.maqam}";
    _replayLastTrack = () => playIbtihal(ibtihal);

    await _playResolvedTrack(
      cacheKey: ibtihal.id,
      localAsset: ibtihal.localAsset,
      streamUrl: ibtihal.streamUrl,
      estimatedDuration: _parseDuration(ibtihal.duration),
    );
  }

  Future<void> _playResolvedTrack({
    required String cacheKey,
    required String? localAsset,
    required String streamUrl,
    required Duration estimatedDuration,
  }) async {
    final token = ++_playRequestToken;
    _currentCacheKey = cacheKey;
    _duration = estimatedDuration;
    _position = Duration.zero;
    _isLoading = true;
    _isPlaying = false;
    _hasLoadedSource = false;
    _errorMessage = null;
    notifyListeners();

    final player = _ensurePlayer();
    if (player == null) {
      _isLoading = false;
      _errorMessage = "مشغل الصوت غير متاح في بيئة الاختبار الحالية";
      notifyListeners();
      return;
    }

    try {
      await player.stop();
      await player.setReleaseMode(_isLooping ? ReleaseMode.loop : ReleaseMode.release);

      if (token != _playRequestToken) return;

      final cachedFilePath = await AudioCacheHelper.getExistingFilePath(cacheKey);
      if (token != _playRequestToken) return;

      if (cachedFilePath != null) {
        _isOfflineSource = true;
        _downloadedKeys.add(cacheKey);
        await player.play(DeviceFileSource(cachedFilePath));
        _hasLoadedSource = true;
        _isLoading = false;
        _isPlaying = true;
        notifyListeners();
        return;
      }

      if (localAsset != null && localAsset.isNotEmpty) {
        try {
          _isOfflineSource = true;
          await player.play(AssetSource(localAsset));
          if (token != _playRequestToken) return;
          _hasLoadedSource = true;
          _isLoading = false;
          _isPlaying = true;
          notifyListeners();
          return;
        } catch (assetErr) {
          debugPrint('Asset fallback to stream for $localAsset: $assetErr');
        }
      }

      _isOfflineSource = false;
      await player.play(UrlSource(streamUrl));
      if (token != _playRequestToken) return;
      _hasLoadedSource = true;
      _isLoading = false;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      if (token != _playRequestToken) return;
      debugPrint('Audio playback error ($streamUrl): $e');
      _isLoading = false;
      _isPlaying = false;
      _hasLoadedSource = false;
      _errorMessage =
          "تعذر تشغيل الصوت حالياً — تأكد من اتصال الإنترنت أو حمّل المقطع للاستماع بدون نت.";
      notifyListeners();
    }
  }

  Future<bool> downloadTrackForOffline(String cacheKey, String url) async {
    if (!AudioCacheHelper.supportsOfflineFileCache) {
      _errorMessage = "حفظ المقاطع بدون إنترنت متاح في تطبيق الأندرويد.";
      notifyListeners();
      return false;
    }
    if (_downloadingProgress.containsKey(cacheKey)) {
      return false;
    }

    _downloadingProgress[cacheKey] = 0.01;
    _errorMessage = null;
    notifyListeners();

    DateTime lastEmit = DateTime.now();
    try {
      final path = await AudioCacheHelper.downloadTrack(
        cacheKey,
        url,
        onProgress: (p) {
          final now = DateTime.now();
          if (now.difference(lastEmit).inMilliseconds >= 120 || p >= 0.99) {
            lastEmit = now;
            _downloadingProgress[cacheKey] = p.clamp(0.02, 1.0);
            notifyListeners();
          }
        },
      );
      _downloadingProgress.remove(cacheKey);
      if (path != null) {
        _downloadedKeys.add(cacheKey);
        if (_currentCacheKey == cacheKey) {
          _isOfflineSource = true;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Offline download error ($cacheKey): $e');
      _downloadingProgress.remove(cacheKey);
      _errorMessage = "فشل تحميل المقطع للاستماع بدون إنترنت — حاول مرة أخرى.";
      notifyListeners();
      return false;
    }
  }

  Future<void> togglePlay() async {
    if (_isLoading) return;
    if (_isPlaying) {
      await pause();
      return;
    }

    final player = _ensurePlayer();
    if (player == null) return;

    try {
      if (_hasLoadedSource && _position < _duration) {
        await player.resume();
        _isPlaying = true;
        _errorMessage = null;
        notifyListeners();
      } else if (_replayLastTrack != null) {
        await _replayLastTrack!();
      }
    } catch (e) {
      if (_replayLastTrack != null) {
        await _replayLastTrack!();
      } else {
        _errorMessage = "تعذر استئناف التشغيل: $e";
        notifyListeners();
      }
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
    try {
      await _player?.pause();
    } catch (_) {}
  }

  Future<void> seekTo(double ratio) async {
    final safeRatio = ratio.clamp(0.0, 1.0);
    final newMs = (_duration.inMilliseconds * safeRatio).round();
    final target = Duration(milliseconds: newMs);
    _position = target;
    notifyListeners();
    try {
      await _player?.seek(target);
    } catch (_) {}
  }

  Future<void> seekForward10() async {
    final next = _position + const Duration(seconds: 10);
    final target = next > _duration ? _duration : next;
    _position = target;
    notifyListeners();
    try {
      await _player?.seek(target);
    } catch (_) {}
  }

  Future<void> seekRewind10() async {
    final prev = _position - const Duration(seconds: 10);
    final target = prev < Duration.zero ? Duration.zero : prev;
    _position = target;
    notifyListeners();
    try {
      await _player?.seek(target);
    } catch (_) {}
  }

  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    notifyListeners();
    try {
      await _player?.setReleaseMode(
        _isLooping ? ReleaseMode.loop : ReleaseMode.release,
      );
    } catch (_) {}
  }

  Future<void> closePlayer() async {
    _playRequestToken++;
    _isPlaying = false;
    _isLoading = false;
    _hasLoadedSource = false;
    _currentAudioId = null;
    _currentSurah = null;
    _currentSurahNumber = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Duration _parseDuration(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]) ?? 5;
      final sec = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: min, seconds: sec);
    } else if (parts.length == 3) {
      final hr = int.tryParse(parts[0]) ?? 0;
      final min = int.tryParse(parts[1]) ?? 30;
      final sec = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: hr, minutes: min, seconds: sec);
    }
    return const Duration(minutes: 5);
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return "${twoDigits(d.inHours)}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    try {
      _player?.dispose();
    } catch (_) {}
    super.dispose();
  }
}
