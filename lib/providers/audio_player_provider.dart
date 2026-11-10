import 'dart:async';
import 'package:flutter/material.dart';
import '../models/islamic_audio_data.dart';

enum AudioCategory {
  quran,
  ruqyah,
  ibtihalat,
}

class AudioPlayerProvider extends ChangeNotifier {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5, seconds: 30);
  Timer? _playbackTimer;

  String _currentTitle = "سورة الفاتحة";
  String _currentSubTitle = "الشيخ ناصر القطامي";
  String? _currentAudioId;
  AudioCategory _activeCategory = AudioCategory.quran;
  ReciterInfo _selectedReciter = IslamicAudioLibrary.reciters.first;
  bool _isLooping = false;

  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentSubTitle => _currentSubTitle;
  String? get currentAudioId => _currentAudioId;
  AudioCategory get activeCategory => _activeCategory;
  ReciterInfo get selectedReciter => _selectedReciter;
  bool get isLooping => _isLooping;

  double get progressRatio {
    if (_duration.inMilliseconds == 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void selectReciter(ReciterInfo reciter) {
    _selectedReciter = reciter;
    if (_activeCategory == AudioCategory.quran && _isPlaying) {
      _currentSubTitle = reciter.name;
    }
    notifyListeners();
  }

  void playSurah(SurahAudioItem surah) {
    _activeCategory = AudioCategory.quran;
    _currentAudioId = "surah_${surah.number}";
    _currentTitle = "سورة ${surah.nameArabic}";
    _currentSubTitle = "${_selectedReciter.name} • ${surah.isMakki ? 'مكية' : 'مدنية'} (${surah.versesCount} آية)";
    _duration = _parseDuration(surah.defaultDuration);
    _position = Duration.zero;
    _startPlaying();
  }

  void playRuqyah(RuqyahAudioItem ruqyah) {
    _activeCategory = AudioCategory.ruqyah;
    _currentAudioId = ruqyah.id;
    _currentTitle = ruqyah.title;
    _currentSubTitle = "${ruqyah.reciter} • ${ruqyah.purpose}";
    _duration = _parseDuration(ruqyah.duration);
    _position = Duration.zero;
    _startPlaying();
  }

  void playIbtihal(IbtihalAudioItem ibtihal) {
    _activeCategory = AudioCategory.ibtihalat;
    _currentAudioId = ibtihal.id;
    _currentTitle = ibtihal.title;
    _currentSubTitle = "${ibtihal.reciter} • ${ibtihal.maqam}";
    _duration = _parseDuration(ibtihal.duration);
    _position = Duration.zero;
    _startPlaying();
  }

  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      _startPlaying();
    }
  }

  void pause() {
    _isPlaying = false;
    _playbackTimer?.cancel();
    notifyListeners();
  }

  void seekTo(double ratio) {
    final newMs = (_duration.inMilliseconds * ratio).round();
    _position = Duration(milliseconds: newMs);
    notifyListeners();
  }

  void seekForward10() {
    final next = _position + const Duration(seconds: 10);
    _position = next > _duration ? _duration : next;
    notifyListeners();
  }

  void seekRewind10() {
    final prev = _position - const Duration(seconds: 10);
    _position = prev < Duration.zero ? Duration.zero : prev;
    notifyListeners();
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void closePlayer() {
    pause();
    _currentAudioId = null;
    notifyListeners();
  }

  void _startPlaying() {
    _isPlaying = true;
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      final nextPos = _position + const Duration(seconds: 1);
      if (nextPos >= _duration) {
        if (_isLooping) {
          _position = Duration.zero;
        } else {
          _isPlaying = false;
          _position = _duration;
          timer.cancel();
        }
      } else {
        _position = nextPos;
      }
      notifyListeners();
    });
    notifyListeners();
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
    _playbackTimer?.cancel();
    super.dispose();
  }
}
