import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'islamic_audio_data.dart';

class QuranAyah {
  final int number;
  final String text;
  final String normalizedText;
  final int juz;
  final int page;

  const QuranAyah({
    required this.number,
    required this.text,
    required this.normalizedText,
    required this.juz,
    required this.page,
  });
}

class QuranSurah {
  final int number;
  final String ornateName;
  final String cleanName;
  final String normalizedName;
  final String englishName;
  final bool isMakki;
  final List<QuranAyah> ayahs;

  const QuranSurah({
    required this.number,
    required this.ornateName,
    required this.cleanName,
    required this.normalizedName,
    required this.englishName,
    required this.isMakki,
    required this.ayahs,
  });

  int get versesCount => ayahs.length;
  int get startingJuz => ayahs.isNotEmpty ? ayahs.first.juz : 1;
  int get startingPage => ayahs.isNotEmpty ? ayahs.first.page : 1;
  bool get hasOpeningBasmalah => number != 1 && number != 9;
}

class QuranSearchHit {
  final QuranSurah surah;
  final QuranAyah ayah;

  const QuranSearchHit({required this.surah, required this.ayah});
}

/// يزيل التشكيل والرموز العثمانية ويوحد الحروف لتسهيل البحث الدقيق
String normalizeArabicForSearch(String input) {
  var s = input.replaceAll('\uFEFF', '').trim();
  // إزالة علامات الضبط والتجويد والتشكيل والوقف العثماني والألف الخنجرية والتطويل
  s = s.replaceAll(
    RegExp(r'[\u0610-\u061A\u0640\u064B-\u065F\u0670\u06D6-\u06ED]'),
    '',
  );
  // توحيد الهمزات والألف المقصورة والوصل
  s = s
      .replaceAll('ٱ', 'ا')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
}

String toArabicIndicDigits(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final str = number.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    final code = str.codeUnitAt(i);
    if (code >= 48 && code <= 57) {
      buf.write(digits[code - 48]);
    } else {
      buf.write(str[i]);
    }
  }
  return buf.toString();
}

String _stripPrependedBasmalah(int surahNumber, int ayahNumber, String text) {
  var cleaned = text.replaceAll('\uFEFF', '').trim();
  if (surahNumber == 1 || surahNumber == 9 || ayahNumber != 1) {
    return cleaned;
  }

  const exactPrefix1 = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ';
  const exactPrefix2 = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ';
  // بعض علامات الشدة أو الترتيب في حزمة الخطوط العثمانية
  const raheemMarker = 'ٱلرَّحِيمِ';
  const raheemMarkerAlt = 'ٱلرَّحِيمِ';

  if (cleaned.startsWith(exactPrefix1)) {
    return cleaned.substring(exactPrefix1.length).trim();
  }
  if (cleaned.startsWith(exactPrefix2)) {
    return cleaned.substring(exactPrefix2.length).trim();
  }

  final idx1 = cleaned.indexOf(raheemMarker);
  if (idx1 > 0 && idx1 < 45) {
    return cleaned.substring(idx1 + raheemMarker.length).trim();
  }
  final idx2 = cleaned.indexOf(raheemMarkerAlt);
  if (idx2 > 0 && idx2 < 45) {
    return cleaned.substring(idx2 + raheemMarkerAlt.length).trim();
  }
  return cleaned;
}

List<QuranSurah> parseQuranJsonString(String rawJson) {
  final decoded = jsonDecode(rawJson.replaceFirst('\uFEFF', '')) as List<dynamic>;
  final surahs = <QuranSurah>[];

  for (final item in decoded) {
    final map = item as Map<String, dynamic>;
    final number = (map['n'] as num).toInt();
    final ornateName = (map['name'] as String).replaceAll('\uFEFF', '').trim();
    final metaSurah = IslamicAudioLibrary.getSurahByNumber(number);
    final cleanName = metaSurah?.nameArabic ??
        ornateName.replaceFirst(RegExp(r'^سُورَةُ\s*|^سورة\s*'), '').trim();
    final englishName = (map['en'] as String? ?? '').trim();
    final isMakki = (map['type'] as String? ?? 'Meccan') == 'Meccan';

    final rawAyahs = (map['ayahs'] as List<dynamic>);
    final ayahs = <QuranAyah>[];
    for (final rawAyah in rawAyahs) {
      final aMap = rawAyah as Map<String, dynamic>;
      final aNum = (aMap['n'] as num).toInt();
      final text = _stripPrependedBasmalah(number, aNum, aMap['t'] as String);
      ayahs.add(
        QuranAyah(
          number: aNum,
          text: text,
          normalizedText: normalizeArabicForSearch(text),
          juz: (aMap['j'] as num).toInt(),
          page: (aMap['p'] as num).toInt(),
        ),
      );
    }

    surahs.add(
      QuranSurah(
        number: number,
        ornateName: ornateName,
        cleanName: cleanName,
        normalizedName: normalizeArabicForSearch('$cleanName $ornateName $englishName $number'),
        englishName: englishName,
        isMakki: isMakki,
        ayahs: ayahs,
      ),
    );
  }

  return surahs;
}

class QuranRepository {
  static List<QuranSurah>? _cachedSurahs;
  static Future<List<QuranSurah>>? _inFlight;

  static Future<List<QuranSurah>> loadCompleteQuran() async {
    if (_cachedSurahs != null) return _cachedSurahs!;
    if (_inFlight != null) return _inFlight!;

    _inFlight = () async {
      final raw = await rootBundle.loadString('assets/data/quran_complete.json');
      final parsed = await compute(parseQuranJsonString, raw);
      _cachedSurahs = parsed;
      return parsed;
    }();

    try {
      return await _inFlight!;
    } catch (e) {
      _inFlight = null;
      rethrow;
    }
  }

  static List<QuranSearchHit> searchInsideAyahs(
    List<QuranSurah> surahs,
    String query, {
    int limit = 40,
  }) {
    final normQuery = normalizeArabicForSearch(query);
    if (normQuery.length < 2) return const [];

    final hits = <QuranSearchHit>[];
    for (final surah in surahs) {
      for (final ayah in surah.ayahs) {
        if (ayah.normalizedText.contains(normQuery)) {
          hits.add(QuranSearchHit(surah: surah, ayah: ayah));
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }
}
