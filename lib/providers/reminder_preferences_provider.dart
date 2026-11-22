import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferences specific to the new foreground prayer reminder and quiet hours.
/// Salawat enabled/interval remain in SettingsProvider to retain existing keys
/// and the user's existing choices.
class ReminderPreferencesProvider extends ChangeNotifier {
  static const String _prayerEnabledKey = 'reminder_prayer_foreground_v1';
  static const String _quietEnabledKey = 'reminder_quiet_enabled_v1';
  static const String _quietStartKey = 'reminder_quiet_start_hour_v1';
  static const String _quietEndKey = 'reminder_quiet_end_hour_v1';

  SharedPreferences? _preferences;
  Future<void>? _initialization;
  Future<void> _writeQueue = Future<void>.value();
  final Set<String> _changedBeforeLoad = <String>{};
  bool _isInitialized = false;
  bool _prayerRemindersEnabled = false;
  bool _quietHoursEnabled = true;
  int _quietStartHour = 22;
  int _quietEndHour = 8;
  String _nativeScheduleStatus = 'لم تُطلب جدولة إشعارات الجهاز بعد.';

  bool get prayerRemindersEnabled => _prayerRemindersEnabled;
  bool get quietHoursEnabled => _quietHoursEnabled;
  int get quietStartHour => _quietStartHour;
  int get quietEndHour => _quietEndHour;
  String get nativeScheduleStatus => _nativeScheduleStatus;

  Future<void> init() => _initialization ??= _loadPreferences();

  Future<void> _loadPreferences() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      if (!_changedBeforeLoad.contains(_prayerEnabledKey)) {
        _prayerRemindersEnabled =
            _preferences!.getBool(_prayerEnabledKey) ?? false;
      }
      if (!_changedBeforeLoad.contains(_quietEnabledKey)) {
        _quietHoursEnabled = _preferences!.getBool(_quietEnabledKey) ?? true;
      }
      if (!_changedBeforeLoad.contains(_quietStartKey)) {
        _quietStartHour =
            (_preferences!.getInt(_quietStartKey) ?? 22).clamp(0, 23);
      }
      if (!_changedBeforeLoad.contains(_quietEndKey)) {
        _quietEndHour = (_preferences!.getInt(_quietEndKey) ?? 8).clamp(0, 23);
      }
      _isInitialized = true;
      notifyListeners();
    } catch (error) {
      debugPrint('Reminder preferences init error: $error');
    }
  }

  Future<void> setPrayerRemindersEnabled(bool enabled) {
    if (_isInitialized && _prayerRemindersEnabled == enabled) {
      return Future<void>.value();
    }
    _prayerRemindersEnabled = enabled;
    _changedBeforeLoad.add(_prayerEnabledKey);
    notifyListeners();
    return _persist(
        (preferences) => preferences.setBool(_prayerEnabledKey, enabled));
  }

  Future<void> setQuietHoursEnabled(bool enabled) {
    if (_isInitialized && _quietHoursEnabled == enabled) {
      return Future<void>.value();
    }
    _quietHoursEnabled = enabled;
    _changedBeforeLoad.add(_quietEnabledKey);
    notifyListeners();
    return _persist(
        (preferences) => preferences.setBool(_quietEnabledKey, enabled));
  }

  Future<void> setQuietStartHour(int hour) {
    final safeHour = hour.clamp(0, 23);
    if (_isInitialized && _quietStartHour == safeHour) {
      return Future<void>.value();
    }
    _quietStartHour = safeHour;
    _changedBeforeLoad.add(_quietStartKey);
    notifyListeners();
    return _persist(
        (preferences) => preferences.setInt(_quietStartKey, safeHour));
  }

  Future<void> setQuietEndHour(int hour) {
    final safeHour = hour.clamp(0, 23);
    if (_isInitialized && _quietEndHour == safeHour) {
      return Future<void>.value();
    }
    _quietEndHour = safeHour;
    _changedBeforeLoad.add(_quietEndKey);
    notifyListeners();
    return _persist(
        (preferences) => preferences.setInt(_quietEndKey, safeHour));
  }

  Future<void> _persist(
    Future<bool> Function(SharedPreferences preferences) operation,
  ) {
    final nextWrite = _writeQueue.catchError((Object _) {}).then((_) async {
      final preferences = _preferences ?? await SharedPreferences.getInstance();
      _preferences = preferences;
      await operation(preferences);
    }).catchError((Object error) {
      // Preferences are a convenience; keep the in-memory setting active if storage fails.
      debugPrint('Reminder preferences save error: $error');
    });
    _writeQueue = nextWrite;
    return nextWrite;
  }

  /// Runtime-only status from the foreground host; never persisted as proof of
  /// delivery, since the OS may still suppress a scheduled notification.
  void reportNativeScheduleStatus(String message) {
    if (_nativeScheduleStatus == message) return;
    _nativeScheduleStatus = message;
    notifyListeners();
  }
}
