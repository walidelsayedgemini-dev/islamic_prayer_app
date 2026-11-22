import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/widgets/calm_page_transition.dart';

void main() {
  testWidgets('tab transition retains the child state across index changes',
      (tester) async {
    var currentIndex = 0;
    late StateSetter update;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        update = setState;
        return CalmPageTransition(
          pageIndex: currentIndex,
          child: const _Counter(),
        );
      }),
    ));
    await tester.tap(find.text('0'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    update(() => currentIndex = 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion makes tab arrival immediate', (tester) async {
    var currentIndex = 0;
    late StateSetter update;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: StatefulBuilder(builder: (context, setState) {
          update = setState;
          return CalmPageTransition(
            pageIndex: currentIndex,
            child: const SizedBox(),
          );
        }),
      ),
    ));
    update(() => currentIndex = 1);
    await tester.pump();
    final scope = find.byType(CalmPageTransition);
    final slide = tester.widget<SlideTransition>(find.descendant(
      of: scope,
      matching: find.byType(SlideTransition),
    ));
    expect(slide.position.value, Offset.zero);
    final fade = tester.widget<FadeTransition>(find.descendant(
      of: scope,
      matching: find.byType(FadeTransition),
    ));
    expect(fade.opacity.value, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
}

class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => count++),
        child: Text('$count'),
      );
}
