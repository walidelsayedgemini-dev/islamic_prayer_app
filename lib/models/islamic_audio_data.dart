class AdhanVoiceInfo {
  final String id;
  final String title;
  final String muezzin;
  final String rawResourceName;
  final String assetPath;

  const AdhanVoiceInfo({
    required this.id,
    required this.title,
    required this.muezzin,
    required this.rawResourceName,
    required this.assetPath,
  });
}

class ReciterInfo {
  final String id;
  final String name;
  final String country;
  final String riwayah;
  final String cdnSlug;

  const ReciterInfo({
    required this.id,
    required this.name,
    required this.country,
    required this.riwayah,
    required this.cdnSlug,
  });
}

class SurahAudioItem {
  final int number;
  final String nameArabic;
  final String englishName;
  final int versesCount;
  final bool isMakki;
  final String defaultDuration;
  final String audioUrl;

  const SurahAudioItem({
    required this.number,
    required this.nameArabic,
    required this.englishName,
    required this.versesCount,
    required this.isMakki,
    required this.defaultDuration,
    required this.audioUrl,
  });
}

class RuqyahAudioItem {
  final String id;
  final String title;
  final String reciter;
  final String duration;
  final String purpose;
  final String description;
  final String streamUrl;
  final String? localAsset;

  const RuqyahAudioItem({
    required this.id,
    required this.title,
    required this.reciter,
    required this.duration,
    required this.purpose,
    required this.description,
    required this.streamUrl,
    this.localAsset,
  });
}

class IbtihalAudioItem {
  final String id;
  final String title;
  final String reciter;
  final String duration;
  final String maqam;
  final String streamUrl;
  final String? localAsset;

  const IbtihalAudioItem({
    required this.id,
    required this.title,
    required this.reciter,
    required this.duration,
    required this.maqam,
    required this.streamUrl,
    this.localAsset,
  });
}

class ParadiseBirdsongItem {
  final String id;
  final String title;
  final String subtitle;
  final String localAsset;
  final String? streamUrl;

  const ParadiseBirdsongItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.localAsset,
    this.streamUrl,
  });
}

class IslamicAudioLibrary {
  static const List<AdhanVoiceInfo> adhanVoices = [
    AdhanVoiceInfo(
      id: 'madinah',
      title: 'أذان الحرم النبوي الشريف 🕌',
      muezzin: 'المدينة المنورة',
      rawResourceName: 'adhan_madinah',
      assetPath: 'audio/adhan_madinah.mp3',
    ),
    AdhanVoiceInfo(
      id: 'makkah',
      title: 'أذان الحرم المكي الشريف 🕋',
      muezzin: 'مكة المكرمة',
      rawResourceName: 'adhan_makkah',
      assetPath: 'audio/adhan_makkah.mp3',
    ),
    AdhanVoiceInfo(
      id: 'aqsa',
      title: 'أذان المسجد الأقصى المبارك 🌙',
      muezzin: 'القدس الشريف',
      rawResourceName: 'adhan_aqsa',
      assetPath: 'audio/adhan_aqsa.mp3',
    ),
    AdhanVoiceInfo(
      id: 'cairo',
      title: 'الأذان المصري الخاشع ✨',
      muezzin: 'مصر المباركة',
      rawResourceName: 'adhan_cairo',
      assetPath: 'audio/adhan_cairo.mp3',
    ),
    AdhanVoiceInfo(
      id: 'afasy',
      title: 'أذان الشيخ مشاري العفاسي 🎙️',
      muezzin: 'الشيخ مشاري راشد العفاسي',
      rawResourceName: 'adhan_afasy',
      assetPath: 'audio/adhan_afasy.mp3',
    ),
  ];

  static AdhanVoiceInfo getAdhanVoiceById(String id) {
    return adhanVoices.firstWhere(
      (v) => v.id == id,
      orElse: () => adhanVoices.first,
    );
  }

  static const List<ReciterInfo> reciters = [
    ReciterInfo(
      id: 'qatami',
      name: 'الشيخ ناصر القطامي',
      country: 'المملكة العربية السعودية',
      riwayah: 'حفص عن عاصم',
      cdnSlug: 'nasser-qatami/r1',
    ),
    ReciterInfo(
      id: 'afasy',
      name: 'الشيخ مشاري راشد العفاسي',
      country: 'الكويت',
      riwayah: 'حفص عن عاصم',
      cdnSlug: 'mishary-alafasy/r1',
    ),
    ReciterInfo(
      id: 'abdulbasit',
      name: 'الشيخ عبد الباسط عبد الصمد',
      country: 'مصر',
      riwayah: 'المصحف المرتل',
      cdnSlug: 'abdulbasit-abdulsamad/r3',
    ),
    ReciterInfo(
      id: 'minshawi',
      name: 'الشيخ محمد صديق المنشاوي',
      country: 'مصر',
      riwayah: 'حفص عن عاصم',
      cdnSlug: 'muhammad-minshawi/r1',
    ),
    ReciterInfo(
      id: 'maher',
      name: 'الشيخ ماهر المعيقلي',
      country: 'المملكة العربية السعودية - إمام الحرم',
      riwayah: 'حفص عن عاصم',
      cdnSlug: 'maher-muaiqly/r1',
    ),
    ReciterInfo(
      id: 'ghamdi',
      name: 'الشيخ سعد الغامدي',
      country: 'المملكة العربية السعودية',
      riwayah: 'حفص عن عاصم',
      cdnSlug: 'saad-ghamdi/r1',
    ),
  ];

