import 'package:flutter/foundation.dart';

/// Capabilities implemented by this app's current notification integrations.
/// The web build schedules no local notifications and has no native alarm path.
class NotificationPlatformCapabilities {
  final String platformLabel;
  final bool canCheckNotificationPermission;
  final bool supportsLocalNotifications;
  final bool supportsExactAlarms;
  final bool supportsBatteryOptimizationDiagnostics;
  final bool supportsNativeAdhanAlarm;
  final String userNotice;

  const NotificationPlatformCapabilities({
    required this.platformLabel,
    required this.canCheckNotificationPermission,
    required this.supportsLocalNotifications,
    required this.supportsExactAlarms,
    required this.supportsBatteryOptimizationDiagnostics,
    required this.supportsNativeAdhanAlarm,
    required this.userNotice,
  });

  static NotificationPlatformCapabilities forTarget({
    required bool isWeb,
    required TargetPlatform targetPlatform,
  }) {
    if (isWeb) {
      return const NotificationPlatformCapabilities(
        platformLabel: 'الويب',
        canCheckNotificationPermission: false,
        supportsLocalNotifications: false,
        supportsExactAlarms: false,
        supportsBatteryOptimizationDiagnostics: false,
        supportsNativeAdhanAlarm: false,
        userNotice:
            'نسخة الويب لا تنفذ تذكيراً محلياً قبل الأذان، ولا تنبيهات محلية بعد إغلاق الصفحة أو منبهاً يعمل في الخلفية؛ لا نضمن وصول الأذان أو التنبيه عند إغلاق الصفحة.',
      );
    }

    if (targetPlatform == TargetPlatform.android) {
      return const NotificationPlatformCapabilities(
        platformLabel: 'Android',
        canCheckNotificationPermission: true,
        supportsLocalNotifications: true,
        supportsExactAlarms: true,
        supportsBatteryOptimizationDiagnostics: true,
        supportsNativeAdhanAlarm: true,
        userNotice:
            'يدعم Android التنبيهات المحلية ومنبه الأذان الأصلي؛ يعتمد التنفيذ الفعلي على أذونات الإشعارات والمنبه الدقيق وإعدادات البطارية.',
      );
    }

    if (targetPlatform == TargetPlatform.iOS) {
      return const NotificationPlatformCapabilities(
        platformLabel: 'iOS',
        canCheckNotificationPermission: true,
        supportsLocalNotifications: true,
        supportsExactAlarms: false,
        supportsBatteryOptimizationDiagnostics: false,
        supportsNativeAdhanAlarm: false,
        userNotice:
            'يمكن فحص إذن الإشعارات المحلية على iOS. فحص المنبه الدقيق واستثناء البطارية ومنبه الأذان الأصلي خاصية Android وليست متاحة هنا.',
      );
    }

    return NotificationPlatformCapabilities(
      platformLabel: targetPlatform.name,
      canCheckNotificationPermission: false,
      supportsLocalNotifications: false,
      supportsExactAlarms: false,
      supportsBatteryOptimizationDiagnostics: false,
      supportsNativeAdhanAlarm: false,
      userNotice: 'فحص التنبيهات غير متاح لهذا الهدف في تكامل التطبيق الحالي.',
    );
  }
}
