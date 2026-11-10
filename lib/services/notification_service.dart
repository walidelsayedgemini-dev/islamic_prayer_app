import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // طلب أذونات التنبيهات والأوقات الدقيقة على أندرويد
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }
  }

  // جدولة صلوات اليوم مع ملف الصوت المختار
  Future<void> scheduleDailyPrayers({
    required AdvancedPrayerTimes prayers,
    required String voiceResource, // e.g., 'madinah', 'makkah', etc.
    bool preAdhanReminder = true,
  }) async {
    try {
      // مسح الجداول السابقة لتجنب التكرار
      await flutterLocalNotificationsPlugin.cancelAll();

      final times = {
        1: {'name': 'صلاة الفجر', 'time': prayers.prayerTimes.fajr},
        2: {'name': 'صلاة الظهر', 'time': prayers.prayerTimes.dhuhr},
        3: {'name': 'صلاة العصر', 'time': prayers.prayerTimes.asr},
        4: {'name': 'صلاة المغرب', 'time': prayers.prayerTimes.maghrib},
        5: {'name': 'صلاة العشاء', 'time': prayers.prayerTimes.isha},
      };

      final now = DateTime.now();

      for (var entry in times.entries) {
        final prayerTime = entry.value['time'] as DateTime;
        final prayerName = entry.value['name'] as String;

        // جدولة الأذان إذا كان وقته لم يمضِ بعد اليوم
        if (prayerTime.isAfter(now)) {
          await _scheduleSingleAdhan(
            id: entry.key,
            title: prayerName,
            scheduledTime: prayerTime,
            soundResource: voiceResource,
          );

          // تذكير قبل الأذان بـ 15 دقيقة للوضوء والاستعداد
          if (preAdhanReminder) {
            final reminderTime = prayerTime.subtract(const Duration(minutes: 15));
            if (reminderTime.isAfter(now)) {
              await _schedulePreAdhanReminder(
                id: entry.key + 100,
                prayerName: prayerName,
                scheduledTime: reminderTime,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error scheduling prayers: $e");
    }
  }

  Future<void> _scheduleSingleAdhan({
    required int id,
    required String title,
    required DateTime scheduledTime,
    required String soundResource,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      'حي على الصلاة.. حان الآن موعد $title',
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'adhan_high_priority_channel',
          'تنبيهات الأذان',
          channelDescription: 'قناة بث الأذان في الوقت المحدد بدقة',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: '$soundResource.caf',
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _schedulePreAdhanReminder({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'اقترب موعد $prayerName',
      'بقي 15 دقيقة على الأذان، استعد للوضوء والصلاة',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pre_adhan_channel',
          'تذكير ما قبل الصلاة',
          channelDescription: 'تذكير قبل الأذان بـ 15 دقيقة للاستعداد',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