  static const Set<int> _qatamiBundledSurahs = {1, 108, 109, 110, 111, 112, 113, 114};
  static const Set<int> _afasyBundledSurahs = {1, 112, 113, 114};

  static ReciterInfo getReciterById(String reciterId) {
    return reciters.firstWhere(
      (r) => r.id == reciterId,
      orElse: () => reciters.first,
    );
  }

  /// رابط التلاوة المباشر المعتمد لجميع القراء الـ 6 × 114 سورة عبر cdn.mp3quran.net
  static String getSurahUrl(String reciterId, int surahNumber) {
    final reciter = getReciterById(reciterId);
    final padded = surahNumber.toString().padLeft(3, '0');
    return 'https://cdn.mp3quran.net/audio/${reciter.cdnSlug}/$padded.mp3';
  }

  /// مسار الملف الصوتي المدمج داخل التطبيق (يعمل بدون إنترنت تماماً) عند توفره
  /// المسار نسبي لمجلد assets/ حسب متطلبات AssetSource في حزمة audioplayers
  static String? getBundledSurahAsset(String reciterId, int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    if (reciterId == 'qatami' && _qatamiBundledSurahs.contains(surahNumber)) {
      return 'audio/qatami_$padded.mp3';
    }
    if (reciterId == 'afasy' && _afasyBundledSurahs.contains(surahNumber)) {
      return 'audio/afasy_$padded.mp3';
    }
    return null;
  }

  static String surahCacheKey(String reciterId, int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return 'surah_${reciterId}_$padded';
  }

  static SurahAudioItem? getSurahByNumber(int surahNumber) {
    for (final s in allSurahs) {
      if (s.number == surahNumber) return s;
    }
    return null;
  }

