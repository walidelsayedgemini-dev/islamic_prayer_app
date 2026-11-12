import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/settings_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/firdaws_user_provider.dart';
import 'providers/jannati_provider.dart';
import 'providers/family_challenge_provider.dart';
import 'providers/hasanat_provider.dart';
import 'models/events_missions_catalog.dart';
import 'models/prayer_model.dart';
import 'screens/adhan_alarm_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/firdaws_native_service.dart';
import 'services/notification_service.dart';
import 'theme/islamic_theme.dart';
import 'widgets/touch_effects_overlay.dart';
import 'widgets/user_profile_editor_sheet.dart';

final GlobalKey<NavigatorState> firdawsNavigatorKey =
    GlobalKey<NavigatorState>();
final ValueNotifier<bool> firdawsBootReadyNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  final audioPlayerProvider = AudioPlayerProvider();
  final firdawsUserProvider = FirdawsUserProvider();
  final jannatiProvider = JannatiProvider();
  final familyChallengeProvider = FamilyChallengeProvider();
  final hasanatProvider = HasanatProvider();

  // تشغيل التطبيق فوراً دون انتظار عمليات الحساسات أو التنبيهات
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<AudioPlayerProvider>.value(
            value: audioPlayerProvider),
        ChangeNotifierProvider<FirdawsUserProvider>.value(
            value: firdawsUserProvider),
        ChangeNotifierProvider<JannatiProvider>.value(value: jannatiProvider),
        ChangeNotifierProvider<FamilyChallengeProvider>.value(
            value: familyChallengeProvider),
        ChangeNotifierProvider<HasanatProvider>.value(value: hasanatProvider),
      ],
      child: const IslamicPrayerApp(),
    ),
  );

  // تحميل الإعدادات والخدمات بالترتيب الآمن في الخلفية بعد رسم الشاشة الأولى
  Future.microtask(() async {
    try {
      await NotificationService().initialize();
      await FirdawsNativeService().initialize();
      await settingsProvider.init();
      await firdawsUserProvider.init();
      await jannatiProvider.init();
      await familyChallengeProvider.init();
      await hasanatProvider.init();
      settingsProvider.syncAllNotifications();
      firdawsBootReadyNotifier.value = true;
    } catch (e) {
      debugPrint('Background init: $e');
    }
  });
}

class IslamicPrayerApp extends StatefulWidget {
  const IslamicPrayerApp({super.key});

  @override
  State<IslamicPrayerApp> createState() => _IslamicPrayerAppState();
}

