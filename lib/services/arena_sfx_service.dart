import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// خدمة المؤثرات الصوتية الواقعية للألعاب والمسابقات والنتائج (فوز، خسارة، نقاط، صناديق، إصابات).
/// تستخدم أصول WAV مدمجة وتُغلَّف بحماية آمنة ضد اختبارات الوحدات أو الأجهزة الصامتة.
class ArenaSfxService {
  ArenaSfxService._();

  static final ArenaSfxService instance = ArenaSfxService._();

  bool _enabled = true;
  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  final List<AudioPlayer> _pool = <AudioPlayer>[];
  int _poolIndex = 0;
  DateTime _lastTapAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastScoreAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastDamageAt = DateTime.fromMillisecondsSinceEpoch(0);

  AudioPlayer _nextPlayer() {
    if (_pool.length < 4) {
      final p = AudioPlayer();
      try {
        p.setReleaseMode(ReleaseMode.stop);
      } catch (_) {}
      _pool.add(p);
      return p;
    }
    final p = _pool[_poolIndex % _pool.length];
    _poolIndex = (_poolIndex + 1) % _pool.length;
    return p;
  }

  void _playAsset(String assetRelativePath, {double volume = 0.72}) {
    if (!_enabled) return;
    try {
      final player = _nextPlayer();
      unawaited(
        player
            .setVolume(volume.clamp(0.0, 1.0))
            .then((_) => player.stop())
            .then((_) => player.play(AssetSource(assetRelativePath)))
            .catchError((_) {}),
      );
    } catch (_) {
      // حماية في بيئة الاختبار widget_test أو المتصفح قبل تفعيل الصوت
    }
  }

  void playTap() {
    final now = DateTime.now();
    if (now.difference(_lastTapAt).inMilliseconds < 45) return;
    _lastTapAt = now;
    _playAsset('audio/sfx/sfx_tap.wav', volume: 0.45);
  }

  void playScore() {
    final now = DateTime.now();
    if (now.difference(_lastScoreAt).inMilliseconds < 65) return;
    _lastScoreAt = now;
    _playAsset('audio/sfx/sfx_score.wav', volume: 0.65);
  }

  void playCombo() {
    _playAsset('audio/sfx/sfx_combo.wav', volume: 0.75);
  }

  void playCrate() {
    _playAsset('audio/sfx/sfx_crate.wav', volume: 0.80);
  }

  void playDamage() {
    final now = DateTime.now();
    if (now.difference(_lastDamageAt).inMilliseconds < 120) return;
    _lastDamageAt = now;
    _playAsset('audio/sfx/sfx_damage.wav', volume: 0.78);
  }

  void playWin() {
    _playAsset('audio/sfx/sfx_win.wav', volume: 0.88);
  }

  void playLose() {
    _playAsset('audio/sfx/sfx_lose.wav', volume: 0.90);
  }
}
