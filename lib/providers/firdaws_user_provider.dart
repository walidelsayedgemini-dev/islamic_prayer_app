import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hijri_calendar_model.dart';
import '../models/islamic_missions_data.dart';
import '../models/islamic_titles_200.dart';
import '../models/motivational_phrases_500.dart';

enum PrayerLogStatus {
  none,
  prayedOnTime,
  prayedInGroup,
  prayedQada,
  missed,
}

extension PrayerLogStatusExt on PrayerLogStatus {
  String get arabicLabel {
    switch (this) {
      case PrayerLogStatus.none:
        return 'لم تُسجّل';
      case PrayerLogStatus.prayedOnTime:
        return 'في وقتها';
      case PrayerLogStatus.prayedInGroup:
        return 'جماعة';
      case PrayerLogStatus.prayedQada:
        return 'قضاء';
      case PrayerLogStatus.missed:
        return 'فائتة';
    }
  }

  bool get isCompleted =>
      this == PrayerLogStatus.prayedOnTime ||
      this == PrayerLogStatus.prayedInGroup ||
      this == PrayerLogStatus.prayedQada;

  Color statusColor(bool isDark) {
    switch (this) {
      case PrayerLogStatus.none:
        return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      case PrayerLogStatus.prayedOnTime:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
      case PrayerLogStatus.prayedInGroup:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
      case PrayerLogStatus.prayedQada:
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
      case PrayerLogStatus.missed:
        return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerLogStatus.none:
        return Icons.radio_button_unchecked_rounded;
      case PrayerLogStatus.prayedOnTime:
        return Icons.check_circle_rounded;
      case PrayerLogStatus.prayedInGroup:
        return Icons.groups_rounded;
      case PrayerLogStatus.prayedQada:
        return Icons.history_toggle_off_rounded;
      case PrayerLogStatus.missed:
        return Icons.cancel_rounded;
    }
  }
}

class DayPrayerRecord {
  final String dateKey; // yyyy-MM-dd
  final Map<String, PrayerLogStatus> prayers; // fajr, dhuhr, asr, maghrib, isha
  final bool duhaDone;
  final bool qiyamDone;
  final bool witrDone;
  final int sunnahCount;
  final String dailyNote;

  const DayPrayerRecord({
    required this.dateKey,
    this.prayers = const {},
    this.duhaDone = false,
    this.qiyamDone = false,
    this.witrDone = false,
    this.sunnahCount = 0,
    this.dailyNote = '',
  });

  PrayerLogStatus statusFor(String key) => prayers[key] ?? PrayerLogStatus.none;

  int get completedObligatoryCount {
    int count = 0;
    for (final key in FirdawsUserProvider.obligatoryPrayerKeys) {
      if (statusFor(key).isCompleted) count++;
    }
    return count;
  }

  bool get allFiveCompleted => completedObligatoryCount == 5;

  DayPrayerRecord copyWith({
    Map<String, PrayerLogStatus>? prayers,
    bool? duhaDone,
    bool? qiyamDone,
    bool? witrDone,
    int? sunnahCount,
    String? dailyNote,
  }) {
    return DayPrayerRecord(
      dateKey: dateKey,
      prayers: prayers ?? Map<String, PrayerLogStatus>.from(this.prayers),
      duhaDone: duhaDone ?? this.duhaDone,
      qiyamDone: qiyamDone ?? this.qiyamDone,
      witrDone: witrDone ?? this.witrDone,
      sunnahCount: sunnahCount ?? this.sunnahCount,
      dailyNote: dailyNote ?? this.dailyNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'prayers': prayers.map((k, v) => MapEntry(k, v.name)),
        'duhaDone': duhaDone,
        'qiyamDone': qiyamDone,
        'witrDone': witrDone,
        'sunnahCount': sunnahCount,
        'dailyNote': dailyNote,
      };

  factory DayPrayerRecord.fromJson(Map<String, dynamic> json) {
    final rawPrayers = json['prayers'] as Map<String, dynamic>? ?? {};
    final parsedPrayers = <String, PrayerLogStatus>{};
    for (final entry in rawPrayers.entries) {
      final status = PrayerLogStatus.values.firstWhere(
        (e) => e.name == entry.value,
        orElse: () => PrayerLogStatus.none,
      );
      parsedPrayers[entry.key] = status;
    }
    return DayPrayerRecord(
      dateKey: json['dateKey'] as String? ?? '',
      prayers: parsedPrayers,
      duhaDone: json['duhaDone'] as bool? ?? false,
      qiyamDone: json['qiyamDone'] as bool? ?? false,
      witrDone: json['witrDone'] as bool? ?? false,
      sunnahCount: (json['sunnahCount'] as num?)?.toInt() ?? 0,
      dailyNote: json['dailyNote'] as String? ?? '',
    );
  }
}

class MissedPrayerEntry {
  final DateTime date;
  final String prayerKey;
  final String prayerArabicName;

