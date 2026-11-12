import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/backgrounds_500_catalog.dart';
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
  final int age;
  final List<String> traits;
  final String? customPhotoBase64;
  final String? networkPhotoUrl;
  final int dailyTasbihGoal;
  final String bioNote;

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
    this.age = 25,
    this.traits = const ['صاحب همة'],
    this.customPhotoBase64,
    this.networkPhotoUrl,
    this.dailyTasbihGoal = 100,
    this.bioNote = '',
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
    int? age,
    List<String>? traits,
    String? customPhotoBase64,
    bool clearCustomPhoto = false,
    String? networkPhotoUrl,
    bool clearNetworkPhoto = false,
    int? dailyTasbihGoal,
    String? bioNote,
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
      age: age ?? this.age,
      traits: traits ?? this.traits,
      customPhotoBase64:
          clearCustomPhoto ? null : (customPhotoBase64 ?? this.customPhotoBase64),
      networkPhotoUrl:
          clearNetworkPhoto ? null : (networkPhotoUrl ?? this.networkPhotoUrl),
      dailyTasbihGoal: dailyTasbihGoal ?? this.dailyTasbihGoal,
      bioNote: bioNote ?? this.bioNote,
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
        'age': age,
        'traits': traits,
        'customPhotoBase64': customPhotoBase64,
        'networkPhotoUrl': networkPhotoUrl,
        'dailyTasbihGoal': dailyTasbihGoal,
        'bioNote': bioNote,
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
        age: (j['age'] as num?)?.toInt() ?? 25,
        traits: (j['traits'] as List?)
                ?.map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList() ??
            const ['صاحب همة'],
        customPhotoBase64: j['customPhotoBase64']?.toString(),
        networkPhotoUrl: j['networkPhotoUrl']?.toString(),
        dailyTasbihGoal: (j['dailyTasbihGoal'] as num?)?.toInt() ?? 100,
        bioNote: (j['bioNote'] ?? '').toString(),
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

  static List<ChallengerMember> _defaultStarterMembers() {
    const p = Background500Catalog.personaPortraits50;
    String portrait(int i) => p[i % p.length];
    return [
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
        age: 56,
        traits: const ['محافظ على الفجر', 'واصل للرحم', 'وقور الحكيم'],
        networkPhotoUrl: portrait(0),
        dailyTasbihGoal: 300,
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
        age: 51,
        traits: const ['سبّاحة كثير الذكر', 'قائمة الليل', 'داعية بالخير'],
        networkPhotoUrl: portrait(28),
        dailyTasbihGoal: 500,
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
        age: 24,
        traits: const ['منافس شرس', 'سريع البديهة', 'محافظ على السنن'],
        networkPhotoUrl: portrait(1),
        dailyTasbihGoal: 200,
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
        age: 21,
        traits: const ['حافظة للقرآن', 'صاحبة أذكار', 'عالية الهمة'],
        networkPhotoUrl: portrait(29),
        dailyTasbihGoal: 300,
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
        age: 26,
        traits: const ['صادق الصحبة', 'مثابر', 'سبّاح كثير الذكر'],
        networkPhotoUrl: portrait(2),
        dailyTasbihGoal: 300,
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
        age: 25,
        traits: const ['شجاع الهمة', 'مبادر للخير', 'كريم النفس'],
        networkPhotoUrl: portrait(3),
        dailyTasbihGoal: 150,
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
        age: 27,
        traits: const ['متقن التلاوة', 'صبور', 'صاحب أخلاق رفيعة'],
        networkPhotoUrl: portrait(4),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'fam_grandpa',
        name: 'جدي عبد الرحمن',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الجد',
        avatarEmoji: '🕌',
        tasbihCount: 680,
        championScore: 420,
        winsCount: 8,
        lossesCount: 2,
        age: 74,
        traits: const ['شيخ الوقار', 'ملازم للمسجد', 'قدوة العائلة'],
        networkPhotoUrl: portrait(5),
        dailyTasbihGoal: 600,
      ),
      ChallengerMember(
        id: 'fam_grandma',
        name: 'جدتي زينب',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الجدة',
        avatarEmoji: '🌙',
        tasbihCount: 720,
        championScore: 440,
        winsCount: 9,
        lossesCount: 1,
        age: 70,
        traits: const ['كثيرة الاستغفار', 'بارة رحيمة', 'قائمة السحر'],
        networkPhotoUrl: portrait(30),
        dailyTasbihGoal: 700,
      ),
      ChallengerMember(
        id: 'fam_uncle_mahmoud',
        name: 'عمي محمود',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • العم',
        avatarEmoji: '🌿',
        tasbihCount: 310,
        championScore: 375,
        winsCount: 5,
        lossesCount: 3,
        age: 48,
        traits: const ['واصل للرحم', 'كريم اليد', 'حليم الحكمة'],
        networkPhotoUrl: portrait(6),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'fam_aunt_huda',
        name: 'عمتي هدى',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • العمة',
        avatarEmoji: '🌸',
        tasbihCount: 430,
        championScore: 395,
        winsCount: 6,
        lossesCount: 2,
        age: 45,
        traits: const ['طيبة القلب', 'معلمة قرآن', 'سبّاحة دائمة'],
        networkPhotoUrl: portrait(31),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'fam_khal_mostafa',
        name: 'خالي مصطفى',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الخال',
        avatarEmoji: '⛰️',
        tasbihCount: 270,
        championScore: 360,
        winsCount: 4,
        lossesCount: 3,
        age: 44,
        traits: const ['صادق الوعد', 'محب للسنة', 'شهم المروءة'],
        networkPhotoUrl: portrait(7),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'fam_khalah_suad',
        name: 'خالتي سعاد',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الخالة',
        avatarEmoji: '🌺',
        tasbihCount: 390,
        championScore: 345,
        winsCount: 5,
        lossesCount: 2,
        age: 42,
        traits: const ['صاحبة دعاء', 'هادئة الطبع', 'معينة على الخير'],
        networkPhotoUrl: portrait(32),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'fam_bro_ahmed',
        name: 'أخي أحمد',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الأخ الأكبر',
        avatarEmoji: '🦅',
        tasbihCount: 450,
        championScore: 520,
        winsCount: 8,
        lossesCount: 3,
        age: 30,
        traits: const ['سند الأسرة', 'محافظ على الفجر', 'عاقل متزن'],
        networkPhotoUrl: portrait(8),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'fam_bro_hamza',
        name: 'أخي حمزة',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الأخ الأصغر',
        avatarEmoji: '🔥',
        tasbihCount: 195,
        championScore: 380,
        winsCount: 4,
        lossesCount: 4,
        age: 18,
        traits: const ['نشيط الهمة', 'شغوف بالمعرفة', 'مبتسم دائماً'],
        networkPhotoUrl: portrait(9),
        dailyTasbihGoal: 150,
      ),
      ChallengerMember(
        id: 'fam_sis_aisha',
        name: 'أختي عائشة',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الأخت الكبرى',
        avatarEmoji: '🕊️',
        tasbihCount: 480,
        championScore: 470,
        winsCount: 7,
        lossesCount: 2,
        age: 28,
        traits: const ['مرتّلة مجودة', 'بارّة بوالديها', 'متفائلة'],
        networkPhotoUrl: portrait(33),
        dailyTasbihGoal: 400,
      ),
      ChallengerMember(
        id: 'fam_sis_khadija',
        name: 'أختي خديجة',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • الأخت الصغرى',
        avatarEmoji: '💎',
        tasbihCount: 310,
        championScore: 335,
        winsCount: 5,
        lossesCount: 3,
        age: 19,
        traits: const ['حافظة للأذكار', 'محبة للصدقة', 'لطيفة المعشر'],
        networkPhotoUrl: portrait(34),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'fam_cousin_tariq',
        name: 'ابن عمي طارق',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • ابن العم',
        avatarEmoji: '⚔️',
        tasbihCount: 260,
        championScore: 445,
        winsCount: 6,
        lossesCount: 4,
        age: 24,
        traits: const ['منافس ذكي', 'بارع في السيرة', 'رياضي'],
        networkPhotoUrl: portrait(10),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'fam_cousin_malik',
        name: 'ابن خالي مالك',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • ابن الخال',
        avatarEmoji: '🌟',
        tasbihCount: 305,
        championScore: 410,
        winsCount: 5,
        lossesCount: 3,
        age: 23,
        traits: const ['حافظ لجزء عم', 'أمين', 'خفيف الظل'],
        networkPhotoUrl: portrait(11),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'fam_nephew_yahya',
        name: 'ابن أختي يحيى',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • ابن الأخت',
        avatarEmoji: '🌱',
        tasbihCount: 155,
        championScore: 295,
        winsCount: 3,
        lossesCount: 2,
        age: 14,
        traits: const ['نشء الفجر', 'نبيه', 'كثير السؤال النافع'],
        networkPhotoUrl: portrait(12),
        dailyTasbihGoal: 100,
      ),
      ChallengerMember(
        id: 'fam_cousin_fatima',
        name: 'ابنة عمي فاطمة',
        group: ChallengerGroup.family,
        relationLabel: 'العائلة • ابنة العم',
        avatarEmoji: '🌷',
        tasbihCount: 380,
        championScore: 405,
        winsCount: 6,
        lossesCount: 2,
        age: 22,
        traits: const ['خاشعة الدعاء', 'سديدة الرأي', 'مجتهدة'],
        networkPhotoUrl: portrait(35),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'frd_bilal',
        name: 'صديقي بلال',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • مؤذن الحلقة',
        avatarEmoji: '🎙️',
        tasbihCount: 540,
        championScore: 590,
        winsCount: 8,
        lossesCount: 2,
        age: 26,
        traits: const ['نديّ الصوت', 'سبّاق للجامع', 'أمين السر'],
        networkPhotoUrl: portrait(13),
        dailyTasbihGoal: 400,
      ),
      ChallengerMember(
        id: 'frd_muadh',
        name: 'صديقي معاذ',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • رفيق الفقه',
        avatarEmoji: '📚',
        tasbihCount: 410,
        championScore: 615,
        winsCount: 9,
        lossesCount: 2,
        age: 28,
        traits: const ['فقيه اللسان', 'بشوش الوجه', 'ناصح صادق'],
        networkPhotoUrl: portrait(14),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'frd_khalid',
        name: 'صديقي خالد',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • فارس الميدان',
        avatarEmoji: '🐎',
        tasbihCount: 330,
        championScore: 510,
        winsCount: 7,
        lossesCount: 3,
        age: 29,
        traits: const ['حازم العزيمة', 'مقدام', 'محافظ على الوتر'],
        networkPhotoUrl: portrait(15),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'frd_anas',
        name: 'صديقي أنس',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • خادم الخير',
        avatarEmoji: '☀️',
        tasbihCount: 465,
        championScore: 485,
        winsCount: 6,
        lossesCount: 3,
        age: 25,
        traits: const ['رقيق القلب', 'سريع العون', 'كثير الذكر'],
        networkPhotoUrl: portrait(16),
        dailyTasbihGoal: 350,
      ),
      ChallengerMember(
        id: 'frd_hossam',
        name: 'صديقي حسام',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • بطل الألغاز',
        avatarEmoji: '🧩',
        tasbihCount: 230,
        championScore: 470,
        winsCount: 6,
        lossesCount: 4,
        age: 24,
        traits: const ['ذكي سريع الحساب', 'صبور', 'طيب السيرة'],
        networkPhotoUrl: portrait(17),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'frd_ziyad',
        name: 'صديقي زياد',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • صاحب النور',
        avatarEmoji: '✨',
        tasbihCount: 380,
        championScore: 430,
        winsCount: 5,
        lossesCount: 3,
        age: 23,
        traits: const ['منير البسمة', 'واصل للأصحاب', 'مخلص'],
        networkPhotoUrl: portrait(18),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'frd_abdullah',
        name: 'صديقي عبد الله',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • رفيق القرآن',
        avatarEmoji: '📖',
        tasbihCount: 610,
        championScore: 640,
        winsCount: 10,
        lossesCount: 2,
        age: 27,
        traits: const ['حافظ كتاب الله', 'تقي نقي', 'صاحب خشوع'],
        networkPhotoUrl: portrait(19),
        dailyTasbihGoal: 500,
      ),
      ChallengerMember(
        id: 'frd_yassin',
        name: 'صديقي ياسين',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • زميل الدراسة',
        avatarEmoji: '🎓',
        tasbihCount: 295,
        championScore: 395,
        winsCount: 5,
        lossesCount: 4,
        age: 22,
        traits: const ['متفوق مجتهد', 'منضبط الوقت', 'محب للسنة'],
        networkPhotoUrl: portrait(20),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'frd_rayyan',
        name: 'صديقي ريان',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • صائم النوافل',
        avatarEmoji: '🌴',
        tasbihCount: 490,
        championScore: 530,
        winsCount: 7,
        lossesCount: 2,
        age: 26,
        traits: const ['صائم الاثنين والخميس', 'جواد كريم', 'متواضع'],
        networkPhotoUrl: portrait(21),
        dailyTasbihGoal: 350,
      ),
      ChallengerMember(
        id: 'frd_ilyas',
        name: 'صديقي إلياس',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • محب التاريخ الإسلامي',
        avatarEmoji: '🏰',
        tasbihCount: 255,
        championScore: 455,
        winsCount: 6,
        lossesCount: 3,
        age: 28,
        traits: const ['قارئ للتاريخ', 'فصيح اللسان', 'شجاع الرأي'],
        networkPhotoUrl: portrait(22),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'frd_ibrahim',
        name: 'صديقي إبراهيم',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • أخ كريم',
        avatarEmoji: '🤝',
        tasbihCount: 360,
        championScore: 480,
        winsCount: 6,
        lossesCount: 2,
        age: 31,
        traits: const ['إمام الجماعة', 'حكيم متأنٍ', 'سخي البذل'],
        networkPhotoUrl: portrait(23),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'frd_suleiman',
        name: 'صديقي سليمان',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • خبير السيرة',
        avatarEmoji: '🦅',
        tasbihCount: 315,
        championScore: 505,
        winsCount: 7,
        lossesCount: 3,
        age: 32,
        traits: const ['عالم بالسيرة', 'شهم الموقف', 'صبور'],
        networkPhotoUrl: portrait(24),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'frd_marwan',
        name: 'صديقي مروان',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • فارس التحديات',
        avatarEmoji: '⚡',
        tasbihCount: 210,
        championScore: 425,
        winsCount: 5,
        lossesCount: 4,
        age: 24,
        traits: const ['منافس لا ييأس', 'طيب العشرة', 'مبادر'],
        networkPhotoUrl: portrait(25),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'frd_faris',
        name: 'صديقي فارس',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • بطل السرعة',
        avatarEmoji: '🏆',
        tasbihCount: 285,
        championScore: 495,
        winsCount: 6,
        lossesCount: 3,
        age: 23,
        traits: const ['قوي الهمة', 'صادق القول', 'نشيط'],
        networkPhotoUrl: portrait(26),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'frd_tamer',
        name: 'صديقي تامر',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • زميل العمل',
        avatarEmoji: '💼',
        tasbihCount: 240,
        championScore: 370,
        winsCount: 4,
        lossesCount: 4,
        age: 29,
        traits: const ['متقن لعمله', 'معين لإخوانه', 'متوكل على الله'],
        networkPhotoUrl: portrait(27),
        dailyTasbihGoal: 200,
      ),
      ChallengerMember(
        id: 'frd_sufyan',
        name: 'صديقي سفيان',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • صاحب السنة',
        avatarEmoji: '🌙',
        tasbihCount: 470,
        championScore: 550,
        winsCount: 8,
        lossesCount: 2,
        age: 27,
        traits: const ['متبع للأثر', 'زاهد القلب', 'صادق الحديث'],
        networkPhotoUrl: portrait(36),
        dailyTasbihGoal: 400,
      ),
      ChallengerMember(
        id: 'frd_hudhayfa',
        name: 'صديقي حذيفة',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • حافظ السر',
        avatarEmoji: '🛡️',
        tasbihCount: 350,
        championScore: 460,
        winsCount: 6,
        lossesCount: 3,
        age: 26,
        traits: const ['كتوم أمين', 'بصير بالفتن', 'كثير الاستغفار'],
        networkPhotoUrl: portrait(37),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'frd_musab',
        name: 'صديقي مصعب',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • داعي الخير',
        avatarEmoji: '🕊️',
        tasbihCount: 420,
        championScore: 515,
        winsCount: 7,
        lossesCount: 2,
        age: 24,
        traits: const ['لبق الدعوة', 'صاحب خلق حسن', 'صبور'],
        networkPhotoUrl: portrait(38),
        dailyTasbihGoal: 350,
      ),
      ChallengerMember(
        id: 'frd_ammar',
        name: 'صديقي عمار',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • عامر المسجد',
        avatarEmoji: '🕌',
        tasbihCount: 510,
        championScore: 565,
        winsCount: 8,
        lossesCount: 3,
        age: 30,
        traits: const ['ثابت العقيدة', 'صاحب قيام', 'رقيق القلب'],
        networkPhotoUrl: portrait(39),
        dailyTasbihGoal: 400,
      ),
      ChallengerMember(
        id: 'frd_suhaib',
        name: 'صديقي صهيب',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • التاجر الصدوق',
        avatarEmoji: '⚖️',
        tasbihCount: 280,
        championScore: 440,
        winsCount: 5,
        lossesCount: 3,
        age: 28,
        traits: const ['سخي الصدقة', 'صادق المعاملة', 'بشوش'],
        networkPhotoUrl: portrait(40),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'frd_usama',
        name: 'صديقي أسامة',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • همة الشباب',
        avatarEmoji: '🦁',
        tasbihCount: 310,
        championScore: 475,
        winsCount: 6,
        lossesCount: 3,
        age: 21,
        traits: const ['شجاع القلب', 'مقدام الطاعة', 'بارّ'],
        networkPhotoUrl: portrait(41),
        dailyTasbihGoal: 250,
      ),
      ChallengerMember(
        id: 'frd_talha',
        name: 'صديقي طلحة',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • الجود والكرم',
        avatarEmoji: '🌾',
        tasbihCount: 390,
        championScore: 490,
        winsCount: 6,
        lossesCount: 2,
        age: 29,
        traits: const ['طلحة الخير', 'كريم اليد', 'نصير للمظلوم'],
        networkPhotoUrl: portrait(42),
        dailyTasbihGoal: 300,
      ),
      ChallengerMember(
        id: 'frd_salman',
        name: 'صديقي سلمان',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • باحث عن الحكمة',
        avatarEmoji: '🧭',
        tasbihCount: 445,
        championScore: 535,
        winsCount: 7,
        lossesCount: 2,
        age: 33,
        traits: const ['كثير البحث', 'صاحب تدبر', 'متواضع'],
        networkPhotoUrl: portrait(43),
        dailyTasbihGoal: 350,
      ),
      ChallengerMember(
        id: 'frd_othman',
        name: 'رفيقي في القرآن عثمان',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • صاحب الحياء',
        avatarEmoji: '📜',
        tasbihCount: 580,
        championScore: 605,
        winsCount: 9,
        lossesCount: 2,
        age: 27,
        traits: const ['كريم الحياء', 'قائم بالقرآن', 'هادئ النفس'],
        networkPhotoUrl: portrait(44),
        dailyTasbihGoal: 500,
      ),
      ChallengerMember(
        id: 'frd_abubakr',
        name: 'جارنا الصالح أبو بكر',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • الجار الوفي',
        avatarEmoji: '🤍',
        tasbihCount: 620,
        championScore: 630,
        winsCount: 9,
        lossesCount: 1,
        age: 40,
        traits: const ['سبّاق إلى الخيرات', 'صادق الصداقة', 'سريع البكاء'],
        networkPhotoUrl: portrait(45),
        dailyTasbihGoal: 500,
      ),
      ChallengerMember(
        id: 'frd_hasan',
        name: 'زميل الفجر حسن',
        group: ChallengerGroup.friend,
        relationLabel: 'الأصدقاء • رفيق الفجر',
        avatarEmoji: '🌅',
        tasbihCount: 375,
        championScore: 465,
        winsCount: 6,
        lossesCount: 3,
        age: 25,
        traits: const ['محافظ على الفجر', 'نقي السريرة', 'متفائل'],
        networkPhotoUrl: portrait(46),
        dailyTasbihGoal: 300,
      ),
    ];
  }

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
          final loaded = rawMembers
              .map((e) => ChallengerMember.fromJson(e as Map<String, dynamic>))
              .toList();
          final starters = _defaultStarterMembers();
          final starterById = {for (final s in starters) s.id: s};
          final existingIds = <String>{};
          final merged = <ChallengerMember>[];

          for (final m in loaded) {
            existingIds.add(m.id);
            final st = starterById[m.id];
            if (st != null &&
                (m.networkPhotoUrl == null || m.networkPhotoUrl!.isEmpty)) {
              merged.add(
                m.copyWith(
                  networkPhotoUrl: st.networkPhotoUrl,
                  age: m.age == 25 ? st.age : m.age,
                  traits: (m.traits.length == 1 && m.traits.first == 'صاحب همة')
                      ? st.traits
                      : m.traits,
                  dailyTasbihGoal: m.dailyTasbihGoal == 100
                      ? st.dailyTasbihGoal
                      : m.dailyTasbihGoal,
                ),
              );
            } else {
              merged.add(m);
            }
          }
          for (final st in starters) {
            if (!existingIds.contains(st.id)) {
              merged.add(st);
            }
          }
          _members = merged;
        } else {
          _members = _defaultStarterMembers();
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
    int age = 25,
    List<String> traits = const ['صاحب همة'],
    String? customPhotoBase64,
    String? networkPhotoUrl,
    int dailyTasbihGoal = 100,
    String bioNote = '',
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    const pList = Background500Catalog.personaPortraits50;
    final resolvedNet = (networkPhotoUrl != null && networkPhotoUrl.isNotEmpty)
        ? networkPhotoUrl
        : pList[_members.length % pList.length];
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
      age: age.clamp(5, 110),
      traits: traits.isEmpty ? const ['صاحب همة'] : List<String>.from(traits),
      customPhotoBase64: customPhotoBase64,
      networkPhotoUrl: resolvedNet,
      dailyTasbihGoal: dailyTasbihGoal.clamp(10, 10000),
      bioNote: bioNote.trim(),
    );
    _members = [newMember, ..._members];
    _selectedRivalId = newMember.id;
    notifyListeners();
    await _save();
  }

  Future<void> updateChallenger(ChallengerMember updated) async {
    final idx = _members.indexWhere((m) => m.id == updated.id);
    if (idx == -1) return;
    final copy = List<ChallengerMember>.from(_members);
    copy[idx] = updated;
    _members = copy;
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
          group: m.group,
          age: m.age,
          traits: m.traits,
          customPhotoBase64: m.customPhotoBase64,
          networkPhotoUrl: m.networkPhotoUrl,
          dailyTasbihGoal: m.dailyTasbihGoal,
          memberRef: m,
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
          group: m.group,
          age: m.age,
          traits: m.traits,
          customPhotoBase64: m.customPhotoBase64,
          networkPhotoUrl: m.networkPhotoUrl,
          dailyTasbihGoal: m.dailyTasbihGoal,
          memberRef: m,
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
  final ChallengerGroup? group;
  final int age;
  final List<String> traits;
  final String? customPhotoBase64;
  final String? networkPhotoUrl;
  final int dailyTasbihGoal;
  final ChallengerMember? memberRef;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.relation,
    required this.emoji,
    required this.value,
    required this.wins,
    required this.losses,
    required this.isCurrentUser,
    this.group,
    this.age = 25,
    this.traits = const [],
    this.customPhotoBase64,
    this.networkPhotoUrl,
    this.dailyTasbihGoal = 100,
    this.memberRef,
  });
}
