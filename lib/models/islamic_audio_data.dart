class ReciterInfo {
  final String id;
  final String name;
  final String country;
  final String riwayah;

  const ReciterInfo({
    required this.id,
    required this.name,
    required this.country,
    required this.riwayah,
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

  const RuqyahAudioItem({
    required this.id,
    required this.title,
    required this.reciter,
    required this.duration,
    required this.purpose,
    required this.description,
  });
}

class IbtihalAudioItem {
  final String id;
  final String title;
  final String reciter;
  final String duration;
  final String maqam;

  const IbtihalAudioItem({
    required this.id,
    required this.title,
    required this.reciter,
    required this.duration,
    required this.maqam,
  });
}

class IslamicAudioLibrary {
  static const List<ReciterInfo> reciters = [
    ReciterInfo(
      id: 'qatami',
      name: 'الشيخ ناصر القطامي',
      country: 'المملكة العربية السعودية',
      riwayah: 'حفص عن عاصم',
    ),
    ReciterInfo(
      id: 'afasy',
      name: 'الشيخ مشاري راشد العفاسي',
      country: 'الكويت',
      riwayah: 'حفص عن عاصم',
    ),
    ReciterInfo(
      id: 'abdulbasit',
      name: 'الشيخ عبد الباسط عبد الصمد',
      country: 'مصر',
      riwayah: 'المصحف المجود والمرتل',
    ),
    ReciterInfo(
      id: 'minshawi',
      name: 'الشيخ محمد صديق المنشاوي',
      country: 'مصر',
      riwayah: 'حفص عن عاصم',
    ),
    ReciterInfo(
      id: 'maher',
      name: 'الشيخ ماهر المعيقلي',
      country: 'المملكة العربية السعودية - إمام الحرم',
      riwayah: 'حفص عن عاصم',
    ),
    ReciterInfo(
      id: 'ghamdi',
      name: 'الشيخ سعد الغامدي',
      country: 'المملكة العربية السعودية',
      riwayah: 'حفص عن عاصم',
    ),
  ];

  static const List<SurahAudioItem> allSurahs = [
    SurahAudioItem(number: 1, nameArabic: "الفاتحة", englishName: "Al-Fatihah", versesCount: 7, isMakki: true, defaultDuration: "00:54", audioUrl: "https://server8.mp3quran.net/afs/001.mp3"),
    SurahAudioItem(number: 2, nameArabic: "البقرة", englishName: "Al-Baqarah", versesCount: 286, isMakki: false, defaultDuration: "02:14:15", audioUrl: "https://server8.mp3quran.net/afs/002.mp3"),
    SurahAudioItem(number: 3, nameArabic: "آل عمران", englishName: "Ali 'Imran", versesCount: 200, isMakki: false, defaultDuration: "01:21:40", audioUrl: "https://server8.mp3quran.net/afs/003.mp3"),
    SurahAudioItem(number: 4, nameArabic: "النساء", englishName: "An-Nisa", versesCount: 176, isMakki: false, defaultDuration: "01:26:00", audioUrl: "https://server8.mp3quran.net/afs/004.mp3"),
    SurahAudioItem(number: 5, nameArabic: "المائدة", englishName: "Al-Ma'idah", versesCount: 120, isMakki: false, defaultDuration: "01:04:12", audioUrl: "https://server8.mp3quran.net/afs/005.mp3"),
    SurahAudioItem(number: 6, nameArabic: "الأنعام", englishName: "Al-An'am", versesCount: 165, isMakki: true, defaultDuration: "01:09:50", audioUrl: "https://server8.mp3quran.net/afs/006.mp3"),
    SurahAudioItem(number: 7, nameArabic: "الأعراف", englishName: "Al-A'raf", versesCount: 206, isMakki: true, defaultDuration: "01:15:20", audioUrl: "https://server8.mp3quran.net/afs/007.mp3"),
    SurahAudioItem(number: 8, nameArabic: "الأنفال", englishName: "Al-Anfal", versesCount: 75, isMakki: false, defaultDuration: "00:32:10", audioUrl: "https://server8.mp3quran.net/afs/008.mp3"),
    SurahAudioItem(number: 9, nameArabic: "التوبة", englishName: "At-Tawbah", versesCount: 129, isMakki: false, defaultDuration: "00:58:30", audioUrl: "https://server8.mp3quran.net/afs/009.mp3"),
    SurahAudioItem(number: 10, nameArabic: "يونس", englishName: "Yunus", versesCount: 109, isMakki: true, defaultDuration: "00:44:18", audioUrl: "https://server8.mp3quran.net/afs/010.mp3"),
    SurahAudioItem(number: 11, nameArabic: "هود", englishName: "Hud", versesCount: 123, isMakki: true, defaultDuration: "00:51:00", audioUrl: "https://server8.mp3quran.net/afs/011.mp3"),
    SurahAudioItem(number: 12, nameArabic: "يوسف", englishName: "Yusuf", versesCount: 111, isMakki: true, defaultDuration: "00:46:12", audioUrl: "https://server8.mp3quran.net/afs/012.mp3"),
    SurahAudioItem(number: 13, nameArabic: "الرعد", englishName: "Ar-Ra'd", versesCount: 43, isMakki: false, defaultDuration: "00:23:45", audioUrl: "https://server8.mp3quran.net/afs/013.mp3"),
    SurahAudioItem(number: 14, nameArabic: "إبراهيم", englishName: "Ibrahim", versesCount: 52, isMakki: true, defaultDuration: "00:24:10", audioUrl: "https://server8.mp3quran.net/afs/014.mp3"),
    SurahAudioItem(number: 15, nameArabic: "الحجر", englishName: "Al-Hijr", versesCount: 99, isMakki: true, defaultDuration: "00:20:15", audioUrl: "https://server8.mp3quran.net/afs/015.mp3"),
    SurahAudioItem(number: 16, nameArabic: "النحل", englishName: "An-Nahl", versesCount: 128, isMakki: true, defaultDuration: "00:45:30", audioUrl: "https://server8.mp3quran.net/afs/016.mp3"),
    SurahAudioItem(number: 17, nameArabic: "الإسراء", englishName: "Al-Isra", versesCount: 111, isMakki: true, defaultDuration: "00:39:40", audioUrl: "https://server8.mp3quran.net/afs/017.mp3"),
    SurahAudioItem(number: 18, nameArabic: "الكهف", englishName: "Al-Kahf", versesCount: 110, isMakki: true, defaultDuration: "00:38:15", audioUrl: "https://server8.mp3quran.net/afs/018.mp3"),
    SurahAudioItem(number: 19, nameArabic: "مريم", englishName: "Maryam", versesCount: 98, isMakki: true, defaultDuration: "00:26:50", audioUrl: "https://server8.mp3quran.net/afs/019.mp3"),
    SurahAudioItem(number: 20, nameArabic: "طه", englishName: "Ta-Ha", versesCount: 135, isMakki: true, defaultDuration: "00:30:12", audioUrl: "https://server8.mp3quran.net/afs/020.mp3"),
    SurahAudioItem(number: 21, nameArabic: "الأنبياء", englishName: "Al-Anbiya", versesCount: 112, isMakki: true, defaultDuration: "00:28:40", audioUrl: "https://server8.mp3quran.net/afs/021.mp3"),
    SurahAudioItem(number: 22, nameArabic: "الحج", englishName: "Al-Hajj", versesCount: 78, isMakki: false, defaultDuration: "00:32:00", audioUrl: "https://server8.mp3quran.net/afs/022.mp3"),
    SurahAudioItem(number: 23, nameArabic: "المؤمنون", englishName: "Al-Mu'minun", versesCount: 118, isMakki: true, defaultDuration: "00:26:15", audioUrl: "https://server8.mp3quran.net/afs/023.mp3"),
    SurahAudioItem(number: 24, nameArabic: "النور", englishName: "An-Nur", versesCount: 64, isMakki: false, defaultDuration: "00:33:10", audioUrl: "https://server8.mp3quran.net/afs/024.mp3"),
    SurahAudioItem(number: 25, nameArabic: "الفرقان", englishName: "Al-Furqan", versesCount: 77, isMakki: true, defaultDuration: "00:22:30", audioUrl: "https://server8.mp3quran.net/afs/025.mp3"),
    SurahAudioItem(number: 26, nameArabic: "الشعراء", englishName: "Ash-Shu'ara", versesCount: 227, isMakki: true, defaultDuration: "00:33:50", audioUrl: "https://server8.mp3quran.net/afs/026.mp3"),
    SurahAudioItem(number: 27, nameArabic: "النمل", englishName: "An-Naml", versesCount: 93, isMakki: true, defaultDuration: "00:29:40", audioUrl: "https://server8.mp3quran.net/afs/027.mp3"),
    SurahAudioItem(number: 28, nameArabic: "القصص", englishName: "Al-Qasas", versesCount: 88, isMakki: true, defaultDuration: "00:33:15", audioUrl: "https://server8.mp3quran.net/afs/028.mp3"),
    SurahAudioItem(number: 29, nameArabic: "العنكبوت", englishName: "Al-'Ankabut", versesCount: 69, isMakki: true, defaultDuration: "00:24:20", audioUrl: "https://server8.mp3quran.net/afs/029.mp3"),
    SurahAudioItem(number: 30, nameArabic: "الروم", englishName: "Ar-Rum", versesCount: 60, isMakki: true, defaultDuration: "00:20:10", audioUrl: "https://server8.mp3quran.net/afs/030.mp3"),
    SurahAudioItem(number: 31, nameArabic: "لقمان", englishName: "Luqman", versesCount: 34, isMakki: true, defaultDuration: "00:14:45", audioUrl: "https://server8.mp3quran.net/afs/031.mp3"),
    SurahAudioItem(number: 32, nameArabic: "السجدة", englishName: "As-Sajdah", versesCount: 30, isMakki: true, defaultDuration: "00:10:30", audioUrl: "https://server8.mp3quran.net/afs/032.mp3"),
    SurahAudioItem(number: 33, nameArabic: "الأحزاب", englishName: "Al-Ahzab", versesCount: 73, isMakki: false, defaultDuration: "00:34:20", audioUrl: "https://server8.mp3quran.net/afs/033.mp3"),
    SurahAudioItem(number: 34, nameArabic: "سبأ", englishName: "Saba", versesCount: 54, isMakki: true, defaultDuration: "00:21:40", audioUrl: "https://server8.mp3quran.net/afs/034.mp3"),
    SurahAudioItem(number: 35, nameArabic: "فاطر", englishName: "Fatir", versesCount: 45, isMakki: true, defaultDuration: "00:19:15", audioUrl: "https://server8.mp3quran.net/afs/035.mp3"),
    SurahAudioItem(number: 36, nameArabic: "يس", englishName: "Ya-Sin", versesCount: 83, isMakki: true, defaultDuration: "00:18:40", audioUrl: "https://server8.mp3quran.net/afs/036.mp3"),
    SurahAudioItem(number: 37, nameArabic: "الصافات", englishName: "As-Saffat", versesCount: 182, isMakki: true, defaultDuration: "00:26:10", audioUrl: "https://server8.mp3quran.net/afs/037.mp3"),
    SurahAudioItem(number: 38, nameArabic: "ص", englishName: "Sad", versesCount: 88, isMakki: true, defaultDuration: "00:18:25", audioUrl: "https://server8.mp3quran.net/afs/038.mp3"),
    SurahAudioItem(number: 39, nameArabic: "الزمر", englishName: "Az-Zumar", versesCount: 75, isMakki: true, defaultDuration: "00:30:15", audioUrl: "https://server8.mp3quran.net/afs/039.mp3"),
    SurahAudioItem(number: 40, nameArabic: "غافر", englishName: "Ghafir", versesCount: 85, isMakki: true, defaultDuration: "00:27:50", audioUrl: "https://server8.mp3quran.net/afs/040.mp3"),
    SurahAudioItem(number: 41, nameArabic: "فصلت", englishName: "Fussilat", versesCount: 54, isMakki: true, defaultDuration: "00:20:45", audioUrl: "https://server8.mp3quran.net/afs/041.mp3"),
    SurahAudioItem(number: 42, nameArabic: "الشورى", englishName: "Ash-Shura", versesCount: 53, isMakki: true, defaultDuration: "00:22:10", audioUrl: "https://server8.mp3quran.net/afs/042.mp3"),
    SurahAudioItem(number: 43, nameArabic: "الزخرف", englishName: "Az-Zukhruf", versesCount: 89, isMakki: true, defaultDuration: "00:24:35", audioUrl: "https://server8.mp3quran.net/afs/043.mp3"),
    SurahAudioItem(number: 44, nameArabic: "الدخان", englishName: "Ad-Dukhan", versesCount: 59, isMakki: true, defaultDuration: "00:09:50", audioUrl: "https://server8.mp3quran.net/afs/044.mp3"),
    SurahAudioItem(number: 45, nameArabic: "الجاثية", englishName: "Al-Jathiyah", versesCount: 37, isMakki: true, defaultDuration: "00:12:40", audioUrl: "https://server8.mp3quran.net/afs/045.mp3"),
    SurahAudioItem(number: 46, nameArabic: "الأحقاف", englishName: "Al-Ahqaf", versesCount: 35, isMakki: true, defaultDuration: "00:16:30", audioUrl: "https://server8.mp3quran.net/afs/046.mp3"),
    SurahAudioItem(number: 47, nameArabic: "محمد", englishName: "Muhammad", versesCount: 38, isMakki: false, defaultDuration: "00:14:15", audioUrl: "https://server8.mp3quran.net/afs/047.mp3"),
    SurahAudioItem(number: 48, nameArabic: "الفتح", englishName: "Al-Fath", versesCount: 29, isMakki: false, defaultDuration: "00:15:20", audioUrl: "https://server8.mp3quran.net/afs/048.mp3"),
    SurahAudioItem(number: 49, nameArabic: "الحجرات", englishName: "Al-Hujurat", versesCount: 18, isMakki: false, defaultDuration: "00:09:40", audioUrl: "https://server8.mp3quran.net/afs/049.mp3"),
    SurahAudioItem(number: 50, nameArabic: "ق", englishName: "Qaf", versesCount: 45, isMakki: true, defaultDuration: "00:10:50", audioUrl: "https://server8.mp3quran.net/afs/050.mp3"),
    SurahAudioItem(number: 51, nameArabic: "الذاريات", englishName: "Adh-Dhariyat", versesCount: 60, isMakki: true, defaultDuration: "00:09:30", audioUrl: "https://server8.mp3quran.net/afs/051.mp3"),
    SurahAudioItem(number: 52, nameArabic: "الطور", englishName: "At-Tur", versesCount: 49, isMakki: true, defaultDuration: "00:08:45", audioUrl: "https://server8.mp3quran.net/afs/052.mp3"),
    SurahAudioItem(number: 53, nameArabic: "النجم", englishName: "An-Najm", versesCount: 62, isMakki: true, defaultDuration: "00:08:10", audioUrl: "https://server8.mp3quran.net/afs/053.mp3"),
    SurahAudioItem(number: 54, nameArabic: "القمر", englishName: "Al-Qamar", versesCount: 55, isMakki: true, defaultDuration: "00:09:00", audioUrl: "https://server8.mp3quran.net/afs/054.mp3"),
    SurahAudioItem(number: 55, nameArabic: "الرحمن", englishName: "Ar-Rahman", versesCount: 78, isMakki: false, defaultDuration: "00:13:20", audioUrl: "https://server8.mp3quran.net/afs/055.mp3"),
    SurahAudioItem(number: 56, nameArabic: "الواقعة", englishName: "Al-Waqi'ah", versesCount: 96, isMakki: true, defaultDuration: "00:12:40", audioUrl: "https://server8.mp3quran.net/afs/056.mp3"),
    SurahAudioItem(number: 57, nameArabic: "الحديد", englishName: "Al-Hadid", versesCount: 29, isMakki: false, defaultDuration: "00:15:35", audioUrl: "https://server8.mp3quran.net/afs/057.mp3"),
    SurahAudioItem(number: 58, nameArabic: "المجادلة", englishName: "Al-Mujadila", versesCount: 22, isMakki: false, defaultDuration: "00:11:50", audioUrl: "https://server8.mp3quran.net/afs/058.mp3"),
    SurahAudioItem(number: 59, nameArabic: "الحشر", englishName: "Al-Hashr", versesCount: 24, isMakki: false, defaultDuration: "00:12:15", audioUrl: "https://server8.mp3quran.net/afs/059.mp3"),
    SurahAudioItem(number: 60, nameArabic: "الممتحنة", englishName: "Al-Mumtahanah", versesCount: 13, isMakki: false, defaultDuration: "00:09:40", audioUrl: "https://server8.mp3quran.net/afs/060.mp3"),
    SurahAudioItem(number: 61, nameArabic: "الصف", englishName: "As-Saf", versesCount: 14, isMakki: false, defaultDuration: "00:06:10", audioUrl: "https://server8.mp3quran.net/afs/061.mp3"),
    SurahAudioItem(number: 62, nameArabic: "الجمعة", englishName: "Al-Jumu'ah", versesCount: 11, isMakki: false, defaultDuration: "00:05:40", audioUrl: "https://server8.mp3quran.net/afs/062.mp3"),
    SurahAudioItem(number: 63, nameArabic: "المنافقون", englishName: "Al-Munafiqun", versesCount: 11, isMakki: false, defaultDuration: "00:05:30", audioUrl: "https://server8.mp3quran.net/afs/063.mp3"),
    SurahAudioItem(number: 64, nameArabic: "التغابن", englishName: "At-Taghabun", versesCount: 18, isMakki: false, defaultDuration: "00:07:20", audioUrl: "https://server8.mp3quran.net/afs/064.mp3"),
    SurahAudioItem(number: 65, nameArabic: "الطلاق", englishName: "At-Talaq", versesCount: 12, isMakki: false, defaultDuration: "00:07:15", audioUrl: "https://server8.mp3quran.net/afs/065.mp3"),
    SurahAudioItem(number: 66, nameArabic: "التحريم", englishName: "At-Tahrim", versesCount: 12, isMakki: false, defaultDuration: "00:07:45", audioUrl: "https://server8.mp3quran.net/afs/066.mp3"),
    SurahAudioItem(number: 67, nameArabic: "الملك", englishName: "Al-Mulk", versesCount: 30, isMakki: true, defaultDuration: "00:08:10", audioUrl: "https://server8.mp3quran.net/afs/067.mp3"),
    SurahAudioItem(number: 68, nameArabic: "القلم", englishName: "Al-Qalam", versesCount: 52, isMakki: true, defaultDuration: "00:09:15", audioUrl: "https://server8.mp3quran.net/afs/068.mp3"),
    SurahAudioItem(number: 69, nameArabic: "الحاقة", englishName: "Al-Haqqah", versesCount: 52, isMakki: true, defaultDuration: "00:08:40", audioUrl: "https://server8.mp3quran.net/afs/069.mp3"),
    SurahAudioItem(number: 70, nameArabic: "المعارج", englishName: "Al-Ma'arij", versesCount: 44, isMakki: true, defaultDuration: "00:06:50", audioUrl: "https://server8.mp3quran.net/afs/070.mp3"),
    SurahAudioItem(number: 71, nameArabic: "نوح", englishName: "Nuh", versesCount: 28, isMakki: true, defaultDuration: "00:05:45", audioUrl: "https://server8.mp3quran.net/afs/071.mp3"),
    SurahAudioItem(number: 72, nameArabic: "الجن", englishName: "Al-Jinn", versesCount: 28, isMakki: true, defaultDuration: "00:07:10", audioUrl: "https://server8.mp3quran.net/afs/072.mp3"),
    SurahAudioItem(number: 73, nameArabic: "المزمل", englishName: "Al-Muzzammil", versesCount: 20, isMakki: true, defaultDuration: "00:05:55", audioUrl: "https://server8.mp3quran.net/afs/073.mp3"),
    SurahAudioItem(number: 74, nameArabic: "المدثر", englishName: "Al-Muddaththir", versesCount: 56, isMakki: true, defaultDuration: "00:07:30", audioUrl: "https://server8.mp3quran.net/afs/074.mp3"),
    SurahAudioItem(number: 75, nameArabic: "القيامة", englishName: "Al-Qiyamah", versesCount: 40, isMakki: true, defaultDuration: "00:04:45", audioUrl: "https://server8.mp3quran.net/afs/075.mp3"),
    SurahAudioItem(number: 76, nameArabic: "الإنسان", englishName: "Al-Insan", versesCount: 31, isMakki: false, defaultDuration: "00:07:50", audioUrl: "https://server8.mp3quran.net/afs/076.mp3"),
    SurahAudioItem(number: 77, nameArabic: "المرسلات", englishName: "Al-Mursalat", versesCount: 50, isMakki: true, defaultDuration: "00:06:15", audioUrl: "https://server8.mp3quran.net/afs/077.mp3"),
    SurahAudioItem(number: 78, nameArabic: "النبأ", englishName: "An-Naba", versesCount: 40, isMakki: true, defaultDuration: "00:05:30", audioUrl: "https://server8.mp3quran.net/afs/078.mp3"),
    SurahAudioItem(number: 79, nameArabic: "النازعات", englishName: "An-Nazi'at", versesCount: 46, isMakki: true, defaultDuration: "00:05:40", audioUrl: "https://server8.mp3quran.net/afs/079.mp3"),
    SurahAudioItem(number: 80, nameArabic: "عبس", englishName: "'Abasa", versesCount: 42, isMakki: true, defaultDuration: "00:04:15", audioUrl: "https://server8.mp3quran.net/afs/080.mp3"),
    SurahAudioItem(number: 81, nameArabic: "التكوير", englishName: "At-Takwir", versesCount: 29, isMakki: true, defaultDuration: "00:03:10", audioUrl: "https://server8.mp3quran.net/afs/081.mp3"),
    SurahAudioItem(number: 82, nameArabic: "الانفطار", englishName: "Al-Infitar", versesCount: 19, isMakki: true, defaultDuration: "00:02:40", audioUrl: "https://server8.mp3quran.net/afs/082.mp3"),
    SurahAudioItem(number: 83, nameArabic: "المطففين", englishName: "Al-Mutaffifin", versesCount: 36, isMakki: true, defaultDuration: "00:05:45", audioUrl: "https://server8.mp3quran.net/afs/083.mp3"),
    SurahAudioItem(number: 84, nameArabic: "الانشقاق", englishName: "Al-Inshiqaq", versesCount: 25, isMakki: true, defaultDuration: "00:03:20", audioUrl: "https://server8.mp3quran.net/afs/084.mp3"),
    SurahAudioItem(number: 85, nameArabic: "البروج", englishName: "Al-Buruj", versesCount: 22, isMakki: true, defaultDuration: "00:03:40", audioUrl: "https://server8.mp3quran.net/afs/085.mp3"),
    SurahAudioItem(number: 86, nameArabic: "الطارق", englishName: "At-Tariq", versesCount: 17, isMakki: true, defaultDuration: "00:02:10", audioUrl: "https://server8.mp3quran.net/afs/086.mp3"),
    SurahAudioItem(number: 87, nameArabic: "الأعلى", englishName: "Al-A'la", versesCount: 19, isMakki: true, defaultDuration: "00:02:15", audioUrl: "https://server8.mp3quran.net/afs/087.mp3"),
    SurahAudioItem(number: 88, nameArabic: "الغاشية", englishName: "Al-Ghashiyah", versesCount: 26, isMakki: true, defaultDuration: "00:03:10", audioUrl: "https://server8.mp3quran.net/afs/088.mp3"),
    SurahAudioItem(number: 89, nameArabic: "الفجر", englishName: "Al-Fajr", versesCount: 30, isMakki: true, defaultDuration: "00:04:30", audioUrl: "https://server8.mp3quran.net/afs/089.mp3"),
    SurahAudioItem(number: 90, nameArabic: "البلد", englishName: "Al-Balad", versesCount: 20, isMakki: true, defaultDuration: "00:02:40", audioUrl: "https://server8.mp3quran.net/afs/090.mp3"),
    SurahAudioItem(number: 91, nameArabic: "الشمس", englishName: "Ash-Shams", versesCount: 15, isMakki: true, defaultDuration: "00:01:50", audioUrl: "https://server8.mp3quran.net/afs/091.mp3"),
    SurahAudioItem(number: 92, nameArabic: "الليل", englishName: "Al-Layl", versesCount: 21, isMakki: true, defaultDuration: "00:02:25", audioUrl: "https://server8.mp3quran.net/afs/092.mp3"),
    SurahAudioItem(number: 93, nameArabic: "الضحى", englishName: "Ad-Duha", versesCount: 11, isMakki: true, defaultDuration: "00:01:20", audioUrl: "https://server8.mp3quran.net/afs/093.mp3"),
    SurahAudioItem(number: 94, nameArabic: "الشرح", englishName: "Ash-Sharh", versesCount: 8, isMakki: true, defaultDuration: "00:00:50", audioUrl: "https://server8.mp3quran.net/afs/094.mp3"),
    SurahAudioItem(number: 95, nameArabic: "التين", englishName: "At-Tin", versesCount: 8, isMakki: true, defaultDuration: "00:01:05", audioUrl: "https://server8.mp3quran.net/afs/095.mp3"),
    SurahAudioItem(number: 96, nameArabic: "العلق", englishName: "Al-'Alaq", versesCount: 19, isMakki: true, defaultDuration: "00:02:10", audioUrl: "https://server8.mp3quran.net/afs/096.mp3"),
    SurahAudioItem(number: 97, nameArabic: "القدر", englishName: "Al-Qadr", versesCount: 5, isMakki: true, defaultDuration: "00:00:55", audioUrl: "https://server8.mp3quran.net/afs/097.mp3"),
    SurahAudioItem(number: 98, nameArabic: "البينة", englishName: "Al-Bayyinah", versesCount: 8, isMakki: false, defaultDuration: "00:02:20", audioUrl: "https://server8.mp3quran.net/afs/098.mp3"),
    SurahAudioItem(number: 99, nameArabic: "الزلزلة", englishName: "Az-Zalzalah", versesCount: 8, isMakki: false, defaultDuration: "00:01:10", audioUrl: "https://server8.mp3quran.net/afs/099.mp3"),
    SurahAudioItem(number: 100, nameArabic: "العاديات", englishName: "Al-'Adiyat", versesCount: 11, isMakki: true, defaultDuration: "00:01:15", audioUrl: "https://server8.mp3quran.net/afs/100.mp3"),
    SurahAudioItem(number: 101, nameArabic: "القارعة", englishName: "Al-Qari'ah", versesCount: 11, isMakki: true, defaultDuration: "00:01:08", audioUrl: "https://server8.mp3quran.net/afs/101.mp3"),
    SurahAudioItem(number: 102, nameArabic: "التكاثر", englishName: "At-Takathur", versesCount: 8, isMakki: true, defaultDuration: "00:01:00", audioUrl: "https://server8.mp3quran.net/afs/102.mp3"),
    SurahAudioItem(number: 103, nameArabic: "العصر", englishName: "Al-'Asr", versesCount: 3, isMakki: true, defaultDuration: "00:00:35", audioUrl: "https://server8.mp3quran.net/afs/103.mp3"),
    SurahAudioItem(number: 104, nameArabic: "الهمزة", englishName: "Al-Humazah", versesCount: 9, isMakki: true, defaultDuration: "00:00:58", audioUrl: "https://server8.mp3quran.net/afs/104.mp3"),
    SurahAudioItem(number: 105, nameArabic: "الفيل", englishName: "Al-Fil", versesCount: 5, isMakki: true, defaultDuration: "00:00:45", audioUrl: "https://server8.mp3quran.net/afs/105.mp3"),
    SurahAudioItem(number: 106, nameArabic: "قريش", englishName: "Quraysh", versesCount: 4, isMakki: true, defaultDuration: "00:00:40", audioUrl: "https://server8.mp3quran.net/afs/106.mp3"),
    SurahAudioItem(number: 107, nameArabic: "الماعون", englishName: "Al-Ma'un", versesCount: 7, isMakki: true, defaultDuration: "00:00:50", audioUrl: "https://server8.mp3quran.net/afs/107.mp3"),
    SurahAudioItem(number: 108, nameArabic: "الكوثر", englishName: "Al-Kawthar", versesCount: 3, isMakki: true, defaultDuration: "00:00:30", audioUrl: "https://server8.mp3quran.net/afs/108.mp3"),
    SurahAudioItem(number: 109, nameArabic: "الكافرون", englishName: "Al-Kafirun", versesCount: 6, isMakki: true, defaultDuration: "00:01:05", audioUrl: "https://server8.mp3quran.net/afs/109.mp3"),
    SurahAudioItem(number: 110, nameArabic: "النصر", englishName: "An-Nasr", versesCount: 3, isMakki: false, defaultDuration: "00:00:35", audioUrl: "https://server8.mp3quran.net/afs/110.mp3"),
    SurahAudioItem(number: 111, nameArabic: "المسد", englishName: "Al-Masad", versesCount: 5, isMakki: true, defaultDuration: "00:00:40", audioUrl: "https://server8.mp3quran.net/afs/111.mp3"),
    SurahAudioItem(number: 112, nameArabic: "الإخلاص", englishName: "Al-Ikhlas", versesCount: 4, isMakki: true, defaultDuration: "00:00:25", audioUrl: "https://server8.mp3quran.net/afs/112.mp3"),
    SurahAudioItem(number: 113, nameArabic: "الفلق", englishName: "Al-Falaq", versesCount: 5, isMakki: true, defaultDuration: "00:00:30", audioUrl: "https://server8.mp3quran.net/afs/113.mp3"),
    SurahAudioItem(number: 114, nameArabic: "الناس", englishName: "An-Nas", versesCount: 6, isMakki: true, defaultDuration: "00:00:35", audioUrl: "https://server8.mp3quran.net/afs/114.mp3"),
  ];

  static const List<RuqyahAudioItem> allRuqyah = [
    RuqyahAudioItem(
      id: 'ruqyah_ayn',
      title: 'رقية العين والحسد والضيق',
      reciter: 'الشيخ إدريس أبكر',
      duration: '34:12',
      purpose: 'علاج العين الحارة والحسد المستقر في الجسد والروح',
      description: 'آيات إبطال العين والحسد متبوعة بأدعية نبوية مأثورة للشفاء وراحة الصدر.',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_sihr',
      title: 'رقية إبطال السحر وفك العقد',
      reciter: 'الشيخ ماهر المعيقلي',
      duration: '42:50',
      purpose: 'إبطال الأسحار المأكولة والمشروبة والمرشوشة وفك العقد',
      description: 'تلاوة قوية لآيات السحر من سور البقرة والأعراف ويونس وطه مصحوبة بأدعية التعويذ.',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_mass',
      title: 'رقية المس العاشق والوساوس',
      reciter: 'الشيخ سعد الغامدي',
      duration: '28:40',
      purpose: 'طرد الشياطين ووساوس الصدر والتخبط الليلي والهلع',
      description: 'آيات الحفظ والشهب والسكينة لحرق العوارض وتطهير النفس من المخاوف والوساوس.',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_sakina',
      title: 'رقية السكينة وطمأنينة القلب',
      reciter: 'الشيخ مشاري راشد العفاسي',
      duration: '21:15',
      purpose: 'تفريج الهم والحزن وعلاج نوبات القلق والأرق قبل النوم',
      description: 'آيات السكينة الست في القرآن الكريم مع دعاء الهم والحزن النبوي الشريف بصوت هادئ ومريح.',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_children',
      title: 'رقية تحصين الأطفال والمنزل',
      reciter: 'الشيخ ياسر الدوسري',
      duration: '18:30',
      purpose: 'حفظ الصغار والبيوت من الفزع وبكاء الليل وطرد الطوارق',
      description: 'أعيذكم بكلمات الله التامة من كل شيطان وهامة ومن كل عين لامة مع المعوذتين والفاتحة.',
    ),
    RuqyahAudioItem(
      id: 'ruqyah_shifa',
      title: 'رقية الشفاء للأمراض العضوية والجسدية',
      reciter: 'الشيخ أحمد العجمي',
      duration: '25:45',
      purpose: 'الاستشفاء بآيات الشفاء الست والأدعية النبوية للمريض',
      description: 'تكرار آيات الشفاء السبع مع المسح والنفث بنية البرء والشفاء التام بإذن الله تعالى.',
    ),
  ];

  static const List<IbtihalAudioItem> allIbtihalat = [
    IbtihalAudioItem(
      id: 'ibtihal_toobar_1',
      title: 'جل المنادي يا من له عنت الوجوه',
      reciter: 'الشيخ نصر الدين طوبار',
      duration: '14:20',
      maqam: 'مقام البياتي والصبا',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_naqsh_1',
      title: 'مولاي إني ببابك قد بسطت يدي',
      reciter: 'الشيخ سيد النقشبندي',
      duration: '09:45',
      maqam: 'مقام الرست والحجاز',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_toobar_2',
      title: 'حين يهدأ الليل وتسكن الأكوان',
      reciter: 'الشيخ نصر الدين طوبار',
      duration: '11:15',
      maqam: 'مقام النهاوند',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_dua_sudais',
      title: 'دعاء القنوت الباكي وتفريج الكروب',
      reciter: 'الشيخ عبد الرحمن السديس',
      duration: '18:50',
      maqam: 'الحرم المكي الشريف',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_khatm_quran',
      title: 'دعاء ختم القرآن العظيم من الحرم النبوي',
      reciter: 'الشيخ علي الحذيفي',
      duration: '22:30',
      maqam: 'تضرع وخشوع نبوي',
    ),
    IbtihalAudioItem(
      id: 'ibtihal_nafees',
      title: 'ولد الهدى فالكائنات ضياء وبشائر',
      reciter: 'الشيخ أحمد النفيس',
      duration: '06:15',
      maqam: 'مقام الكرد الروحي',
    ),
  ];
}