  const MissedPrayerEntry({
    required this.date,
    required this.prayerKey,
    required this.prayerArabicName,
  });
}

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String category;
  final String mood;
  final String createdAtIso;
  final String hijriDateText;
  final bool isPinned;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.mood,
    required this.createdAtIso,
    required this.hijriDateText,
    this.isPinned = false,
  });

  JournalEntry copyWith({
    String? title,
    String? content,
    String? category,
    String? mood,
    bool? isPinned,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      mood: mood ?? this.mood,
      createdAtIso: createdAtIso,
      hijriDateText: hijriDateText,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'mood': mood,
        'createdAtIso': createdAtIso,
        'hijriDateText': hijriDateText,
        'isPinned': isPinned,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String? ?? '${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'ملاحظة',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'خاطرة إيمانية',
      mood: json['mood'] as String? ?? 'طمأنينة',
      createdAtIso:
          json['createdAtIso'] as String? ?? DateTime.now().toIso8601String(),
      hijriDateText: json['hijriDateText'] as String? ??
          HijriDate.fromGregorian(DateTime.now()).formatFullArabic(),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}

class FirdawsUserProfile {
  final String name;
  final int age;
  final String gender; // 'male' or 'female'
  final List<String> preferences;
  final int dailyDhikrGoal;
  final String? activeTitleId;
  final bool enableMotivations;
  final bool enablePrayerTimeEffects;
  final String prayerTimeEffectOverride; // 'auto', 'fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha', 'qiyam'

  const FirdawsUserProfile({
    this.name = '',
    this.age = 24,
    this.gender = 'male',
    this.preferences = const ['الفجر في جماعة', 'أذكار الصباح والمساء'],
    this.dailyDhikrGoal = 100,
    this.activeTitleId,
    this.enableMotivations = true,
    this.enablePrayerTimeEffects = true,
    this.prayerTimeEffectOverride = 'auto',
  });

  bool get isFemale => gender == 'female';
  bool get hasCustomName => name.trim().isNotEmpty;
  String get displayName =>
      hasCustomName ? name.trim() : (isFemale ? 'ضيفة الفردوس' : 'ضيف الفردوس');

  FirdawsUserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    List<String>? preferences,
    int? dailyDhikrGoal,
    String? activeTitleId,
    bool clearActiveTitle = false,
    bool? enableMotivations,
    bool? enablePrayerTimeEffects,
    String? prayerTimeEffectOverride,
  }) {
    return FirdawsUserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      preferences: preferences ?? List<String>.from(this.preferences),
      dailyDhikrGoal: dailyDhikrGoal ?? this.dailyDhikrGoal,
      activeTitleId: clearActiveTitle ? null : (activeTitleId ?? this.activeTitleId),
      enableMotivations: enableMotivations ?? this.enableMotivations,
      enablePrayerTimeEffects:
          enablePrayerTimeEffects ?? this.enablePrayerTimeEffects,
      prayerTimeEffectOverride:
          prayerTimeEffectOverride ?? this.prayerTimeEffectOverride,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'preferences': preferences,
        'dailyDhikrGoal': dailyDhikrGoal,
        'activeTitleId': activeTitleId,
        'enableMotivations': enableMotivations,
        'enablePrayerTimeEffects': enablePrayerTimeEffects,
        'prayerTimeEffectOverride': prayerTimeEffectOverride,
      };

  factory FirdawsUserProfile.fromJson(Map<String, dynamic> json) {
    final prefsRaw = json['preferences'] as List<dynamic>? ?? const [];
    return FirdawsUserProfile(
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt().clamp(5, 110) ?? 24,
      gender: (json['gender'] as String?) == 'female' ? 'female' : 'male',
      preferences: prefsRaw.map((e) => e.toString()).toList(),
      dailyDhikrGoal: (json['dailyDhikrGoal'] as num?)?.toInt() ?? 100,
      activeTitleId: json['activeTitleId'] as String?,
      enableMotivations: json['enableMotivations'] as bool? ?? true,
      enablePrayerTimeEffects: json['enablePrayerTimeEffects'] as bool? ?? true,
      prayerTimeEffectOverride:
          json['prayerTimeEffectOverride'] as String? ?? 'auto',
    );
  }
}

class FirdawsUserProvider extends ChangeNotifier {
  static const List<String> obligatoryPrayerKeys = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static const Map<String, String> prayerArabicNames = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  static const List<String> availablePreferences = [
    'الفجر في جماعة',
    'أذكار الصباح والمساء',
    'تلاوة القرآن اليومية',
    'قيام الليل والوتر',
    'صلاة الضحى',
    'الصلاة على النبي ﷺ',
    'الاستغفار بالأسحار',
    'السنن الرواتب',
    'تدوين المذكرة',
    'المسابقات الدينية',
  ];

  static const List<String> journalCategories = [
    'خاطرة إيمانية',
    'تأمل قرآني',
    'دعاء وأمنية',
    'محاسبة نفس',
    'درس مستفاد',
    'إنجاز يومي',
  ];

  static const List<String> journalMoods = [
    'طمأنينة',
    'شكر',
    'دعاء',
    'همة',
    'خشوع',
  ];

  SharedPreferences? _prefs;
  bool _initialized = false;

