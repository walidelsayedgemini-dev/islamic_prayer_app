import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/screens/settings_screen.dart';
import 'package:islamic_prayer_app/services/notification_capabilities.dart';
import 'calm_redesign_test.dart' show wrapQuietApp;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auto_loc': false,
      'pre_adhan_reminder': true,
    });
  });

  for (final isWeb in <bool>[true, false]) {
    testWidgets(
      '${isWeb ? 'web' : 'Android'} pre-Adhan reminder control matches platform support',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final capabilities = NotificationPlatformCapabilities.forTarget(
          isWeb: isWeb,
          targetPlatform: TargetPlatform.android,
        );

        await tester.pumpWidget(
          wrapQuietApp(
            SettingsScreen(notificationCapabilities: capabilities),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.ensureVisible(find.text('تذكير قبل الأذان'));
        await tester.pump(const Duration(milliseconds: 100));

        final tileFinder =
            find.widgetWithText(SwitchListTile, 'تذكير قبل الأذان');
        expect(tileFinder, findsOneWidget);
        final tile = tester.widget<SwitchListTile>(tileFinder);
        if (isWeb) {
          expect(tile.onChanged, isNull);
          expect(
            find.text(
              'غير متاح في نسخة الويب؛ لا يعمل حتى مع بقاء الصفحة مفتوحة',
            ),
            findsOneWidget,
          );
        } else {
          expect(tile.onChanged, isNotNull);
          expect(find.text('قبل دخول الوقت بـ ١٥ دقيقة'), findsOneWidget);
        }

        final settings = tester
            .element(find.byType(SettingsScreen))
            .read<SettingsProvider>();
        expect(settings.playPreAdhanReminder, isTrue);
        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getBool('pre_adhan_reminder'), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
