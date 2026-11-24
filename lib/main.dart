import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/comfort_provider.dart';
import 'providers/reminder_preferences_provider.dart';
import 'widgets/in_app_reminder_host.dart';
import 'providers/settings_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/firdaws_user_provider.dart';
import 'providers/hoor_companion_provider.dart';
import 'providers/jannati_provider.dart';
import 'providers/family_challenge_provider.dart';
import 'providers/hasanat_provider.dart';
import 'models/events_missions_catalog.dart';
import 'models/prayer_alarm_preference.dart';
import 'models/prayer_model.dart';
import 'screens/adhan_alarm_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/prayer_setup_screen.dart';
import 'services/firdaws_native_service.dart';
import 'services/notification_service.dart';
import 'theme/comfort_theme.dart';
import 'theme/islamic_theme.dart';
import 'widgets/calm_page_transition.dart';

final GlobalKey<NavigatorState> firdawsNavigatorKey =
    GlobalKey<NavigatorState>();
final ValueNotifier<bool> firdawsBootReadyNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final comfortProvider = ComfortProvider();
  final reminderPreferencesProvider = ReminderPreferencesProvider();
  final settingsProvider = SettingsProvider();
  final audioPlayerProvider = AudioPlayerProvider();
  final firdawsUserProvider = FirdawsUserProvider();
  final jannatiProvider = JannatiProvider();
  final hoorCompanionProvider = HoorCompanionProvider();
  final familyChallengeProvider = FamilyChallengeProvider();
  final hasanatProvider = HasanatProvider();

  // تشغيل التطبيق فوراً دون انتظار عمليات الحساسات أو التنبيهات
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ComfortProvider>.value(value: comfortProvider),
        ChangeNotifierProvider<ReminderPreferencesProvider>.value(
            value: reminderPreferencesProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<AudioPlayerProvider>.value(
            value: audioPlayerProvider),
        ChangeNotifierProvider<FirdawsUserProvider>.value(
            value: firdawsUserProvider),
        ChangeNotifierProvider<JannatiProvider>.value(value: jannatiProvider),
        ChangeNotifierProvider<HoorCompanionProvider>.value(
            value: hoorCompanionProvider),
        ChangeNotifierProvider<FamilyChallengeProvider>.value(
            value: familyChallengeProvider),
        ChangeNotifierProvider<HasanatProvider>.value(value: hasanatProvider),
      ],
      child: const IslamicPrayerApp(),
    ),
  );

  // تأجيل التهيئة المتزامنة، ومنها تحميل قاعدة المناطق الزمنية، إلى ما بعد أول إطار.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(Future<void>.microtask(() async {
      try {
        await NotificationService().initialize();
        await FirdawsNativeService().initialize();
        await comfortProvider.init();
        await reminderPreferencesProvider.init();
        await settingsProvider.init();
        await firdawsUserProvider.init();
        await jannatiProvider.init();
        await hoorCompanionProvider.init();
        await familyChallengeProvider.init();
        await hasanatProvider.init();
        settingsProvider.syncAllNotifications();
        firdawsBootReadyNotifier.value = true;
      } catch (e) {
        debugPrint('Background init: $e');
      }
    }));
  });
}

class IslamicPrayerApp extends StatefulWidget {
  const IslamicPrayerApp({super.key});

  @override
  State<IslamicPrayerApp> createState() => _IslamicPrayerAppState();
}

