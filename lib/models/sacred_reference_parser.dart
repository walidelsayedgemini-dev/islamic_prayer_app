import 'islamic_audio_data.dart';
import 'quran_model.dart';
import 'sahih_hadith_data.dart';

class QuranRefMatch {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String rawLabel;

  const QuranRefMatch({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.rawLabel,
  });

  String get formattedBadge => 'سورة $surahName: $ayahNumber';
}

class SacredReferenceParser {
  static String toWesternDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = input;
    for (int i = 0; i < 10; i++) {
      out = out.replaceAll(arabicDigits[i], '$i');
    }
    return out;
  }

  static final Map<String, int> _normalizedSurahLookup = () {
    final map = <String, int>{};
    for (final s in IslamicAudioLibrary.allSurahs) {
      final norm = normalizeArabicForSearch(s.nameArabic);
      map[norm] = s.number;
      if (norm.startsWith('ال')) {
        map[norm.substring(2)] = s.number;
      }
    }
    // أسماء شائعة ومختصرات
    map['ال عمران'] = 3;
    map['سوره يسن'] = 36;
    map['ياسين'] = 36;
    map['عم'] = 78;
    map['تبارك'] = 67;
    map['قل هو الله احد'] = 112;
    map['سبح'] = 87;
    return map;
  }();

  static int? findSurahNumberByName(String candidate) {
    var norm = normalizeArabicForSearch(candidate)
        .replaceFirst(RegExp(r'^سوره\s+'), '')
        .trim();
    if (norm.isEmpty) return null;
    if (_normalizedSurahLookup.containsKey(norm)) {
      return _normalizedSurahLookup[norm];
    }
    for (final entry in _normalizedSurahLookup.entries) {
      if (entry.key == norm) return entry.value;
    }
    return null;
  }

  /// يستخرج جميع المراجع القرآنية الصريحة في النص (مثل: البقرة: 255، سورة الأعراف آية 31، آية الكرسي)
  static List<QuranRefMatch> extractQuranReferences(String rawText) {
    final text = toWesternDigits(rawText);
    final results = <QuranRefMatch>[];
    final seen = <String>{};

    void addMatch(int surahNum, int ayahNum, String label) {
      final surah = IslamicAudioLibrary.getSurahByNumber(surahNum);
      if (surah == null) return;
      final clampedAyah = ayahNum.clamp(1, surah.versesCount);
      final key = '$surahNum:$clampedAyah';
      if (seen.add(key)) {
        results.add(
          QuranRefMatch(
            surahNumber: surahNum,
            ayahNumber: clampedAyah,
            surahName: surah.nameArabic,
            rawLabel: label.trim(),
          ),
        );
      }
    }

    // 1) نمط صريح: [سورة] <اسم> : <آية> أو <اسم> — الآية (<آية>)
    final explicitRegex = RegExp(
      r'(?:سورة\s+)?([ء-يًٌٍَُِّْ\s]{2,26}?)\s*(?:[-–—]+\s*)?(?:[:،]\s*|(?:ال)?آي[ةه]\s+)[\(\[]?\s*(\d{1,3})(?:\s*[-–]\s*\d{1,3})?\s*[\)\]]?',
    );
    // 1-ب) نمط سورة <اسم> (<آية>) مثل: سورة يس (20-27) أو سورة البقرة (255)
    final parenSurahRegex = RegExp(
      r'سورة\s+([ء-يًٌٍَُِّْ\s]{2,26}?)\s*[\(\[]\s*(\d{1,3})(?:\s*[-–]\s*\d{1,3})?\s*[\)\]]',
    );
    for (final m in [...explicitRegex.allMatches(text), ...parenSurahRegex.allMatches(text)]) {
      final candidateName = (m.group(1) ?? '').trim();
      final ayahStr = m.group(2);
      if (ayahStr == null) continue;
      final ayahNum = int.tryParse(ayahStr);
      if (ayahNum == null || ayahNum <= 0) continue;

      final tokens = candidateName.split(RegExp(r'\s+'));
      int? foundSurah;
      for (int start = 0; start < tokens.length; start++) {
        final sub = tokens.sublist(start).join(' ');
        foundSurah = findSurahNumberByName(sub);
        if (foundSurah != null) break;
      }
      if (foundSurah != null) {
        addMatch(foundSurah, ayahNum, m.group(0) ?? '');
      }
    }

    // 2) علامات قرآنية شهيرة بدون رقم صريح
    if (text.contains('آية الكرسي') || text.contains('ايه الكرسي')) {
      addMatch(2, 255, 'آية الكرسي (البقرة: 255)');
    }
    if (text.contains('خواتيم البقرة') || text.contains('أواخر البقرة')) {
      addMatch(2, 285, 'خواتيم البقرة (285-286)');
    }
    if (text.contains('الصلاة الوسطى')) {
      addMatch(2, 238, 'البقرة: 238');
    }
    if (text.contains('سورة الملك') && seen.every((k) => !k.startsWith('67:'))) {
      addMatch(67, 1, 'سورة الملك');
    }
    if (text.contains('سورة الكهف') && seen.every((k) => !k.startsWith('18:'))) {
      addMatch(18, 1, 'سورة الكهف');
    }
    if (text.contains('سورة الإخلاص') && seen.every((k) => !k.startsWith('112:'))) {
      addMatch(112, 1, 'سورة الإخلاص');
    }
    if (text.contains('المعوذات') || text.contains('المعوذتين')) {
      addMatch(113, 1, 'سورة الفلق (1)');
    }
    if (text.contains('سورة الفاتحة') && seen.every((k) => !k.startsWith('1:'))) {
      addMatch(1, 1, 'سورة الفاتحة');
    }
    if (text.contains('سورة الواقعة') && seen.every((k) => !k.startsWith('56:'))) {
      addMatch(56, 1, 'سورة الواقعة');
    }
    if (text.contains('تبارك الذي بيده الملك')) {
      addMatch(67, 1, 'الملك: 1');
    }
    if (text.contains('ألا بذكر الله تطمئن القلوب')) {
      addMatch(13, 28, 'الرعد: 28');
    }
    if (text.contains('وقرآن الفجر')) {
      addMatch(17, 78, 'الإسراء: 78');
    }

    return results;
  }

  static QuranRefMatch? firstQuranReference(String rawText) {
    final list = extractQuranReferences(rawText);
    return list.isEmpty ? null : list.first;
  }

  /// يحدد هل النص يحتوي على إشارة حديث نبوي لإبرازه وإتاحة فتح صحيح البخاري وشرحه
  static bool containsHadithReference(String rawText) {
    final t = rawText;
    return t.contains('البخاري') ||
        t.contains('مسلم') ||
        t.contains('متفق عليه') ||
        t.contains('الصحيحين') ||
        t.contains('الترمذي') ||
        t.contains('أبو داود') ||
        t.contains('أبي داود') ||
        t.contains('النسائي') ||
        t.contains('ابن ماجه') ||
        t.contains('أحمد') ||
        t.contains('رواه ') ||
        t.contains('قال ﷺ');
  }

  static SahihHadithEntry resolveHadith(String rawText) {
    return SahihHadithCatalog.resolveReference(toWesternDigits(rawText));
  }
}
