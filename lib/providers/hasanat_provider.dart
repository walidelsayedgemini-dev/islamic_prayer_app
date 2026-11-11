import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/events_missions_catalog.dart';
import '../models/hasanat_store_catalog.dart';

class HasanatLedgerEntry {
  final String title;
  final int delta; // + or -
  final String sourceTag;
  final String timestampIso;

  const HasanatLedgerEntry({
    required this.title,
    required this.delta,
    required this.sourceTag,
    required this.timestampIso,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'delta': delta,
        'sourceTag': sourceTag,
        'timestampIso': timestampIso,
      };

  factory HasanatLedgerEntry.fromJson(Map<String, dynamic> json) {
    return HasanatLedgerEntry(
      title: json['title'] as String? ?? 'حركة حسنات',
      delta: (json['delta'] as num?)?.toInt() ?? 0,
      sourceTag: json['sourceTag'] as String? ?? 'عام',
      timestampIso:
          json['timestampIso'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}

class HasanatPurchaseResult {
  final bool success;
  final String message;

  const HasanatPurchaseResult({required this.success, required this.message});
}

class MissionClaimResult {
  final bool success;
  final int hasanatEarned;
  final UnlockableGameEvent? unlockedEvent;
  final String message;

  const MissionClaimResult({
    required this.success,
    required this.hasanatEarned,
    required this.unlockedEvent,
    required this.message,
  });
}

class HasanatProvider extends ChangeNotifier {
  static const String _kBalanceKey = 'hasanat_balance_v1';
  static const String _kLifetimeKey = 'hasanat_lifetime_v1';
  static const String _kOwnedSkinsKey = 'hasanat_owned_skins_v1';
  static const String _kEquippedSkinsKey = 'hasanat_equipped_skins_v1';
  static const String _kMetricsKey = 'hasanat_event_metrics_v1';
  static const String _kClaimedMissionsKey = 'hasanat_claimed_missions_v1';
  static const String _kUnlockedEventsKey = 'hasanat_unlocked_events_v1';
  static const String _kActiveEventKey = 'hasanat_active_event_v1';
  static const String _kLedgerKey = 'hasanat_ledger_v1';

  SharedPreferences? _prefs;
  bool _initialized = false;

  int _hasanatBalance = 220; // رصيد ترحيبي للانطلاق الفوري
  int _lifetimeHasanat = 220;

  final Set<String> _ownedSkinIds = {
    for (final s in HasanatStoreCatalog.allSkins)
      if (s.isDefaultUnlocked) s.id,
  };

  final Map<StoreItemCategory, String> _equippedSkins = {
    for (final c in StoreItemCategory.values)
      c: HasanatStoreCatalog.defaultForCategory(c).id,
  };

  final Map<EventMissionMetric, int> _metricCounters = {
    for (final m in EventMissionMetric.values) m: 0,
  };

  final Set<String> _claimedMissionIds = {};
  final Set<String> _unlockedEventIds = {};
  String? _activeEventId;
  final List<HasanatLedgerEntry> _ledger = [];

  bool get isInitialized => _initialized;
  int get hasanatBalance => _hasanatBalance;
  int get lifetimeHasanat => _lifetimeHasanat;
  Set<String> get ownedSkinIds => Set<String>.unmodifiable(_ownedSkinIds);
  Set<String> get claimedMissionIds =>
      Set<String>.unmodifiable(_claimedMissionIds);
  Set<String> get unlockedEventIds =>
      Set<String>.unmodifiable(_unlockedEventIds);
  String? get activeEventId => _activeEventId;
  List<HasanatLedgerEntry> get ledger => List<HasanatLedgerEntry>.unmodifiable(_ledger);

  UnlockableGameEvent? get activeEvent {
    if (_activeEventId == null) return null;
    if (!_unlockedEventIds.contains(_activeEventId)) return null;
    return EventsMissionsCatalog.eventById(_activeEventId);
  }

  double get activeMultiplier => activeEvent?.hasanatMultiplier ?? 1.0;

  bool ownsSkin(String skinId) => _ownedSkinIds.contains(skinId);

  HasanatSkinItem equippedSkin(StoreItemCategory category) {
    final id = _equippedSkins[category] ??
        HasanatStoreCatalog.defaultForCategory(category).id;
    return HasanatStoreCatalog.byId(id);
  }

  String equippedStyleKey(StoreItemCategory category) =>
      equippedSkin(category).styleKey;

  int metricValue(EventMissionMetric metric) => _metricCounters[metric] ?? 0;

  int missionProgressValue(HasanatMissionSpec mission) =>
      metricValue(mission.metric).clamp(0, mission.targetValue);

  bool isMissionReadyToClaim(HasanatMissionSpec mission) =>
      !_claimedMissionIds.contains(mission.id) &&
      metricValue(mission.metric) >= mission.targetValue;

  int get claimableMissionsCount =>
      EventsMissionsCatalog.missions.where(isMissionReadyToClaim).length;

  bool isEventUnlocked(String eventId) => _unlockedEventIds.contains(eventId);

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      _loadFromPrefs();
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('HasanatProvider init error: $e');
    }
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    _hasanatBalance = prefs.getInt(_kBalanceKey) ?? 220;
    _lifetimeHasanat = prefs.getInt(_kLifetimeKey) ?? _hasanatBalance;

    final owned = prefs.getStringList(_kOwnedSkinsKey);
    if (owned != null) {
      _ownedSkinIds.addAll(owned);
    }

    final equippedRaw = prefs.getString(_kEquippedSkinsKey);
    if (equippedRaw != null && equippedRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(equippedRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final cat = StoreItemCategory.values.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => StoreItemCategory.craftSkin,
          );
          final skinId = entry.value?.toString() ?? '';
          if (skinId.isNotEmpty && _ownedSkinIds.contains(skinId)) {
            _equippedSkins[cat] = skinId;
          }
        }
      } catch (_) {}
    }

    final metricsRaw = prefs.getString(_kMetricsKey);
    if (metricsRaw != null && metricsRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(metricsRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final metric = EventMissionMetric.values.firstWhere(
            (m) => m.name == entry.key,
            orElse: () => EventMissionMetric.tasbihCount,
          );
          _metricCounters[metric] = (entry.value as num?)?.toInt() ?? 0;
        }
      } catch (_) {}
    }

