import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hoor_companion_data.dart';

class HoorVentMessage {
  final String id;
  final bool isUser;
  final String text;
  final String timestampIso;

  const HoorVentMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestampIso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUser': isUser,
        'text': text,
        'timestampIso': timestampIso,
      };

  factory HoorVentMessage.fromJson(Map<String, dynamic> json) {
    return HoorVentMessage(
      id: json['id'] as String? ?? 'msg',
      isUser: json['isUser'] as bool? ?? true,
      text: json['text'] as String? ?? '',
      timestampIso: json['timestampIso'] as String? ?? '',
    );
  }
}

class HoorCompanionProvider extends ChangeNotifier {
  static const String _kMainKey = 'hoor_companion_v1';
  static const String _kBackupKey = 'hoor_companion_backup_v2';

  SharedPreferences? _prefs;
  bool _initialized = false;

  HoorAppearanceConfig _appearance = const HoorAppearanceConfig();
  int _activeSkinIndex = 0; // 0..999
  int _activeBackdropIndex = 0; // 0..999
  int _activeMovementIndex = 0; // 0..999

  String _activeBubbleText =
      'أهلاً بيك في جنتي يا غالي! أنا حُور رفيقتك في الفردوس.. سبّح واستغفر وشوف رحمة ربنا وبشائر الجنة! 🌸';
  String _activeHadithCitation =
      '«مَنْ قَالَ سُبْحَانَ اللَّهِ العَظِيمِ وَبِحَمْدِهِ غُرِسَتْ لَهُ نَخْلَةٌ فِي الجَنَّةِ» — رواه الترمذي';
  int _interactionCount = 0;
  int _kineticPulseTick = 0;

  bool _floatingGuideEnabled = true;
  bool _guidePopupOpen = false;
  double _floatingGuideX = 0.04;
  double _floatingGuideY = 0.76;
  String _activeScreenRoute = 'prayer_home';

  final List<HoorVentMessage> _ventingHistory = [];

  bool get isInitialized => _initialized;
  HoorAppearanceConfig get appearance => _appearance;
  String get companionName => _appearance.name;
  bool get isMaleCompanion => _appearance.gender == HoorGender.male;
  int get activeSkinIndex => _activeSkinIndex;
  int get activeBackdropIndex => _activeBackdropIndex;
  int get activeMovementIndex => _activeMovementIndex;

  HoorSkinSpec get activeSkin => HoorCatalog.skinByIndex(_activeSkinIndex);
  HoorBackdropSpec get activeBackdrop =>
      HoorCatalog.backdropByIndex(_activeBackdropIndex);
  HoorMovementSpec get activeMovement =>
      HoorCatalog.movementByIndex(_activeMovementIndex);

  /// يضمن العرض النصي فقط داخل الواجهة (بدون نطق صوتي أبداً)
  String get activeBubbleText => _activeBubbleText;
  String get activeHadithCitation => _activeHadithCitation;
  int get interactionCount => _interactionCount;
  int get kineticPulseTick => _kineticPulseTick;

  bool get floatingGuideEnabled => _floatingGuideEnabled;
  bool get guidePopupOpen => _guidePopupOpen;
  double get floatingGuideX => _floatingGuideX;
  double get floatingGuideY => _floatingGuideY;
  String get activeScreenRoute => _activeScreenRoute;
  HoorScreenGuideEntry get currentScreenGuide =>
      HoorCatalog.guideForRoute(_activeScreenRoute);

