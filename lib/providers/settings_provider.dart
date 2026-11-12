import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/font_catalog.dart';
import '../models/prayer_model.dart';
import '../services/arena_sfx_service.dart';
import '../services/firdaws_native_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../theme/islamic_theme.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // القيم الافتراضية لتطبيق الفردوس
  CalculationMethod _calculationMethod = CalculationMethod.umm_al_qura;
  Madhab _madhab = Madhab.shafi;
  String _selectedTheme = 'emerald_gold';
  String _selectedFont = 'Cairo';
  String _brightnessMode = 'night'; // 'night', 'day', 'auto'
  String? _selectedAppWallpaperAsset;
  String? _selectedGardenWallpaperAsset;
  int _selectedJannatiSceneryIndex = 0; // 0..99 (من الـ 100 صورة 4K لجنتي - اختيار يدوي فقط)
  bool _jannatiAutoCycleScenery = false;
  int _selectedTasbihBackdropIndex = 0; // 0..29 (تتغير تلقائياً كل 100 تسبيحة عبر 30 صورة إسلامية)
  int _lastTasbihStageMilestone = 0;
  bool _ambientSparklesEnabled = true;
  int _ambientShapePresetIndex = 0; // 0..499 (500 شكل طبيعي هادئ قابل للتخصيص)
  bool _gameSfxEnabled = true;
  String _adhanVoice = 'madinah';
  bool _isAutoLocation = true;
  double _latitude = 24.7136; // افتراضي مؤقت حتى يكتشف الجهاز بلدك ومدينتك
  double _longitude = 46.6753;
  String _cityName = "جاري تحديد مدينتك وبلدك...";
  bool _isDetectingLocation = false;
  String _lastLocationStatus = 'لم يتم الفحص بعد';
  String? _lastLocationError;
  bool _playPreAdhanReminder = true;
  bool _autoMuteDuringPrayer = false;

  // 200 تأثير تفاعلي للمس وحركة المؤشر والماوس
  bool _touchEffectsEnabled = true;
  int _touchEffectNumber = 1; // 1..200
  bool _touchEffectsAutoCycle = false;

  // التذكير العائم بالصلاة على النبي ﷺ فوق كل التطبيقات
  bool _salawatOverlayEnabled = true;
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
  bool get isAutoLocation => _isAutoLocation;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get cityName => _cityName;
  bool get isDetectingLocation => _isDetectingLocation;
  String get lastLocationStatus => _lastLocationStatus;
  String? get lastLocationError => _lastLocationError;
  bool get playPreAdhanReminder => _playPreAdhanReminder;
  bool get autoMuteDuringPrayer => _autoMuteDuringPrayer;
  Map<String, int> get offsets => _offsets;

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
        (savedAppWp != null && savedAppWp.trim().isNotEmpty) ? savedAppWp : null;

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
        _prefs!.getBool('ambient_sparkles_enabled') ?? true;
    _ambientShapePresetIndex =
        (_prefs!.getInt('ambient_shape_preset_idx') ?? 0).clamp(0, 499);

    _gameSfxEnabled = _prefs!.getBool('game_sfx_enabled') ?? true;
    ArenaSfxService.instance.setEnabled(_gameSfxEnabled);

    final savedBrightness = _prefs!.getString('brightness_mode') ?? 'night';
    if (savedBrightness == 'day' || savedBrightness == 'night' || savedBrightness == 'auto') {
      _brightnessMode = savedBrightness;
    }

    _adhanVoice = _prefs!.getString('adhan_voice') ?? 'madinah';
    _isAutoLocation = _prefs!.getBool('auto_loc') ?? true;
    _latitude = _prefs!.getDouble('lat') ?? 24.7136;
    _longitude = _prefs!.getDouble('lng') ?? 46.6753;
    final savedCity = _prefs!.getString('city_name');
    if (savedCity != null &&
        savedCity.trim().isNotEmpty &&
        savedCity != "الموقع الحالي المكتشف (GPS)") {
      _cityName = savedCity;
      _lastLocationStatus = _isAutoLocation ? 'موقع محفوظ (سيتم التحديث)' : 'مدينة مختارة يدوياً';
    } else {
      _cityName = "جاري تحديد موقعك تلقائياً...";
    }

    _playPreAdhanReminder = _prefs!.getBool('pre_adhan_reminder') ?? true;
    _autoMuteDuringPrayer = _prefs!.getBool('auto_mute') ?? false;

    _touchEffectsEnabled = _prefs!.getBool('touch_fx_enabled') ?? true;
    _touchEffectNumber = (_prefs!.getInt('touch_fx_number') ?? 1).clamp(1, 200);
    _touchEffectsAutoCycle = _prefs!.getBool('touch_fx_autocycle') ?? false;

    _salawatOverlayEnabled = _prefs!.getBool('salawat_enabled') ?? true;
    _salawatIntervalMinutes =
        (_prefs!.getInt('salawat_interval_mins') ?? 30).clamp(1, 180);
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
    notifyListeners();
    _syncSalawatReminders();

    // كشف الموقع الحقيقي واسم البلد والمدينة في الخلفية فوراً دون تعليق واجهة البداية
    if (_isAutoLocation) {
      Future.microtask(() => refreshCurrentLocation(silent: true));
    }
  }

  void setJannatiSceneryIndex(int index) {
    final safe = ((index % 100) + 100) % 100;
    _selectedJannatiSceneryIndex = safe;
    _selectedGardenWallpaperAsset = null; // نمنح الأولوية للمنظر المختار من الـ 100 صورة 4K
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
    _salawatCustomTimes =
        _salawatCustomTimes.where((t) => t != hhMm).toList();
    _prefs?.setStringList('salawat_custom_times', _salawatCustomTimes);
    notifyListeners();
    _syncSalawatReminders();
  }

  void _syncSalawatReminders() {
    try {
      FirdawsNativeService().scheduleSalawatReminders(
        enabled: _salawatOverlayEnabled,
        intervalMinutes: _salawatIntervalMinutes,
        customTimes: _salawatCustomTimes,
      );
    } catch (_) {}
  }

  /// كشف الموقع الجغرافي الحالي واسم المدينة والبلد دون تعليق
  Future<DetectedLocationResult> refreshCurrentLocation({bool silent = false}) async {
    if (_isDetectingLocation) {
      return DetectedLocationResult(
        succeeded: false,
        cityArabic: _cityName,
        countryArabic: '',
        displayName: _cityName,
        sourceLabel: 'جاري الفحص...',
      );
    }

    _isDetectingLocation = true;
    _lastLocationError = null;
    if (!silent) {
      _lastLocationStatus = 'جاري تحديد موقعك وبلدك...';
      notifyListeners();
    }

    try {
      final result = await LocationService.detectCurrentLocation();
      if (result.succeeded && result.latitude != null && result.longitude != null) {
        _latitude = result.latitude!;
        _longitude = result.longitude!;
        _cityName = result.displayName;
        _isAutoLocation = true;
        _lastLocationStatus = 'مُحدَّث عبر ${result.sourceLabel}';
        _lastLocationError = null;
        _prefs?.setDouble('lat', _latitude);
        _prefs?.setDouble('lng', _longitude);
        _prefs?.setString('city_name', _cityName);
        _prefs?.setBool('auto_loc', true);
        _isDetectingLocation = false;
        notifyListeners();
        _rescheduleNotifications();
        return result;
      } else {
        _lastLocationError = result.errorMessage;
        _lastLocationStatus = 'تعذر الكشف التلقائي';
        if (_cityName.contains('جاري')) {
          final fallback = LocationService.presetCities[5]; // القاهرة كافتراضي عربي واضح عند فشل الشبكة والـ GPS أول مرة فقط
          _latitude = fallback.latitude;
          _longitude = fallback.longitude;
          _cityName = fallback.name;
        }
        _isDetectingLocation = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      _isDetectingLocation = false;
      _lastLocationError = 'تعذر الاتصال بخدمة الموقع حالياً';
      _lastLocationStatus = 'فشل مؤقت';
      if (_cityName.contains('جاري')) {
        _cityName = "مكة المكرمة، السعودية";
      }
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
    if (mode != 'night' && mode != 'day' && mode != 'auto') return;
    _brightnessMode = mode;
    _prefs?.setString('brightness_mode', mode);
    notifyListeners();
  }

  void toggleDayNight() {
    setBrightnessMode(isNightEffective ? 'day' : 'night');
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

  void setAutoMute(bool enabled) {
    _autoMuteDuringPrayer = enabled;
    _prefs?.setBool('auto_mute', enabled);
    notifyListeners();
  }

  void updateOffset(String prayer, int minutes) {
    _offsets[prayer] = minutes;
    _prefs?.setInt('offset_$prayer', minutes);
    notifyListeners();
    _rescheduleNotifications();
  }

  void setManualLocation(double lat, double lng, String name) {
    _latitude = lat;
    _longitude = lng;
    _cityName = name;
    _isAutoLocation = false;
    _lastLocationStatus = 'مدينة مختارة يدوياً';
    _lastLocationError = null;
    _prefs?.setDouble('lat', lat);
    _prefs?.setDouble('lng', lng);
    _prefs?.setString('city_name', name);
    _prefs?.setBool('auto_loc', false);
    notifyListeners();
    _rescheduleNotifications();
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
      latitude: _latitude,
      longitude: _longitude,
      method: _calculationMethod,
      madhab: _madhab,
      offsets: _offsets,
    );
  }
}
