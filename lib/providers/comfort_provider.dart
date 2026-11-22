import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locally stored accessibility and comfort preferences, independent of app settings.
class ComfortProvider extends ChangeNotifier {
  ComfortProvider({bool? systemReduceMotion})
      : _systemReduceMotion = systemReduceMotion ??
            WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
                .disableAnimations;

  static const String textScalePreferenceKey = 'comfort_v1_text_scale';
  static const String highContrastPreferenceKey = 'comfort_v1_high_contrast';
  static const String reduceMotionPreferenceKey = 'comfort_v1_reduce_motion';
  static const List<double> textScaleChoices = <double>[
    1.0,
    1.1,
    1.2,
    1.3,
    1.4
  ];

  SharedPreferences? _preferences;
  Future<void>? _initialization;
  Future<void> _writeQueue = Future<void>.value();
  double _additionalTextScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotionPreference = false;
  bool _systemReduceMotion;
  final Set<String> _changedBeforeLoad = <String>{};

  double get additionalTextScale => _additionalTextScale;
  bool get highContrast => _highContrast;
  bool get systemReduceMotion => _systemReduceMotion;
  bool get reduceMotionPreference => _reduceMotionPreference;

  /// System preference cannot be disabled by the app-level preference.
  bool get reduceMotion => _systemReduceMotion || _reduceMotionPreference;

  Future<void> init() => _initialization ??= _loadPreferences();

  Future<void> _loadPreferences() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      if (!_changedBeforeLoad.contains(textScalePreferenceKey)) {
        final storedScale = _preferences!.getDouble(textScalePreferenceKey);
        if (storedScale != null) {
          _additionalTextScale = _sanitizeTextScale(storedScale);
        }
      }
      if (!_changedBeforeLoad.contains(highContrastPreferenceKey)) {
        _highContrast =
            _preferences!.getBool(highContrastPreferenceKey) ?? false;
      }
      if (!_changedBeforeLoad.contains(reduceMotionPreferenceKey)) {
        _reduceMotionPreference =
            _preferences!.getBool(reduceMotionPreferenceKey) ?? false;
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Comfort preferences init error: $error');
    }
  }

  Future<void> setAdditionalTextScale(double scale) {
    _additionalTextScale = _sanitizeTextScale(scale);
    _changedBeforeLoad.add(textScalePreferenceKey);
    notifyListeners();
    return _persist((prefs) async {
      await prefs.setDouble(textScalePreferenceKey, _additionalTextScale);
    });
  }

  Future<void> setHighContrast(bool enabled) {
    if (_highContrast == enabled) return Future<void>.value();
    _highContrast = enabled;
    _changedBeforeLoad.add(highContrastPreferenceKey);
    notifyListeners();
    return _persist((prefs) async {
      await prefs.setBool(highContrastPreferenceKey, _highContrast);
    });
  }

  Future<void> setReduceMotionPreference(bool enabled) {
    if (_reduceMotionPreference == enabled) return Future<void>.value();
    _reduceMotionPreference = enabled;
    _changedBeforeLoad.add(reduceMotionPreferenceKey);
    notifyListeners();
    return _persist((prefs) async {
      await prefs.setBool(reduceMotionPreferenceKey, _reduceMotionPreference);
    });
  }

  /// Refresh when the platform accessibility features change while the app runs.
  void updateSystemReduceMotion(bool enabled) {
    if (_systemReduceMotion == enabled) return;
    _systemReduceMotion = enabled;
    notifyListeners();
  }

  /// Restore only these comfort preferences; app data and religious/game state are untouched.
  Future<void> resetComfortPreferences() {
    _additionalTextScale = 1.0;
    _highContrast = false;
    _reduceMotionPreference = false;
    _changedBeforeLoad
      ..add(textScalePreferenceKey)
      ..add(highContrastPreferenceKey)
      ..add(reduceMotionPreferenceKey);
    notifyListeners();
    return _persist((prefs) async {
      await prefs.setDouble(textScalePreferenceKey, 1.0);
      await prefs.setBool(highContrastPreferenceKey, false);
      await prefs.setBool(reduceMotionPreferenceKey, false);
    });
  }

  Future<void> _persist(Future<void> Function(SharedPreferences) operation) {
    final nextWrite = _writeQueue.catchError((Object _) {}).then((_) async {
      final prefs = _preferences ?? await SharedPreferences.getInstance();
      _preferences = prefs;
      await operation(prefs);
    }).catchError((Object error) {
      // Preferences are a convenience; keep the in-memory setting active if storage fails.
      debugPrint('Comfort preferences save error: $error');
    });
    _writeQueue = nextWrite;
    return nextWrite;
  }

  static double _sanitizeTextScale(double scale) {
    if (!scale.isFinite) return 1.0;
    final bounded = scale.clamp(1.0, 1.4).toDouble();
    return textScaleChoices.reduce((closest, choice) =>
        (choice - bounded).abs() < (closest - bounded).abs()
            ? choice
            : closest);
  }
}
