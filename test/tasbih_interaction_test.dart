import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:islamic_prayer_app/models/events_missions_catalog.dart';
import 'package:islamic_prayer_app/providers/comfort_provider.dart';
import 'package:islamic_prayer_app/providers/family_challenge_provider.dart';
import 'package:islamic_prayer_app/providers/firdaws_user_provider.dart';
import 'package:islamic_prayer_app/providers/hasanat_provider.dart';
import 'package:islamic_prayer_app/providers/hoor_companion_provider.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/screens/tasbih_screen.dart';
import 'package:islamic_prayer_app/widgets/interactive_tasbih_beads.dart';

class _DelayedPreferencesStore extends InMemorySharedPreferencesStore {
  _DelayedPreferencesStore() : super.withData({'flutter.tasbih_counter': 12});

  final readStarted = Completer<void>();
  final releaseRead = Completer<void>();

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    if (!readStarted.isCompleted) readStarted.complete();
    await releaseRead.future;
    return super.getAllWithParameters(parameters);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('bead and button activations preserve one-for-one saved metrics',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final comfort = ComfortProvider(systemReduceMotion: true);
    final hasanat = HasanatProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ComfortProvider>.value(value: comfort),
          ChangeNotifierProvider(create: (_) => FirdawsUserProvider()),
          ChangeNotifierProvider(create: (_) => JannatiProvider()),
          ChangeNotifierProvider(create: (_) => HoorCompanionProvider()),
          ChangeNotifierProvider(create: (_) => FamilyChallengeProvider()),
          ChangeNotifierProvider<HasanatProvider>.value(value: hasanat),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TasbihScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final beadRing = find.byType(InteractiveTasbihBeads);
    await tester.ensureVisible(beadRing);
    await tester.pumpAndSettle();
    await tester.tap(beadRing);
    await tester.pumpAndSettle();

    final countButton = find.text('تسبيح');
    await tester.ensureVisible(countButton);
    await tester.pumpAndSettle();
    await tester.tap(countButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 30));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('tasbih_counter'), 2);
    expect(prefs.getInt('tasbih_lifetime'), 2);
    expect(hasanat.metricValue(EventMissionMetric.tasbihCount), 2);
    expect(hasanat.hasanatBalance, 222);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bead and button stay disabled until saved counter is restored',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final delayedStore = _DelayedPreferencesStore();
    SharedPreferencesStorePlatform.instance = delayedStore;
    addTearDown(() {
      if (!delayedStore.releaseRead.isCompleted) {
        delayedStore.releaseRead.complete();
      }
      SharedPreferences.setMockInitialValues({});
    });

    final comfort = ComfortProvider(systemReduceMotion: true);
    final hasanat = HasanatProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ComfortProvider>.value(value: comfort),
          ChangeNotifierProvider(create: (_) => FirdawsUserProvider()),
          ChangeNotifierProvider(create: (_) => JannatiProvider()),
          ChangeNotifierProvider(create: (_) => HoorCompanionProvider()),
          ChangeNotifierProvider(create: (_) => FamilyChallengeProvider()),
          ChangeNotifierProvider<HasanatProvider>.value(value: hasanat),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TasbihScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await delayedStore.readStarted.future;

    final beadRing = find.byType(InteractiveTasbihBeads);
    await tester.ensureVisible(beadRing);
    expect(tester.widget<InteractiveTasbihBeads>(beadRing).onTap, isNull);
    final countButton = find.ancestor(
      of: find.text('تسبيح'),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(countButton).onPressed, isNull);

    await tester.tap(beadRing, warnIfMissed: false);
    await tester.tap(find.text('تسبيح'), warnIfMissed: false);
    await tester.pump();
    expect(tester.widget<InteractiveTasbihBeads>(beadRing).count, 0);

    delayedStore.releaseRead.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<InteractiveTasbihBeads>(beadRing).count, 12);
    expect(tester.widget<InteractiveTasbihBeads>(beadRing).onTap, isNotNull);
    await tester.tap(beadRing);
    await tester.pumpAndSettle();
    expect(tester.widget<InteractiveTasbihBeads>(beadRing).count, 13);
    expect(tester.takeException(), isNull);
  });
}
