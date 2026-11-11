import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge_phrases_800.dart';

enum ChallengerGroup { family, friend }

class ChallengerMember {
  final String id;
  final String name;
  final ChallengerGroup group;
  final String relationLabel;
  final String avatarEmoji;
  final int tasbihCount;
  final int championScore;
  final int winsCount;
  final int lossesCount;

  const ChallengerMember({
    required this.id,
    required this.name,
    required this.group,
    required this.relationLabel,
    required this.avatarEmoji,
    this.tasbihCount = 0,
    this.championScore = 0,
    this.winsCount = 0,
    this.lossesCount = 0,
  });

  ChallengerMember copyWith({
    String? name,
    ChallengerGroup? group,
    String? relationLabel,
    String? avatarEmoji,
    int? tasbihCount,
    int? championScore,
    int? winsCount,
    int? lossesCount,
  }) {
    return ChallengerMember(
      id: id,
      name: name ?? this.name,
      group: group ?? this.group,
      relationLabel: relationLabel ?? this.relationLabel,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      tasbihCount: tasbihCount ?? this.tasbihCount,
      championScore: championScore ?? this.championScore,
      winsCount: winsCount ?? this.winsCount,
      lossesCount: lossesCount ?? this.lossesCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group.name,
        'relationLabel': relationLabel,
        'avatarEmoji': avatarEmoji,
        'tasbihCount': tasbihCount,
        'championScore': championScore,
        'winsCount': winsCount,
        'lossesCount': lossesCount,
      };

  factory ChallengerMember.fromJson(Map<String, dynamic> j) => ChallengerMember(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? 'منافس').toString(),
        group: (j['group'] == 'family')
            ? ChallengerGroup.family
            : ChallengerGroup.friend,
        relationLabel: (j['relationLabel'] ?? 'صديق').toString(),
        avatarEmoji: (j['avatarEmoji'] ?? '🌟').toString(),
        tasbihCount: (j['tasbihCount'] as num?)?.toInt() ?? 0,
        championScore: (j['championScore'] as num?)?.toInt() ?? 0,
        winsCount: (j['winsCount'] as num?)?.toInt() ?? 0,
        lossesCount: (j['lossesCount'] as num?)?.toInt() ?? 0,
      );
}

class ChallengeMatchRecord {
  final String id;
  final String rivalId;
  final String rivalName;
  final String modeTitle;
  final int userScore;
  final int rivalScore;
  final bool won;
  final String phraseShown;
  final String timestampIso;

  const ChallengeMatchRecord({
    required this.id,
    required this.rivalId,
    required this.rivalName,
    required this.modeTitle,
    required this.userScore,
    required this.rivalScore,
    required this.won,
    required this.phraseShown,
    required this.timestampIso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rivalId': rivalId,
        'rivalName': rivalName,
        'modeTitle': modeTitle,
        'userScore': userScore,
        'rivalScore': rivalScore,
        'won': won,
        'phraseShown': phraseShown,
        'timestampIso': timestampIso,
      };

  factory ChallengeMatchRecord.fromJson(Map<String, dynamic> j) =>
      ChallengeMatchRecord(
        id: (j['id'] ?? '').toString(),
        rivalId: (j['rivalId'] ?? '').toString(),
        rivalName: (j['rivalName'] ?? '').toString(),
        modeTitle: (j['modeTitle'] ?? '').toString(),
        userScore: (j['userScore'] as num?)?.toInt() ?? 0,
        rivalScore: (j['rivalScore'] as num?)?.toInt() ?? 0,
        won: j['won'] == true,
        phraseShown: (j['phraseShown'] ?? '').toString(),
        timestampIso: (j['timestampIso'] ?? '').toString(),
      );
}

class DualPlayerPhraseOutcome {
  final String winnerName;
  final String loserName;
  final String winnerPhrase;
  final String loserPhrase;
  final bool isTie;

  const DualPlayerPhraseOutcome({
    required this.winnerName,
    required this.loserName,
    required this.winnerPhrase,
    required this.loserPhrase,
    this.isTie = false,
  });
}

class FamilyChallengeProvider with ChangeNotifier {
  static const _storageKey = 'firdaws_family_challenge_v1';

  bool _isInitialized = false;
  int _userTasbihCount = 0;
  int _userChampionScore = 120;
  int _userWins = 0;
  int _userLosses = 0;
  int _phraseCounter = 0;
  String _selectedRivalId = 'fam_brother';

  String? _lastMatchPhrase;
  bool? _lastMatchWon;
  String? _lastRivalName;
  String? _lastModeTitle;