class _IslamicPrayerAppState extends State<IslamicPrayerApp>
    with WidgetsBindingObserver {
  Timer? _salawatTimer;
  Timer? _prayerWatcherTimer;
  Timer? _salawatAutoHideTimer;
  DateTime _lastSalawatShownAt = DateTime.now();
  DateTime? _lastNotificationSyncAt;
  String? _lastCustomMinuteKey;
  final Set<String> _triggeredAdhanKeys = {};
  bool _showInAppSalawat = false;
  int _salawatStyleSeed = 0;
  bool _adhanOpen = false;
  bool _checkedFirstRunPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final native = FirdawsNativeService();
    native.onOpenAdhanScreen = _openAdhanScreenIfNeeded;
    native.onShowInAppSalawatPreview = _showFloatingSalawatNow;

    _salawatTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _checkSalawatSchedule(),
    );

    // مراقب حي لدخول أوقات الصلاة الخمس أثناء عمل التطبيق لتشغيل شاشة وصوت الأذان المتواصل فوراً
    _prayerWatcherTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkForegroundPrayerArrival(),
    );

    firdawsBootReadyNotifier.addListener(_onBootReady);
    if (firdawsBootReadyNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onBootReady());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNativeState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    firdawsBootReadyNotifier.removeListener(_onBootReady);
    _salawatTimer?.cancel();
    _prayerWatcherTimer?.cancel();
    _salawatAutoHideTimer?.cancel();
    final native = FirdawsNativeService();
    if (native.onOpenAdhanScreen == _openAdhanScreenIfNeeded) {
      native.onOpenAdhanScreen = null;
    }
    if (native.onShowInAppSalawatPreview == _showFloatingSalawatNow) {
      native.onShowInAppSalawatPreview = null;
    }
    super.dispose();
  }

  Future<void> _onBootReady() async {
    if (!mounted || _checkedFirstRunPrompt) return;
    _checkedFirstRunPrompt = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyPrompted =
          prefs.getBool('firdaws_first_run_profile_prompted_v1') ?? false;
      if (alreadyPrompted || !mounted) return;

      final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
      if (userProv.profile.hasCustomName) {
        await prefs.setBool('firdaws_first_run_profile_prompted_v1', true);
        return;
      }

      await prefs.setBool('firdaws_first_run_profile_prompted_v1', true);
      final navCtx = firdawsNavigatorKey.currentContext;
      if (navCtx != null && navCtx.mounted && !_adhanOpen) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (navCtx.mounted) {
          UserProfileEditorSheet.show(navCtx);
        }
      }
    } catch (e) {
      debugPrint('First-run profile check: $e');
    }
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

  void _checkForegroundPrayerArrival() {
    if (!mounted) return;
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
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
              _openAdhanScreenIfNeeded(settings.adhanVoice, item.$2);
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
        );
        return;
      }

      final ringing = await native.isAdhanRinging();
      if (ringing['isRinging'] == true) {
        _openAdhanScreenIfNeeded(
          ringing['voiceId']?.toString() ?? 'madinah',
          ringing['prayerName']?.toString() ?? 'موعد الصلاة',
        );
      }
    } catch (e) {
      debugPrint('Sync native state error: $e');
    }
  }

  void _openAdhanScreenIfNeeded(String voiceId, String prayerName) {
    if (!mounted || _adhanOpen) return;
    final nav = firdawsNavigatorKey.currentState;
    if (nav == null) return;
    _adhanOpen = true;
    nav
        .push(
          MaterialPageRoute(
            builder: (_) => AdhanAlarmScreen(
              voiceId: voiceId,
              prayerName: prayerName,
              useNativeService: FirdawsNativeService().isAndroid,
            ),
          ),
        )
        .whenComplete(() {
      _adhanOpen = false;
    });
  }

  void _checkSalawatSchedule() {
    if (!mounted) return;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.salawatOverlayEnabled) return;

    final now = DateTime.now();
    final hhMm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final minuteKey = '${now.year}-${now.month}-${now.day} $hhMm';

    final hitCustomTime = settings.salawatCustomTimes.contains(hhMm) &&
        _lastCustomMinuteKey != minuteKey;
    final hitInterval = settings.salawatIntervalMinutes > 0 &&
        now.difference(_lastSalawatShownAt).inMinutes >=
            settings.salawatIntervalMinutes;

    if (hitCustomTime || hitInterval) {
      if (hitCustomTime) {
        _lastCustomMinuteKey = minuteKey;
      }
      _lastSalawatShownAt = now;
      _showFloatingSalawatNow();
    }
  }

  void _showFloatingSalawatNow() {
    if (!mounted) return;
    _salawatAutoHideTimer?.cancel();
    setState(() {
      _salawatStyleSeed++;
      _showInAppSalawat = true;
    });
    _salawatAutoHideTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _showInAppSalawat) {
        setState(() => _showInAppSalawat = false);
      }
    });
  }

  void _dismissFloatingSalawatOnTouch() {
    _salawatAutoHideTimer?.cancel();
    if (!mounted || !_showInAppSalawat) return;
    setState(() => _showInAppSalawat = false);
    try {
      Provider.of<FirdawsUserProvider>(context, listen: false)
          .recordDhikrByText('اللهم صل وسلم على نبينا محمد');
      final hasanat = Provider.of<HasanatProvider>(context, listen: false);
      hasanat.earnHasanat(3, reason: 'الصلاة على النبي ﷺ', sourceTag: 'نفحة نبوية');
      hasanat.recordMetric(EventMissionMetric.tasbihCount, delta: 1);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isNight = settings.isNightEffective;
        return MaterialApp(
          navigatorKey: firdawsNavigatorKey,
          title: 'الفردوس',
          debugShowCheckedModeBanner: false,
          theme: IslamicTheme.getTheme(
            settings.selectedTheme,
            isNight: isNight,
            fontFamily: settings.selectedFont,
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
            return TouchEffectsOverlay(
              child: Stack(
                children: [
                  if (child != null) child,
                  if (_showInAppSalawat)
                    _InAppFloatingSalawatBanner(
                      styleSeed: _salawatStyleSeed,
                      onTouchDismiss: _dismissFloatingSalawatOnTouch,
                    ),
                ],
              ),
            );
          },
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class _SalawatVisualStyle {
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color borderColor;
  final ShapeBorder shape;

  const _SalawatVisualStyle({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.borderColor,
    required this.shape,
  });
}

class _InAppFloatingSalawatBanner extends StatelessWidget {
  final int styleSeed;
  final VoidCallback onTouchDismiss;

  const _InAppFloatingSalawatBanner({
    required this.styleSeed,
    required this.onTouchDismiss,
  });

  static const List<_SalawatVisualStyle> _styles = [
    _SalawatVisualStyle(
      badge: '🕌 نفحة نبوية ✨',
      title: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ ﷺ 🌹',
      subtitle: 'المس الشريط للاختفاء الفوري وكسب الأجر 💫',
      gradient: [Color(0xFF064E3B), Color(0xFF047857)],
      borderColor: Color(0xFFFBBF24),
      shape: StadiumBorder(
        side: BorderSide(color: Color(0xFFFBBF24), width: 1.8),
      ),
    ),
    _SalawatVisualStyle(
      badge: '🌟 صلاةٌ وعشرُ حسنات 💛',
      title: 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ تَسْلِيماً كَثِيراً 🌸',
      subtitle: 'من صلّى عليّ صلاةً صلّى الله عليه بها عشراً — المس للإغلاق 🌿',
      gradient: [Color(0xFF78350F), Color(0xFFB45309)],
      borderColor: Color(0xFFFDE047),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: Color(0xFFFDE047), width: 1.8),
      ),
    ),
    _SalawatVisualStyle(
      badge: '💫 الصلاة الإبراهيمية 🕋',
      title: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ 🤍',
      subtitle: 'كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ — لمسة واحدة وتختفي ✨',
      gradient: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
      borderColor: Color(0xFF38BDF8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        side: BorderSide(color: Color(0xFF38BDF8), width: 1.8),
      ),
    ),
    _SalawatVisualStyle(
      badge: '🌹 عطر المجالس النبوية 🌺',
      title: 'عَطِّرْ لِسَانَكَ بِالصَّلَاةِ عَلَى الْحَبِيبِ ﷺ 💎',
      subtitle: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَيْهِ 🤲 — المس للإخفاء',
      gradient: [Color(0xFF500724), Color(0xFF9D174D)],
      borderColor: Color(0xFFF472B6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(28),
          topLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        side: BorderSide(color: Color(0xFFF472B6), width: 1.8),
      ),
    ),
    _SalawatVisualStyle(
      badge: '👑 القرب المحمدي ✨',
      title: 'أَوْلَى النَّاسِ بِي أَكْثَرُهُمْ عَلَيَّ صَلَاةً 🌙',
      subtitle: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ 🌟 — المس للاختفاء فوراً',
      gradient: [Color(0xFF2E1065), Color(0xFF6D28D9)],
      borderColor: Color(0xFFC084FC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFFC084FC), width: 1.8),
      ),
    ),
    _SalawatVisualStyle(
      badge: '🕊️ كفاية الهمّ ومغفرة الذنب 🌊',
      title: 'بِالصَّلَاةِ عَلَى النَّبِيِّ ﷺ تَنْفَرِجُ الْكُرُوبُ 💚',
      subtitle: 'إِذًا تُكْفَى هَمَّكَ وَيُغْفَرُ ذَنْبُكَ — المس هنا للانصراف ✨',
      gradient: [Color(0xFF042F2E), Color(0xFF0F766E)],
      borderColor: Color(0xFF5EEAD4),
      shape: StadiumBorder(
        side: BorderSide(color: Color(0xFF5EEAD4), width: 1.8),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final style = _styles[styleSeed.abs() % _styles.length];
    final topPad = (styleSeed.abs() % 3) * 14.0 + 10.0;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPad, 16, 0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => onTouchDismiss(),
              child: Material(
                type: MaterialType.transparency,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey<int>(styleSeed),
                  tween: Tween<double>(begin: 0.84, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    decoration: ShapeDecoration(
                      shape: style.shape,
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: style.gradient,
                      ),
                      shadows: [
                        BoxShadow(
                          color: style.borderColor.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          style.badge,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: style.borderColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          style.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          style.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 11,
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
    );
  }
}