    final claimed = prefs.getStringList(_kClaimedMissionsKey);
    if (claimed != null) {
      _claimedMissionIds
        ..clear()
        ..addAll(claimed);
    }

    final unlockedEvents = prefs.getStringList(_kUnlockedEventsKey);
    if (unlockedEvents != null) {
      _unlockedEventIds
        ..clear()
        ..addAll(unlockedEvents);
    }

    _activeEventId = prefs.getString(_kActiveEventKey);
    if (_activeEventId != null && !_unlockedEventIds.contains(_activeEventId)) {
      _activeEventId = null;
    }

    final ledgerRaw = prefs.getString(_kLedgerKey);
    if (ledgerRaw != null && ledgerRaw.isNotEmpty) {
      try {
        final list = jsonDecode(ledgerRaw) as List<dynamic>;
        _ledger
          ..clear()
          ..addAll(
            list
                .whereType<Map<String, dynamic>>()
                .map(HasanatLedgerEntry.fromJson)
                .take(30),
          );
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance().catchError((_) => throw Exception());
    try {
      await prefs.setInt(_kBalanceKey, _hasanatBalance);
      await prefs.setInt(_kLifetimeKey, _lifetimeHasanat);
      await prefs.setStringList(_kOwnedSkinsKey, _ownedSkinIds.toList());
      await prefs.setString(
        _kEquippedSkinsKey,
        jsonEncode(_equippedSkins.map((k, v) => MapEntry(k.name, v))),
      );
      await prefs.setString(
        _kMetricsKey,
        jsonEncode(_metricCounters.map((k, v) => MapEntry(k.name, v))),
      );
      await prefs.setStringList(
          _kClaimedMissionsKey, _claimedMissionIds.toList());
      await prefs.setStringList(
          _kUnlockedEventsKey, _unlockedEventIds.toList());
      if (_activeEventId != null) {
        await prefs.setString(_kActiveEventKey, _activeEventId!);
      } else {
        await prefs.remove(_kActiveEventKey);
      }
      await prefs.setString(
        _kLedgerKey,
        jsonEncode(_ledger.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// إضافة «حسنات» إلى رصيد المستخدم مع تطبيق مضاعف الحدث النشط تلقائياً إن طُلب
  Future<int> earnHasanat(
    int baseAmount, {
    required String reason,
    String sourceTag = 'نشاط',
    bool applyActiveEventMultiplier = true,
  }) async {
    if (baseAmount <= 0) return 0;
    final ev = applyActiveEventMultiplier ? activeEvent : null;
    final finalAmount = ev != null
        ? (baseAmount * ev.hasanatMultiplier).round()
        : baseAmount;

    _hasanatBalance += finalAmount;
    _lifetimeHasanat += finalAmount;
    _ledger.insert(
      0,
      HasanatLedgerEntry(
        title: ev != null ? '$reason (×${ev.hasanatMultiplier})' : reason,
        delta: finalAmount,
        sourceTag: sourceTag,
        timestampIso: DateTime.now().toIso8601String(),
      ),
    );
    if (_ledger.length > 30) {
      _ledger.removeRange(30, _ledger.length);
    }
    notifyListeners();
    await _save();
    return finalAmount;
  }

  Future<void> recordMetric(
    EventMissionMetric metric, {
    int delta = 1,
  }) async {
    if (delta <= 0) return;
    _metricCounters[metric] = (_metricCounters[metric] ?? 0) + delta;
    notifyListeners();
    await _save();
  }

  Future<HasanatPurchaseResult> buyOrEquipSkin(HasanatSkinItem skin) async {
    if (_ownedSkinIds.contains(skin.id)) {
      _equippedSkins[skin.category] = skin.id;
      notifyListeners();
      await _save();
      return HasanatPurchaseResult(
        success: true,
        message: 'تم تجهيز «${skin.name}» بنجاح ✨',
      );
    }

    if (_hasanatBalance < skin.price) {
      final shortage = skin.price - _hasanatBalance;
      return HasanatPurchaseResult(
        success: false,
        message: 'تحتاج إلى $shortage حسنة إضافية لشراء «${skin.name}» 🪙',
      );
    }

    _hasanatBalance -= skin.price;
    _ownedSkinIds.add(skin.id);
    _equippedSkins[skin.category] = skin.id;
    _ledger.insert(
      0,
      HasanatLedgerEntry(
        title: 'شراء سكن: ${skin.name}',
        delta: -skin.price,
        sourceTag: 'المتجر',
        timestampIso: DateTime.now().toIso8601String(),
      ),
    );
    if (_ledger.length > 30) {
      _ledger.removeRange(30, _ledger.length);
    }

    notifyListeners();
    await _save();
    return HasanatPurchaseResult(
      success: true,
      message: 'مبارك! امتلكت وجهّزت «${skin.name}» (${skin.price} حسنة) 🎉',
    );
  }

  Future<MissionClaimResult> claimMission(String missionId) async {
    final mission = EventsMissionsCatalog.missionById(missionId);
    if (mission == null) {
      return const MissionClaimResult(
        success: false,
        hasanatEarned: 0,
        unlockedEvent: null,
        message: 'المهمة غير موجودة',
      );
    }
    if (_claimedMissionIds.contains(mission.id)) {
      return const MissionClaimResult(
        success: false,
        hasanatEarned: 0,
        unlockedEvent: null,
        message: 'تم استلام مكافأة هذه المهمة مسبقاً',
      );
    }
    if (metricValue(mission.metric) < mission.targetValue) {
      return const MissionClaimResult(
        success: false,
        hasanatEarned: 0,
        unlockedEvent: null,
        message: 'أكمل متطلبات المهمة أولاً لاستلام الجائزة',
      );
    }

    _claimedMissionIds.add(mission.id);
    _hasanatBalance += mission.hasanatReward;
    _lifetimeHasanat += mission.hasanatReward;

    UnlockableGameEvent? unlockedEvent;
    if (mission.unlocksEventId != null) {
      final ev = EventsMissionsCatalog.eventById(mission.unlocksEventId);
      if (ev != null) {
        _unlockedEventIds.add(ev.id);
        _activeEventId ??= ev.id;
        unlockedEvent = ev;
      }
    }

    _ledger.insert(
      0,
      HasanatLedgerEntry(
        title: 'مكافأة مهمة: ${mission.title}',
        delta: mission.hasanatReward,
        sourceTag: 'المهام',
        timestampIso: DateTime.now().toIso8601String(),
      ),
    );
    if (_ledger.length > 30) {
      _ledger.removeRange(30, _ledger.length);
    }

    notifyListeners();
    await _save();

    final msg = unlockedEvent != null
        ? 'نلت +${mission.hasanatReward} حسنة وفتحت حدث «${unlockedEvent.title}»! 🎊'
        : 'مبارك! حصلت على +${mission.hasanatReward} حسنة من إنجاز المهمة 🪙';
    return MissionClaimResult(
      success: true,
      hasanatEarned: mission.hasanatReward,
      unlockedEvent: unlockedEvent,
      message: msg,
    );
  }

  Future<bool> activateEvent(String? eventId) async {
    if (eventId == null) {
      _activeEventId = null;
      notifyListeners();
      await _save();
      return true;
    }
    if (!_unlockedEventIds.contains(eventId)) return false;
    _activeEventId = eventId;
    notifyListeners();
    await _save();
    return true;
  }
}
