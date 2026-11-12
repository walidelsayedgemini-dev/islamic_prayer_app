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
  bool _tzConfigured = false;

  /// ضبط المنطقة الزمنية المحلية لحزمة timezone بدقة حتى لا تُجدول التنبيهات بتوقيت UTC الخاطئ
  void configureLocalTimezone({int? overrideOffsetMillis}) {
    if (!_tzConfigured) {
      tz.initializeTimeZones();
      _tzConfigured = true;
    }

    final targetMillis =
        overrideOffsetMillis ?? DateTime.now().timeZoneOffset.inMilliseconds;
    final sysName = DateTime.now().timeZoneName.toLowerCase();

    // أولوية لبعض المناطق العربية والإسلامية الشهيرة حسب الإزاحة
    const preferredByHours = <int, List<String>>{
      2: ['Africa/Cairo', 'Asia/Jerusalem', 'Asia/Amman', 'Asia/Beirut'],
      3: ['Asia/Riyadh', 'Asia/Kuwait', 'Asia/Qatar', 'Asia/Baghdad', 'Europe/Istanbul'],
      4: ['Asia/Dubai', 'Asia/Muscat'],
      1: ['Africa/Casablanca', 'Africa/Tunis', 'Africa/Algiers'],
      0: ['Europe/London', 'UTC'],
    };

    final hours = (targetMillis / 3600000).round();
    final preferred = preferredByHours[hours];
    if (preferred != null) {
      for (final name in preferred) {
        final loc = tz.timeZoneDatabase.locations[name];
        if (loc != null && loc.currentTimeZone.offset == targetMillis) {
          tz.setLocalLocation(loc);
          return;
        }
      }
    }

    // مطابقة عامة على أي منطقة زمنية تطابق الإزاحة والاسم
    tz.Location? firstMatch;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == targetMillis) {
        firstMatch ??= loc;
        if (loc.name.toLowerCase().contains(sysName) ||
            loc.currentTimeZone.abbreviation.toLowerCase() == sysName) {
          tz.setLocalLocation(loc);
          return;
        }
      }
    }
    if (firstMatch != null) {
      tz.setLocalLocation(firstMatch);
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      configureLocalTimezone();
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

  /// جدولة صلوات اليوم والغد بالكامل مع منبه الأذان المتواصل بصوت المؤذن المختار
  Future<void> scheduleDailyPrayers({
    required AdvancedPrayerTimes prayers,
    required String voiceResource,
    bool preAdhanReminder = true,
    double? latitude,
    double? longitude,
    dynamic method,
    dynamic madhab,
    Map<String, int>? offsets,
  }) async {
    try {
      configureLocalTimezone();
      if (!kIsWeb) {
        try {
          await flutterLocalNotificationsPlugin.cancelAll();
        } catch (_) {}
      }

      final resolvedVoice = IslamicAudioLibrary.getAdhanVoiceById(voiceResource);
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

      final todayTimes = <int, ({String name, DateTime time})>{
        1: (name: 'صلاة الفجر', time: prayers.prayerTimes.fajr),
        2: (name: 'صلاة الظهر', time: prayers.prayerTimes.dhuhr),
        3: (name: 'صلاة العصر', time: prayers.prayerTimes.asr),
        4: (name: 'صلاة المغرب', time: prayers.prayerTimes.maghrib),
        5: (name: 'صلاة العشاء', time: prayers.prayerTimes.isha),
      };

      for (final entry in todayTimes.entries) {
        await addPrayerAlarm(entry.key, entry.value.name, entry.value.time);
      }

      // جدولة صلوات الغد الخمس كاملة لضمان استمرار الأذان حتى لو لم يفتح المستخدم التطبيق غداً
      if (latitude != null && longitude != null && method != null && madhab != null) {
        final tomorrowPrayers = AdvancedPrayerTimes.calculateForDate(
          date: now.add(const Duration(days: 1)),
          latitude: latitude,
          longitude: longitude,
          method: method,
          madhab: madhab,
          offsets: offsets,
        );
        final tmrTimes = <int, ({String name, DateTime time})>{
          6: (name: 'صلاة الفجر', time: tomorrowPrayers.prayerTimes.fajr),
          7: (name: 'صلاة الظهر', time: tomorrowPrayers.prayerTimes.dhuhr),
          8: (name: 'صلاة العصر', time: tomorrowPrayers.prayerTimes.asr),
          9: (name: 'صلاة المغرب', time: tomorrowPrayers.prayerTimes.maghrib),
          10: (name: 'صلاة العشاء', time: tomorrowPrayers.prayerTimes.isha),
        };
        for (final entry in tmrTimes.entries) {
          await addPrayerAlarm(entry.key, entry.value.name, entry.value.time);
        }
      } else if (!prayers.prayerTimes.fajr.isAfter(now) &&
          prayers.tomorrowFajr.isAfter(now)) {
        await addPrayerAlarm(6, 'صلاة الفجر', prayers.tomorrowFajr);
      }

      // جدولة المنبه الحقيقي المتواصل على مستوى النظام (AdhanAlarmScheduler -> AlarmClock)
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
    if (kIsWeb) return;
    try {
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
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: DarwinNotificationDetails(
            sound: '$rawSoundName.mp3',
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      try {
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
      } catch (e) {
        debugPrint('Fallback adhan schedule failed: $e');
      }
    }
  }

  Future<void> _schedulePreAdhanReminder({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) return;
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '⏰ اقتربت $prayerName — استعد الآن',
        'اقتربت الصلاة! بقي ١٥ دقيقة على الأذان، حيّ على الوضوء والاستعداد 🌿',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pre_adhan_voice_v2',
            'تنبيه صوتي قبل الصلاة (اقتربت الصلاة)',
            channelDescription: 'تنبيه صوتي مسموع قبل الأذان بـ ١٥ دقيقة للاستعداد للصلاة',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('pre_adhan_alert'),
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'pre_adhan_alert.wav',
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Pre-adhan schedule error: $e');
    }
  }
}
