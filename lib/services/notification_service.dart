import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/islamic_audio_data.dart';
import '../models/prayer_model.dart';
import 'firdaws_native_service.dart';

enum ReminderNotificationAvailability {
  available,
  permissionDenied,
  unsupportedWeb,
  unsupportedPlatform,
  unknown,
}

enum ReminderNotificationScheduleStatus {
  scheduled,
  cancelled,
  permissionDenied,
  unsupportedWeb,
  unsupportedPlatform,
  notInitialized,
  failed,
}

class ReminderNotificationScheduleResult {
  const ReminderNotificationScheduleResult(
    this.status, {
    this.count = 0,
    this.limited = false,
  });

  final ReminderNotificationScheduleStatus status;
  final int count;

  /// True when the request set or platform capacity limited the horizon.
  final bool limited;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _tzConfigured = false;
  static const String salawatNotificationPayload = 'firdaws:salawat';
  static const int prayerNotificationIdStart = 1;
  static const int prayerNotificationIdCapacity = 10;
  static const int preAdhanNotificationIdOffset = 100;

  /// Android uses AlarmManager and the native playback service for adhan audio.
  static bool shouldScheduleFlutterAdhanFallback({
    required bool isWeb,
    required TargetPlatform platform,
  }) =>
      !isWeb && platform != TargetPlatform.android;

  void Function(int pageIndex)? _navigationHandler;
  int? _pendingNavigationPage;

  void setNavigationHandler(void Function(int pageIndex)? handler) {
    _navigationHandler = handler;
    final pending = _pendingNavigationPage;
    if (handler != null && pending != null) {
      _pendingNavigationPage = null;
      handler(pending);
    }
  }

  void handleNotificationResponse(NotificationResponse response) {
    if (response.payload != salawatNotificationPayload) return;
    final handler = _navigationHandler;
    if (handler == null) {
      _pendingNavigationPage = 4;
    } else {
      handler(4);
    }
  }