  FirdawsUserProfile _profile = const FirdawsUserProfile();
  final Map<String, DayPrayerRecord> _prayerLogs = {};
  final Map<String, int> _missionProgress = {};
  final List<IslamicMission> _customMissions = [];
  final List<JournalEntry> _journalEntries = [];
  final Set<String> _unlockedTitleIds = {};
  final Set<int> _readSurahNumbers = {};
  final Set<String> _claimedCompetitionIds = {};
  final List<IslamicTitleEntry> _pendingNewTitles = [];

  int _totalDhikr = 0;
  int _istighfarCount = 0;
  int _salawatCount = 0;
  int _completedMissionsTotal = 0;
  int _competitionsWon = 0;
  int _competitionPoints = 0;
  int _bestPrayerStreak = 0;
  int _motivationSeed = 0;

  // صورة المستخدم الشخصية المرفوعة من المعرض (Base64)
  String? _avatarBase64;
  Uint8List? _cachedAvatarBytes;

  // بيانات قسم «عنّي وبياناتي والدعاء»
  String _aboutCreatorName = 'صاحبُ رسالة تطبيق الفردوس';
  String _aboutCreatorTitle = 'خادمُ كتاب الله وسنة نبيه ﷺ';
  String _aboutBio =
      'اجتهدتُ في جمع مواقيت الصلاة، المصحف المرتل الموثق، صحيح البخاري، القصص النبوية، والأذكار في مكانٍ واحدٍ ليكون رفيقك إلى الجنة.';
  String _aboutDuaRequest =
      'أتمنى من كل من انتفع بهذا التطبيق ولو بآيةٍ أو تسبيحةٍ أو صلاةٍ أن يذكرني ووالديَّ وأهلي بصادق الدعوات في ظهر الغيب — جزاكم الله خيراً ولا تنسوني من صالح الدعاء 🤲💛';
  String _aboutContactInfo = 'مشروع وقف وصدقة جارية لوجه الله تعالى';
  int _creatorDuasCount = 0;

  // --------------------- Getters ---------------------
  bool get isInitialized => _initialized;
  FirdawsUserProfile get profile => _profile;
  bool get isFemale => _profile.isFemale;
  String get displayName => _profile.displayName;
  String? get avatarBase64 => _avatarBase64;
  Uint8List? get avatarBytes {
    if (_avatarBase64 == null || _avatarBase64!.isEmpty) return null;
    if (_cachedAvatarBytes != null) return _cachedAvatarBytes;
    try {
      _cachedAvatarBytes = base64Decode(_avatarBase64!);
      return _cachedAvatarBytes;
    } catch (_) {
      return null;
    }
  }

  String get aboutCreatorName => _aboutCreatorName;
  String get aboutCreatorTitle => _aboutCreatorTitle;
  String get aboutBio => _aboutBio;
  String get aboutDuaRequest => _aboutDuaRequest;
  String get aboutContactInfo => _aboutContactInfo;
  int get creatorDuasCount => _creatorDuasCount;
  Map<String, DayPrayerRecord> get prayerLogs => _prayerLogs;
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  Set<String> get unlockedTitleIds => Set.unmodifiable(_unlockedTitleIds);
  Set<int> get readSurahNumbers => Set.unmodifiable(_readSurahNumbers);
  Set<String> get claimedCompetitionIds =>
      Set.unmodifiable(_claimedCompetitionIds);

  int get totalDhikr => _totalDhikr;
  int get istighfarCount => _istighfarCount;
  int get salawatCount => _salawatCount;
  int get completedMissionsTotal => _completedMissionsTotal;
  int get competitionsWon => _competitionsWon;
  int get competitionPoints => _competitionPoints;
  int get motivationSeed => _motivationSeed;

  List<IslamicMission> get allMissions => [
        ...IslamicMissionsCatalog.builtInMissions,
        ..._customMissions,
      ];

  List<IslamicMission> get customMissions => List.unmodifiable(_customMissions);

  IslamicTitleEntry? get activeTitle {
    if (_profile.activeTitleId == null) return null;
    final found = IslamicTitlesCatalog.getById(_profile.activeTitleId!);
    if (found != null && _unlockedTitleIds.contains(found.id)) {
      return found;
    }
    return null;
  }

  String? get activeTitleLabel =>
      activeTitle?.localizedTitle(isFemale: _profile.isFemale);