  List<ChallengerMember> _members = _defaultStarterMembers();
  List<ChallengeMatchRecord> _history = [];

  bool get isInitialized => _isInitialized;
  int get userTasbihCount => _userTasbihCount;
  int get userChampionScore => _userChampionScore;
  int get userWins => _userWins;
  int get userLosses => _userLosses;
  String get selectedRivalId => _selectedRivalId;
  List<ChallengerMember> get members => List.unmodifiable(_members);
  List<ChallengeMatchRecord> get history => List.unmodifiable(_history);

  String? get lastMatchPhrase => _lastMatchPhrase;
  bool? get lastMatchWon => _lastMatchWon;
  String? get lastRivalName => _lastRivalName;
  String? get lastModeTitle => _lastModeTitle;

  ChallengerMember get selectedRival {
    return _members.firstWhere(
      (m) => m.id == _selectedRivalId,
      orElse: () => _members.first,
    );
  }

  static List<ChallengerMember> _defaultStarterMembers() => const [
        ChallengerMember(
          id: 'fam_father',
          name: 'والدي الحبيب',
          group: ChallengerGroup.family,
          relationLabel: 'العائلة • الأب',
          avatarEmoji: '🧔🏻',
          tasbihCount: 340,
          championScore: 280,
          winsCount: 4,
          lossesCount: 2,
        ),
        ChallengerMember(
          id: 'fam_mother',
          name: 'والدتي الغالية',
          group: ChallengerGroup.family,
          relationLabel: 'العائلة • الأم',
          avatarEmoji: '🧕🏻',
          tasbihCount: 520,
          championScore: 310,
          winsCount: 5,
          lossesCount: 1,
        ),
        ChallengerMember(
          id: 'fam_brother',
          name: 'سيف (الأخ)',
          group: ChallengerGroup.family,
          relationLabel: 'العائلة • الأخ',
          avatarEmoji: '🧑🏻',
          tasbihCount: 215,
          championScore: 460,
          winsCount: 6,
          lossesCount: 4,
        ),
        ChallengerMember(
          id: 'fam_sister',
          name: 'مريم (الأخت)',
          group: ChallengerGroup.family,
          relationLabel: 'العائلة • الأخت',
          avatarEmoji: '👩🏻‍🦱',
          tasbihCount: 290,
          championScore: 390,
          winsCount: 5,
          lossesCount: 3,
        ),
        ChallengerMember(
          id: 'frd_omar',
          name: 'عمر',
          group: ChallengerGroup.friend,
          relationLabel: 'الأصدقاء • رفيق الدرب',
          avatarEmoji: '⚡',
          tasbihCount: 410,
          championScore: 540,
          winsCount: 7,
          lossesCount: 3,
        ),
        ChallengerMember(
          id: 'frd_kareem',
          name: 'كريم',
          group: ChallengerGroup.friend,
          relationLabel: 'الأصدقاء • صاحب المنافسة',
          avatarEmoji: '🦁',
          tasbihCount: 165,
          championScore: 320,
          winsCount: 4,
          lossesCount: 5,
        ),
        ChallengerMember(
          id: 'frd_youssef',
          name: 'يوسف',
          group: ChallengerGroup.friend,
          relationLabel: 'الأصدقاء • بطل الساحة',
          avatarEmoji: '🛡️',
          tasbihCount: 245,
          championScore: 495,
          winsCount: 6,
          lossesCount: 2,
        ),
      ];

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        _userTasbihCount = (j['userTasbihCount'] as num?)?.toInt() ?? 0;
        _userChampionScore = (j['userChampionScore'] as num?)?.toInt() ?? 120;
        _userWins = (j['userWins'] as num?)?.toInt() ?? 0;
        _userLosses = (j['userLosses'] as num?)?.toInt() ?? 0;
        _phraseCounter = (j['phraseCounter'] as num?)?.toInt() ?? 0;
        _selectedRivalId =
            (j['selectedRivalId'] ?? 'fam_brother').toString();
        _lastMatchPhrase = j['lastMatchPhrase']?.toString();
        _lastMatchWon = j['lastMatchWon'] as bool?;
        _lastRivalName = j['lastRivalName']?.toString();
        _lastModeTitle = j['lastModeTitle']?.toString();

