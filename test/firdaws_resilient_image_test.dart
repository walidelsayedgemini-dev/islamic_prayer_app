import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/widgets/firdaws_resilient_image.dart';

void main() {
  testWidgets('scales image decoding to its visible bounds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            devicePixelRatio: 3,
          ),
          child: SizedBox(
            width: 100,
            height: 60,
            child: FirdawsResilientImage(
              networkUrl: null,
              fallbackAsset: 'assets/images/themes/lahore_badshahi.jpg',
              width: 100,
              height: 60,
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image).first);
    final resizeProvider = image.image as ResizeImage;
    expect(resizeProvider.width, 300);
    expect(resizeProvider.height, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('caps oversized bitmap decoding below full 4K on mobile',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            devicePixelRatio: 3,
          ),
          child: SizedBox(
            width: 1000,
            height: 2000,
            child: FirdawsResilientImage(
              networkUrl: null,
              fallbackAsset: 'assets/images/themes/lahore_badshahi.jpg',
              width: 1000,
              height: 2000,
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image).first);
    final resizeProvider = image.image as ResizeImage;
    expect(resizeProvider.width, isNull);
    expect(resizeProvider.height, 2048);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