  List<HoorVentMessage> get ventingHistory =>
      List<HoorVentMessage>.unmodifiable(_ventingHistory);

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      _loadFromPrefs();
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('HoorCompanionProvider init error: $e');
    }
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    Map<String, dynamic>? decoded;
    for (final key in [_kMainKey, _kBackupKey]) {
      final raw = prefs.getString(key);
      if (raw != null && raw.trim().isNotEmpty) {
        try {
          decoded = jsonDecode(raw) as Map<String, dynamic>;
          break;
        } catch (_) {}
      }
    }

    if (decoded != null) {
      final appJson = decoded['appearance'];
      if (appJson is Map<String, dynamic>) {
        _appearance = HoorAppearanceConfig.fromJson(appJson);
      } else if (appJson is Map) {
        _appearance =
            HoorAppearanceConfig.fromJson(Map<String, dynamic>.from(appJson));
      }

      _activeSkinIndex =
          ((decoded['skinIndex'] as num?)?.toInt() ?? 0).clamp(0, 999);
      _activeBackdropIndex =
          ((decoded['backdropIndex'] as num?)?.toInt() ?? 0).clamp(0, 999);
      _activeMovementIndex =
          ((decoded['movementIndex'] as num?)?.toInt() ?? 0).clamp(0, 999);
      _interactionCount =
          math.max(0, (decoded['interactionCount'] as num?)?.toInt() ?? 0);
      _floatingGuideEnabled = decoded['floatingGuideEnabled'] as bool? ?? true;
      _floatingGuideX =
          ((decoded['floatingGuideX'] as num?)?.toDouble() ?? 0.04)
              .clamp(0.02, 0.88);
      _floatingGuideY =
          ((decoded['floatingGuideY'] as num?)?.toDouble() ?? 0.76)
              .clamp(0.08, 0.86);

      final historyRaw = decoded['ventingHistory'];
      if (historyRaw is List) {
        _ventingHistory
          ..clear()
          ..addAll(
            historyRaw
                .whereType<Map>()
                .map((e) => HoorVentMessage.fromJson(Map<String, dynamic>.from(e))),
          );
      }

      // دمج أي تفاعلات أكبر من النسخة الاحتياطية الثانية
      final backupRaw = prefs.getString(_kBackupKey);
      if (backupRaw != null && backupRaw.isNotEmpty) {
        try {
          final bk = jsonDecode(backupRaw) as Map<String, dynamic>;
          final bkCount = (bk['interactionCount'] as num?)?.toInt() ?? 0;
          if (bkCount > _interactionCount) {
            _interactionCount = bkCount;
          }
          final bkHist = bk['ventingHistory'];
          if (bkHist is List && bkHist.length > _ventingHistory.length) {
            _ventingHistory
              ..clear()
              ..addAll(
                bkHist.whereType<Map>().map(
                    (e) => HoorVentMessage.fromJson(Map<String, dynamic>.from(e))),
              );
          }
        } catch (_) {}
      }
    }

    if (_ventingHistory.isEmpty) {
      _ventingHistory.add(
        HoorVentMessage(
          id: 'welcome_init',
          isUser: false,
          text:
              'أهلاً بيك في ركن الفضفضة والمؤانسة الصادقة 🤍\nأنا ${_appearance.name}.. احكي لي أي حاجة شاغلة بالك، وهفكرك دايماً برحمة ربنا والجنة!',
          timestampIso: DateTime.now().toIso8601String(),
        ),
      );
    }
    _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final payload = jsonEncode({
      'appearance': _appearance.toJson(),
      'skinIndex': _activeSkinIndex,
      'backdropIndex': _activeBackdropIndex,
      'movementIndex': _activeMovementIndex,
      'interactionCount': _interactionCount,
      'floatingGuideEnabled': _floatingGuideEnabled,
      'floatingGuideX': _floatingGuideX,
      'floatingGuideY': _floatingGuideY,
      'ventingHistory': _ventingHistory.take(80).map((m) => m.toJson()).toList(),
    });
    await prefs.setString(_kMainKey, payload);
    await prefs.setString(_kBackupKey, payload);
  }

  Future<void> setFloatingGuidePosition(
    double normalizedX,
    double normalizedY, {
    bool persist = true,
  }) async {
    _floatingGuideX = normalizedX.clamp(0.02, 0.88);
    _floatingGuideY = normalizedY.clamp(0.08, 0.86);
    notifyListeners();
    if (persist) {
      await _persist();
    }
  }

  Future<void> selectAnimeStylePreset(int presetIndex) async {
    final safe = ((presetIndex % 24) + 24) % 24;
    _appearance = _appearance.copyWith(
      animeStyleIndex: safe,
      robeColorIndex: safe % 12,
      trimColorIndex: (safe * 3) % 8,
      eyeStyle: safe % 4,
      mouthStyle: safe % 4,
      headwearStyle: safe % 5,
      handheldItem: 1 + (safe % 4),
      auraStyle: 1 + (safe % 3),
    );
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  void setActiveScreenRoute(String routeKey) {
    if (_activeScreenRoute == routeKey) return;
    _activeScreenRoute = routeKey;
    notifyListeners();
  }

  Future<void> toggleFloatingGuide(bool enabled) async {
    _floatingGuideEnabled = enabled;
    if (!enabled) _guidePopupOpen = false;
    notifyListeners();
    await _persist();
  }

  void setGuidePopupOpen(bool open) {
    _guidePopupOpen = open;
    notifyListeners();
  }

  void explainCurrentScreen() {
    final guide = currentScreenGuide;
    _activeBubbleText = '${guide.egyptianIntro}\n💡 نصيحة: ${guide.practicalTip}';
    _activeHadithCitation = '«${guide.paradiseHadith}» — ${guide.hadithSource}';
    _guidePopupOpen = true;
    _kineticPulseTick++;
    notifyListeners();
  }

  Future<void> updateAppearance(HoorAppearanceConfig updated) async {
    _appearance = updated;
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  Future<void> switchGenderAndAutoName(HoorGender gender) async {
    final isCurrentlyDefaultFemale = _appearance.name == 'حُور' ||
        _appearance.name == 'حور';
    final isCurrentlyDefaultMale = _appearance.name == 'نُور الدِّين' ||
        _appearance.name == 'عُمر' ||
        _appearance.name == 'أَنَس';

    String nextName = _appearance.name;
    if (gender == HoorGender.male && isCurrentlyDefaultFemale) {
      nextName = 'نُور الدِّين';
    } else if (gender == HoorGender.female && isCurrentlyDefaultMale) {
      nextName = 'حُور';
    }

    _appearance = _appearance.copyWith(
      gender: gender,
      name: nextName,
      headwearStyle: gender == HoorGender.male ? 1 : 0,
    );
    _activeBubbleText = gender == HoorGender.male
        ? 'أهلاً بيك يا صديقي! أنا ${_appearance.name} رفيقك الجديد في طريق الجنة ✨'
        : 'أهلاً بيك! أنا ${_appearance.name} رفيقتك في واحة الفردوس 🌸';
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  Future<void> selectSkin(int index) async {
    _activeSkinIndex = ((index % 1000) + 1000) % 1000;
    final spec = activeSkin;
    _activeBubbleText =
        'الله! حُلّة "${spec.title}" تجنن أوي! شكراً إنك اخترتها لي ${spec.badgeEmoji}';
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  Future<void> selectBackdrop(int index) async {
    _activeBackdropIndex = ((index % 1000) + 1000) % 1000;
    final spec = activeBackdrop;
    _activeBubbleText =
        'ما أجمل "${spec.title}" في رياض الجنة! ربنا يرزقنا الفردوس الأعلى 🌿';
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  Future<void> selectMovement(int index) async {
    _activeMovementIndex = ((index % 1000) + 1000) % 1000;
    final spec = activeMovement;
    _activeBubbleText = 'حركة "${spec.title}" مفعلة بسلاسة ومرونة تامة ✨';
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  /// استجابة فرفوشة نصية بحتة عند التسبيح أو الاستغفار أو الصلاة على النبي ﷺ
  Future<HoorReplyEntry> onDhikrPerformed({
    required String dhikrType,
    int count = 1,
    String userName = 'صديق الفردوس',
    bool isFemale = false,
  }) async {
    _interactionCount += count;
    _kineticPulseTick++;

    final HoorReplyCategory cat;
    final lower = dhikrType.toLowerCase();
    if (lower.contains('استغفر') || lower.contains('أستغفر')) {
      cat = HoorReplyCategory.istighfar;
    } else if (lower.contains('صل') || lower.contains('نبي')) {
      cat = HoorReplyCategory.salawat;
    } else if (lower.contains('دعاء')) {
      cat = HoorReplyCategory.dua;
    } else {
      cat = HoorReplyCategory.tasbih;
    }

    final reply = HoorCatalog.pickReplyForCategory(
      cat,
      seed: _interactionCount + DateTime.now().millisecond,
      userName: userName,
      isFemale: isFemale,
    );

    _activeBubbleText = reply.egyptianMessage;
    _activeHadithCitation = '«${reply.hadithText}» — ${reply.hadithSource}';
    // تدوير لطيف للحركة المتناسقة كل بضع تفاعلات
    _activeMovementIndex = (_activeMovementIndex + 1) % 1000;

    notifyListeners();
    await _persist();
    return reply;
  }

  Future<HoorReplyEntry> onPrayerCompleted({
    required String prayerName,
    String userName = 'صديق الفردوس',
    bool isFemale = false,
  }) async {
    _interactionCount++;
    _kineticPulseTick++;
    final reply = HoorCatalog.pickReplyForCategory(
      HoorReplyCategory.prayer,
      seed: _interactionCount + prayerName.hashCode,
      userName: userName,
      isFemale: isFemale,
    );
    _activeBubbleText =
        'تقبل الله صلاة $prayerName! ${reply.egyptianMessage}';
    _activeHadithCitation = '«${reply.hadithText}» — ${reply.hadithSource}';
    notifyListeners();
    await _persist();
    return reply;
  }

  Future<HoorReplyEntry> onJannahDeedPerformed({
    required String deedTitle,
    String userName = 'صديق الفردوس',
    bool isFemale = false,
  }) async {
    _interactionCount++;
    _kineticPulseTick++;
    final reply = HoorCatalog.pickReplyForCategory(
      HoorReplyCategory.tasbih,
      seed: _interactionCount + deedTitle.hashCode,
      userName: userName,
      isFemale: isFemale,
    );
    _activeBubbleText = '${reply.egyptianMessage} (تم احتساب: $deedTitle ✨)';
    _activeHadithCitation = '«${reply.hadithText}» — ${reply.hadithSource}';
    notifyListeners();
    await _persist();
    return reply;
  }

  Future<void> triggerManualPraise({
    HoorReplyCategory category = HoorReplyCategory.tasbih,
    String userName = 'صديق الفردوس',
    bool isFemale = false,
  }) async {
    _interactionCount++;
    _kineticPulseTick++;
    final reply = HoorCatalog.pickReplyForCategory(
      category,
      seed: _interactionCount + DateTime.now().second,
      userName: userName,
      isFemale: isFemale,
    );
    _activeBubbleText = reply.egyptianMessage;
    _activeHadithCitation = '«${reply.hadithText}» — ${reply.hadithSource}';
    _activeMovementIndex = (_activeMovementIndex + 3) % 1000;
    notifyListeners();
    await _persist();
  }

  Future<void> sendVentMessage({
    required String text,
    String userName = 'صديق الفردوس',
    bool isFemale = false,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();
    _ventingHistory.add(
      HoorVentMessage(
        id: 'u_${DateTime.now().microsecondsSinceEpoch}',
        isUser: true,
        text: clean,
        timestampIso: nowIso,
      ),
    );

    final response = HoorCatalog.craftVentingResponse(
      clean,
      userName: userName,
      isFemale: isFemale,
      companionName: _appearance.name,
    );

    _ventingHistory.add(
      HoorVentMessage(
        id: 'h_${DateTime.now().microsecondsSinceEpoch + 1}',
        isUser: false,
        text: response,
        timestampIso: DateTime.now().toIso8601String(),
      ),
    );

    if (_ventingHistory.length > 80) {
      _ventingHistory.removeRange(0, _ventingHistory.length - 80);
    }

    _activeBubbleText = response.split('\n').first;
    _interactionCount++;
    _kineticPulseTick++;
    notifyListeners();
    await _persist();
  }

  Future<void> clearVentHistory() async {
    _ventingHistory
      ..clear()
      ..add(
        HoorVentMessage(
          id: 'welcome_reset',
          isUser: false,
          text:
              'صفحة جديدة بيضاء يا غالي 🤍 أنا ${_appearance.name} جاهز أسمعك في أي وقت!',
          timestampIso: DateTime.now().toIso8601String(),
        ),
      );
    notifyListeners();
    await _persist();
  }
}