        final rawMembers = j['members'] as List?;
        if (rawMembers != null && rawMembers.isNotEmpty) {
          _members = rawMembers
              .map((e) => ChallengerMember.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        final rawHist = j['history'] as List?;
        if (rawHist != null) {
          _history = rawHist
              .map((e) =>
                  ChallengeMatchRecord.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('FamilyChallengeProvider init error: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode({
          'userTasbihCount': _userTasbihCount,
          'userChampionScore': _userChampionScore,
          'userWins': _userWins,
          'userLosses': _userLosses,
          'phraseCounter': _phraseCounter,
          'selectedRivalId': _selectedRivalId,
          'lastMatchPhrase': _lastMatchPhrase,
          'lastMatchWon': _lastMatchWon,
          'lastRivalName': _lastRivalName,
          'lastModeTitle': _lastModeTitle,
          'members': _members.map((m) => m.toJson()).toList(),
          'history': _history.take(80).map((h) => h.toJson()).toList(),
        }),
      );
    } catch (e) {
      debugPrint('FamilyChallengeProvider save error: $e');
    }
  }

  void selectRival(String rivalId) {
    if (_members.any((m) => m.id == rivalId)) {
      _selectedRivalId = rivalId;
      notifyListeners();
      _save();
    }
  }

  Future<void> recordUserTasbih(int count) async {
    if (count <= 0) return;
    _userTasbihCount += count;
    // نرفع أيضاً رصيد النقاط بشكل متوازن على الورد
    if (_userTasbihCount % 10 == 0) {
      _userChampionScore += 5;
    }
    notifyListeners();
    await _save();
  }

  Future<void> addMemberTasbihManual(String memberId, int count) async {
    if (count <= 0) return;
    _members = _members
        .map((m) => m.id == memberId
            ? m.copyWith(tasbihCount: m.tasbihCount + count)
            : m)
        .toList();
    notifyListeners();
    await _save();
  }

