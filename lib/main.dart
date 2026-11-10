import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/firdaws_user_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';
import 'theme/islamic_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  final audioPlayerProvider = AudioPlayerProvider();
  final firdawsUserProvider = FirdawsUserProvider();

  // تشغيل التطبيق فوراً دون انتظار عمليات الحساسات أو التنبيهات
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<AudioPlayerProvider>.value(value: audioPlayerProvider),
        ChangeNotifierProvider<FirdawsUserProvider>.value(value: firdawsUserProvider),
      ],
      child: const IslamicPrayerApp(),
    ),
  );

  // تحميل الإعدادات والخدمات في الخلفية بعد رسم الشاشة الأولى
  Future.microtask(() async {
    try {
      await settingsProvider.init();
      await firdawsUserProvider.init();
      await NotificationService().initialize();
    } catch (e) {
      debugPrint("Background init: $e");
    }
  });
}

class IslamicPrayerApp extends StatelessWidget {
  const IslamicPrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isNight = settings.isNightEffective;
        return MaterialApp(
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
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