  // --------------------- Date Helpers ---------------------
  static String formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? DateTime.now().month,
      int.tryParse(parts[2]) ?? DateTime.now().day,
    );
  }

  DayPrayerRecord recordForDate(DateTime date) {
    final key = formatDateKey(date);
    return _prayerLogs[key] ?? DayPrayerRecord(dateKey: key);
  }

  // --------------------- Computed Prayer Stats ---------------------
  int get totalPrayersLogged {
    int count = 0;
    for (final rec in _prayerLogs.values) {
      for (final key in obligatoryPrayerKeys) {
        if (rec.statusFor(key).isCompleted) count++;
      }
    }
    return count;
  }

  int get congregationPrayersCount {
    int count = 0;
    for (final rec in _prayerLogs.values) {
      for (final key in obligatoryPrayerKeys) {
        if (rec.statusFor(key) == PrayerLogStatus.prayedInGroup) count++;
      }
    }
    return count;
  }

  int get fajrOnTimeCount {
    int count = 0;
    for (final rec in _prayerLogs.values) {
      final s = rec.statusFor('fajr');
      if (s == PrayerLogStatus.prayedOnTime ||
          s == PrayerLogStatus.prayedInGroup) {
        count++;
      }
    }
    return count;
  }

  int get qadaRecoveredCount {
    int count = 0;
    for (final rec in _prayerLogs.values) {
      for (final key in obligatoryPrayerKeys) {
        if (rec.statusFor(key) == PrayerLogStatus.prayedQada) count++;
      }
    }
    return count;
  }

  int get qiyamNightsCount {
    int count = 0;
    for (final rec in _prayerLogs.values) {
      if (rec.qiyamDone || rec.witrDone || rec.duhaDone) count++;
    }
    return count;
  }

  int get currentPrayerStreak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    DateTime cursor = today;

    // إذا لم يكمل المستخدم يومه اليوم بعد، نبدأ الحساب من أمس حتى لا ينقطع السلسال أثناء اليوم
    if (!recordForDate(cursor).allFiveCompleted) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (recordForDate(cursor).allFiveCompleted) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestPrayerStreak {
    final current = currentPrayerStreak;
    return current > _bestPrayerStreak ? current : _bestPrayerStreak;
  }

  List<MissedPrayerEntry> getMissedPrayerEntries() {
    final list = <MissedPrayerEntry>[];
    final sortedKeys = _prayerLogs.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final k in sortedKeys) {
      final rec = _prayerLogs[k]!;
      final dt = parseDateKey(k);
      for (final pKey in obligatoryPrayerKeys) {
        if (rec.statusFor(pKey) == PrayerLogStatus.missed) {
          list.add(MissedPrayerEntry(
            date: dt,
            prayerKey: pKey,
            prayerArabicName: prayerArabicNames[pKey] ?? pKey,
          ));
        }
      }
    }
    return list;
  }

  // --------------------- Init & Persistence ---------------------
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
      _evaluateTitles(queuePopup: false);
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('FirdawsUserProvider init error: $e');
    }
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;

    final profileRaw = _prefs!.getString('firdaws_user_profile');
    if (profileRaw != null) {
      try {
        _profile = FirdawsUserProfile.fromJson(
          jsonDecode(profileRaw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    final logsRaw = _prefs!.getString('firdaws_prayer_logs');
    _prayerLogs.clear();
    if (logsRaw != null) {
      try {
        final decoded = jsonDecode(logsRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _prayerLogs[entry.key] = DayPrayerRecord.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      } catch (_) {}
    }

    final missionProgRaw = _prefs!.getString('firdaws_mission_progress');
    _missionProgress.clear();
    if (missionProgRaw != null) {
      try {
        final decoded = jsonDecode(missionProgRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _missionProgress[entry.key] = (entry.value as num).toInt();
        }
      } catch (_) {}
    }

    final customMissionsRaw = _prefs!.getString('firdaws_custom_missions');
    _customMissions.clear();
    if (customMissionsRaw != null) {
      try {
        final list = jsonDecode(customMissionsRaw) as List<dynamic>;
        for (final item in list) {
          _customMissions.add(
            IslamicMission.fromJson(item as Map<String, dynamic>),
          );
        }
      } catch (_) {}
    }

    final journalRaw = _prefs!.getString('firdaws_journal_entries');
    _journalEntries.clear();
    if (journalRaw != null) {
      try {
        final list = jsonDecode(journalRaw) as List<dynamic>;
        for (final item in list) {
          _journalEntries.add(
            JournalEntry.fromJson(item as Map<String, dynamic>),
          );
        }
      } catch (_) {}
    }

    final unlockedList = _prefs!.getStringList('firdaws_unlocked_titles') ?? [];
    _unlockedTitleIds
      ..clear()
      ..addAll(unlockedList);

    final surahList = _prefs!.getStringList('firdaws_read_surahs') ?? [];
    _readSurahNumbers
      ..clear()
      ..addAll(surahList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0));

    final claimedList =
        _prefs!.getStringList('firdaws_claimed_competitions') ?? [];
    _claimedCompetitionIds
      ..clear()
      ..addAll(claimedList);

    _totalDhikr = _prefs!.getInt('firdaws_total_dhikr') ?? 0;
    _istighfarCount = _prefs!.getInt('firdaws_istighfar_count') ?? 0;
    _salawatCount = _prefs!.getInt('firdaws_salawat_count') ?? 0;
    _completedMissionsTotal = _prefs!.getInt('firdaws_missions_total') ?? 0;
    _competitionsWon = _prefs!.getInt('firdaws_competitions_won') ?? 0;
    _competitionPoints = _prefs!.getInt('firdaws_competition_points') ?? 0;
    _bestPrayerStreak = _prefs!.getInt('firdaws_best_streak') ?? 0;
    _motivationSeed = _prefs!.getInt('firdaws_motivation_seed') ?? 0;
    _avatarBase64 = _prefs!.getString('firdaws_avatar_base64');
    _cachedAvatarBytes = null;
    _aboutCreatorName =
        _prefs!.getString('firdaws_about_name') ?? _aboutCreatorName;
    _aboutCreatorTitle =
        _prefs!.getString('firdaws_about_title') ?? _aboutCreatorTitle;
    _aboutBio = _prefs!.getString('firdaws_about_bio') ?? _aboutBio;
    _aboutDuaRequest =
        _prefs!.getString('firdaws_about_dua') ?? _aboutDuaRequest;
    _aboutContactInfo =
        _prefs!.getString('firdaws_about_contact') ?? _aboutContactInfo;
    _creatorDuasCount = _prefs!.getInt('firdaws_about_duas_count') ?? 0;
  }

  Future<void> _saveToPrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (_) {
        return;
      }
    }
    try {
      await _prefs!.setString(
        'firdaws_user_profile',
        jsonEncode(_profile.toJson()),
      );
      await _prefs!.setString(
        'firdaws_prayer_logs',
        jsonEncode(_prayerLogs.map((k, v) => MapEntry(k, v.toJson()))),
      );
      await _prefs!.setString(
        'firdaws_mission_progress',
        jsonEncode(_missionProgress),
      );
      await _prefs!.setString(
        'firdaws_custom_missions',
        jsonEncode(_customMissions.map((m) => m.toJson()).toList()),
      );
      await _prefs!.setString(
        'firdaws_journal_entries',
        jsonEncode(_journalEntries.map((j) => j.toJson()).toList()),
      );
      await _prefs!.setStringList(
        'firdaws_unlocked_titles',
        _unlockedTitleIds.toList(),
      );
      await _prefs!.setStringList(
        'firdaws_read_surahs',
        _readSurahNumbers.map((e) => e.toString()).toList(),
      );
      await _prefs!.setStringList(
        'firdaws_claimed_competitions',
        _claimedCompetitionIds.toList(),
      );
      await _prefs!.setInt('firdaws_total_dhikr', _totalDhikr);
      await _prefs!.setInt('firdaws_istighfar_count', _istighfarCount);
      await _prefs!.setInt('firdaws_salawat_count', _salawatCount);
      await _prefs!.setInt('firdaws_missions_total', _completedMissionsTotal);
      await _prefs!.setInt('firdaws_competitions_won', _competitionsWon);
      await _prefs!.setInt('firdaws_competition_points', _competitionPoints);
      await _prefs!.setInt('firdaws_best_streak', _bestPrayerStreak);
      await _prefs!.setInt('firdaws_motivation_seed', _motivationSeed);
    } catch (e) {
      debugPrint('FirdawsUserProvider save error: $e');
    }
  }

  // --------------------- Profile Actions ---------------------
  Future<void> updateProfile({
    String? name,
    int? age,
    String? gender,
    List<String>? preferences,
    int? dailyDhikrGoal,
    bool? enableMotivations,
    bool? enablePrayerTimeEffects,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      age: age,
      gender: gender,
      preferences: preferences,
      dailyDhikrGoal: dailyDhikrGoal,
      enableMotivations: enableMotivations,
      enablePrayerTimeEffects: enablePrayerTimeEffects,
    );
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> setPrayerTimeEffectsEnabled(bool enabled) async {
    _profile = _profile.copyWith(enablePrayerTimeEffects: enabled);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> setPrayerTimeEffectOverride(String key) async {
    _profile = _profile.copyWith(prayerTimeEffectOverride: key);
    if (key != 'auto') {
      _advanceMissionInternal('m_fun_haramain_tour', 1);
      _evaluateTitles();
    }
    notifyListeners();
    await _saveToPrefs();
  }

  Future<bool> equipTitle(String? titleId) async {
    if (titleId == null) {
      _profile = _profile.copyWith(clearActiveTitle: true);
      notifyListeners();
      await _saveToPrefs();
      return true;
    }
    if (!_unlockedTitleIds.contains(titleId)) return false;
    _profile = _profile.copyWith(activeTitleId: titleId);
    notifyListeners();
    await _saveToPrefs();
    return true;
  }

  // --------------------- Prayer Log Actions ---------------------
  Future<List<IslamicTitleEntry>> setPrayerStatus(
    DateTime date,
    String prayerKey,
    PrayerLogStatus status,
  ) async {
    final key = formatDateKey(date);
    final existing = _prayerLogs[key] ?? DayPrayerRecord(dateKey: key);
    final prevStatus = existing.statusFor(prayerKey);
    final updatedPrayers = Map<String, PrayerLogStatus>.from(existing.prayers)
      ..[prayerKey] = status;

    _prayerLogs[key] = existing.copyWith(prayers: updatedPrayers);

    // تحديث سلسلة الأيام المثلى
    final currentStreak = currentPrayerStreak;
    if (currentStreak > _bestPrayerStreak) {
      _bestPrayerStreak = currentStreak;
    }

    // مزامنة المهام المرتبطة بالصلاة إذا تحول من غير منجز لمنجز أو قضاء
    if (!prevStatus.isCompleted && status.isCompleted) {
      if (status == PrayerLogStatus.prayedQada) {
        _advanceMissionInternal('m_prayer_qada', 1);
      }
      if (status == PrayerLogStatus.prayedInGroup) {
        _advanceMissionInternal('m_prayer_jamaah', 1);
      }
      if (prayerKey == 'fajr' &&
          (status == PrayerLogStatus.prayedOnTime ||
              status == PrayerLogStatus.prayedInGroup)) {
        _advanceMissionInternal('m_prayer_fajr_ribat', 1);
        _advanceMissionInternal('m_prayer_bardain', 1);
      }
      if (prayerKey == 'asr' &&
          (status == PrayerLogStatus.prayedOnTime ||
              status == PrayerLogStatus.prayedInGroup)) {
        _advanceMissionInternal('m_prayer_bardain', 1);
      }

      // تحديث مهمة تحدي النجوم الخمس لليوم
      final todayKey = formatDateKey(DateTime.now());
      if (key == todayKey) {
        _setMissionDirect(
          'm_fun_five_stars',
          _prayerLogs[key]!.completedObligatoryCount,
        );
      }
    }

    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  Future<List<IslamicTitleEntry>> updateDayNawafil(
    DateTime date, {
    bool? duhaDone,
    bool? qiyamDone,
    bool? witrDone,
    int? sunnahCount,
    String? dailyNote,
  }) async {
    final key = formatDateKey(date);
    final existing = _prayerLogs[key] ?? DayPrayerRecord(dateKey: key);

    if (duhaDone == true && !existing.duhaDone) {
      _advanceMissionInternal('m_prayer_duha', 1);
    }
    if (witrDone == true && !existing.witrDone) {
      _advanceMissionInternal('m_prayer_witr', 1);
    }
    if (qiyamDone == true && !existing.qiyamDone) {
      _advanceMissionInternal('m_fun_qiyam_watch', 1);
    }
    if (sunnahCount != null && sunnahCount > existing.sunnahCount) {
      _advanceMissionInternal('m_prayer_rawatib', sunnahCount - existing.sunnahCount);
    }

    _prayerLogs[key] = existing.copyWith(
      duhaDone: duhaDone,
      qiyamDone: qiyamDone,
      witrDone: witrDone,
      sunnahCount: sunnahCount,
      dailyNote: dailyNote,
    );

    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  // --------------------- Dhikr & Quran Sync ---------------------
  Future<List<IslamicTitleEntry>> recordDhikrByText(
    String dhikrText, {
    int count = 1,
  }) async {
    _totalDhikr += count;
    _competitionPoints += count;

    if (dhikrText.contains('أَسْتَغْفِرُ') || dhikrText.contains('استغفر')) {
      _istighfarCount += count;
      _advanceMissionInternal('m_dhikr_istighfar', count);
    }
    if (dhikrText.contains('صَلِّ') || dhikrText.contains('نَبِيِّنَا')) {
      _salawatCount += count;
      _advanceMissionInternal('m_dhikr_salawat', count);
    }
    if (dhikrText.contains('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ')) {
      _advanceMissionInternal('m_dhikr_ghiras', count);
    }
    if (dhikrText.contains('الْعَظِيمِ') && dhikrText.contains('سُبْحَانَ')) {
      _advanceMissionInternal('m_dhikr_thaqilatan', count);
    }
    if (dhikrText.contains('لَا حَوْلَ')) {
      _advanceMissionInternal('m_dhikr_kanz', count);
    }
    if (dhikrText.contains('وَحْدَهُ لَا شَرِيكَ')) {
      _advanceMissionInternal('m_dhikr_tawhid', count);
    }
    if (dhikrText.contains('الْحَمْدُ') ||
        dhikrText.contains('اللَّهُ أَكْبَرُ') ||
        dhikrText.contains('سُبْحَانَ')) {
      _advanceMissionInternal('m_dhikr_baqiyat', count);
    }
    _advanceMissionInternal('m_fun_golden_minute', count);

    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  Future<List<IslamicTitleEntry>> recordSurahRead(int surahNumber) async {
    _readSurahNumbers.add(surahNumber);
    if (surahNumber == 18) {
      _advanceMissionInternal('m_taat_kahf_light', 1);
    }
    _setMissionDirect('m_taat_quran_surahs', _readSurahNumbers.length);

    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  // --------------------- Missions & Custom Missions ---------------------
  int missionProgressFor(String missionId) => _missionProgress[missionId] ?? 0;

  bool isMissionCompleted(IslamicMission m) =>
      missionProgressFor(m.id) >= m.targetCount;

  Future<List<IslamicTitleEntry>> advanceMission(
    String missionId, {
    int amount = 1,
  }) async {
    _advanceMissionInternal(missionId, amount);
    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  Future<void> resetMission(String missionId) async {
    _missionProgress[missionId] = 0;
    notifyListeners();
    await _saveToPrefs();
  }

  void _advanceMissionInternal(String missionId, int amount) {
    final mission = allMissions.cast<IslamicMission?>().firstWhere(
          (m) => m?.id == missionId,
          orElse: () => null,
        );
    if (mission == null) return;
    final prev = _missionProgress[missionId] ?? 0;
    final next = (prev + amount).clamp(0, mission.targetCount);
    _missionProgress[missionId] = next;
    if (prev < mission.targetCount && next >= mission.targetCount) {
      _completedMissionsTotal++;
      _competitionPoints += mission.rewardPoints;
    }
  }

  void _setMissionDirect(String missionId, int value) {
    final mission = allMissions.cast<IslamicMission?>().firstWhere(
          (m) => m?.id == missionId,
          orElse: () => null,
        );
    if (mission == null) return;
    final prev = _missionProgress[missionId] ?? 0;
    final next = value.clamp(0, mission.targetCount);
    _missionProgress[missionId] = next;
    if (prev < mission.targetCount && next >= mission.targetCount) {
      _completedMissionsTotal++;
      _competitionPoints += mission.rewardPoints;
    }
  }

  Future<void> addCustomMission({
    required String islamicTitle,
    required String subtitle,
    required IslamicMissionCategory category,
    required int targetCount,
  }) async {
    final mission = IslamicMission(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      islamicTitle: islamicTitle.trim(),
      subtitle: subtitle.trim().isEmpty
          ? 'مهمة إسلامية شخصية نحو الجنة'
          : subtitle.trim(),
      category: category,
      targetCount: targetCount.clamp(1, 10000),
      virtueOrHadith: 'عمل صالح خصّصته بنفسك لنيل رضا الله ورفع درجاتك.',
      rewardPoints: (targetCount * 2).clamp(30, 300),
      iconCodePoint: category.icon.codePoint,
      isCustom: true,
    );
    _customMissions.insert(0, mission);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> deleteCustomMission(String id) async {
    _customMissions.removeWhere((m) => m.id == id);
    _missionProgress.remove(id);
    notifyListeners();
    await _saveToPrefs();
  }

  // --------------------- Competitions & Quiz ---------------------
  int progressForCompetition(IslamicCompetition comp) {
    switch (comp.trackType) {
      case CompetitionTrackType.prayersLogged:
        return totalPrayersLogged;
      case CompetitionTrackType.dhikrTotal:
        return _totalDhikr;
      case CompetitionTrackType.fajrCount:
        return fajrOnTimeCount;
      case CompetitionTrackType.missionsDone:
        return _completedMissionsTotal;
      case CompetitionTrackType.quizWins:
        return _competitionsWon;
      case CompetitionTrackType.journalNotes:
        return _journalEntries.length;
    }
  }

  Future<List<IslamicTitleEntry>> recordQuizRoundResult({
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final isWin = totalQuestions > 0 && (correctAnswers / totalQuestions) >= 0.6;
    _competitionPoints += correctAnswers * 25;
    if (isWin) {
      _competitionsWon++;
      _competitionPoints += 100;
      _advanceMissionInternal('m_fun_quiz_marathon', 1);
    }
    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  Future<List<IslamicTitleEntry>> claimCompetitionReward(
    IslamicCompetition comp,
  ) async {
    if (_claimedCompetitionIds.contains(comp.id)) return [];
    if (progressForCompetition(comp) < comp.targetValue) return [];

    _claimedCompetitionIds.add(comp.id);
    _competitionsWon++;
    _competitionPoints += comp.rewardPoints;
    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  // --------------------- Journal CRUD ---------------------
  Future<List<IslamicTitleEntry>> addJournalEntry({
    required String title,
    required String content,
    String category = 'خاطرة إيمانية',
    String mood = 'طمأنينة',
  }) async {
    final now = DateTime.now();
    final hijri = HijriDate.fromGregorian(now).formatFullArabic();
    final entry = JournalEntry(
      id: 'j_${now.millisecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'ملاحظة وتدبّر' : title.trim(),
      content: content.trim(),
      category: category,
      mood: mood,
      createdAtIso: now.toIso8601String(),
      hijriDateText: hijri,
    );
    _journalEntries.insert(0, entry);
    _advanceMissionInternal('m_taat_journal_reflection', 1);
    final unlocked = _evaluateTitles();
    notifyListeners();
    await _saveToPrefs();
    return unlocked;
  }

  Future<void> updateJournalEntry({
    required String id,
    required String title,
    required String content,
    required String category,
    required String mood,
  }) async {
    final idx = _journalEntries.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _journalEntries[idx] = _journalEntries[idx].copyWith(
      title: title.trim().isEmpty ? 'ملاحظة' : title.trim(),
      content: content.trim(),
      category: category,
      mood: mood,
    );
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> deleteJournalEntry(String id) async {
    _journalEntries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> togglePinJournal(String id) async {
    final idx = _journalEntries.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _journalEntries[idx] = _journalEntries[idx].copyWith(
      isPinned: !_journalEntries[idx].isPinned,
    );
    _journalEntries.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.createdAtIso.compareTo(a.createdAtIso);
    });
    notifyListeners();
    await _saveToPrefs();
  }

  // --------------------- 200 Titles Evaluation ---------------------
  int currentValueForTitle(IslamicTitleEntry title) {
    switch (title.missionType) {
      case TitleMissionType.prayerDaysStreak:
        return bestPrayerStreak;
      case TitleMissionType.totalPrayersLogged:
        return totalPrayersLogged;
      case TitleMissionType.congregationPrayers:
        return congregationPrayersCount;
      case TitleMissionType.fajrCount:
        return fajrOnTimeCount;
      case TitleMissionType.qadaRecovered:
        return qadaRecoveredCount;
      case TitleMissionType.totalDhikr:
        return _totalDhikr;
      case TitleMissionType.istighfarCount:
        return _istighfarCount;
      case TitleMissionType.salawatCount:
        return _salawatCount;
      case TitleMissionType.completedMissions:
        return _completedMissionsTotal;
      case TitleMissionType.competitionsWon:
        return _competitionsWon;
      case TitleMissionType.quranSurahsRead:
        return _readSurahNumbers.length;
      case TitleMissionType.journalNotesCount:
        return _journalEntries.length;
      case TitleMissionType.qiyamNights:
        return qiyamNightsCount;
    }
  }

  double progressForTitle(IslamicTitleEntry title) {
    if (title.targetValue <= 0) return 1.0;
    return (currentValueForTitle(title) / title.targetValue).clamp(0.0, 1.0);
  }

  List<IslamicTitleEntry> _evaluateTitles({bool queuePopup = true}) {
    final newlyUnlocked = <IslamicTitleEntry>[];
    for (final title in IslamicTitlesCatalog.allTitles) {
      if (_unlockedTitleIds.contains(title.id)) continue;
      if (currentValueForTitle(title) >= title.targetValue) {
        _unlockedTitleIds.add(title.id);
        newlyUnlocked.add(title);
        if (queuePopup) {
          _pendingNewTitles.add(title);
        }
        // تعيين أول لقب يُفتح تلقائياً إذا لم يختر المستخدم لقباً بعد
        if (_profile.activeTitleId == null) {
          _profile = _profile.copyWith(activeTitleId: title.id);
        }
      }
    }
    return newlyUnlocked;
  }

  List<IslamicTitleEntry> popPendingNewTitles() {
    if (_pendingNewTitles.isEmpty) return const [];
    final copy = List<IslamicTitleEntry>.from(_pendingNewTitles);
    _pendingNewTitles.clear();
    return copy;
  }

  // --------------------- 500 Personalized Phrases ---------------------
  String formatPhrase(String template) {
    return MotivationalPhrasesCatalog.formatPhrase(
      template,
      name: _profile.displayName,
      isFemale: _profile.isFemale,
    );
  }

  MotivationalPhraseEntry getCurrentMotivationEntry({String category = 'الكل'}) {
    return MotivationalPhrasesCatalog.pickForSeed(
      _motivationSeed,
      category: category,
    );
  }

  String getPersonalizedMotivation({
    String category = 'الكل',
    int? customSeed,
  }) {
    final entry = MotivationalPhrasesCatalog.pickForSeed(
      customSeed ?? _motivationSeed,
      category: category,
    );
    return formatPhrase(entry.template);
  }

  void nextMotivation() {
    _motivationSeed = (_motivationSeed + 1) % 500;
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> updateAvatarBase64(String? base64Data) async {
    _avatarBase64 = (base64Data == null || base64Data.isEmpty) ? null : base64Data;
    _cachedAvatarBytes = null;
    if (_avatarBase64 == null) {
      await _prefs?.remove('firdaws_avatar_base64');
    } else {
      await _prefs?.setString('firdaws_avatar_base64', _avatarBase64!);
    }
    notifyListeners();
  }

  Future<void> updateAboutInfo({
    String? creatorName,
    String? creatorTitle,
    String? bio,
    String? duaRequest,
    String? contactInfo,
  }) async {
    if (creatorName != null) _aboutCreatorName = creatorName.trim();
    if (creatorTitle != null) _aboutCreatorTitle = creatorTitle.trim();
    if (bio != null) _aboutBio = bio.trim();
    if (duaRequest != null) _aboutDuaRequest = duaRequest.trim();
    if (contactInfo != null) _aboutContactInfo = contactInfo.trim();

    await _prefs?.setString('firdaws_about_name', _aboutCreatorName);
    await _prefs?.setString('firdaws_about_title', _aboutCreatorTitle);
    await _prefs?.setString('firdaws_about_bio', _aboutBio);
    await _prefs?.setString('firdaws_about_dua', _aboutDuaRequest);
    await _prefs?.setString('firdaws_about_contact', _aboutContactInfo);
    notifyListeners();
  }

  Future<void> incrementCreatorDua() async {
    _creatorDuasCount++;
    _competitionPoints += 10;
    await _prefs?.setInt('firdaws_about_duas_count', _creatorDuasCount);
    await _prefs?.setInt('firdaws_competition_points', _competitionPoints);
    notifyListeners();
  }
}
