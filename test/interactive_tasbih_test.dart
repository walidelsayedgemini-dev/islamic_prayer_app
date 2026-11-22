import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/widgets/interactive_tasbih_beads.dart';

void main() {
  Widget ringHarness({
    required VoidCallback onTap,
    int count = 0,
    bool reduceMotion = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: InteractiveTasbihBeads(
            count: count,
            target: 33,
            progress: count / 33,
            reduceMotion: reduceMotion,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  testWidgets('a tap adds once, while a drag does not activate the beads',
      (tester) async {
    var activations = 0;
    await tester.pumpWidget(ringHarness(onTap: () => activations++));
    final beadRing = find.byType(InteractiveTasbihBeads);
    expect(tester.getSize(beadRing).width, greaterThanOrEqualTo(220));

    await tester.tap(beadRing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(activations, 1);

    await tester.drag(beadRing, const Offset(0, -70));
    await tester.pump(const Duration(milliseconds: 300));
    expect(activations, 1);
  });

  testWidgets('the bead ring exposes accessible keyboard and semantics actions',
      (tester) async {
    var activations = 0;
    final semanticsHandle = tester.ensureSemantics();
    await tester.pumpWidget(ringHarness(onTap: () => activations++));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activations, 1);
    final semanticsTree = tester
        .binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!
        .toStringDeep();
    expect(semanticsTree, contains('خرز السبحة'));
    expect(semanticsTree, contains('value: "العدد 0 من 33"'));
    expect(semanticsTree, contains('actions: focus, tap'));
    expect(semanticsTree, contains('flags: isButton'));
    semanticsHandle.dispose();
  });

  testWidgets('reduced-motion mode removes the bead travel animation',
      (tester) async {
    await tester.pumpWidget(
      ringHarness(onTap: () {}, reduceMotion: true),
    );
    expect(
      find.byWidgetPredicate(
          (widget) => widget is TweenAnimationBuilder<double>),
      findsNothing,
    );
  });

  testWidgets('bead count remains readable with enlarged text on a small phone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.7)),
        child: Scaffold(
          body: Center(
            child: InteractiveTasbihBeads(
              count: 100001,
              target: 100000,
              progress: 1,
              reduceMotion: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    ));
    expect(find.text('100001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
