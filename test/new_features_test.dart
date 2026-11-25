import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/screens/backup_screen.dart';
import 'package:islamic_prayer_app/services/quran_bookmarks_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggle adds a bookmark then removes it', () {
    final b = QuranBookmark(
        surahNumber: 2,
        ayahNumber: 255,
        surahName: 'البقرة',
        savedAt: DateTime(2026));
    final added = QuranBookmarksStore.toggle([], b);
    expect(added.length, 1);
    expect(QuranBookmarksStore.toggle(added, b), isEmpty);
  });

  test('bookmarks persist through save and load', () async {
    SharedPreferences.setMockInitialValues({});
    final b = QuranBookmark(
        surahNumber: 18,
        ayahNumber: 10,
        surahName: 'الكهف',
        savedAt: DateTime(2026));
    await QuranBookmarksStore.save([b]);
    final loaded = await QuranBookmarksStore.load();
    expect(loaded.single.id, '18:10');
    expect(loaded.single.surahName, 'الكهف');
  });

  test('backup export then import restores every value type', () async {
    SharedPreferences.setMockInitialValues({
      'a': true,
      'b': 7,
      'c': 1.5,
      'd': 'نص',
      'e': <String>['x', 'y'],
    });
    final json = await BackupService.exportAll();
    SharedPreferences.setMockInitialValues({});
    final restored = await BackupService.importAll(json);
    final prefs = await SharedPreferences.getInstance();
    expect(restored, 5);
    expect(prefs.getBool('a'), true);
    expect(prefs.getInt('b'), 7);
    expect(prefs.getDouble('c'), 1.5);
    expect(prefs.getString('d'), 'نص');
    expect(prefs.getStringList('e'), ['x', 'y']);
  });

  test('importing invalid text throws FormatException', () async {
    expect(() => BackupService.importAll('{"hello":1}'),
        throwsA(isA<FormatException>()));
  });
}
