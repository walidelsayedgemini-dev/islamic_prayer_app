import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';

void main() {
  test('every paradise theme image is a bundled local asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(FirdawsParadiseRegistry.all, isNotEmpty);
    for (final spec in FirdawsParadiseRegistry.all) {
      final path = spec.imageAsset;
      expect(path.startsWith('assets/'), isTrue,
          reason: '${spec.key} must use a bundled asset, got $path');
      expect(path.contains('manus-storage'), isFalse, reason: spec.key);
      expect(File(path).existsSync(), isTrue,
          reason: '${spec.key} image is missing: $path');
      final folder = path.substring(0, path.lastIndexOf('/') + 1);
      expect(pubspec.contains(folder) || pubspec.contains(path), isTrue,
          reason: '$folder must be declared in pubspec.yaml');
    }
  });
}
