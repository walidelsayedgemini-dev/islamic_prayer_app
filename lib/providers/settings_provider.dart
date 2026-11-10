import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/font_catalog.dart';
import '../models/prayer_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // القيم الافتراضية لتطبيق الفردوس
  CalculationMethod _calculationMethod = CalculationMethod.umm_al_qura;
  Madhab _madhab = Madhab.shafi;
  String _selectedTheme = 'emerald_gold';
  String _selectedFont = 'Aref Ruqaa';
  String _brightnessMode = 'night'; // 'night', 'day', 'auto'
  String _adhanVoice = 'madinah';
  bool _isAutoLocation = true;
  double _latitude = 24.7136; // افتراضي: الرياض
  double _longitude = 46.6753;
  String _cityName = "الرياض، المملكة العربية السعودية";
  bool _playPreAdhanReminder = true;
  bool _autoMuteDuringPrayer = false;

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
  String get adhanVoice => _adhanVoice;
  bool get isAutoLocation => _isAutoLocation;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get cityName => _cityName;
  bool get playPreAdhanReminder => _playPreAdhanReminder;
  bool get autoMuteDuringPrayer => _autoMuteDuringPrayer;
  Map<String, int> get offsets => _offsets;

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

    final savedFont = _prefs!.getString('app_font') ?? 'Aref Ruqaa';
    _selectedFont = FontCatalog.getByFamily(savedFont).family;

    final savedBrightness = _prefs!.getString('brightness_mode') ?? 'night';
    if (savedBrightness == 'day' || savedBrightness == 'night' || savedBrightness == 'auto') {
      _brightnessMode = savedBrightness;
    }

    _adhanVoice = _prefs!.getString('adhan_voice') ?? 'madinah';
    _isAutoLocation = _prefs!.getBool('auto_loc') ?? true;
    _latitude = _prefs!.getDouble('lat') ?? 24.7136;
    _longitude = _prefs!.getDouble('lng') ?? 46.6753;
    _cityName = _prefs!.getString('city_name') ?? "الرياض، المملكة العربية السعودية";
    _playPreAdhanReminder = _prefs!.getBool('pre_adhan_reminder') ?? true;
    _autoMuteDuringPrayer = _prefs!.getBool('auto_mute') ?? false;

    _offsets = {
      'fajr': _prefs!.getInt('offset_fajr') ?? 0,
      'dhuhr': _prefs!.getInt('offset_dhuhr') ?? 0,
      'asr': _prefs!.getInt('offset_asr') ?? 0,
      'maghrib': _prefs!.getInt('offset_maghrib') ?? 0,
      'isha': _prefs!.getInt('offset_isha') ?? 0,
    };
    notifyListeners();
  }

  Future<void> refreshCurrentLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _cityName = "الموقع الحالي المكتشف (GPS)";
      _isAutoLocation = true;
      _prefs?.setDouble('lat', _latitude);
      _prefs?.setDouble('lng', _longitude);
      _prefs?.setString('city_name', _cityName);
      _prefs?.setBool('auto_loc', true);
      notifyListeners();
      _rescheduleNotifications();
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
    _prefs?.setDouble('lat', lat);
    _prefs?.setDouble('lng', lng);
    _prefs?.setString('city_name', name);
    _prefs?.setBool('auto_loc', false);
    notifyListeners();
    _rescheduleNotifications();
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
    );
  }
}
