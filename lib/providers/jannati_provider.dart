import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jannati_encyclopedia_data.dart';

class JannahDeedLogItem {
  final String investmentId;
  final String title;
  final String timestampIso;
  final int pointsEarned;
  final bool completedCycle;

  const JannahDeedLogItem({
    required this.investmentId,
    required this.title,
    required this.timestampIso,
    required this.pointsEarned,
    required this.completedCycle,
  });

  Map<String, dynamic> toJson() => {
        'investmentId': investmentId,
        'title': title,
        'timestampIso': timestampIso,
        'pointsEarned': pointsEarned,
        'completedCycle': completedCycle,
      };

  factory JannahDeedLogItem.fromJson(Map<String, dynamic> json) {
    return JannahDeedLogItem(
      investmentId: json['investmentId'] as String? ?? 'palms',
      title: json['title'] as String? ?? '',
      timestampIso: json['timestampIso'] as String? ?? '',
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      completedCycle: json['completedCycle'] as bool? ?? true,
    );
  }
}

class JannahTapOutcome {
  final JannahInvestment investment;
  final int newCount;
  final int cycleProgress;
  final bool completedCycle;
  final int pointsEarned;
  final JannahRankTier? promotedToRank;
  final String feedbackMessage;

  const JannahTapOutcome({
    required this.investment,
    required this.newCount,
    required this.cycleProgress,
    required this.completedCycle,
    required this.pointsEarned,
    required this.promotedToRank,
    required this.feedbackMessage,
  });
}

class JannatiProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _initialized = false;

  static const String _kCountsKey = 'jannati_investment_counts_v1';
  static const String _kCyclesKey = 'jannati_cycle_progress_v1';
  static const String _kDailyDateKey = 'jannati_daily_date_v1';
  static const String _kDailyCheckedKey = 'jannati_daily_checked_v1';
  static const String _kBookmarksKey = 'jannati_qa_bookmarks_v1';
  static const String _kAspirationsKey = 'jannati_aspirations_v1';
  static const String _kBestQuizKey = 'jannati_best_quiz_v1';
  static const String _kQuizCountKey = 'jannati_quiz_count_v1';
  static const String _kLogsKey = 'jannati_deed_logs_v1';
  static const String _kBonusPtsKey = 'jannati_bonus_points_v1';
  static const String _kHadithReadsCountKey = 'jannati_hadith_reads_count_v1';
  static const String _kHadithReadIdsKey = 'jannati_hadith_read_ids_v1';
  static const String _kTasbihOrchardTreesKey = 'jannati_tasbih_orchard_trees_v1';
  static const String _kTasbihGrowthStreakKey = 'jannati_tasbih_growth_v1';
  static const String _kLastTasbihTreeNameKey = 'jannati_last_tasbih_tree_v1';
  static const String _kJannatiBackupKey = 'jannati_snapshot_backup_v2';

  final Map<String, int> _counts = {
    for (final inv in JannatiCatalog.investments) inv.id: 0,
  };
  final Map<String, int> _cycleProgress = {};
  final Set<String> _dailyCheckedIds = {};
  final Set<String> _bookmarkedQaIds = {};
  final Set<String> _readJannahHadithIds = {};
  final List<String> _personalAspirations = [
    JannatiCatalog.aspirationTemplates[0],
    JannatiCatalog.aspirationTemplates[1],
    JannatiCatalog.aspirationTemplates[2],
  ];
  final List<JannahDeedLogItem> _recentLogs = [];

  String _dailyDate = '';
  int _bestQuizScore = 0;
  int _quizzesCompleted = 0;
  int _bonusPoints = 0;
  int _hadithsReadCount = 0;
  int _statsKineticTick = 0;
  int _tasbihOrchardTrees = 0;
  int _tasbihGrowthStreak = 0;
  String _lastTasbihTreeName = 'نخلة التوحيد الذهبية';

  bool get isInitialized => _initialized;
  int get hadithsReadCount => _hadithsReadCount;
  Set<String> get readJannahHadithIds =>
      Set<String>.unmodifiable(_readJannahHadithIds);
  int get statsKineticTick => _statsKineticTick;
  int get tasbihOrchardTrees => _tasbihOrchardTrees;
  int get tasbihGrowthStreak => _tasbihGrowthStreak;
  String get lastTasbihTreeName => _lastTasbihTreeName;

  int countFor(String investmentId) => _counts[investmentId] ?? 0;

  int cycleProgressFor(String investmentId) => _cycleProgress[investmentId] ?? 0;

  int get palmsCount => countFor('palms');
  int get palacesCount =>
      countFor('ikhlas_palaces') + countFor('ethics_palaces') + countFor('duha_homes');
  int get housesCount => countFor('rawatib_houses') + countFor('mosque_shares');
  int get treasuresCount => countFor('throne_treasures') + countFor('sayyid_istighfar');
  int get grovesCount => countFor('ibrahim_groves') + countFor('tuba_groves');
  int get charityCount => countFor('charity_pavilions') + countFor('parents_crowns');
  int get salawatCount => countFor('salawat_kawthar') + countFor('wudu_gates');
  int get totalGardenTrees => palmsCount + grovesCount + _tasbihOrchardTrees;

  String get orchardStageTitle {
    final total = totalGardenTrees;
    if (total == 0) return 'روضة الفردوس مهيّأة للغِراس ✨';
    if (total < 15) return 'واحة شتلات النور المتفتّحة 🌿';
    if (total < 60) return 'روضة وارفة الظلال في الجنة 🌸';
    if (total < 150) return 'رياض نخيلٍ وأنهارٍ جارية 🌴';
    if (total < 400) return 'رياض الفردوس العامرة بالثمر ✨';
    return 'جنة الفردوس الكبرى ذات الغراس الوفيرة 👑';
  }

  Set<String> get dailyCheckedIds => Set<String>.unmodifiable(_dailyCheckedIds);
  Set<String> get bookmarkedQaIds => Set<String>.unmodifiable(_bookmarkedQaIds);
  List<String> get personalAspirations => List<String>.unmodifiable(_personalAspirations);
  List<JannahDeedLogItem> get recentLogs => List<JannahDeedLogItem>.unmodifiable(_recentLogs);

  int get bestQuizScore => _bestQuizScore;
  int get quizzesCompleted => _quizzesCompleted;

  int get totalInvestmentActions =>
      _counts.values.fold<int>(0, (sum, value) => sum + value);

  int get totalJannahPoints {
    var pts = _bonusPoints;
    for (final inv in JannatiCatalog.investments) {
      pts += countFor(inv.id) * inv.pointsPerCompletion;
      pts += cycleProgressFor(inv.id) * inv.pointsPerTap;
    }
    for (final action in JannatiCatalog.dailyArchitectChecklist) {
      if (_dailyCheckedIds.contains(action.id)) {
        pts += action.points;
      }
    }
    return pts;
  }

  /// درجة ازدهار الحديقة التفاعلية (0.0..1.0)
  double get gardenVibrancy {
    final pts = totalJannahPoints + (_tasbihOrchardTrees * 8);
    if (pts <= 0) return 0.14;
    return (0.16 + math.min(0.84, pts / 4200.0)).clamp(0.16, 1.0);
  }

  JannahRankTier get currentRank => _rankForPoints(totalJannahPoints);

  JannahRankTier? get nextRank {
    final current = currentRank;
    final idx = JannatiCatalog.ranks.indexWhere((r) => r.level == current.level);
    if (idx < 0 || idx + 1 >= JannatiCatalog.ranks.length) return null;
    return JannatiCatalog.ranks[idx + 1];
  }

  double get rankProgress {
    final current = currentRank;
    final next = nextRank;
    if (next == null) return 1.0;
    final span = next.minPoints - current.minPoints;
    if (span <= 0) return 1.0;
    return ((totalJannahPoints - current.minPoints) / span).clamp(0.0, 1.0);
  }

  static JannahRankTier _rankForPoints(int points) {
    JannahRankTier tier = JannatiCatalog.ranks.first;
    for (final candidate in JannatiCatalog.ranks) {
      if (points >= candidate.minPoints) {
        tier = candidate;
      }
    }
    return tier;
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      _loadFromPrefs();
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('JannatiProvider init error: $e');
    }
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    final countsRaw = prefs.getString(_kCountsKey);
    if (countsRaw != null && countsRaw.isNotEmpty) {
      try {
        final map = jsonDecode(countsRaw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          _counts[entry.key] = (entry.value as num?)?.toInt() ?? 0;
        }
      } catch (_) {}
    }

    final cyclesRaw = prefs.getString(_kCyclesKey);
    if (cyclesRaw != null && cyclesRaw.isNotEmpty) {
      try {
        final map = jsonDecode(cyclesRaw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          _cycleProgress[entry.key] = (entry.value as num?)?.toInt() ?? 0;
        }
      } catch (_) {}
    }

    final today = _todayKey();
    final savedDate = prefs.getString(_kDailyDateKey) ?? '';
    _dailyDate = today;
    _dailyCheckedIds.clear();
    if (savedDate == today) {
      final list = prefs.getStringList(_kDailyCheckedKey) ?? const [];
      _dailyCheckedIds.addAll(list);
    } else {
      prefs.setString(_kDailyDateKey, today);
      prefs.setStringList(_kDailyCheckedKey, const []);
    }

    final savedBookmarks = prefs.getStringList(_kBookmarksKey);
    if (savedBookmarks != null) {
      _bookmarkedQaIds
        ..clear()
        ..addAll(savedBookmarks);
    }

    final savedAspirations = prefs.getStringList(_kAspirationsKey);
    if (savedAspirations != null && savedAspirations.isNotEmpty) {
      _personalAspirations
        ..clear()
        ..addAll(savedAspirations);
    }

    _bestQuizScore = prefs.getInt(_kBestQuizKey) ?? 0;
    _quizzesCompleted = prefs.getInt(_kQuizCountKey) ?? 0;
    _bonusPoints = prefs.getInt(_kBonusPtsKey) ?? 0;
    _hadithsReadCount = prefs.getInt(_kHadithReadsCountKey) ?? 0;
    _tasbihOrchardTrees = prefs.getInt(_kTasbihOrchardTreesKey) ?? 0;
    _tasbihGrowthStreak = prefs.getInt(_kTasbihGrowthStreakKey) ?? 0;
    _lastTasbihTreeName =
        prefs.getString(_kLastTasbihTreeNameKey) ?? 'نخلة التوحيد الذهبية';
    final savedHadithIds = prefs.getStringList(_kHadithReadIdsKey);
    if (savedHadithIds != null) {
      _readJannahHadithIds
        ..clear()
        ..addAll(savedHadithIds);
    }

    // استرجاع النسخة الاحتياطية الثانية لضمان عدم ضياع أي نقطة أو غِراس أبداً
    final backupRaw = prefs.getString(_kJannatiBackupKey);
    if (backupRaw != null && backupRaw.isNotEmpty) {
      try {
        final bk = jsonDecode(backupRaw) as Map<String, dynamic>;
        final bkCounts = bk['counts'];
        if (bkCounts is Map) {
          for (final e in bkCounts.entries) {
            final key = e.key.toString();
            final val = (e.value as num?)?.toInt() ?? 0;
            if (val > (_counts[key] ?? 0)) _counts[key] = val;
          }
        }
        final bkBestQuiz = (bk['bestQuiz'] as num?)?.toInt() ?? 0;
        if (bkBestQuiz > _bestQuizScore) _bestQuizScore = bkBestQuiz;
        final bkQuizzes = (bk['quizzesCompleted'] as num?)?.toInt() ?? 0;
        if (bkQuizzes > _quizzesCompleted) _quizzesCompleted = bkQuizzes;
        final bkBonus = (bk['bonusPoints'] as num?)?.toInt() ?? 0;
        if (bkBonus > _bonusPoints) _bonusPoints = bkBonus;
        final bkHadiths = (bk['hadithsReadCount'] as num?)?.toInt() ?? 0;
        if (bkHadiths > _hadithsReadCount) _hadithsReadCount = bkHadiths;
        final bkTrees = (bk['tasbihOrchardTrees'] as num?)?.toInt() ?? 0;
        if (bkTrees > _tasbihOrchardTrees) _tasbihOrchardTrees = bkTrees;
        final bkStreak = (bk['tasbihGrowthStreak'] as num?)?.toInt() ?? 0;
        if (bkStreak > _tasbihGrowthStreak) _tasbihGrowthStreak = bkStreak;
        final bkHadithIds = bk['readHadithIds'];
        if (bkHadithIds is List) {
          _readJannahHadithIds.addAll(bkHadithIds.map((e) => e.toString()));
        }
        final bkBookmarks = bk['bookmarks'];
        if (bkBookmarks is List) {
          _bookmarkedQaIds.addAll(bkBookmarks.map((e) => e.toString()));
        }
      } catch (_) {}
    }
    _saveBackupSnapshot();

    final logsRaw = prefs.getString(_kLogsKey);
    if (logsRaw != null && logsRaw.isNotEmpty) {
      try {
        final list = jsonDecode(logsRaw) as List<dynamic>;
        _recentLogs
          ..clear()
          ..addAll(
            list
                .whereType<Map<String, dynamic>>()
                .map(JannahDeedLogItem.fromJson)
                .take(40),
          );
      } catch (_) {}
    }
  }

  void _ensureTodayChecklist() {
    final today = _todayKey();
    if (_dailyDate != today) {
      _dailyDate = today;
      _dailyCheckedIds.clear();
      _prefs?.setString(_kDailyDateKey, today);
      _prefs?.setStringList(_kDailyCheckedKey, const []);
    }
  }

  Future<JannahTapOutcome> performInvestmentTap(String investmentId) async {
    final investment = JannatiCatalog.investments.firstWhere(
      (i) => i.id == investmentId,
      orElse: () => JannatiCatalog.investments.first,
    );

    final rankBefore = currentRank.level;
    bool completedCycle = false;
    int pointsEarned = investment.pointsPerTap;

    if (investment.cycleTarget <= 1) {
      _counts[investment.id] = countFor(investment.id) + 1;
      completedCycle = true;
      pointsEarned = investment.pointsPerCompletion;
    } else {
      final nextProgress = cycleProgressFor(investment.id) + 1;
      if (nextProgress >= investment.cycleTarget) {
        _cycleProgress[investment.id] = 0;
        _counts[investment.id] = countFor(investment.id) + 1;
        completedCycle = true;
        pointsEarned = investment.pointsPerCompletion;
      } else {
        _cycleProgress[investment.id] = nextProgress;
      }
    }

    _recentLogs.insert(
      0,
      JannahDeedLogItem(
        investmentId: investment.id,
        title: completedCycle
            ? '${investment.title} (+١ ${investment.unitSingular})'
            : '${investment.shortLabel} (${cycleProgressFor(investment.id)}/${investment.cycleTarget})',
        timestampIso: DateTime.now().toIso8601String(),
        pointsEarned: pointsEarned,
        completedCycle: completedCycle,
      ),
    );
    if (_recentLogs.length > 40) {
      _recentLogs.removeRange(40, _recentLogs.length);
    }

    final newRank = currentRank;
    final promoted = newRank.level > rankBefore ? newRank : null;
    _statsKineticTick++;

    await _persistCountsAndLogs();
    notifyListeners();

    final countNow = countFor(investment.id);
    final cycleNow = cycleProgressFor(investment.id);
    final msg = completedCycle
        ? 'ما شاء الله! نلت +١ ${investment.unitSingular} في «${investment.shortLabel}» (رصيدك: $countNow) ✨'
        : 'مبارك الخطوة ($cycleNow/${investment.cycleTarget}) نحو ${investment.unitSingular} جديدة في ${investment.shortLabel} 📖';

    return JannahTapOutcome(
      investment: investment,
      newCount: countNow,
      cycleProgress: cycleNow,
      completedCycle: completedCycle,
      pointsEarned: pointsEarned,
      promotedToRank: promoted,
      feedbackMessage: msg,
    );
  }

  Future<bool> toggleDailyAction(String actionId) async {
    _ensureTodayChecklist();
    final added = !_dailyCheckedIds.contains(actionId);
    if (added) {
      _dailyCheckedIds.add(actionId);
      final action = JannatiCatalog.dailyArchitectChecklist.firstWhere(
        (a) => a.id == actionId,
        orElse: () => JannatiCatalog.dailyArchitectChecklist.first,
      );
      _recentLogs.insert(
        0,
        JannahDeedLogItem(
          investmentId: 'daily',
          title: 'ورد يومي: ${action.title}',
          timestampIso: DateTime.now().toIso8601String(),
          pointsEarned: action.points,
          completedCycle: true,
        ),
      );
      if (_recentLogs.length > 40) {
        _recentLogs.removeRange(40, _recentLogs.length);
      }
      await _prefs?.setString(
        _kLogsKey,
        jsonEncode(_recentLogs.map((l) => l.toJson()).toList()),
      );
    } else {
      _dailyCheckedIds.remove(actionId);
    }
    await _prefs?.setString(_kDailyDateKey, _dailyDate);
    await _prefs?.setStringList(_kDailyCheckedKey, _dailyCheckedIds.toList());
    _statsKineticTick++;
    notifyListeners();
    return added;
  }

  /// يسجل قراءة/تصفح حديث نبوي في الجنة ويحرّك الشريط الإحصائي مباشرةً
  Future<bool> markJannahHadithRead(
    String hadithKey, {
    String? title,
    String? sourceRef,
  }) async {
    final isFirstTime = _readJannahHadithIds.add(hadithKey);
    _hadithsReadCount++;
    _bonusPoints += isFirstTime ? 15 : 5;
    _statsKineticTick++;

    _recentLogs.insert(
      0,
      JannahDeedLogItem(
        investmentId: 'hadith',
        title: title != null
            ? 'قراءة حديث: $title'
            : 'تأمل حديث شريف في الجنة ${sourceRef ?? ""}'.trim(),
        timestampIso: DateTime.now().toIso8601String(),
        pointsEarned: isFirstTime ? 15 : 5,
        completedCycle: true,
      ),
    );
    if (_recentLogs.length > 40) {
      _recentLogs.removeRange(40, _recentLogs.length);
    }

    await _prefs?.setInt(_kHadithReadsCountKey, _hadithsReadCount);
    await _prefs?.setStringList(
      _kHadithReadIdsKey,
      _readJannahHadithIds.toList(),
    );
    await _prefs?.setInt(_kBonusPtsKey, _bonusPoints);
    await _prefs?.setString(
      _kLogsKey,
      jsonEncode(_recentLogs.map((l) => l.toJson()).toList()),
    );
    await _saveBackupSnapshot();
    notifyListeners();
    return isFirstTime;
  }

  Future<bool> toggleQaBookmark(String qaId) async {
    final added = !_bookmarkedQaIds.contains(qaId);
    if (added) {
      _bookmarkedQaIds.add(qaId);
    } else {
      _bookmarkedQaIds.remove(qaId);
    }
    await _prefs?.setStringList(_kBookmarksKey, _bookmarkedQaIds.toList());
    await _saveBackupSnapshot();
    notifyListeners();
    return added;
  }

  Future<void> addPersonalAspiration(String wish) async {
    final trimmed = wish.trim();
    if (trimmed.isEmpty) return;
    if (!_personalAspirations.contains(trimmed)) {
      _personalAspirations.insert(0, trimmed);
      await _prefs?.setStringList(_kAspirationsKey, _personalAspirations);
      notifyListeners();
    }
  }

  Future<void> removePersonalAspiration(int index) async {
    if (index < 0 || index >= _personalAspirations.length) return;
    _personalAspirations.removeAt(index);
    await _prefs?.setStringList(_kAspirationsKey, _personalAspirations);
    notifyListeners();
  }

  Future<void> recordQuizResult({
    required int score,
    required int total,
  }) async {
    _quizzesCompleted++;
    if (score > _bestQuizScore) {
      _bestQuizScore = score;
    }
    final earned = score * 20 + (score == total ? 100 : 0);
    _bonusPoints += earned;
    _recentLogs.insert(
      0,
      JannahDeedLogItem(
        investmentId: 'quiz',
        title: 'اختبار المعرفة بالجنة: $score/$total',
        timestampIso: DateTime.now().toIso8601String(),
        pointsEarned: earned,
        completedCycle: true,
      ),
    );
    if (_recentLogs.length > 40) {
      _recentLogs.removeRange(40, _recentLogs.length);
    }
    await _prefs?.setInt(_kBestQuizKey, _bestQuizScore);
    await _prefs?.setInt(_kQuizCountKey, _quizzesCompleted);
    await _prefs?.setInt(_kBonusPtsKey, _bonusPoints);
    await _prefs?.setString(
      _kLogsKey,
      jsonEncode(_recentLogs.map((l) => l.toJson()).toList()),
    );
    await _saveBackupSnapshot();
    _statsKineticTick++;
    notifyListeners();
  }

  Future<void> _saveBackupSnapshot() async {
    try {
      await _prefs?.setString(
        _kJannatiBackupKey,
        jsonEncode({
          'counts': _counts,
          'cycles': _cycleProgress,
          'bestQuiz': _bestQuizScore,
          'quizzesCompleted': _quizzesCompleted,
          'bonusPoints': _bonusPoints,
          'hadithsReadCount': _hadithsReadCount,
          'tasbihOrchardTrees': _tasbihOrchardTrees,
          'tasbihGrowthStreak': _tasbihGrowthStreak,
          'readHadithIds': _readJannahHadithIds.toList(),
          'bookmarks': _bookmarkedQaIds.toList(),
        }),
      );
    } catch (_) {}
  }

  Future<void> _persistCountsAndLogs() async {
    await _prefs?.setString(_kCountsKey, jsonEncode(_counts));
    await _prefs?.setString(_kCyclesKey, jsonEncode(_cycleProgress));
    await _prefs?.setInt(_kBonusPtsKey, _bonusPoints);
    await _prefs?.setInt(_kTasbihOrchardTreesKey, _tasbihOrchardTrees);
    await _prefs?.setInt(_kTasbihGrowthStreakKey, _tasbihGrowthStreak);
    await _prefs?.setString(_kLastTasbihTreeNameKey, _lastTasbihTreeName);
    await _prefs?.setString(
      _kLogsKey,
      jsonEncode(_recentLogs.map((l) => l.toJson()).toList()),
    );
    await _saveBackupSnapshot();
  }

  /// تغرس شجرة أو فسيلة جديدة في رياض «جنتي» بالفردوس مع كل تسبيحة!
  Future<void> recordTasbihForGarden(String dhikrText, {int count = 1}) async {
    if (count <= 0) return;
    _tasbihOrchardTrees += count;
    _tasbihGrowthStreak += count;
    _bonusPoints += count * 2;
    _statsKineticTick++;

    if (dhikrText.contains('الحمد')) {
      _lastTasbihTreeName = 'شجرة الرمان الوارفة بالحمد 🌳';
    } else if (dhikrText.contains('أكبر')) {
      _lastTasbihTreeName = 'نخلة التاج الذهبية السامقة 🌴';
    } else if (dhikrText.contains('لا إله إلا الله')) {
      _lastTasbihTreeName = 'روضات الإخلاص وشجر الياسمين 🌿';
    } else if (dhikrText.contains('صل')) {
      _lastTasbihTreeName = 'سدرة المحبة والكوثر الزاهرة 🌸';
    } else if (dhikrText.contains('استغفر') || dhikrText.contains('أستغفر')) {
      _lastTasbihTreeName = 'روضة المغفرة والأنهار الصافية 🌲';
    } else {
      _lastTasbihTreeName = 'غِراسُ سبحان الله في الفردوس 🌴';
    }

    if (_tasbihOrchardTrees == 1 ||
        _tasbihOrchardTrees % 10 == 0 ||
        count >= 5) {
      _recentLogs.insert(
        0,
        JannahDeedLogItem(
          investmentId: 'tasbih_orchard',
          title:
              'غِراس الفردوس بالتسبيح (+$count • الإجمالي: $_tasbihOrchardTrees نخلة)',
          timestampIso: DateTime.now().toIso8601String(),
          pointsEarned: count * 2,
          completedCycle: true,
        ),
      );
      if (_recentLogs.length > 40) {
        _recentLogs.removeRange(40, _recentLogs.length);
      }
    }

    notifyListeners();
    await _prefs?.setInt(_kTasbihOrchardTreesKey, _tasbihOrchardTrees);
    await _prefs?.setInt(_kTasbihGrowthStreakKey, _tasbihGrowthStreak);
    await _prefs?.setString(_kLastTasbihTreeNameKey, _lastTasbihTreeName);
    await _prefs?.setInt(_kBonusPtsKey, _bonusPoints);
    if (_tasbihOrchardTrees == 1 ||
        _tasbihOrchardTrees % 10 == 0 ||
        count >= 5) {
      await _prefs?.setString(
        _kLogsKey,
        jsonEncode(_recentLogs.map((l) => l.toJson()).toList()),
      );
    }
    await _saveBackupSnapshot();
  }

  /// يضيف ثواباً ومكافأة نقاط في خزينة «جنتي» عند الفوز في المسابقات أو تحديات المعرفة.
  Future<void> recordArenaKnowledgeReward(String title, int points) async {
    if (points <= 0) return;
    _bonusPoints += points;
    _statsKineticTick++;
    _recentLogs.insert(
      0,
      JannahDeedLogItem(
        investmentId: 'arena_reward',
        title: title,
        timestampIso: DateTime.now().toIso8601String(),
        pointsEarned: points,
        completedCycle: true,
      ),
    );
    if (_recentLogs.length > 40) {
      _recentLogs.removeRange(40, _recentLogs.length);
    }
    notifyListeners();
    await _prefs?.setInt(_kBonusPtsKey, _bonusPoints);
    await _prefs?.setString(
      _kLogsKey,
      jsonEncode(_recentLogs.map((l) => l.toJson()).toList()),
    );
    await _saveBackupSnapshot();
  }
}