  /// Reserved only for the optional salawat reminder feature. Prayer alarms
  /// continue to use IDs 1..10 and pre-adhan IDs 101..110.
  static const int reminderNotificationIdBase = 3000;
  static const int reminderNotificationIdCapacity = 400;
  static const int iosPendingNotificationLimit = 64;
  static const int iosSalawatNotificationLimit = 40;

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
      3: [
        'Asia/Riyadh',
        'Asia/Kuwait',
        'Asia/Qatar',
        'Asia/Baghdad',
        'Europe/Istanbul'
      ],
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

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: handleNotificationResponse,
      );

      final launchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      final launchResponse = launchDetails?.notificationResponse;
      if ((launchDetails?.didNotificationLaunchApp ?? false) &&
          launchResponse != null) {
        handleNotificationResponse(launchResponse);
      }

      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
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
          // Do not erase unrelated reminders (including this feature's IDs).
          for (final id in <int>[
            ...List<int>.generate(
              prayerNotificationIdCapacity,
              (i) => i + prayerNotificationIdStart,
            ),
            ...List<int>.generate(
              prayerNotificationIdCapacity,
              (i) =>
                  i + prayerNotificationIdStart + preAdhanNotificationIdOffset,
            ),
          ]) {
            await flutterLocalNotificationsPlugin.cancel(id);
          }
        } catch (_) {}
      }

      final resolvedVoice =
          IslamicAudioLibrary.getAdhanVoiceById(voiceResource);
      final now = DateTime.now();
      final nativeAlarms = <Map<String, dynamic>>[];

      Future<void> addPrayerAlarm(
          int id, String prayerName, DateTime prayerTime) async {
        if (!prayerTime.isAfter(now)) return;
        nativeAlarms.add({
          'triggerAtMillis': prayerTime.millisecondsSinceEpoch,
          'voiceId': resolvedVoice.id,
          'prayerName': prayerName,
        });

        if (shouldScheduleFlutterAdhanFallback(
          isWeb: kIsWeb,
          platform: defaultTargetPlatform,
        )) {
          await _scheduleSingleAdhanNotificationFallback(
            id: id,
            title: prayerName,
            scheduledTime: prayerTime,
            rawSoundName: resolvedVoice.rawResourceName,
          );
        }

        if (preAdhanReminder) {
          final reminderTime = prayerTime.subtract(const Duration(minutes: 15));
          if (reminderTime.isAfter(now)) {
            await _schedulePreAdhanReminder(
              id: id + preAdhanNotificationIdOffset,
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
      if (latitude != null &&
          longitude != null &&
          method != null &&
          madhab != null) {
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
    if (!shouldScheduleFlutterAdhanFallback(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    )) {
      return;
    }
    final channelId = 'adhan_v4_$rawSoundName';
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '🕌 $title',
        'حيّ على الصلاة.. حان الآن موعد $title',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'تنبيهات الأذان ($rawSoundName)',
            channelDescription:
                'بث الأذان بصوت المؤذن المختار في الوقت المحدد بدقة',
            importance: Importance.max,
            priority: Priority.max,
            sound: RawResourceAndroidNotificationSound(rawSoundName),
            playSound: true,
            onlyAlertOnce: true,
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
              channelId,
              'تنبيهات الأذان ($rawSoundName)',
              channelDescription:
                  'بث الأذان بصوت المؤذن المختار في الوقت المحدد بدقة',
              importance: Importance.max,
              priority: Priority.max,
              sound: RawResourceAndroidNotificationSound(rawSoundName),
              playSound: true,
              onlyAlertOnce: true,
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
            'pre_adhan_v4',
            'تنبيه صوتي قبل الصلاة (اقتربت الصلاة)',
            channelDescription:
                'تنبيه صوتي مسموع قبل الأذان بـ ١٥ دقيقة للاستعداد للصلاة',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('pre_adhan_alert'),
            playSound: true,
            enableVibration: true,
            onlyAlertOnce: true,
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

  /// Checks device notification access without requesting or changing any
  /// permission. Web is intentionally reported as foreground-only.
  Future<ReminderNotificationAvailability>
      checkReminderNotificationAvailability() async {
    if (kIsWeb) return ReminderNotificationAvailability.unsupportedWeb;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await android?.areNotificationsEnabled();
        if (enabled == true) return ReminderNotificationAvailability.available;
        if (enabled == false) {
          return ReminderNotificationAvailability.permissionDenied;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final permissions = await ios?.checkPermissions();
        if (permissions?.isEnabled == true) {
          return ReminderNotificationAvailability.available;
        }
        if (permissions != null) {
          return ReminderNotificationAvailability.permissionDenied;
        }
      } else {
        return ReminderNotificationAvailability.unsupportedPlatform;
      }
    } catch (error) {
      debugPrint('Reminder permission check failed: $error');
    }
    return ReminderNotificationAvailability.unknown;
  }

  /// Cancels only the salawat reminder namespace (3000..3399).
  Future<ReminderNotificationScheduleResult>
      cancelSalawatReminderNotifications() async {
    if (kIsWeb) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.unsupportedWeb,
      );
    }
    try {
      final pending =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      for (final request in pending) {
        final id = request.id;
        if (id >= reminderNotificationIdBase &&
            id < reminderNotificationIdBase + reminderNotificationIdCapacity) {
          await flutterLocalNotificationsPlugin.cancel(id);
        }
      }
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.cancelled,
      );
    } catch (error) {
      debugPrint('Reminder cancellation failed: $error');
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.failed,
      );
    }
  }

  /// Schedules a bounded set of local reminders using only IDs 3000..3399.
  /// Does not request permissions and never claims success when scheduling
  /// fails. Callers should refresh the schedule when the app next resumes.
  Future<ReminderNotificationScheduleResult> scheduleSalawatReminders({
    required List<DateTime> occurrences,
  }) async {
    if (kIsWeb) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.unsupportedWeb,
      );
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.unsupportedPlatform,
      );
    }

    final cancellation = await cancelSalawatReminderNotifications();
    if (cancellation.status == ReminderNotificationScheduleStatus.failed) {
      return cancellation;
    }
    if (occurrences.isEmpty) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.cancelled,
      );
    }
    if (!_isInitialized) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.notInitialized,
      );
    }
    final availability = await checkReminderNotificationAvailability();
    if (availability == ReminderNotificationAvailability.permissionDenied) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.permissionDenied,
      );
    }
    if (availability != ReminderNotificationAvailability.available) {
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.failed,
      );
    }

    configureLocalTimezone();
    final upcoming = occurrences
        .where((time) => time.isAfter(DateTime.now()))
        .toList(growable: false);
    var platformCapacity = reminderNotificationIdCapacity;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        // Leave capacity for prayer alarms and other app notifications. The
        // salawat feature itself never consumes more than 40 of iOS's 64 slots.
        final pending =
            await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        platformCapacity = (iosPendingNotificationLimit - pending.length)
            .clamp(0, iosSalawatNotificationLimit);
      } catch (error) {
        debugPrint(
            'Could not inspect iOS pending notification capacity: $error');
        return const ReminderNotificationScheduleResult(
          ReminderNotificationScheduleStatus.failed,
        );
      }
    }
    final bounded = upcoming.take(platformCapacity).toList(growable: false);
    final limited = upcoming.length > bounded.length ||
        occurrences.length >= reminderNotificationIdCapacity;
    if (bounded.isEmpty) {
      if (upcoming.isNotEmpty && limited) {
        return const ReminderNotificationScheduleResult(
          ReminderNotificationScheduleStatus.scheduled,
          limited: true,
        );
      }
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.cancelled,
      );
    }
    try {
      for (var index = 0; index < bounded.length; index++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          reminderNotificationIdBase + index,
          'تذكير بالصلاة على النبي ﷺ',
          'اللهم صلِّ وسلم على نبينا محمد',
          tz.TZDateTime.from(bounded[index], tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'firdaws_optional_salawat',
              'تذكيرات اختيارية',
              channelDescription: 'تذكير اختياري بالصلاة على النبي ﷺ',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              playSound: false,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: false,
              presentSound: false,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: salawatNotificationPayload,
        );
      }
      return ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.scheduled,
        count: bounded.length,
        limited: limited,
      );
    } catch (error) {
      debugPrint('Optional salawat scheduling failed: $error');
      await cancelSalawatReminderNotifications();
      return const ReminderNotificationScheduleResult(
        ReminderNotificationScheduleStatus.failed,
      );
    }
  }
}
