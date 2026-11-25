import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// علامة مرجعية محفوظة لآية محددة في المصحف.
class QuranBookmark {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final DateTime savedAt;

  const QuranBookmark({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.savedAt,
  });

  String get id => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toJson() => {
        's': surahNumber,
        'a': ayahNumber,
        'n': surahName,
        't': savedAt.millisecondsSinceEpoch,
      };

  static QuranBookmark? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final s = raw['s'];
    final a = raw['a'];
    if (s is! int || a is! int) return null;
    final t = raw['t'];
    return QuranBookmark(
      surahNumber: s,
      ayahNumber: a,
      surahName: raw['n'] is String ? raw['n'] as String : '',
      savedAt: DateTime.fromMillisecondsSinceEpoch(t is int ? t : 0),
    );
  }
}

/// تخزين محلي بسيط لقائمة العلامات المرجعية (الأحدث أولاً).
class QuranBookmarksStore {
  static const String prefsKey = 'quran_bookmarks_v1';
  static const int maxBookmarks = 200;

  static Future<List<QuranBookmark>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map(QuranBookmark.fromJson)
          .whereType<QuranBookmark>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<QuranBookmark> bookmarks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trimmed = bookmarks.take(maxBookmarks).toList();
      await prefs.setString(
          prefsKey, jsonEncode(trimmed.map((b) => b.toJson()).toList()));
    } catch (_) {}
  }

  /// يضيف العلامة إن لم تكن موجودة، ويحذفها إن كانت موجودة.
  /// يُرجع القائمة الجديدة.
  static List<QuranBookmark> toggle(
      List<QuranBookmark> current, QuranBookmark bookmark) {
    final exists = current.any((b) => b.id == bookmark.id);
    if (exists) {
      return current.where((b) => b.id != bookmark.id).toList();
    }
    return [bookmark, ...current];
  }
}