  static const List<SurahAudioItem> allSurahs = [
    SurahAudioItem(number: 1, nameArabic: "الفاتحة", englishName: "Al-Fatihah", versesCount: 7, isMakki: true, defaultDuration: "00:48", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/001.mp3"),
    SurahAudioItem(number: 2, nameArabic: "البقرة", englishName: "Al-Baqarah", versesCount: 286, isMakki: false, defaultDuration: "02:14:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/002.mp3"),
    SurahAudioItem(number: 3, nameArabic: "آل عمران", englishName: "Ali 'Imran", versesCount: 200, isMakki: false, defaultDuration: "01:21:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/003.mp3"),
    SurahAudioItem(number: 4, nameArabic: "النساء", englishName: "An-Nisa", versesCount: 176, isMakki: false, defaultDuration: "01:26:00", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/004.mp3"),
    SurahAudioItem(number: 5, nameArabic: "المائدة", englishName: "Al-Ma'idah", versesCount: 120, isMakki: false, defaultDuration: "01:04:12", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/005.mp3"),
    SurahAudioItem(number: 6, nameArabic: "الأنعام", englishName: "Al-An'am", versesCount: 165, isMakki: true, defaultDuration: "01:09:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/006.mp3"),
    SurahAudioItem(number: 7, nameArabic: "الأعراف", englishName: "Al-A'raf", versesCount: 206, isMakki: true, defaultDuration: "01:15:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/007.mp3"),
    SurahAudioItem(number: 8, nameArabic: "الأنفال", englishName: "Al-Anfal", versesCount: 75, isMakki: false, defaultDuration: "00:32:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/008.mp3"),
    SurahAudioItem(number: 9, nameArabic: "التوبة", englishName: "At-Tawbah", versesCount: 129, isMakki: false, defaultDuration: "00:58:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/009.mp3"),
    SurahAudioItem(number: 10, nameArabic: "يونس", englishName: "Yunus", versesCount: 109, isMakki: true, defaultDuration: "00:44:18", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/010.mp3"),
    SurahAudioItem(number: 11, nameArabic: "هود", englishName: "Hud", versesCount: 123, isMakki: true, defaultDuration: "00:51:00", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/011.mp3"),
    SurahAudioItem(number: 12, nameArabic: "يوسف", englishName: "Yusuf", versesCount: 111, isMakki: true, defaultDuration: "00:46:12", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/012.mp3"),
    SurahAudioItem(number: 13, nameArabic: "الرعد", englishName: "Ar-Ra'd", versesCount: 43, isMakki: false, defaultDuration: "00:23:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/013.mp3"),
    SurahAudioItem(number: 14, nameArabic: "إبراهيم", englishName: "Ibrahim", versesCount: 52, isMakki: true, defaultDuration: "00:24:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/014.mp3"),
    SurahAudioItem(number: 15, nameArabic: "الحجر", englishName: "Al-Hijr", versesCount: 99, isMakki: true, defaultDuration: "00:20:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/015.mp3"),
    SurahAudioItem(number: 16, nameArabic: "النحل", englishName: "An-Nahl", versesCount: 128, isMakki: true, defaultDuration: "00:45:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/016.mp3"),
    SurahAudioItem(number: 17, nameArabic: "الإسراء", englishName: "Al-Isra", versesCount: 111, isMakki: true, defaultDuration: "00:39:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/017.mp3"),
    SurahAudioItem(number: 18, nameArabic: "الكهف", englishName: "Al-Kahf", versesCount: 110, isMakki: true, defaultDuration: "00:38:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/018.mp3"),
    SurahAudioItem(number: 19, nameArabic: "مريم", englishName: "Maryam", versesCount: 98, isMakki: true, defaultDuration: "00:26:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/019.mp3"),
    SurahAudioItem(number: 20, nameArabic: "طه", englishName: "Ta-Ha", versesCount: 135, isMakki: true, defaultDuration: "00:30:12", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/020.mp3"),
    SurahAudioItem(number: 21, nameArabic: "الأنبياء", englishName: "Al-Anbiya", versesCount: 112, isMakki: true, defaultDuration: "00:28:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/021.mp3"),
    SurahAudioItem(number: 22, nameArabic: "الحج", englishName: "Al-Hajj", versesCount: 78, isMakki: false, defaultDuration: "00:32:00", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/022.mp3"),
    SurahAudioItem(number: 23, nameArabic: "المؤمنون", englishName: "Al-Mu'minun", versesCount: 118, isMakki: true, defaultDuration: "00:26:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/023.mp3"),
    SurahAudioItem(number: 24, nameArabic: "النور", englishName: "An-Nur", versesCount: 64, isMakki: false, defaultDuration: "00:33:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/024.mp3"),
    SurahAudioItem(number: 25, nameArabic: "الفرقان", englishName: "Al-Furqan", versesCount: 77, isMakki: true, defaultDuration: "00:22:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/025.mp3"),
    SurahAudioItem(number: 26, nameArabic: "الشعراء", englishName: "Ash-Shu'ara", versesCount: 227, isMakki: true, defaultDuration: "00:33:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/026.mp3"),
    SurahAudioItem(number: 27, nameArabic: "النمل", englishName: "An-Naml", versesCount: 93, isMakki: true, defaultDuration: "00:29:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/027.mp3"),
    SurahAudioItem(number: 28, nameArabic: "القصص", englishName: "Al-Qasas", versesCount: 88, isMakki: true, defaultDuration: "00:33:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/028.mp3"),
    SurahAudioItem(number: 29, nameArabic: "العنكبوت", englishName: "Al-'Ankabut", versesCount: 69, isMakki: true, defaultDuration: "00:24:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/029.mp3"),
    SurahAudioItem(number: 30, nameArabic: "الروم", englishName: "Ar-Rum", versesCount: 60, isMakki: true, defaultDuration: "00:20:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/030.mp3"),
    SurahAudioItem(number: 31, nameArabic: "لقمان", englishName: "Luqman", versesCount: 34, isMakki: true, defaultDuration: "00:14:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/031.mp3"),
    SurahAudioItem(number: 32, nameArabic: "السجدة", englishName: "As-Sajdah", versesCount: 30, isMakki: true, defaultDuration: "00:10:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/032.mp3"),
    SurahAudioItem(number: 33, nameArabic: "الأحزاب", englishName: "Al-Ahzab", versesCount: 73, isMakki: false, defaultDuration: "00:34:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/033.mp3"),
    SurahAudioItem(number: 34, nameArabic: "سبأ", englishName: "Saba", versesCount: 54, isMakki: true, defaultDuration: "00:21:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/034.mp3"),
    SurahAudioItem(number: 35, nameArabic: "فاطر", englishName: "Fatir", versesCount: 45, isMakki: true, defaultDuration: "00:19:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/035.mp3"),
    SurahAudioItem(number: 36, nameArabic: "يس", englishName: "Ya-Sin", versesCount: 83, isMakki: true, defaultDuration: "00:18:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/036.mp3"),
    SurahAudioItem(number: 37, nameArabic: "الصافات", englishName: "As-Saffat", versesCount: 182, isMakki: true, defaultDuration: "00:26:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/037.mp3"),
    SurahAudioItem(number: 38, nameArabic: "ص", englishName: "Sad", versesCount: 88, isMakki: true, defaultDuration: "00:18:25", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/038.mp3"),
    SurahAudioItem(number: 39, nameArabic: "الزمر", englishName: "Az-Zumar", versesCount: 75, isMakki: true, defaultDuration: "00:30:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/039.mp3"),
    SurahAudioItem(number: 40, nameArabic: "غافر", englishName: "Ghafir", versesCount: 85, isMakki: true, defaultDuration: "00:27:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/040.mp3"),
    SurahAudioItem(number: 41, nameArabic: "فصلت", englishName: "Fussilat", versesCount: 54, isMakki: true, defaultDuration: "00:20:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/041.mp3"),
    SurahAudioItem(number: 42, nameArabic: "الشورى", englishName: "Ash-Shura", versesCount: 53, isMakki: true, defaultDuration: "00:22:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/042.mp3"),
    SurahAudioItem(number: 43, nameArabic: "الزخرف", englishName: "Az-Zukhruf", versesCount: 89, isMakki: true, defaultDuration: "00:24:35", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/043.mp3"),
    SurahAudioItem(number: 44, nameArabic: "الدخان", englishName: "Ad-Dukhan", versesCount: 59, isMakki: true, defaultDuration: "00:09:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/044.mp3"),
    SurahAudioItem(number: 45, nameArabic: "الجاثية", englishName: "Al-Jathiyah", versesCount: 37, isMakki: true, defaultDuration: "00:12:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/045.mp3"),
    SurahAudioItem(number: 46, nameArabic: "الأحقاف", englishName: "Al-Ahqaf", versesCount: 35, isMakki: true, defaultDuration: "00:16:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/046.mp3"),
    SurahAudioItem(number: 47, nameArabic: "محمد", englishName: "Muhammad", versesCount: 38, isMakki: false, defaultDuration: "00:14:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/047.mp3"),
    SurahAudioItem(number: 48, nameArabic: "الفتح", englishName: "Al-Fath", versesCount: 29, isMakki: false, defaultDuration: "00:15:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/048.mp3"),
    SurahAudioItem(number: 49, nameArabic: "الحجرات", englishName: "Al-Hujurat", versesCount: 18, isMakki: false, defaultDuration: "00:09:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/049.mp3"),
    SurahAudioItem(number: 50, nameArabic: "ق", englishName: "Qaf", versesCount: 45, isMakki: true, defaultDuration: "00:10:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/050.mp3"),
    SurahAudioItem(number: 51, nameArabic: "الذاريات", englishName: "Adh-Dhariyat", versesCount: 60, isMakki: true, defaultDuration: "00:09:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/051.mp3"),
    SurahAudioItem(number: 52, nameArabic: "الطور", englishName: "At-Tur", versesCount: 49, isMakki: true, defaultDuration: "00:08:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/052.mp3"),
    SurahAudioItem(number: 53, nameArabic: "النجم", englishName: "An-Najm", versesCount: 62, isMakki: true, defaultDuration: "00:08:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/053.mp3"),
    SurahAudioItem(number: 54, nameArabic: "القمر", englishName: "Al-Qamar", versesCount: 55, isMakki: true, defaultDuration: "00:09:00", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/054.mp3"),
    SurahAudioItem(number: 55, nameArabic: "الرحمن", englishName: "Ar-Rahman", versesCount: 78, isMakki: false, defaultDuration: "00:13:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/055.mp3"),
    SurahAudioItem(number: 56, nameArabic: "الواقعة", englishName: "Al-Waqi'ah", versesCount: 96, isMakki: true, defaultDuration: "00:12:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/056.mp3"),
    SurahAudioItem(number: 57, nameArabic: "الحديد", englishName: "Al-Hadid", versesCount: 29, isMakki: false, defaultDuration: "00:15:35", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/057.mp3"),
    SurahAudioItem(number: 58, nameArabic: "المجادلة", englishName: "Al-Mujadila", versesCount: 22, isMakki: false, defaultDuration: "00:11:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/058.mp3"),
    SurahAudioItem(number: 59, nameArabic: "الحشر", englishName: "Al-Hashr", versesCount: 24, isMakki: false, defaultDuration: "00:12:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/059.mp3"),
    SurahAudioItem(number: 60, nameArabic: "الممتحنة", englishName: "Al-Mumtahanah", versesCount: 13, isMakki: false, defaultDuration: "00:09:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/060.mp3"),
    SurahAudioItem(number: 61, nameArabic: "الصف", englishName: "As-Saf", versesCount: 14, isMakki: false, defaultDuration: "00:06:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/061.mp3"),
    SurahAudioItem(number: 62, nameArabic: "الجمعة", englishName: "Al-Jumu'ah", versesCount: 11, isMakki: false, defaultDuration: "00:05:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/062.mp3"),
    SurahAudioItem(number: 63, nameArabic: "المنافقون", englishName: "Al-Munafiqun", versesCount: 11, isMakki: false, defaultDuration: "00:05:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/063.mp3"),
    SurahAudioItem(number: 64, nameArabic: "التغابن", englishName: "At-Taghabun", versesCount: 18, isMakki: false, defaultDuration: "00:07:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/064.mp3"),
    SurahAudioItem(number: 65, nameArabic: "الطلاق", englishName: "At-Talaq", versesCount: 12, isMakki: false, defaultDuration: "00:07:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/065.mp3"),
    SurahAudioItem(number: 66, nameArabic: "التحريم", englishName: "At-Tahrim", versesCount: 12, isMakki: false, defaultDuration: "00:07:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/066.mp3"),
    SurahAudioItem(number: 67, nameArabic: "الملك", englishName: "Al-Mulk", versesCount: 30, isMakki: true, defaultDuration: "00:08:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/067.mp3"),
    SurahAudioItem(number: 68, nameArabic: "القلم", englishName: "Al-Qalam", versesCount: 52, isMakki: true, defaultDuration: "00:09:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/068.mp3"),
    SurahAudioItem(number: 69, nameArabic: "الحاقة", englishName: "Al-Haqqah", versesCount: 52, isMakki: true, defaultDuration: "00:08:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/069.mp3"),
    SurahAudioItem(number: 70, nameArabic: "المعارج", englishName: "Al-Ma'arij", versesCount: 44, isMakki: true, defaultDuration: "00:06:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/070.mp3"),
    SurahAudioItem(number: 71, nameArabic: "نوح", englishName: "Nuh", versesCount: 28, isMakki: true, defaultDuration: "00:05:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/071.mp3"),
    SurahAudioItem(number: 72, nameArabic: "الجن", englishName: "Al-Jinn", versesCount: 28, isMakki: true, defaultDuration: "00:07:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/072.mp3"),
    SurahAudioItem(number: 73, nameArabic: "المزمل", englishName: "Al-Muzzammil", versesCount: 20, isMakki: true, defaultDuration: "00:05:55", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/073.mp3"),
    SurahAudioItem(number: 74, nameArabic: "المدثر", englishName: "Al-Muddaththir", versesCount: 56, isMakki: true, defaultDuration: "00:07:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/074.mp3"),
    SurahAudioItem(number: 75, nameArabic: "القيامة", englishName: "Al-Qiyamah", versesCount: 40, isMakki: true, defaultDuration: "00:04:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/075.mp3"),
    SurahAudioItem(number: 76, nameArabic: "الإنسان", englishName: "Al-Insan", versesCount: 31, isMakki: false, defaultDuration: "00:07:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/076.mp3"),
    SurahAudioItem(number: 77, nameArabic: "المرسلات", englishName: "Al-Mursalat", versesCount: 50, isMakki: true, defaultDuration: "00:06:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/077.mp3"),
    SurahAudioItem(number: 78, nameArabic: "النبأ", englishName: "An-Naba", versesCount: 40, isMakki: true, defaultDuration: "00:05:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/078.mp3"),
    SurahAudioItem(number: 79, nameArabic: "النازعات", englishName: "An-Nazi'at", versesCount: 46, isMakki: true, defaultDuration: "00:05:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/079.mp3"),
    SurahAudioItem(number: 80, nameArabic: "عبس", englishName: "'Abasa", versesCount: 42, isMakki: true, defaultDuration: "00:04:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/080.mp3"),
    SurahAudioItem(number: 81, nameArabic: "التكوير", englishName: "At-Takwir", versesCount: 29, isMakki: true, defaultDuration: "00:03:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/081.mp3"),
    SurahAudioItem(number: 82, nameArabic: "الانفطار", englishName: "Al-Infitar", versesCount: 19, isMakki: true, defaultDuration: "00:02:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/082.mp3"),
    SurahAudioItem(number: 83, nameArabic: "المطففين", englishName: "Al-Mutaffifin", versesCount: 36, isMakki: true, defaultDuration: "00:05:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/083.mp3"),
    SurahAudioItem(number: 84, nameArabic: "الانشقاق", englishName: "Al-Inshiqaq", versesCount: 25, isMakki: true, defaultDuration: "00:03:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/084.mp3"),
    SurahAudioItem(number: 85, nameArabic: "البروج", englishName: "Al-Buruj", versesCount: 22, isMakki: true, defaultDuration: "00:03:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/085.mp3"),
    SurahAudioItem(number: 86, nameArabic: "الطارق", englishName: "At-Tariq", versesCount: 17, isMakki: true, defaultDuration: "00:02:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/086.mp3"),
    SurahAudioItem(number: 87, nameArabic: "الأعلى", englishName: "Al-A'la", versesCount: 19, isMakki: true, defaultDuration: "00:02:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/087.mp3"),
    SurahAudioItem(number: 88, nameArabic: "الغاشية", englishName: "Al-Ghashiyah", versesCount: 26, isMakki: true, defaultDuration: "00:03:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/088.mp3"),
    SurahAudioItem(number: 89, nameArabic: "الفجر", englishName: "Al-Fajr", versesCount: 30, isMakki: true, defaultDuration: "00:04:30", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/089.mp3"),
    SurahAudioItem(number: 90, nameArabic: "البلد", englishName: "Al-Balad", versesCount: 20, isMakki: true, defaultDuration: "00:02:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/090.mp3"),
    SurahAudioItem(number: 91, nameArabic: "الشمس", englishName: "Ash-Shams", versesCount: 15, isMakki: true, defaultDuration: "00:01:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/091.mp3"),
    SurahAudioItem(number: 92, nameArabic: "الليل", englishName: "Al-Layl", versesCount: 21, isMakki: true, defaultDuration: "00:02:25", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/092.mp3"),
    SurahAudioItem(number: 93, nameArabic: "الضحى", englishName: "Ad-Duha", versesCount: 11, isMakki: true, defaultDuration: "00:01:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/093.mp3"),
    SurahAudioItem(number: 94, nameArabic: "الشرح", englishName: "Ash-Sharh", versesCount: 8, isMakki: true, defaultDuration: "00:00:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/094.mp3"),
    SurahAudioItem(number: 95, nameArabic: "التين", englishName: "At-Tin", versesCount: 8, isMakki: true, defaultDuration: "00:01:05", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/095.mp3"),
    SurahAudioItem(number: 96, nameArabic: "العلق", englishName: "Al-'Alaq", versesCount: 19, isMakki: true, defaultDuration: "00:02:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/096.mp3"),
    SurahAudioItem(number: 97, nameArabic: "القدر", englishName: "Al-Qadr", versesCount: 5, isMakki: true, defaultDuration: "00:00:55", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/097.mp3"),
    SurahAudioItem(number: 98, nameArabic: "البينة", englishName: "Al-Bayyinah", versesCount: 8, isMakki: false, defaultDuration: "00:02:20", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/098.mp3"),
    SurahAudioItem(number: 99, nameArabic: "الزلزلة", englishName: "Az-Zalzalah", versesCount: 8, isMakki: false, defaultDuration: "00:01:10", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/099.mp3"),
    SurahAudioItem(number: 100, nameArabic: "العاديات", englishName: "Al-'Adiyat", versesCount: 11, isMakki: true, defaultDuration: "00:01:15", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/100.mp3"),
    SurahAudioItem(number: 101, nameArabic: "القارعة", englishName: "Al-Qari'ah", versesCount: 11, isMakki: true, defaultDuration: "00:01:08", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/101.mp3"),
    SurahAudioItem(number: 102, nameArabic: "التكاثر", englishName: "At-Takathur", versesCount: 8, isMakki: true, defaultDuration: "00:01:00", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/102.mp3"),
    SurahAudioItem(number: 103, nameArabic: "العصر", englishName: "Al-'Asr", versesCount: 3, isMakki: true, defaultDuration: "00:00:35", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/103.mp3"),
    SurahAudioItem(number: 104, nameArabic: "الهمزة", englishName: "Al-Humazah", versesCount: 9, isMakki: true, defaultDuration: "00:00:58", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/104.mp3"),
    SurahAudioItem(number: 105, nameArabic: "الفيل", englishName: "Al-Fil", versesCount: 5, isMakki: true, defaultDuration: "00:00:45", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/105.mp3"),
    SurahAudioItem(number: 106, nameArabic: "قريش", englishName: "Quraysh", versesCount: 4, isMakki: true, defaultDuration: "00:00:40", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/106.mp3"),
    SurahAudioItem(number: 107, nameArabic: "الماعون", englishName: "Al-Ma'un", versesCount: 7, isMakki: true, defaultDuration: "00:00:50", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/107.mp3"),
    SurahAudioItem(number: 108, nameArabic: "الكوثر", englishName: "Al-Kawthar", versesCount: 3, isMakki: true, defaultDuration: "00:00:18", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/108.mp3"),
    SurahAudioItem(number: 109, nameArabic: "الكافرون", englishName: "Al-Kafirun", versesCount: 6, isMakki: true, defaultDuration: "00:00:48", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/109.mp3"),
    SurahAudioItem(number: 110, nameArabic: "النصر", englishName: "An-Nasr", versesCount: 3, isMakki: false, defaultDuration: "00:00:26", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/110.mp3"),
    SurahAudioItem(number: 111, nameArabic: "المسد", englishName: "Al-Masad", versesCount: 5, isMakki: true, defaultDuration: "00:00:36", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/111.mp3"),
    SurahAudioItem(number: 112, nameArabic: "الإخلاص", englishName: "Al-Ikhlas", versesCount: 4, isMakki: true, defaultDuration: "00:00:16", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/112.mp3"),
    SurahAudioItem(number: 113, nameArabic: "الفلق", englishName: "Al-Falaq", versesCount: 5, isMakki: true, defaultDuration: "00:00:28", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/113.mp3"),
    SurahAudioItem(number: 114, nameArabic: "الناس", englishName: "An-Nas", versesCount: 6, isMakki: true, defaultDuration: "00:00:55", audioUrl: "https://cdn.mp3quran.net/audio/nasser-qatami/r1/114.mp3"),
  ];

  static const List<RuqyahAudioItem> allRuqyah = [
    RuqyahAudioItem(
      id: 'ruqyah_sakina',
      title: 'رقية السكينة وطمأنينة القلب',
      reciter: 'الشيخ مشاري راشد العفاسي',
      duration: '72:50',
      purpose: 'تفريج الهم والحزن وعلاج نوبات القلق والأرق قبل النوم',
      description: 'آيات السكينة الست في القرآن الكريم مع أدعية الحفظ والشفاء بصوت خاشع ومريح — متاحة للتحميل عند الطلب أو البث المباشر.',
      streamUrl: 'https://archive.org/download/roqya-shar2ya_mp3/afasy.mp3',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_mass',
      title: 'الرقية الشرعية الشاملة للحفظ والطرد',
      reciter: 'الشيخ سعد الغامدي',
      duration: '62:34',
      purpose: 'طرد الوساوس والتخبط الليلي وحفظ النفس والبيت بإذن الله',
      description: 'تلاوة كاملة للرقية الشرعية الثابتة في الكتاب والسنة — متاحة للتحميل عند الطلب أو البث المباشر.',
      streamUrl: 'https://archive.org/download/roqya-shar2ya_mp3/saad.mp3',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_shifa',
      title: 'رقية الشفاء والعافية من كل داء',
      reciter: 'الشيخ أحمد العجمي',
      duration: '62:32',
      purpose: 'الاستشفاء بآيات الشفاء الست والأدعية النبوية للمريض',
      description: 'تلاوة خاشعة مؤثرة لآيات الشفاء والعافية في القرآن الكريم — متاحة للتحميل عند الطلب أو البث المباشر.',
      streamUrl: 'https://archive.org/download/roqya-shar2ya_mp3/ajmee.mp3',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_ayn',
      title: 'رقية العين والحسد والضيق',
      reciter: 'الشيخ إدريس أبكر',
      duration: '33:45',
      purpose: 'علاج العين والحسد وانشراح الصدر بإذن الله تعالى',
      description: 'آيات إبطال العين والحسد متبوعة بأدعية نبوية مأثورة للشفاء وراحة الصدر.',
      streamUrl: 'https://archive.org/download/roqya-shar2ya_mp3/33Abkar.mp3',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_sihr',
      title: 'رقية إبطال السحر وفك العقد',
      reciter: 'الشيخ ماهر المعيقلي',
      duration: '39:44',
      purpose: 'إبطال الأسحار وفك العقد بالقرآن الكريم من الحرم المكي',
      description: 'تلاوة قوية لآيات السحر من سور البقرة والأعراف ويونس وطه مصحوبة بأدعية التعويذ.',
      streamUrl: 'https://archive.org/download/roqya-shar2ya_mp3/3939maher.mp3',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_children',
      title: 'رقية الحسد وتحصين الأطفال والمنزل',
      reciter: 'الشيخ ياسر الدوسري',
      duration: '19:50',
      purpose: 'حفظ الصغار والبيوت من الفزع وبكاء الليل والحسد',
      description: 'أعيذكم بكلمات الله التامة من كل شيطان وهامة ومن كل عين لامة مع المعوذتين والفاتحة.',
      streamUrl: 'https://archive.org/download/dosari-Roqia/dosari-hasd.mp3',
    ),
  ];

  static const List<IbtihalAudioItem> allIbtihalat = [
    IbtihalAudioItem(
      id: 'ibtihal_toobar_1',
      title: 'نادى المنادي يا من له عنت الوجوه',
      reciter: 'الشيخ نصر الدين طوبار',
      duration: '08:15',
      maqam: 'مقام البياتي والصبا',
      streamUrl: 'https://archive.org/download/Tawashih/Almonady.mp3',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_naqsh_1',
      title: 'مولاي إني ببابك قد بسطت يدي',
      reciter: 'الشيخ سيد النقشبندي',
      duration: '06:17',
      maqam: 'مقام الرست والحجاز',
      streamUrl: 'https://archive.org/download/20240309_20240309_1714/008%20%20%D9%85%D9%88%D9%84%D8%A7%D9%8A%20%D8%A5%D9%86%D9%8A%20%D8%A8%D8%A8%D8%A7%D8%A8%D9%83%20%D9%82%D8%AF%20%D8%A8%D8%B3%D8%B7%D8%AA%20%D9%8A%D8%AF%D9%8A%20%20%20%D9%84%D9%84%D8%B4%D9%8A%D8%AE%20%D8%A7%D9%84%D9%86%D9%82%D8%B4%D8%A8%D9%86%D8%AF%D9%89.mp3',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_naqsh_yarab',
      title: 'يا رب إن عظمت ذنوبي كثرة',
      reciter: 'الشيخ سيد النقشبندي',
      duration: '03:08',
      maqam: 'مقام النهاوند والخشوع',
      streamUrl: 'https://archive.org/download/20240309_20240309_1714/004%20%20%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D8%B3%D9%8A%D8%AF%20%D8%A7%D9%84%D9%86%D9%82%D8%B4%D8%A8%D9%86%D8%AF%D9%89%2C%20%D9%8A%D8%A7%20%D8%B1%D8%A8%20%D8%A7%D9%86%20%D8%B9%D8%B8%D9%85%D8%AA%20%D8%B0%D9%86%D9%88%D8%A8%D9%89%20%D9%83%D8%AB%D8%B1%D8%A9.mp3',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_dua_sudais',
      title: 'دعاء القنوت الباكي وتفريج الكروب',
      reciter: 'الشيخ عبد الرحمن السديس',
      duration: '06:52',
      maqam: 'الحرم المكي الشريف',
      streamUrl: 'https://archive.org/download/Dua-e-qunootFromMakkahOn11thNightOfRamadaan/Night11-Dua-e-Qunoot_Shaikh_Sudais_64kb.mp3',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_khatm_quran',
      title: 'دعاء ختم القرآن العظيم من الحرم النبوي',
      reciter: 'الشيخ علي الحذيفي',
      duration: '24:25',
      maqam: 'تضرع وخشوع نبوي',
      streamUrl: 'https://archive.org/download/mp3-____------alhozifi---alharam---alnabawy---do3aa----traweeh----khatm---qura/171435.mp3',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_wled_hoda',
      title: 'ولد الهدى فالكائنات ضياء',
      reciter: 'تواشيح وابتهالات دينية',
      duration: '04:55',
      maqam: 'مقام الكرد الروحي',
      streamUrl: 'https://archive.org/download/Tawashih/04.mp3',
    ),
  ];

  static const List<ParadiseBirdsongItem> paradiseBirdsongTracks = [
    ParadiseBirdsongItem(
      id: 'birds_paradise',
      title: 'تغريد عصافير الفردوس مع خَرِير الأنهار 🐦🌊',
      subtitle: 'صوت طبيعي هادئ يعمل مباشرة بدون إنترنت',
      localAsset: 'audio/birds_paradise.wav',
    ),
    ParadiseBirdsongItem(
      id: 'birds_forest',
      title: 'أنس بلابل الحدائق الغنّاء 🌿🎶',
      subtitle: 'نغمات طيور نقية مدمجة بدون إنترنت',
      localAsset: 'audio/birds_forest.wav',
    ),
    ParadiseBirdsongItem(
      id: 'birds_dawn_brook',
      title: 'فجر البستان وتسابيح الطيور الصباحية 🌅🕊️',
      subtitle: 'بث طبيعة هادئ للاستجمام والخشوع (مع بديل أوفلاين)',
      localAsset: 'audio/birds_paradise.wav',
      streamUrl: 'https://archive.org/download/birds_singing_202104/birds_singing.mp3',
    ),
    ParadiseBirdsongItem(
      id: 'birds_rain_garden',
      title: 'زخات المطر في رياض الجنة وزقزقة العصافير 🌧️🌴',
      subtitle: 'سكينة وهدوء نفسي عميق للتأمل والذكر',
      localAsset: 'audio/birds_forest.wav',
      streamUrl: 'https://archive.org/download/relaxing-nature-sounds/Forest%20Birds.mp3',
    ),
  ];

  static ParadiseBirdsongItem getBirdsongById(String id) {
    return paradiseBirdsongTracks.firstWhere(
      (t) => t.id == id,
      orElse: () => paradiseBirdsongTracks.first,
    );
  }
}
