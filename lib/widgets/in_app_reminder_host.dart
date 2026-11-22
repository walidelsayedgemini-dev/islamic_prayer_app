import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prayer_model.dart';
import '../providers/reminder_preferences_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/reminder_schedule.dart';

/// Wrap the navigation root once. In-app reminders run only while the Flutter
/// app is resumed; the host never registers a background timer or web worker.
class InAppReminderHost extends StatefulWidget {
  const InAppReminderHost({
    super.key,
    required this.child,
    required this.onNavigate,
  });

  final Widget child;
  final void Function(int pageIndex) onNavigate;

  @override
  State<InAppReminderHost> createState() => _InAppReminderHostState();
}

class _InAppReminderHostState extends State<InAppReminderHost>
    with WidgetsBindingObserver {
  static const Duration _pollInterval = Duration(seconds: 15);
  static const Duration _bannerDuration = Duration(seconds: 14);

  SettingsProvider? _settings;
  ReminderPreferencesProvider? _preferences;
  Timer? _foregroundTimer;
  Timer? _bannerTimer;
  DateTime _lastSalawatAt = DateTime.now();
  DateTime _foregroundSince = DateTime.now();
  String? _lastCustomMinuteKey;
  final Set<String> _handledPrayerOccurrences = <String>{};
  _ReminderMessage? _message;
  bool _isResumed = false;
  bool _nativeScheduledForBackground = false;
  bool? _observedSalawatEnabled;
  int? _observedInterval;
  String? _observedConfiguration;
  int _nativeScheduleGeneration = 0;
  Future<void> _nativeScheduleQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isResumed = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _foregroundSince = DateTime.now();
    _lastSalawatAt = _foregroundSince;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextSettings = context.read<SettingsProvider>();
    final nextPreferences = context.read<ReminderPreferencesProvider>();
    if (!identical(_settings, nextSettings)) {
      _settings?.removeListener(_onPreferencesChanged);
      _settings = nextSettings..addListener(_onPreferencesChanged);
    }
    if (!identical(_preferences, nextPreferences)) {
      _preferences?.removeListener(_onPreferencesChanged);
      _preferences = nextPreferences..addListener(_onPreferencesChanged);
    }
    _onPreferencesChanged();
  }

  String _configurationSignature() {
    final settings = _settings;
    final preferences = _preferences;
    if (settings == null || preferences == null) return '';
    return <Object?>[
      settings.salawatOverlayEnabled,
      settings.salawatIntervalMinutes,
      settings.salawatCustomTimes.join(','),
      preferences.prayerRemindersEnabled,
      preferences.quietHoursEnabled,
      preferences.quietStartHour,
      preferences.quietEndHour,
    ].join('|');
  }

  void _onPreferencesChanged() {
    if (!mounted || _settings == null || _preferences == null) return;
    final signature = _configurationSignature();
    if (signature == _observedConfiguration) return;
    _observedConfiguration = signature;

    final enabled = _settings!.salawatOverlayEnabled;
    final interval = ReminderSchedule.normalizedInterval(
      _settings!.salawatIntervalMinutes,
    );
    if (_observedSalawatEnabled != enabled || _observedInterval != interval) {
      _lastSalawatAt = DateTime.now();
      _observedSalawatEnabled = enabled;
      _observedInterval = interval;
    }
    _updateForegroundTimer();
    if (_isResumed) {
      unawaited(_cancelNativeSchedule());
    } else {
      unawaited(_scheduleNativeReminders());
    }
  }

  void _updateForegroundTimer() {
    final needsTimer = _isResumed &&
        (_settings?.salawatOverlayEnabled == true ||
            _preferences?.prayerRemindersEnabled == true);
    if (needsTimer && _foregroundTimer == null) {
      _foregroundTimer =
          Timer.periodic(_pollInterval, (_) => _checkReminders());
      _checkReminders();
    } else if (!needsTimer) {
      _foregroundTimer?.cancel();
      _foregroundTimer = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _isResumed) return;
    _isResumed = resumed;
    if (resumed) {
      // A pause is not a reminder delivery. Start fresh and avoid catch-up.
      _foregroundSince = DateTime.now();
      _lastSalawatAt = _foregroundSince;
      _nativeScheduledForBackground = false;
      _updateForegroundTimer();
      unawaited(_cancelNativeSchedule());
    } else {
      _foregroundTimer?.cancel();
      _foregroundTimer = null;
      _bannerTimer?.cancel();
      if ((state == AppLifecycleState.hidden ||
              state == AppLifecycleState.paused) &&
          !_nativeScheduledForBackground) {
        _nativeScheduledForBackground = true;
        unawaited(_scheduleNativeReminders());
      }
      if (mounted && _message != null) setState(() => _message = null);
    }
  }

  void _checkReminders() {
    if (!mounted || !_isResumed) return;
    final settings = _settings;
    final preferences = _preferences;
    if (settings == null || preferences == null) return;
    final now = DateTime.now();
    final quiet = ReminderSchedule.isQuietTime(
      now,
      enabled: preferences.quietHoursEnabled,
      startHour: preferences.quietStartHour,
      endHour: preferences.quietEndHour,
    );

    // Prayer reminders take priority if events coincide. Each occurrence is
    // marked handled even in quiet hours, so no delayed catch-up can appear.
    if (preferences.prayerRemindersEnabled) {
      try {
        final times = AdvancedPrayerTimes.calculate(
          latitude: settings.latitude,
          longitude: settings.longitude,
          method: settings.calculationMethod,
          madhab: settings.madhab,
          offsets: settings.offsets,
        ).prayerTimes;
        final prayers = <(String, String, DateTime)>[
          ('fajr', 'صلاة الفجر', times.fajr),
          ('dhuhr', 'صلاة الظهر', times.dhuhr),
          ('asr', 'صلاة العصر', times.asr),
          ('maghrib', 'صلاة المغرب', times.maghrib),
          ('isha', 'صلاة العشاء', times.isha),
        ];
        for (final (key, name, time) in prayers) {
          if (!ReminderSchedule.prayerOccurrenceIsDue(
            now: now,
            prayerTime: time,
            foregroundSince: _foregroundSince,
          )) {
            continue;
          }
          final occurrence = ReminderSchedule.prayerOccurrenceKey(key, time);
          if (!_handledPrayerOccurrences.add(occurrence)) continue;
          if (_handledPrayerOccurrences.length > 50) {
            _handledPrayerOccurrences.remove(_handledPrayerOccurrences.first);
          }
          if (!quiet) {
            _showReminder(
              _ReminderMessage(
                title: 'حان وقت $name',
                body: 'يمكنك الانتقال إلى صفحة الصلاة.',
                actionLabel: 'اذهب إلى الصلاة',
                targetPage: 0,
              ),
            );
          }
          if (settings.salawatOverlayEnabled && _isSalawatDue(now, settings)) {
            _lastSalawatAt = now;
          }
          return;
        }
      } catch (error) {
        debugPrint('Foreground prayer reminder error: $error');
      }
    }

    if (!settings.salawatOverlayEnabled) return;
    final intervalDue = _isSalawatDue(now, settings);
    final minute = _minuteKey(now);
    final hhMm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final customDue = settings.salawatCustomTimes.contains(hhMm) &&
        _lastCustomMinuteKey != minute;
    if (!intervalDue && !customDue) return;
    if (customDue) _lastCustomMinuteKey = minute;
    // Quiet hours consume a due reminder; they do not queue one for later.
    _lastSalawatAt = now;
    if (quiet) return;
    _showReminder(
      const _ReminderMessage(
        title: 'تذكير بالصلاة على النبي ﷺ',
        body: 'اللهم صلِّ وسلم على نبينا محمد',
        actionLabel: 'افتح السبحة',
        targetPage: 4,
      ),
    );
  }

  bool _isSalawatDue(DateTime now, SettingsProvider settings) {
    final interval =
        ReminderSchedule.normalizedInterval(settings.salawatIntervalMinutes);
    return interval > 0 && now.difference(_lastSalawatAt).inMinutes >= interval;
  }

  String _minuteKey(DateTime time) =>
      '${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}';

  void _showReminder(_ReminderMessage message) {
    if (!mounted) return;
    _bannerTimer?.cancel();
    setState(() => _message = message);
    _bannerTimer = Timer(_bannerDuration, () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _dismissReminder() {
    _bannerTimer?.cancel();
    if (mounted) setState(() => _message = null);
  }

  Future<void> _cancelNativeSchedule() {
    final generation = ++_nativeScheduleGeneration;
    if (kIsWeb) {
      _preferences?.reportNativeScheduleStatus(
        'في الويب: التذكير داخل الصفحة المفتوحة فقط؛ لا إشعارات بعد إغلاقها.',
      );
      return Future<void>.value();
    }
    return _enqueueNativeOperation(generation, () async {
      final result =
          await NotificationService().cancelSalawatReminderNotifications();
      if (!mounted || generation != _nativeScheduleGeneration) return;
      final salawatEnabled = _settings?.salawatOverlayEnabled == true;
      _preferences?.reportNativeScheduleStatus(
        result.status == ReminderNotificationScheduleStatus.cancelled
            ? salawatEnabled
                ? 'أثناء فتح التطبيق يظهر التذكير داخله؛ إشعار الجهاز يُجدول عند انتقال التطبيق للخلفية.'
                : 'التذكير متوقف؛ أُلغيت إشعاراته المحلية المجدولة.'
            : 'تعذر تأكيد إلغاء إشعارات التذكير.',
      );
    });
  }

  Future<void> _scheduleNativeReminders() {
    final generation = ++_nativeScheduleGeneration;
    final settings = _settings;
    final preferences = _preferences;
    if (kIsWeb) {
      preferences?.reportNativeScheduleStatus(
        'في الويب: التذكير داخل الصفحة المفتوحة فقط؛ لا إشعارات بعد إغلاقها.',
      );
      return Future<void>.value();
    }
    return _enqueueNativeOperation(generation, () async {
      if (settings == null ||
          preferences == null ||
          !settings.salawatOverlayEnabled) {
        final result =
            await NotificationService().cancelSalawatReminderNotifications();
        if (!mounted || generation != _nativeScheduleGeneration) return;
        preferences?.reportNativeScheduleStatus(
          result.status == ReminderNotificationScheduleStatus.cancelled
              ? 'التذكير متوقف؛ أُلغيت إشعاراته المحلية المجدولة.'
              : 'تعذر تأكيد إلغاء إشعارات التذكير.',
        );
        return;
      }

      final now = DateTime.now();
      final occurrences = ReminderSchedule.nativeSalawatOccurrences(
        after: _lastSalawatAt,
        now: now,
        intervalMinutes: settings.salawatIntervalMinutes,
        quietHoursEnabled: preferences.quietHoursEnabled,
        quietStartHour: preferences.quietStartHour,
        quietEndHour: preferences.quietEndHour,
        customTimes: settings.salawatCustomTimes,
      );
      final result = await NotificationService()
          .scheduleSalawatReminders(occurrences: occurrences);
      if (!mounted || generation != _nativeScheduleGeneration) return;
      preferences.reportNativeScheduleStatus(_nativeStatusMessage(result));
    });
  }

  Future<void> _enqueueNativeOperation(
    int generation,
    Future<void> Function() operation,
  ) {
    final task = _nativeScheduleQueue.catchError((Object _) {}).then((_) async {
      if (!mounted || generation != _nativeScheduleGeneration) return;
      await operation();
    });
    _nativeScheduleQueue = task.catchError((Object error) {
      debugPrint('Native reminder queue error: $error');
    });
    return _nativeScheduleQueue;
  }

  String _nativeStatusMessage(ReminderNotificationScheduleResult result) {
    switch (result.status) {
      case ReminderNotificationScheduleStatus.scheduled:
        if (result.count == 0) {
          return 'لم تتوفر سعة كافية لجدولة إشعارات التذكير؛ تُحدّث الجدولة عند عودة التطبيق إلى الخلفية.';
        }
        if (result.limited) {
          return 'جُدول ${result.count} إشعاراً فقط؛ قد تكون التغطية أقصر من سبعة أيام بسبب حد سعة النظام. تُحدّث الجدولة عند عودة التطبيق إلى الخلفية، ولا يمكن ضمان التسليم.';
        }
        return 'جُدول ${result.count} إشعاراً محلياً للأيام السبعة القادمة؛ قد يقيّد النظام التسليم.';
      case ReminderNotificationScheduleStatus.permissionDenied:
        return 'لم تُجدول إشعارات الجهاز لأن إذن الإشعارات غير متاح.';
      case ReminderNotificationScheduleStatus.unsupportedWeb:
        return 'في الويب: التذكير داخل الصفحة المفتوحة فقط؛ لا إشعارات بعد إغلاقها.';
      case ReminderNotificationScheduleStatus.unsupportedPlatform:
        return 'الجدولة المحلية غير مدعومة على هذا الجهاز؛ سيعمل التذكير داخل التطبيق فقط.';
      case ReminderNotificationScheduleStatus.notInitialized:
        return 'لم تكتمل تهيئة الإشعارات؛ لم تُؤكد الجدولة.';
      case ReminderNotificationScheduleStatus.failed:
        return 'تعذرت جدولة إشعارات الجهاز؛ لم يُعرض نجاح غير مؤكد.';
      case ReminderNotificationScheduleStatus.cancelled:
        return 'لا توجد إشعارات محلية مجدولة حالياً.';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foregroundTimer?.cancel();
    _bannerTimer?.cancel();
    _settings?.removeListener(_onPreferencesChanged);
    _preferences?.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (_message case final message?)
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: SafeArea(
              child: Semantics(
                container: true,
                liveRegion: true,
                label: '${message.title}. ${message.body}',
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Material(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        message.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        message.body,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'إغلاق التذكير',
                                  onPressed: _dismissReminder,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton.icon(
                                onPressed: () {
                                  final target = message.targetPage;
                                  _dismissReminder();
                                  widget.onNavigate(target);
                                },
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: Text(message.actionLabel),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReminderMessage {
  const _ReminderMessage({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.targetPage,
  });

  final String title;
  final String body;
  final String actionLabel;
  final int targetPage;
}