class _IslamicPrayerAppState extends State<IslamicPrayerApp>
    with WidgetsBindingObserver {
  Timer? _prayerWatcherTimer;
  DateTime? _lastNotificationSyncAt;
  final Set<String> _triggeredAdhanKeys = {};
  bool _adhanOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final native = FirdawsNativeService();
    native.onOpenAdhanScreen = _openAdhanScreenIfNeeded;

    // مراقب حي لدخول أوقات الصلاة الخمس أثناء عمل التطبيق لتشغيل شاشة وصوت الأذان المتواصل فوراً
    _prayerWatcherTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkForegroundPrayerArrival(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNativeState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _prayerWatcherTimer?.cancel();
    final native = FirdawsNativeService();
    if (native.onOpenAdhanScreen == _openAdhanScreenIfNeeded) {
      native.onOpenAdhanScreen = null;
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncNativeState();
      _checkForegroundPrayerArrival();
      final now = DateTime.now();
      if (_lastNotificationSyncAt == null ||
          now.difference(_lastNotificationSyncAt!).inMinutes >= 15) {
        _lastNotificationSyncAt = now;
        try {
          Provider.of<SettingsProvider>(context, listen: false)
              .syncAllNotifications();
        } catch (_) {}
      }
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    try {
      Provider.of<ComfortProvider>(context, listen: false)
          .updateSystemReduceMotion(
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations,
      );
    } catch (_) {}
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (!mounted) return;
    try {
      Provider.of<SettingsProvider>(context, listen: false)
          .refreshDerivedBrightness();
    } catch (_) {}
  }

  void _checkForegroundPrayerArrival() {
    if (!mounted) return;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      settings.refreshDerivedBrightness();
      final now = DateTime.now();
      final prayerData = AdvancedPrayerTimes.calculate(
        latitude: settings.latitude,
        longitude: settings.longitude,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        offsets: settings.offsets,
      );

      final checks = <(String key, String arabic, DateTime time)>[
        ('fajr', 'صلاة الفجر', prayerData.prayerTimes.fajr),
        ('dhuhr', 'صلاة الظهر', prayerData.prayerTimes.dhuhr),
        ('asr', 'صلاة العصر', prayerData.prayerTimes.asr),
        ('maghrib', 'صلاة المغرب', prayerData.prayerTimes.maghrib),
        ('isha', 'صلاة العشاء', prayerData.prayerTimes.isha),
      ];

      for (final item in checks) {
        final t = item.$3;
        final alarmPreference = settings.prayerAlarmPreference(item.$1);
        if (alarmPreference.mode != PrayerAlarmMode.adhan) continue;
        final diffSec = now.difference(t).inSeconds;
        if (!now.isBefore(t) && diffSec >= 0 && diffSec <= 50) {
          final uniqueKey =
              '${item.$1}_${t.year}-${t.month}-${t.day}_${t.hour}:${t.minute}';
          if (!_triggeredAdhanKeys.contains(uniqueKey)) {
            _triggeredAdhanKeys.add(uniqueKey);
            if (_triggeredAdhanKeys.length > 30) {
              _triggeredAdhanKeys.remove(_triggeredAdhanKeys.first);
            }
            if (!_adhanOpen) {
              _openAdhanScreenIfNeeded(
                alarmPreference.voiceId ?? settings.adhanVoice,
                item.$2,
                alarmPreference.volumePercent,
              );
            }
            // إعادة جدولة صلوات الغد الخمس فوراً عند دخول وقت الصلاة
            settings.syncAllNotifications();
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Foreground prayer watcher error: $e');
    }
  }

  Future<void> _syncNativeState() async {
    if (!mounted) return;
    try {
      final native = FirdawsNativeService();
      final taps = await native.consumeNativeSalawatTaps();
      if (taps > 0 && mounted) {
        final userProv =
            Provider.of<FirdawsUserProvider>(context, listen: false);
        if (!userProv.isInitialized) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
        }
        if (mounted) {
          HasanatProvider? hasanat;
          try {
            hasanat = Provider.of<HasanatProvider>(context, listen: false);
          } catch (_) {}
          await userProv.recordDhikrByText(
            'اللهم صل وسلم على نبينا محمد',
            count: taps,
          );
          if (hasanat != null) {
            try {
              await hasanat.earnHasanat(
                taps * 2,
                reason: 'صلاة على النبي ($taps)',
                sourceTag: 'الذكر',
              );
              await hasanat.recordMetric(
                EventMissionMetric.tasbihCount,
                delta: taps,
              );
            } catch (_) {}
          }
        }
      }

      final launchExtras = await native.consumeNativeLaunchExtras();
      if (launchExtras != null && launchExtras['openAdhanAlarm'] == true) {
        _openAdhanScreenIfNeeded(
          launchExtras['voiceId']?.toString() ?? 'madinah',
          launchExtras['prayerName']?.toString() ?? 'موعد الصلاة',
          (launchExtras['volumePercent'] as num?)?.toInt() ?? 100,
        );
        return;
      }

      final ringing = await native.isAdhanRinging();
      if (ringing['isRinging'] == true) {
        _openAdhanScreenIfNeeded(
          ringing['voiceId']?.toString() ?? 'madinah',
          ringing['prayerName']?.toString() ?? 'موعد الصلاة',
          (ringing['volumePercent'] as num?)?.toInt() ?? 100,
        );
      }
    } catch (e) {
      debugPrint('Sync native state error: $e');
    }
  }

  void _openAdhanScreenIfNeeded(
    String voiceId,
    String prayerName,
    int volumePercent,
  ) {
    if (!mounted || _adhanOpen) return;
    final settings = context.read<SettingsProvider>();
    final nav = firdawsNavigatorKey.currentState;
    if (nav == null) return;
    _adhanOpen = true;
    nav
        .push(
      MaterialPageRoute(
        builder: (_) => AdhanAlarmScreen(
          voiceId: voiceId,
          prayerName: prayerName,
          volumePercent: volumePercent,
          useNativeService: FirdawsNativeService().isAndroid,
          skinId: settings.adhanSkinId,
          onSkinSelected: settings.setAdhanSkin,
        ),
      ),
    )
        .whenComplete(() {
      _adhanOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comfort = context.watch<ComfortProvider>();
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isNight = settings.isNightEffective;
        return MaterialApp(
          navigatorKey: firdawsNavigatorKey,
          title: 'الفردوس',
          debugShowCheckedModeBanner: false,
          theme: ComfortTheme.apply(
            IslamicTheme.getTheme(
              settings.selectedTheme,
              isNight: isNight,
              fontFamily: settings.selectedFont,
            ),
            highContrast: comfort.highContrast,
          ).copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CalmRouteTransitionsBuilder(),
                TargetPlatform.iOS: CalmRouteTransitionsBuilder(),
                TargetPlatform.linux: CalmRouteTransitionsBuilder(),
                TargetPlatform.macOS: CalmRouteTransitionsBuilder(),
                TargetPlatform.windows: CalmRouteTransitionsBuilder(),
                TargetPlatform.fuchsia: CalmRouteTransitionsBuilder(),
              },
            ),
          ),
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final inheritedMedia = MediaQuery.of(context);
            final comfortMedia = inheritedMedia.copyWith(
              textScaler: ComfortTextScaler(
                inheritedMedia.textScaler,
                comfort.additionalTextScale,
              ),
              disableAnimations:
                  inheritedMedia.disableAnimations || comfort.reduceMotion,
              // Keep screen-reader navigation intact; it is separate from reduced motion.
              accessibleNavigation: inheritedMedia.accessibleNavigation,
            );
            return MediaQuery(
              data: comfortMedia,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Consumer<SettingsProvider>(
            builder: (context, firstRunSettings, _) {
              if (!firstRunSettings.isInitialized) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (firstRunSettings.shouldShowFirstRunSetup) {
                return const PrayerSetupScreen();
              }
              return InAppReminderHost(
                onNavigate: (index) => FirdawsNavBridge.jumpTo(index),
                child: const MainNavigationScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
