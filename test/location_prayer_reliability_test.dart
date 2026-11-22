import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/services/location_service.dart';
import 'package:islamic_prayer_app/services/notification_capabilities.dart';
import 'package:islamic_prayer_app/services/prayer_reliability_labels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Location reliability', () {
    test('manual selection supersedes an in-flight lookup and persists',
        () async {
      SharedPreferences.setMockInitialValues({'auto_loc': false});
      final pendingLookup = Completer<DetectedLocationResult>();
      final settings = SettingsProvider(
        locationDetector: () => pendingLookup.future,
      );
      await settings.init();

      final request = settings.refreshCurrentLocation();
      expect(settings.isDetectingLocation, isTrue);

      settings.setManualLocation(21.4225, 39.8262, 'مكة المكرمة، السعودية');
      pendingLookup.complete(
        const DetectedLocationResult(
          succeeded: true,
          latitude: 51.5074,
          longitude: -0.1278,
          cityArabic: 'لندن',
          countryArabic: 'بريطانيا',
          displayName: 'لندن، بريطانيا',
          sourceLabel: 'GPS الدقيق',
        ),
      );

      final staleResult = await request;
      expect(staleResult.succeeded, isFalse);
      expect(settings.cityName, 'مكة المكرمة، السعودية');
      expect(settings.latitude, 21.4225);
      expect(settings.longitude, 39.8262);
      expect(settings.isAutoLocation, isFalse);
      expect(settings.isDetectingLocation, isFalse);
      expect(settings.hasConfirmedLocation, isTrue);
      expect(settings.locationSourceLabel, 'اختيار يدوي من قائمة المدن');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('city_name'), 'مكة المكرمة، السعودية');
      expect(prefs.getDouble('lat'), 21.4225);
      expect(prefs.getDouble('lng'), 39.8262);
      expect(prefs.getBool('auto_loc'), isFalse);
      expect(prefs.getBool('location_confirmed'), isTrue);

      final restored = SettingsProvider(
        locationDetector: () async => const DetectedLocationResult(
          succeeded: false,
          cityArabic: '',
          countryArabic: '',
          displayName: '',
          sourceLabel: 'تعذر التحديد',
        ),
      );
      await restored.init();
      expect(restored.cityName, 'مكة المكرمة، السعودية');
      expect(restored.latitude, 21.4225);
      expect(restored.longitude, 39.8262);
      expect(restored.isAutoLocation, isFalse);
      expect(restored.hasConfirmedLocation, isTrue);
      expect(restored.locationSourceLabel, 'اختيار يدوي من قائمة المدن');
    });

    test('default coordinates are not presented as a confirmed location',
        () async {
      SharedPreferences.setMockInitialValues({'auto_loc': false});
      final settings = SettingsProvider(
        locationDetector: () async => const DetectedLocationResult(
          succeeded: false,
          cityArabic: '',
          countryArabic: '',
          displayName: '',
          sourceLabel: 'تعذر التحديد',
        ),
      );
      await settings.init();

      expect(settings.hasConfirmedLocation, isFalse);
      expect(settings.locationSourceLabel, 'إحداثيات مؤقتة غير مؤكدة');
      expect(settings.cityName, 'لم تُحدّد مدينة بعد');
    });
  });

  group('Prayer and notification reliability labels', () {
    test('prayer method and madhab labels cover configured choices', () {
      expect(
        PrayerReliabilityLabels.method(CalculationMethod.umm_al_qura),
        'أم القرى',
      );
      expect(
        PrayerReliabilityLabels.method(CalculationMethod.egyptian),
        'الهيئة المصرية العامة للمساحة',
      );
      expect(
        PrayerReliabilityLabels.method(CalculationMethod.north_america),
        'أمريكا الشمالية (ISNA)',
      );
      expect(PrayerReliabilityLabels.madhab(Madhab.hanafi), 'المذهب الحنفي');
      expect(
        PrayerReliabilityLabels.madhab(Madhab.shafi),
        'الجمهور (شافعي، مالكي، حنبلي)',
      );
    });

    test('web does not claim notification or background alarm support', () {
      final capabilities = NotificationPlatformCapabilities.forTarget(
        isWeb: true,
        targetPlatform: TargetPlatform.android,
      );

      expect(capabilities.canCheckNotificationPermission, isFalse);
      expect(capabilities.supportsLocalNotifications, isFalse);
      expect(capabilities.supportsExactAlarms, isFalse);
      expect(capabilities.supportsNativeAdhanAlarm, isFalse);
      expect(capabilities.userNotice,
          contains('لا تنفذ تذكيراً محلياً قبل الأذان'));
      expect(capabilities.userNotice, contains('لا نضمن'));
    });

    test('supported native platforms expose only their actual diagnostics', () {
      final android = NotificationPlatformCapabilities.forTarget(
        isWeb: false,
        targetPlatform: TargetPlatform.android,
      );
      final ios = NotificationPlatformCapabilities.forTarget(
        isWeb: false,
        targetPlatform: TargetPlatform.iOS,
      );

      expect(android.canCheckNotificationPermission, isTrue);
      expect(android.supportsExactAlarms, isTrue);
      expect(android.supportsBatteryOptimizationDiagnostics, isTrue);
      expect(android.supportsNativeAdhanAlarm, isTrue);
      expect(ios.canCheckNotificationPermission, isTrue);
      expect(ios.supportsLocalNotifications, isTrue);
      expect(ios.supportsExactAlarms, isFalse);
      expect(ios.supportsBatteryOptimizationDiagnostics, isFalse);
      expect(ios.supportsNativeAdhanAlarm, isFalse);
    });
  });
}
