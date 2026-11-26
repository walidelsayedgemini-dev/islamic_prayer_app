import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

String activityDayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// عدّ التسبيح لكل يوم (يحتفظ بآخر 60 يومًا فقط).
class TasbihDailyStore {
  static const String prefsKey = 'tasbih_daily_v1';

  static Future<Map<String, int>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, int>{};
      decoded.forEach((k, v) {
        if (k is String && v is int) out[k] = v;
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  static Future<void> increment({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await load();
      final today = now ?? DateTime.now();
      final key = activityDayKey(today);
      data[key] = (data[key] ?? 0) + 1;
      final cutoff = activityDayKey(today.subtract(const Duration(days: 60)));
      data.removeWhere((k, _) => k.compareTo(cutoff) < 0);
      await prefs.setString(prefsKey, jsonEncode(data));
    } catch (_) {}
  }

  static int sumLastDays(Map<String, int> data, int days, {DateTime? now}) {
    final today = now ?? DateTime.now();
    var total = 0;
    for (var i = 0; i < days; i++) {
      final d = DateTime(today.year, today.month, today.day - i);
      total += data[activityDayKey(d)] ?? 0;
    }
    return total;
  }
}

/// الورد اليومي من القرآن: هدف بعدد الصفحات وتتبّع الصفحات المقروءة اليوم.
class QuranWirdStore {
  static const String goalKey = 'quran_wird_goal_pages';
  static const String todayKey = 'quran_wird_today_v1';
  static const List<int> goalChoices = [1, 2, 5, 10, 20];
  static const int totalPages = 604;

  static Future<int> loadGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(goalKey) ?? 2;
    } catch (_) {
      return 2;
    }
  }

  static Future<void> saveGoal(int pages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(goalKey, pages);
    } catch (_) {}
  }

  /// الصفحات التي سُجّلت اليوم.
  static Future<Set<int>> loadToday({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(todayKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['d'] != activityDayKey(now ?? DateTime.now())) {
        return {};
      }
      final pages = decoded['p'];
      if (pages is! List) return {};
      return pages.whereType<int>().toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<Set<int>> markPage(int page, {DateTime? now}) async {
    final pages = await loadToday(now: now);
    pages.add(page);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(todayKey,
          jsonEncode({'d': activityDayKey(now ?? DateTime.now()), 'p': pages.toList()}));
    } catch (_) {}
    return pages;
  }

  /// عدد الأيام اللازمة لختم المصحف بالهدف الحالي.
  static int daysToFinish(int goalPages) =>
      goalPages <= 0 ? 0 : (totalPages / goalPages).ceil();
}
