import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/screens/backup_screen.dart';
import 'package:islamic_prayer_app/services/activity_stats_store.dart';
import 'package:islamic_prayer_app/services/quran_bookmarks_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  activityTests();

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
    expect(restored, 6); // 5 قيم + تاريخ آخر نسخة
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

void activityTests() {
  test('tasbih daily store counts per day and sums ranges', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 11, 25);
    await TasbihDailyStore.increment(now: now);
    await TasbihDailyStore.increment(now: now);
    await TasbihDailyStore.increment(now: DateTime(2026, 11, 22));
    final data = await TasbihDailyStore.load();
    expect(TasbihDailyStore.sumLastDays(data, 1, now: now), 2);
    expect(TasbihDailyStore.sumLastDays(data, 7, now: now), 3);
  });

  test('wird store tracks distinct pages per day and resets next day',
      () async {
    SharedPreferences.setMockInitialValues({});
    final day = DateTime(2026, 11, 25);
    await QuranWirdStore.markPage(5, now: day);
    final pages = await QuranWirdStore.markPage(5, now: day);
    expect(pages.length, 1);
    await QuranWirdStore.markPage(6, now: day);
    expect((await QuranWirdStore.loadToday(now: day)).length, 2);
    expect(await QuranWirdStore.loadToday(now: DateTime(2026, 11, 26)), isEmpty);
    expect(QuranWirdStore.daysToFinish(2), 302);
  });

  test('backup reminder is due after a week', () {
    final now = DateTime(2026, 11, 25);
    expect(BackupService.isDue(null, now: now), true);
    expect(BackupService.isDue(DateTime(2026, 11, 20), now: now), false);
    expect(BackupService.isDue(DateTime(2026, 11, 10), now: now), true);
  });
}