  Future<void> addChallenger({
    required String name,
    required ChallengerGroup group,
    required String relationLabel,
    String avatarEmoji = '🌟',
    int initialTasbih = 0,
    int initialScore = 100,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final newMember = ChallengerMember(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      group: group,
      relationLabel: relationLabel.trim().isEmpty
          ? (group == ChallengerGroup.family ? 'العائلة' : 'الأصدقاء')
          : relationLabel.trim(),
      avatarEmoji: avatarEmoji,
      tasbihCount: initialTasbih,
      championScore: initialScore,
    );
    _members = [..._members, newMember];
    _selectedRivalId = newMember.id;
    notifyListeners();
    await _save();
  }

  Future<void> removeChallenger(String id) async {
    if (_members.length <= 1) return;
    _members = _members.where((m) => m.id != id).toList();
    if (_selectedRivalId == id) {
      _selectedRivalId = _members.first.id;
    }
    notifyListeners();
    await _save();
  }

  /// تسجيل نتيجة تحدٍّ بين المستخدم وأحد أفراد العائلة أو الأصدقاء،
  /// وإرجاع عبارة من الـ 400 عبارة فوز أو الـ 400 عبارة خسارة.
  Future<String> recordChallengeMatchResult({
    required String userName,
    String? rivalId,
    required String modeTitle,
    required int userScore,
    required int rivalScore,
    bool forceWonIfTie = true,
  }) async {
    final target = rivalId != null
        ? _members.firstWhere((m) => m.id == rivalId, orElse: () => selectedRival)
        : selectedRival;

    final won = userScore > rivalScore ||
        (userScore == rivalScore && forceWonIfTie);
    _phraseCounter++;
    final seed = _phraseCounter + DateTime.now().millisecond + userScore;

    final phrase = won
        ? ChallengePhrasesCatalog.pickWinPhrase(
            seed,
            name: userName,
            rival: target.name,
          )
        : ChallengePhrasesCatalog.pickLosePhrase(
            seed,
            name: userName,
            rival: target.name,
          );

    if (won) {
      _userWins++;
      _userChampionScore += 50 + (userScore ~/ 10).clamp(5, 120);
      _members = _members
          .map((m) => m.id == target.id
              ? m.copyWith(
                  lossesCount: m.lossesCount + 1,
                  championScore: m.championScore + 10,
                )
              : m)
          .toList();
    } else {
      _userLosses++;
      _userChampionScore += 15;
      _members = _members
          .map((m) => m.id == target.id
              ? m.copyWith(
                  winsCount: m.winsCount + 1,
                  championScore: m.championScore + 55,
                )
              : m)
          .toList();
    }

    _lastMatchPhrase = phrase;
    _lastMatchWon = won;
    _lastRivalName = target.name;
    _lastModeTitle = modeTitle;

    _history.insert(
      0,
      ChallengeMatchRecord(
        id: 'match_${DateTime.now().millisecondsSinceEpoch}',
        rivalId: target.id,
        rivalName: target.name,
        modeTitle: modeTitle,
        userScore: userScore,
        rivalScore: rivalScore,
        won: won,
        phraseShown: phrase,
        timestampIso: DateTime.now().toIso8601String(),
      ),
    );
    if (_history.length > 80) {
      _history = _history.take(80).toList();
    }

    notifyListeners();
    await _save();
    return phrase;
  }

  /// توليد عبارتي الفوز والخسارة لمباراة محلية بين لاعبين (مشاركة ٢ في نفس الألعاب)
  DualPlayerPhraseOutcome recordDualPlayerMatch({
    required String player1Name,
    required int player1Score,
    required String player2Name,
    required int player2Score,
    required String modeTitle,
  }) {
    _phraseCounter += 2;
    final p1Won = player1Score >= player2Score;
    final winner = p1Won ? player1Name : player2Name;
    final loser = p1Won ? player2Name : player1Name;

    final winPhrase = ChallengePhrasesCatalog.pickWinPhrase(
      _phraseCounter + player1Score,
      name: winner,
      rival: loser,
    );
    final losePhrase = ChallengePhrasesCatalog.pickLosePhrase(
      _phraseCounter + player2Score + 17,
      name: loser,
      rival: winner,
    );

    if (p1Won) {
      _userWins++;
      _userChampionScore += 45;
    } else {
      _userLosses++;
      _userChampionScore += 15;
    }
    _lastMatchPhrase = p1Won ? winPhrase : losePhrase;
    _lastMatchWon = p1Won;
    _lastRivalName = player2Name;
    _lastModeTitle = '$modeTitle (لاعب ١ ضد لاعب ٢)';

    _history.insert(
      0,
      ChallengeMatchRecord(
        id: 'dual_${DateTime.now().millisecondsSinceEpoch}',
        rivalId: 'local_p2',
        rivalName: player2Name,
        modeTitle: '$modeTitle • ٢ لاعبين',
        userScore: player1Score,
        rivalScore: player2Score,
        won: p1Won,
        phraseShown: _lastMatchPhrase!,
        timestampIso: DateTime.now().toIso8601String(),
      ),
    );
    if (_history.length > 80) {
      _history = _history.take(80).toList();
    }

    notifyListeners();
    _save();

    return DualPlayerPhraseOutcome(
      winnerName: winner,
      loserName: loser,
      winnerPhrase: winPhrase,
      loserPhrase: losePhrase,
      isTie: player1Score == player2Score,
    );
  }

  /// لوحة ترتيب: مين سبّح أكتر؟
  List<LeaderboardEntry> buildTasbihLeaderboard(String userName) {
    final entries = <LeaderboardEntry>[
      LeaderboardEntry(
        id: 'self_user',
        name: '$userName (أنت)',
        relation: 'حسابك الشخصي 🌟',
        emoji: '👑',
        value: _userTasbihCount,
        wins: _userWins,
        losses: _userLosses,
        isCurrentUser: true,
      ),
      ..._members.map(
        (m) => LeaderboardEntry(
          id: m.id,
          name: m.name,
          relation: m.relationLabel,
          emoji: m.avatarEmoji,
          value: m.tasbihCount,
          wins: m.winsCount,
          losses: m.lossesCount,
          isCurrentUser: false,
        ),
      ),
    ];
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// لوحة ترتيب: مين بطل أكتر؟
  List<LeaderboardEntry> buildChampionLeaderboard(String userName) {
    final entries = <LeaderboardEntry>[
      LeaderboardEntry(
        id: 'self_user',
        name: '$userName (أنت)',
        relation: 'حسابك الشخصي 🏆',
        emoji: '👑',
        value: _userChampionScore,
        wins: _userWins,
        losses: _userLosses,
        isCurrentUser: true,
      ),
      ..._members.map(
        (m) => LeaderboardEntry(
          id: m.id,
          name: m.name,
          relation: m.relationLabel,
          emoji: m.avatarEmoji,
          value: m.championScore,
          wins: m.winsCount,
          losses: m.lossesCount,
          isCurrentUser: false,
        ),
      ),
    ];
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}

class LeaderboardEntry {
  final String id;
  final String name;
  final String relation;
  final String emoji;
  final int value;
  final int wins;
  final int losses;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.relation,
    required this.emoji,
    required this.value,
    required this.wins,
    required this.losses,
    required this.isCurrentUser,
  });
}
