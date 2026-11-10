import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/islamic_audio_data.dart';
import '../models/prayer_model.dart';
import 'firdaws_native_service.dart';

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
      await FirdawsNativeService().initialize();

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

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  // جدولة صلوات اليوم مع تشغيل الأذان المتواصل بصوت المؤذن المختار
  Future<void> scheduleDailyPrayers({
    required AdvancedPrayerTimes prayers,
    required String voiceResource,
    bool preAdhanReminder = true,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();

      final resolvedVoice = IslamicAudioLibrary.getAdhanVoiceById(voiceResource);
      final times = <int, Map<String, dynamic>>{
        1: {'name': 'صلاة الفجر', 'time': prayers.prayerTimes.fajr},
        2: {'name': 'صلاة الظهر', 'time': prayers.prayerTimes.dhuhr},
        3: {'name': 'صلاة العصر', 'time': prayers.prayerTimes.asr},
        4: {'name': 'صلاة المغرب', 'time': prayers.prayerTimes.maghrib},
        5: {'name': 'صلاة العشاء', 'time': prayers.prayerTimes.isha},
      };

      final now = DateTime.now();
      final nativeAlarms = <Map<String, dynamic>>[];

      Future<void> addPrayerAlarm(int id, String prayerName, DateTime prayerTime) async {
        if (!prayerTime.isAfter(now)) return;
        nativeAlarms.add({
          'triggerAtMillis': prayerTime.millisecondsSinceEpoch,
          'voiceId': resolvedVoice.id,
          'prayerName': prayerName,
        });

        await _scheduleSingleAdhanNotificationFallback(
          id: id,
          title: prayerName,
          scheduledTime: prayerTime,
          rawSoundName: resolvedVoice.rawResourceName,
        );

        if (preAdhanReminder) {
          final reminderTime =
              prayerTime.subtract(const Duration(minutes: 15));
          if (reminderTime.isAfter(now)) {
            await _schedulePreAdhanReminder(
              id: id + 100,
              prayerName: prayerName,
              scheduledTime: reminderTime,
            );
          }
        }
      }

      for (final entry in times.entries) {
        final prayerTime = entry.value['time'] as DateTime;
        final prayerName = entry.value['name'] as String;
        await addPrayerAlarm(entry.key, prayerName, prayerTime);
      }

      // إذا انقضى وقت فجر اليوم، نُجدول فجر الغد (ID: 6) حتى لا يفوت منبه الفجر ليلاً
      if (!prayers.prayerTimes.fajr.isAfter(now) &&
          prayers.tomorrowFajr.isAfter(now)) {
        await addPrayerAlarm(6, 'صلاة الفجر', prayers.tomorrowFajr);
      }

      // جدولة المنبه الحقيقي المتواصل على مستوى النظام (AdhanAlarmReceiver -> AdhanPlaybackService)
      await FirdawsNativeService().schedulePrayerAlarms(nativeAlarms);
    } catch (e) {
      debugPrint('Error scheduling prayers: $e');
    }
  }

  Future<void> _scheduleSingleAdhanNotificationFallback({
    required int id,
    required String title,
    required DateTime scheduledTime,
    required String rawSoundName,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '🕌 $title',
      'حيّ على الصلاة.. حان الآن موعد $title',
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'firdaws_adhan_ch_$rawSoundName',
          'تنبيهات الأذان ($rawSoundName)',
          channelDescription: 'بث الأذان بصوت المؤذن المختار في الوقت المحدد بدقة',
          importance: Importance.max,
          priority: Priority.max,
          sound: RawResourceAndroidNotificationSound(rawSoundName),
          playSound: true,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          sound: '$rawSoundName.mp3',
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
      '⏰ اقترب موعد $prayerName',
      'بقي 15 دقيقة على الأذان، استعد للوضوء والصلاة 🌿',
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
