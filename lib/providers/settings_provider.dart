import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/adhan_skin_catalog.dart';
import '../models/font_catalog.dart';
import '../models/prayer_alarm_preference.dart';
import '../models/prayer_model.dart';
import '../services/arena_sfx_service.dart';
import '../services/firdaws_native_service.dart';
import '../services/location_clock.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../theme/islamic_theme.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    Future<DetectedLocationResult> Function()? locationDetector,
  }) : _locationDetector =
            locationDetector ?? LocationService.detectCurrentLocation;

  final Future<DetectedLocationResult> Function() _locationDetector;
  SharedPreferences? _prefs;
  int _locationRequestGeneration = 0;

  // القيم الافتراضية لتطبيق الفردوس
  CalculationMethod _calculationMethod = CalculationMethod.umm_al_qura;
  Madhab _madhab = Madhab.shafi;
  String _selectedTheme = 'emerald_gold';
  String _selectedFont = 'Cairo';
  String _brightnessMode = 'day'; // 'night', 'day', 'auto'
  String? _selectedAppWallpaperAsset;
  String? _selectedGardenWallpaperAsset;
  int _selectedJannatiSceneryIndex =
      0; // 0..99 (من الـ 100 صورة 4K لجنتي - اختيار يدوي فقط)
  bool _jannatiAutoCycleScenery = false;
  int _selectedTasbihBackdropIndex =
      0; // 0..29 (تتغير تلقائياً كل 100 تسبيحة عبر 30 صورة إسلامية)
  int _lastTasbihStageMilestone = 0;
  bool _ambientSparklesEnabled = false;
  int _ambientShapePresetIndex = 0; // 0..499 (500 شكل طبيعي هادئ قابل للتخصيص)
  bool _gameSfxEnabled = true;
  String _adhanVoice = 'madinah';
  String _adhanSkinId = AdhanSkinCatalog.defaultId;
  bool _isAutoLocation = true;
  double _latitude = 24.7136; // افتراضي مؤقت حتى يكتشف الجهاز بلدك ومدينتك
  double _longitude = 46.6753;
  String _cityName = "جاري تحديد مدينتك وبلدك...";
  String _locationSourceLabel = 'إحداثيات مؤقتة غير مؤكدة';
  bool _hasConfirmedLocation = false;
  bool _isDetectingLocation = false;
  String _lastLocationStatus = 'لم يتم الفحص بعد';
  String? _lastLocationError;
  bool _playPreAdhanReminder = true;
  int _preAdhanReminderMinutes = 15;
  bool _autoMuteDuringPrayer = false;
  bool _isInitialized = false;
  bool _firstRunSetupCompleted = false;
  bool? _lastPublishedNightMode;

  // 200 تأثير تفاعلي للمس وحركة المؤشر والماوس
  bool _touchEffectsEnabled = false;
  int _touchEffectNumber = 1; // 1..200
  bool _touchEffectsAutoCycle = false;

  // التذكير العائم بالصلاة على النبي ﷺ فوق كل التطبيقات
  bool _salawatOverlayEnabled = false;
  int _salawatIntervalMinutes = 30;
  List<String> _salawatCustomTimes = ['09:00', '13:30', '20:00'];

  // إزاحات التوقيت بالدقائق (+ أو -)
  Map<String, int> _offsets = {
    'fajr': 0,
    'dhuhr': 0,
    'asr': 0,
    'maghrib': 0,
    'isha': 0,
  };
  final Map<String, Map<String, int>> _offsetProfiles = {};
  Map<String, PrayerAlarmPreference> _prayerAlarmPreferences = {
    for (final key in _prayerOffsetKeys) key: const PrayerAlarmPreference(),
  };

  static const Set<String> _prayerOffsetKeys = {
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  };

  CalculationMethod get calculationMethod => _calculationMethod;
  Madhab get madhab => _madhab;
  String get selectedTheme => _selectedTheme;
  String get selectedFont => _selectedFont;
  String get brightnessMode => _brightnessMode;
  String? get selectedAppWallpaperAsset => _selectedAppWallpaperAsset;
  String? get selectedGardenWallpaperAsset => _selectedGardenWallpaperAsset;
  int get selectedJannatiSceneryIndex => _selectedJannatiSceneryIndex;
  bool get jannatiAutoCycleScenery => _jannatiAutoCycleScenery;
  Background4KEntry get activeJannatiScenery =>
      Background500Catalog.jannatiByIndex(_selectedJannatiSceneryIndex);
  int get selectedTasbihBackdropIndex => _selectedTasbihBackdropIndex;
  Background4KEntry get activeTasbihBackdrop =>
      Background500Catalog.forTasbihStage(_selectedTasbihBackdropIndex);
  bool get ambientSparklesEnabled => _ambientSparklesEnabled;
  int get ambientShapePresetIndex => _ambientShapePresetIndex;
  bool get gameSfxEnabled => _gameSfxEnabled;
  String get adhanVoice => _adhanVoice;
  String get adhanSkinId => _adhanSkinId;
  bool get isAutoLocation => _isAutoLocation;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get cityName => _cityName;

  /// IANA zone of the selected/detected location. Null means the device zone.
  String? get timeZoneId => _timeZoneId;
  String? _timeZoneId;

  void _setTimeZone(String? id) {
    LocationClock.setZoneId(id);
    _timeZoneId = LocationClock.zoneId;
    if (_timeZoneId == null) {
      _prefs?.remove('tz_id');
    } else {
      _prefs?.setString('tz_id', _timeZoneId!);
    }
  }

  String? _presetZoneFor(double lat, double lng) {
    final city = LocationService.findNearestPresetCity(lat, lng);
    return city == null ? null : LocationClock.zoneIdForPresetName(city.name);
  }

  String get locationSourceLabel => _locationSourceLabel;
  bool get hasConfirmedLocation => _hasConfirmedLocation;
  bool get isDetectingLocation => _isDetectingLocation;
  String get lastLocationStatus => _lastLocationStatus;
  String? get lastLocationError => _lastLocationError;
  bool get playPreAdhanReminder => _playPreAdhanReminder;
  int get preAdhanReminderMinutes => _preAdhanReminderMinutes;
  bool get autoMuteDuringPrayer => _autoMuteDuringPrayer;
  Map<String, int> get offsets => Map.unmodifiable(_offsets);
  Map<String, PrayerAlarmPreference> get prayerAlarmPreferences =>
      Map.unmodifiable(_prayerAlarmPreferences);
  PrayerAlarmPreference prayerAlarmPreference(String key) =>
      _prayerAlarmPreferences[key] ?? const PrayerAlarmPreference();
  bool get isInitialized => _isInitialized;
  bool get shouldShowFirstRunSetup =>
      _isInitialized && !_firstRunSetupCompleted;

  bool get touchEffectsEnabled => _touchEffectsEnabled;
  int get touchEffectNumber => _touchEffectNumber;
  bool get touchEffectsAutoCycle => _touchEffectsAutoCycle;

  bool get salawatOverlayEnabled => _salawatOverlayEnabled;
  int get salawatIntervalMinutes => _salawatIntervalMinutes;
  List<String> get salawatCustomTimes => List.unmodifiable(_salawatCustomTimes);

  ThemePalette get currentPalette =>
      IslamicTheme.resolvePalette(_selectedTheme, isNight: isNightEffective);

  /// تحديد ما إذا كان الوضع الليلي مفعلاً حالياً (يدوياً أو تلقائياً مع المغرب والفجر)
  bool get isNightEffective {
    if (_brightnessMode == 'night') return true;
    if (_brightnessMode == 'day') return false;
    if (_brightnessMode == 'system') {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }

    try {
      final todayPrayers = AdvancedPrayerTimes.calculate(
        latitude: _latitude,
        longitude: _longitude,
        method: _calculationMethod,
        madhab: _madhab,
        offsets: _offsets,
      ).prayerTimes;
      final current = todayPrayers.currentPrayer();
      return current == Prayer.maghrib ||
          current == Prayer.isha ||
          current == Prayer.fajr ||
          current == Prayer.none;
    } catch (_) {
      final h = DateTime.now().hour;
      return h >= 18 || h < 6;
    }
  }

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadPreferences();
    } catch (e) {
      debugPrint("Prefs init error: $e");
    }
  }

  void _loadPreferences() {
    if (_prefs == null) return;

    final hadExistingPreferences = _prefs!.getKeys().isNotEmpty;
    _firstRunSetupCompleted =
        _prefs!.getBool('first_run_setup_v1') ?? hadExistingPreferences;
    if (_firstRunSetupCompleted) {
      _prefs!.setBool('first_run_setup_v1', true);
    }

    final methodIndex = _prefs!.getInt('calc_method');
    if (methodIndex != null && methodIndex < CalculationMethod.values.length) {
      _calculationMethod = CalculationMethod.values[methodIndex];
    } else {
      _calculationMethod = CalculationMethod.umm_al_qura;
    }

    final madhabIndex = _prefs!.getInt('madhab');
    if (madhabIndex != null && madhabIndex < Madhab.values.length) {
      _madhab = Madhab.values[madhabIndex];
    } else {
      _madhab = Madhab.shafi;
    }

    final savedTheme = _prefs!.getString('theme') ?? 'emerald_gold';
    _selectedTheme = savedTheme == 'emerald' ? 'emerald_gold' : savedTheme;

    final savedFont = _prefs!.getString('app_font') ?? 'Cairo';
    _selectedFont = FontCatalog.getByFamily(savedFont).family;

    final savedAppWp = _prefs!.getString('app_wallpaper_4k');
    _selectedAppWallpaperAsset =
        (savedAppWp != null && savedAppWp.trim().isNotEmpty)
            ? savedAppWp
            : null;

    final savedGardenWp = _prefs!.getString('garden_wallpaper_4k');
    _selectedGardenWallpaperAsset =
        (savedGardenWp != null && savedGardenWp.trim().isNotEmpty)
            ? savedGardenWp
            : null;

    _selectedJannatiSceneryIndex =
        (_prefs!.getInt('jannati_scenery_idx_100') ?? 0).clamp(0, 99);
    _jannatiAutoCycleScenery =
        _prefs!.getBool('jannati_scenery_autocycle_v2') ?? false;
    _selectedTasbihBackdropIndex =
        (_prefs!.getInt('tasbih_backdrop_idx_30') ?? 0).clamp(0, 29);
    _lastTasbihStageMilestone =
        _prefs!.getInt('tasbih_backdrop_milestone') ?? 0;
    _ambientSparklesEnabled =
        _prefs!.getBool('ambient_sparkles_enabled') ?? false;
    _ambientShapePresetIndex =
        (_prefs!.getInt('ambient_shape_preset_idx') ?? 0).clamp(0, 499);

    _gameSfxEnabled = _prefs!.getBool('game_sfx_enabled') ?? true;
    ArenaSfxService.instance.setEnabled(_gameSfxEnabled);

    final savedBrightness = _prefs!.getString('brightness_mode') ?? 'day';
    if (savedBrightness == 'day' ||
        savedBrightness == 'night' ||
        savedBrightness == 'auto' ||
        savedBrightness == 'system') {
      _brightnessMode = savedBrightness;
    }

    _adhanVoice = _prefs!.getString('adhan_voice') ?? 'madinah';
    _adhanSkinId = AdhanSkinCatalog.byId(
      _prefs!.getString('adhan_skin_id') ?? AdhanSkinCatalog.defaultId,
    ).id;
    _isAutoLocation = _prefs!.getBool('auto_loc') ?? true;
    final savedLatitude = _prefs!.getDouble('lat');
    final savedLongitude = _prefs!.getDouble('lng');
    _latitude = savedLatitude ?? 24.7136;
    _longitude = savedLongitude ?? 46.6753;
    _timeZoneId = _prefs!.getString('tz_id');
    LocationClock.setZoneId(_timeZoneId);
    final savedCity = _prefs!.getString('city_name');
    final hasSavedLocation = savedLatitude != null &&
        savedLongitude != null &&
        savedCity != null &&
        savedCity.trim().isNotEmpty &&
        savedCity != "الموقع الحالي المكتشف (GPS)" &&
        !savedCity.contains('جاري');
    if (hasSavedLocation) {
      _cityName = savedCity;
      _hasConfirmedLocation = true;
      _locationSourceLabel = _prefs!.getString('location_source') ??
          (_isAutoLocation
              ? 'موقع محفوظ سابقاً'
              : 'اختيار يدوي من قائمة المدن');
      _lastLocationStatus = _isAutoLocation
          ? 'موقع محفوظ سابقاً؛ قد يتغير بعد التحديث'
          : 'مدينة مختارة يدوياً';
    } else {
      _cityName = _isAutoLocation
          ? 'جارٍ تحديد موقعك تلقائياً...'
          : 'لم تُحدّد مدينة بعد';
      _locationSourceLabel = 'إحداثيات مؤقتة غير مؤكدة';
      _hasConfirmedLocation = false;
      _lastLocationStatus = 'موقع غير مؤكد';
    }

    _playPreAdhanReminder = _prefs!.getBool('pre_adhan_reminder') ?? true;
    _preAdhanReminderMinutes =
        (_prefs!.getInt('pre_adhan_reminder_minutes') ?? 15).clamp(5, 60);
    _autoMuteDuringPrayer = _prefs!.getBool('auto_mute') ?? false;

    _touchEffectsEnabled = _prefs!.getBool('touch_fx_enabled') ?? false;
    _touchEffectNumber = (_prefs!.getInt('touch_fx_number') ?? 1).clamp(1, 200);
    _touchEffectsAutoCycle = _prefs!.getBool('touch_fx_autocycle') ?? false;

    _salawatOverlayEnabled = _prefs!.getBool('salawat_enabled') ?? false;
    _salawatIntervalMinutes =
        (_prefs!.getInt('salawat_interval_mins') ?? 30).clamp(0, 240);
    final savedTimes = _prefs!.getStringList('salawat_custom_times');
    if (savedTimes != null) {
      _salawatCustomTimes = List<String>.from(savedTimes);
    }

    _offsets = {
      'fajr': _prefs!.getInt('offset_fajr') ?? 0,
      'dhuhr': _prefs!.getInt('offset_dhuhr') ?? 0,
      'asr': _prefs!.getInt('offset_asr') ?? 0,
      'maghrib': _prefs!.getInt('offset_maghrib') ?? 0,
      'isha': _prefs!.getInt('offset_isha') ?? 0,
    };
    _loadOffsetProfiles();
    final currentProfile = _offsetProfileKey(_latitude, _longitude);
    if (_offsetProfiles.containsKey(currentProfile)) {
      _offsets = Map<String, int>.from(_offsetProfiles[currentProfile]!);
    } else {
      // Preserve legacy global corrections as the profile for the saved location.
      _persistCurrentOffsetProfile();
    }
    _loadPrayerAlarmPreferences();
    _isInitialized = true;
    _lastPublishedNightMode = isNightEffective;
    notifyListeners();
    _syncSalawatReminders();

    // Do not request location permission before the first-run setup explains it.
    if (_isAutoLocation && _firstRunSetupCompleted) {
      Future.microtask(() => refreshCurrentLocation(silent: true));
    }
  }

  void _loadOffsetProfiles() {
    _offsetProfiles.clear();
    final raw = _prefs?.getString('prayer_offset_profiles_v1');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final entry in decoded.entries) {
        if (entry.value is! Map) continue;
        final profile = <String, int>{};
        for (final key in _prayerOffsetKeys) {
          final value = (entry.value as Map)[key];
          profile[key] = value is num ? value.round().clamp(-15, 15) : 0;
        }
        _offsetProfiles[entry.key.toString()] = profile;
      }
    } catch (_) {
      _offsetProfiles.clear();
    }
  }

  void _loadPrayerAlarmPreferences() {
    final raw = _prefs?.getString('prayer_alarm_preferences_v1');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      _prayerAlarmPreferences = {
        for (final key in _prayerOffsetKeys)
          key: PrayerAlarmPreference.fromJson(decoded[key]),
      };
    } catch (_) {
      _prayerAlarmPreferences = {
        for (final key in _prayerOffsetKeys) key: const PrayerAlarmPreference(),
      };
    }
  }

  String _offsetProfileKey(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';

  void _persistCurrentOffsetProfile() {
    final key = _offsetProfileKey(_latitude, _longitude);
    _offsetProfiles[key] = Map<String, int>.from(_offsets);
    while (_offsetProfiles.length > 50) {
      final oldest = _offsetProfiles.keys.first;
      if (oldest == key && _offsetProfiles.length > 1) {
        _offsetProfiles.remove(_offsetProfiles.keys.elementAt(1));
      } else {
        _offsetProfiles.remove(oldest);
      }
    }
    _prefs?.setString('prayer_offset_profiles_v1', jsonEncode(_offsetProfiles));
  }

  void _activateOffsetProfile(double latitude, double longitude) {
    _offsets = Map<String, int>.from(
      _offsetProfiles[_offsetProfileKey(latitude, longitude)] ??
          <String, int>{for (final key in _prayerOffsetKeys) key: 0},
    );
  }

  void setJannatiSceneryIndex(int index) {
    final safe = ((index % 100) + 100) % 100;
    _selectedJannatiSceneryIndex = safe;
    _selectedGardenWallpaperAsset =
        null; // نمنح الأولوية للمنظر المختار من الـ 100 صورة 4K
    _prefs?.setInt('jannati_scenery_idx_100', safe);
    _prefs?.remove('garden_wallpaper_4k');
    notifyListeners();
  }

  void nextJannatiScenery() =>
      setJannatiSceneryIndex((_selectedJannatiSceneryIndex + 1) % 100);

  void previousJannatiScenery() =>
      setJannatiSceneryIndex((_selectedJannatiSceneryIndex - 1 + 100) % 100);

  void cycleJannatiIfAuto() {
    if (_jannatiAutoCycleScenery) {
      nextJannatiScenery();
    }
  }

  void setJannatiAutoCycleScenery(bool enabled) {
    _jannatiAutoCycleScenery = enabled;
    _prefs?.setBool('jannati_scenery_autocycle_v2', enabled);
    notifyListeners();
  }

  void setTasbihBackdropIndex(int index) {
    final len = Background500Catalog.tasbihIslamic30.length;
    final safe = ((index % len) + len) % len;
    _selectedTasbihBackdropIndex = safe;
    _prefs?.setInt('tasbih_backdrop_idx_30', safe);
    notifyListeners();
  }

  void nextTasbihBackdrop() =>
      setTasbihBackdropIndex(_selectedTasbihBackdropIndex + 1);

  void previousTasbihBackdrop() =>
      setTasbihBackdropIndex(_selectedTasbihBackdropIndex - 1);

  /// يبدّل خلفية السبحة الإسلامية تلقائياً عبر ٣٠ صورة إسلامية عند كل ١٠٠ تسبيحة
  /// ويعيد true إذا تم الانتقال لخلفية جديدة عند مضاعف الـ ١٠٠.
  bool onTasbihCountChanged(int totalLifetimeTasbih) {
    if (totalLifetimeTasbih <= 0) return false;
    final milestone = totalLifetimeTasbih ~/ 100;
    if (milestone > _lastTasbihStageMilestone) {
      _lastTasbihStageMilestone = milestone;
      _selectedTasbihBackdropIndex =
          milestone % Background500Catalog.tasbihIslamic30.length;
      _prefs?.setInt('tasbih_backdrop_milestone', _lastTasbihStageMilestone);
      _prefs?.setInt('tasbih_backdrop_idx_30', _selectedTasbihBackdropIndex);
      notifyListeners();
      return true;
    }
    return false;
  }

  void setAmbientSparklesEnabled(bool enabled) {
    _ambientSparklesEnabled = enabled;
    _prefs?.setBool('ambient_sparkles_enabled', enabled);
    notifyListeners();
  }

  void setAmbientShapePresetIndex(int index) {
    final safe = ((index % 500) + 500) % 500;
    _ambientShapePresetIndex = safe;
    _prefs?.setInt('ambient_shape_preset_idx', safe);
    notifyListeners();
  }

  void setTouchEffectsEnabled(bool enabled) {
    _touchEffectsEnabled = enabled;
    _prefs?.setBool('touch_fx_enabled', enabled);
    notifyListeners();
  }

  void setTouchEffectNumber(int number) {
    _touchEffectNumber = number.clamp(1, 200);
    _prefs?.setInt('touch_fx_number', _touchEffectNumber);
    notifyListeners();
  }

  void setTouchEffectsAutoCycle(bool autoCycle) {
    _touchEffectsAutoCycle = autoCycle;
    _prefs?.setBool('touch_fx_autocycle', autoCycle);
    notifyListeners();
  }

  void setSalawatOverlayEnabled(bool enabled) {
    _salawatOverlayEnabled = enabled;
    _prefs?.setBool('salawat_enabled', enabled);
    notifyListeners();
    _syncSalawatReminders();
  }

  void setSalawatIntervalMinutes(int minutes) {
    _salawatIntervalMinutes = minutes.clamp(0, 240);
    _prefs?.setInt('salawat_interval_mins', _salawatIntervalMinutes);
    notifyListeners();
    _syncSalawatReminders();
  }

  void addSalawatCustomTime(String hhMm) {
    final trimmed = hhMm.trim();
    if (!_salawatCustomTimes.contains(trimmed)) {
      _salawatCustomTimes = [..._salawatCustomTimes, trimmed]..sort();
      _prefs?.setStringList('salawat_custom_times', _salawatCustomTimes);
      notifyListeners();
      _syncSalawatReminders();
    }
  }

  void removeSalawatCustomTime(String hhMm) {
    _salawatCustomTimes = _salawatCustomTimes.where((t) => t != hhMm).toList();
    _prefs?.setStringList('salawat_custom_times', _salawatCustomTimes);
    notifyListeners();
    _syncSalawatReminders();
  }

  void _syncSalawatReminders() {
    try {
      // Retire the old over-app overlay scheduler without changing saved keys.
      // InAppReminderHost owns the single quiet-hours-aware salawat schedule.
      FirdawsNativeService().scheduleSalawatReminders(
        enabled: false,
        intervalMinutes: 0,
        customTimes: const [],
      );
    } catch (_) {}
  }

  /// كشف الموقع الجغرافي الحالي واسم المدينة والبلد دون تعليق
  Future<DetectedLocationResult> refreshCurrentLocation(
      {bool silent = false}) async {
    if (_isDetectingLocation) {
      return DetectedLocationResult(
        succeeded: false,
        cityArabic: _cityName,
        countryArabic: '',
        displayName: _cityName,
        sourceLabel: 'جاري الفحص...',
      );
    }

    final requestGeneration = ++_locationRequestGeneration;
    _isDetectingLocation = true;
    _lastLocationError = null;
    if (!silent) {
      _lastLocationStatus = 'جاري تحديد موقعك وبلدك...';
    }
    // Even a silent startup lookup must expose its loading state so the user
    // can choose a city before it finishes.
    notifyListeners();

    try {
      final result = await _locationDetector().timeout(
        const Duration(seconds: 25),
      );
      if (requestGeneration != _locationRequestGeneration) {
        return _supersededLocationResult();
      }
      if (result.succeeded &&
          result.latitude != null &&
          result.longitude != null) {
        _persistCurrentOffsetProfile();
        _latitude = result.latitude!;
        _longitude = result.longitude!;
        _activateOffsetProfile(_latitude, _longitude);
        _persistCurrentOffsetProfile();
        _cityName = result.displayName;
        _setTimeZone(result.timeZoneId ??
            _presetZoneFor(result.latitude!, result.longitude!));
        _isAutoLocation = true;
        _locationSourceLabel = result.sourceLabel;
        _hasConfirmedLocation = true;
        _lastLocationStatus = 'تم التحديث عبر ${result.sourceLabel}';
        _lastLocationError = null;
        _prefs?.setDouble('lat', _latitude);
        _prefs?.setDouble('lng', _longitude);
        _prefs?.setString('city_name', _cityName);
        _prefs?.setBool('auto_loc', true);
        _prefs?.setString('location_source', _locationSourceLabel);
        _prefs?.setBool('location_confirmed', true);
        _isDetectingLocation = false;
        notifyListeners();
        _rescheduleNotifications();
        return result;
      } else {
        _lastLocationError = result.errorMessage;
        _lastLocationStatus = 'تعذر الكشف التلقائي';
        _isDetectingLocation = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      if (requestGeneration != _locationRequestGeneration) {
        return _supersededLocationResult();
      }
      _isDetectingLocation = false;
      _lastLocationError = e.toString().contains('TimeoutException')
          ? 'انتهت مهلة تحديد الموقع. يمكنك اختيار المدينة يدوياً.'
          : 'تعذر الاتصال بخدمة الموقع حالياً';
      _lastLocationStatus = 'فشل مؤقت';
      notifyListeners();
      return DetectedLocationResult(
        succeeded: false,
        cityArabic: _cityName,
        countryArabic: '',
        displayName: _cityName,
        sourceLabel: 'خطأ',
        errorMessage: _lastLocationError,
      );
    }
  }

  DetectedLocationResult _supersededLocationResult() => DetectedLocationResult(
        succeeded: false,
        latitude: _latitude,
        longitude: _longitude,
        cityArabic: _cityName,
        countryArabic: '',
        displayName: _cityName,
        sourceLabel: _locationSourceLabel,
        errorMessage: 'تم تغيير الموقع أثناء الفحص؛ احتُفظ بالاختيار الأحدث.',
      );

  void setAutomaticLocationEnabled(bool enabled) {
    if (_isAutoLocation == enabled) return;
    _isAutoLocation = enabled;
    _prefs?.setBool('auto_loc', enabled);
    if (!enabled) {
      // Turning automatic detection off also invalidates a pending lookup.
      _locationRequestGeneration++;
      _isDetectingLocation = false;
      _lastLocationStatus = _hasConfirmedLocation
          ? 'تم تثبيت الموقع الحالي؛ لن يُحدّث تلقائياً'
          : 'الموقع المؤقت غير مؤكد؛ اختر مدينة يدوياً';
    } else {
      _lastLocationStatus = 'بانتظار تحديث الموقع تلقائياً';
    }
    notifyListeners();
  }

  void setCalculationMethod(CalculationMethod method) {
    _calculationMethod = method;
    _prefs?.setInt('calc_method', method.index);
    notifyListeners();
    _rescheduleNotifications();
  }

  void setMadhab(Madhab madhab) {
    _madhab = madhab;
    _prefs?.setInt('madhab', madhab.index);
    notifyListeners();
    _rescheduleNotifications();
  }

  void setTheme(String themeKey) {
    _selectedTheme = themeKey;
    _prefs?.setString('theme', themeKey);
    notifyListeners();
  }

  void setFont(String fontFamily) {
    _selectedFont = FontCatalog.getByFamily(fontFamily).family;
    _prefs?.setString('app_font', _selectedFont);
    notifyListeners();
  }

  void setAppWallpaper(String? assetPath) {
    final clean =
        (assetPath != null && assetPath.trim().isNotEmpty) ? assetPath : null;
    _selectedAppWallpaperAsset = clean;
    if (clean == null) {
      _prefs?.remove('app_wallpaper_4k');
    } else {
      _prefs?.setString('app_wallpaper_4k', clean);
    }
    notifyListeners();
  }

  void setGardenWallpaper(String? assetPath) {
    final clean =
        (assetPath != null && assetPath.trim().isNotEmpty) ? assetPath : null;
    _selectedGardenWallpaperAsset = clean;
    if (clean == null) {
      _prefs?.remove('garden_wallpaper_4k');
    } else {
      _prefs?.setString('garden_wallpaper_4k', clean);
    }
    notifyListeners();
  }

  void setBothWallpapers(String? assetPath) {
    final clean =
        (assetPath != null && assetPath.trim().isNotEmpty) ? assetPath : null;
    _selectedAppWallpaperAsset = clean;
    _selectedGardenWallpaperAsset = clean;
    if (clean == null) {
      _prefs?.remove('app_wallpaper_4k');
      _prefs?.remove('garden_wallpaper_4k');
    } else {
      _prefs?.setString('app_wallpaper_4k', clean);
      _prefs?.setString('garden_wallpaper_4k', clean);
    }
    notifyListeners();
  }

  void clearWallpapers() => setBothWallpapers(null);

  void setGameSfxEnabled(bool enabled) {
    _gameSfxEnabled = enabled;
    ArenaSfxService.instance.setEnabled(enabled);
    _prefs?.setBool('game_sfx_enabled', enabled);
    notifyListeners();
  }

  void setBrightnessMode(String mode) {
    if (mode != 'night' &&
        mode != 'day' &&
        mode != 'auto' &&
        mode != 'system') {
      return;
    }
    _brightnessMode = mode;
    _prefs?.setString('brightness_mode', mode);
    _lastPublishedNightMode = isNightEffective;
    notifyListeners();
  }

  void refreshDerivedBrightness() {
    if (_brightnessMode != 'auto' && _brightnessMode != 'system') return;
    final night = isNightEffective;
    if (_lastPublishedNightMode != night) {
      _lastPublishedNightMode = night;
      notifyListeners();
    }
  }

  void toggleDayNight() {
    setBrightnessMode(isNightEffective ? 'day' : 'night');
  }

  void setAdhanSkin(String id) {
    _adhanSkinId = AdhanSkinCatalog.byId(id).id;
    _prefs?.setString('adhan_skin_id', _adhanSkinId);
    notifyListeners();
  }

  void setAdhanVoice(String voice) {
    _adhanVoice = voice;
    _prefs?.setString('adhan_voice', voice);
    notifyListeners();
    _rescheduleNotifications();
  }

  void setPreAdhanReminder(bool enabled) {
    _playPreAdhanReminder = enabled;
    _prefs?.setBool('pre_adhan_reminder', enabled);
    notifyListeners();
    _rescheduleNotifications();
  }

  void setPreAdhanReminderMinutes(int minutes) {
    _preAdhanReminderMinutes = minutes.clamp(5, 60);
    _prefs?.setInt('pre_adhan_reminder_minutes', _preAdhanReminderMinutes);
    notifyListeners();
    _rescheduleNotifications();
  }

  void setPrayerAlarmPreference(
    String prayerKey,
    PrayerAlarmPreference preference,
  ) {
    if (!_prayerOffsetKeys.contains(prayerKey)) return;
    _prayerAlarmPreferences = {
      ..._prayerAlarmPreferences,
      prayerKey: PrayerAlarmPreference.fromJson(preference.toJson()),
    };
    _prefs?.setString(
      'prayer_alarm_preferences_v1',
      jsonEncode({
        for (final entry in _prayerAlarmPreferences.entries)
          entry.key: entry.value.toJson(),
      }),
    );
    notifyListeners();
    _rescheduleNotifications();
  }

  void setAutoMute(bool enabled) {
    _autoMuteDuringPrayer = enabled;
    _prefs?.setBool('auto_mute', enabled);
    notifyListeners();
  }

  void updateOffset(String prayer, int minutes) {
    if (!_prayerOffsetKeys.contains(prayer)) return;
    _offsets[prayer] = minutes.clamp(-15, 15);
    _prefs?.setInt('offset_$prayer', _offsets[prayer]!);
    _persistCurrentOffsetProfile();
    notifyListeners();
    _rescheduleNotifications();
  }

  void setManualLocation(double lat, double lng, String name) {
    // Manual selection always wins over an older GPS/IP request still in flight.
    _locationRequestGeneration++;
    _isDetectingLocation = false;
    _persistCurrentOffsetProfile();
    _latitude = lat;
    _longitude = lng;
    _activateOffsetProfile(lat, lng);
    _persistCurrentOffsetProfile();
    _cityName = name;
    _setTimeZone(
        LocationClock.zoneIdForPresetName(name) ?? _presetZoneFor(lat, lng));
    _isAutoLocation = false;
    _locationSourceLabel = 'اختيار يدوي من قائمة المدن';
    _hasConfirmedLocation = true;
    _lastLocationStatus = 'مدينة مختارة يدوياً';
    _lastLocationError = null;
    _prefs?.setDouble('lat', lat);
    _prefs?.setDouble('lng', lng);
    _prefs?.setString('city_name', name);
    _prefs?.setBool('auto_loc', false);
    _prefs?.setString('location_source', _locationSourceLabel);
    _prefs?.setBool('location_confirmed', true);
    notifyListeners();
    _rescheduleNotifications();
  }

  Future<void> completeFirstRunSetup() async {
    if (_firstRunSetupCompleted) return;
    _firstRunSetupCompleted = true;
    if (!_hasConfirmedLocation) {
      // Do not request location automatically after the user skips setup.
      setAutomaticLocationEnabled(false);
    }
    await _prefs?.setBool('first_run_setup_v1', true);
    notifyListeners();
  }

  void syncAllNotifications() {
    _rescheduleNotifications();
    _syncSalawatReminders();
  }

  void _rescheduleNotifications() {
    final prayers = AdvancedPrayerTimes.calculate(
      latitude: _latitude,
      longitude: _longitude,
      method: _calculationMethod,
      madhab: _madhab,
      offsets: _offsets,
    );

    NotificationService().scheduleDailyPrayers(
      prayers: prayers,
      voiceResource: _adhanVoice,
      preAdhanReminder: _playPreAdhanReminder,
      preAdhanReminderMinutes: _preAdhanReminderMinutes,
      alarmPreferences: _prayerAlarmPreferences,
      latitude: _latitude,
      longitude: _longitude,
      method: _calculationMethod,
      madhab: _madhab,
      offsets: _offsets,
    );

    final now = DateTime.now();
    final todayAtLocation = LocationClock.now();
    final widgetPrayers = <Map<String, dynamic>>[];
    for (var dayOffset = 0; dayOffset < 30; dayOffset++) {
      final dayTimes = dayOffset == 0
          ? prayers.prayerTimes
          : AdvancedPrayerTimes.calculateForDate(
              date: todayAtLocation.add(Duration(days: dayOffset)),
              latitude: _latitude,
              longitude: _longitude,
              method: _calculationMethod,
              madhab: _madhab,
              offsets: _offsets,
            ).prayerTimes;
      final dailyEntries = <({String name, DateTime time})>[
        (name: 'صلاة الفجر', time: dayTimes.fajr),
        (name: 'صلاة الظهر', time: dayTimes.dhuhr),
        (name: 'صلاة العصر', time: dayTimes.asr),
        (name: 'صلاة المغرب', time: dayTimes.maghrib),
        (name: 'صلاة العشاء', time: dayTimes.isha),
      ];
      for (final entry in dailyEntries) {
        if (!entry.time.isAfter(now)) continue;
        widgetPrayers.add({
          'prayerName': entry.name,
          'prayerTimeMillis': entry.time.millisecondsSinceEpoch,
          'timeLabel': LocationClock.formatTime(entry.time),
        });
      }
    }
    widgetPrayers.sort(
      (a, b) => (a['prayerTimeMillis'] as int)
          .compareTo(b['prayerTimeMillis'] as int),
    );

    final candidates = <({String name, DateTime time})>[
      (name: 'الفجر', time: prayers.prayerTimes.fajr),
      (name: 'الظهر', time: prayers.prayerTimes.dhuhr),
      (name: 'العصر', time: prayers.prayerTimes.asr),
      (name: 'المغرب', time: prayers.prayerTimes.maghrib),
      (name: 'العشاء', time: prayers.prayerTimes.isha),
    ];
    final upcoming = candidates.where((entry) => entry.time.isAfter(now));
    final nextPrayer = upcoming.isNotEmpty
        ? upcoming.first
        : (name: 'الفجر', time: prayers.tomorrowFajr);
    final widgetNext = widgetPrayers.isEmpty ? null : widgetPrayers.first;
    unawaited(
      FirdawsNativeService().updatePrayerWidget(
        cityName: _cityName,
        prayerName: widgetNext?['prayerName'] as String? ?? nextPrayer.name,
        prayerTimeMillis: widgetNext?['prayerTimeMillis'] as int? ??
            nextPrayer.time.millisecondsSinceEpoch,
        prayerTimeLabel: widgetNext?['timeLabel'] as String? ??
            LocationClock.formatTime(nextPrayer.time),
        prayers: widgetPrayers,
      ),
    );
  }
}
