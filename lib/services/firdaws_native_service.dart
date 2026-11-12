import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirdawsNativeService {
  static final FirdawsNativeService _instance = FirdawsNativeService._internal();
  factory FirdawsNativeService() => _instance;
  FirdawsNativeService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.islamic.app/firdaws_native');

  bool _initialized = false;

  void Function(String voiceId, String prayerName)? onOpenAdhanScreen;
  void Function(bool isRinging, String voiceId, String prayerName)?
      onAdhanStateChanged;
  VoidCallback? onVolumeUpPressed;
  VoidCallback? onShowInAppSalawatPreview;

  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (_initialized || !isAndroid) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onOpenAdhanScreen':
          final args = (call.arguments as Map?) ?? const {};
          final voiceId = args['voiceId']?.toString() ?? 'madinah';
          final prayerName = args['prayerName']?.toString() ?? 'موعد الصلاة';
          onOpenAdhanScreen?.call(voiceId, prayerName);
          break;
        case 'onAdhanStateChanged':
          final args = (call.arguments as Map?) ?? const {};
          final isRinging = args['isRinging'] == true;
          final voiceId = args['voiceId']?.toString() ?? 'madinah';
          final prayerName = args['prayerName']?.toString() ?? 'موعد الصلاة';
          onAdhanStateChanged?.call(isRinging, voiceId, prayerName);
          break;
        case 'onVolumeUpPressed':
          onVolumeUpPressed?.call();
          break;
      }
    });
  }

  Future<bool> startAdhanAlarm({
    required String voiceId,
    required String prayerName,
  }) async {
    if (!isAndroid) return false;
    try {
      await _channel.invokeMethod('startAdhanAlarm', {
        'voiceId': voiceId,
        'prayerName': prayerName,
      });
      return true;
    } catch (e) {
      debugPrint('Native startAdhanAlarm error: $e');
      return false;
    }
  }

  Future<bool> stopAdhanAlarm() async {
    if (!isAndroid) return false;
    try {
      await _channel.invokeMethod('stopAdhanAlarm');
      return true;
    } catch (e) {
      debugPrint('Native stopAdhanAlarm error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> isAdhanRinging() async {
    if (!isAndroid) {
      return const {'isRinging': false, 'voiceId': 'madinah', 'prayerName': ''};
    }
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('isAdhanRinging');
      return res ?? const {'isRinging': false};
    } catch (_) {
      return const {'isRinging': false};
    }
  }

  Future<void> schedulePrayerAlarms(
    List<Map<String, dynamic>> alarms,
  ) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('schedulePrayerAlarms', {'alarms': alarms});
    } catch (e) {
      debugPrint('Native schedulePrayerAlarms error: $e');
    }
  }

  Future<Map<String, dynamic>> getAdhanDiagnostics() async {
    if (!isAndroid) {
      return const {
        'canScheduleExactAlarms': true,
        'notificationsEnabled': true,
        'ignoringBatteryOptimizations': true,
        'canDrawOverlays': true,
        'scheduledCount': 0,
      };
    }
    try {
      final res =
          await _channel.invokeMapMethod<String, dynamic>('getAdhanDiagnostics');
      return res ?? const {};
    } catch (_) {
      return const {};
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (_) {}
  }

  Future<void> requestBatteryOptimizationExemption() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('requestBatteryOptimizationExemption');
    } catch (_) {}
  }

  Future<bool> canDrawOverlays() async {
    if (!isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('canDrawOverlays');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestOverlayPermission() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  Future<bool> showSalawatOverlayNow() async {
    if (!isAndroid) return false;
    try {
      final shownOverlay =
          await _channel.invokeMethod<bool>('showSalawatOverlayNow');
      return shownOverlay ?? false;
    } catch (e) {
      debugPrint('Native showSalawatOverlayNow error: $e');
      return false;
    }
  }

  Future<void> scheduleSalawatReminders({
    required bool enabled,
    required int intervalMinutes,
    required List<String> customTimes,
  }) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('scheduleSalawatReminders', {
        'enabled': enabled,
        'intervalMinutes': intervalMinutes,
        'customTimes': customTimes,
      });
    } catch (e) {
      debugPrint('Native scheduleSalawatReminders error: $e');
    }
  }

  Future<Map<String, dynamic>?> consumeNativeLaunchExtras() async {
    if (!isAndroid) return null;
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>(
        'consumeNativeLaunchExtras',
      );
      return res;
    } catch (_) {
      return null;
    }
  }

  /// استهلاك عداد النقرات المسجل من الإشعار العائم للصلاة على النبي ﷺ
  Future<int> consumeNativeSalawatTaps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('salawat_native_taps') ?? 0;
      if (count > 0) {
        await prefs.setInt('salawat_native_taps', 0);
      }
      return count;
    } catch (_) {
      return 0;
    }
  }
}
