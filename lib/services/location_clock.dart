import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Holds the time zone of the selected / detected prayer location so prayer
/// times are shown as the wall-clock time at that location, not on the device.
///
/// The adhan package returns correct instants (as device-local DateTimes), so
/// countdowns and comparisons with DateTime.now() are already right. Only the
/// displayed wall-clock fields (hour, minute) and the "today" date used for
/// the calculation need to follow the location's zone.
///
/// When no zone is known (null), behaviour is unchanged: the device zone is used.
class LocationClock {
  LocationClock._();

  static bool _dbReady = false;
  static tz.Location? _zone;
  static String? _zoneId;

  static String? get zoneId => _zoneId;

  /// IANA zone ids for the preset cities, keyed by the Arabic country name.
  static const Map<String, String> _countryZones = {
    'السعودية': 'Asia/Riyadh',
    'مصر': 'Africa/Cairo',
    'فلسطين': 'Asia/Jerusalem',
    'الإمارات': 'Asia/Dubai',
    'تركيا': 'Europe/Istanbul',
    'المغرب': 'Africa/Casablanca',
    'تونس': 'Africa/Tunis',
    'الجزائر': 'Africa/Algiers',
    'ليبيا': 'Africa/Tripoli',
    'السودان': 'Africa/Khartoum',
    'الأردن': 'Asia/Amman',
    'سوريا': 'Asia/Damascus',
    'لبنان': 'Asia/Beirut',
    'الكويت': 'Asia/Kuwait',
    'قطر': 'Asia/Qatar',
    'البحرين': 'Asia/Bahrain',
    'عُمان': 'Asia/Muscat',
    'العراق': 'Asia/Baghdad',
    'اليمن': 'Asia/Aden',
    'بريطانيا': 'Europe/London',
    'فرنسا': 'Europe/Paris',
    'ألمانيا': 'Europe/Berlin',
    'إيطاليا': 'Europe/Rome',
    'إسبانيا': 'Europe/Madrid',
    'أمريكا': 'America/New_York',
    'كندا': 'America/Toronto',
    'ماليزيا': 'Asia/Kuala_Lumpur',
    'إندونيسيا': 'Asia/Jakarta',
    'باكستان': 'Asia/Karachi',
    'بنغلاديش': 'Asia/Dhaka',
    'اليابان': 'Asia/Tokyo',
    'أستراليا': 'Australia/Sydney',
  };

  /// Zone id for a preset city name such as "القاهرة، مصر", or null.
  static String? zoneIdForPresetName(String name) {
    if (!name.contains('،')) return null;
    return _countryZones[name.split('،').last.trim()];
  }

  /// Sets the active zone. Unknown or null ids fall back to the device zone.
  static void setZoneId(String? id) {
    if (id == null || id.trim().isEmpty) {
      _zone = null;
      _zoneId = null;
      return;
    }
    if (!_dbReady) {
      tzdata.initializeTimeZones();
      _dbReady = true;
    }
    try {
      _zone = tz.getLocation(id.trim());
      _zoneId = id.trim();
    } catch (_) {
      _zone = null;
      _zoneId = null;
    }
  }

  /// Current time as seen at the location.
  static DateTime now() => toZone(DateTime.now());

  /// Same instant, with wall-clock fields (hour, minute, day) in the location's
  /// zone. Returns the input unchanged if no zone is set.
  static DateTime toZone(DateTime time) {
    final zone = _zone;
    if (zone == null) return time;
    return tz.TZDateTime.from(time, zone);
  }

  /// Wall-clock time at the location in Arabic, e.g. "١١:٤٤ ص" (ص / م).
  static String formatTime(DateTime time) =>
      DateFormat('hh:mm a', 'ar').format(toZone(time));

  /// Calendar date "today" at the location, for prayer calculation.
  static DateComponents todayComponents() => DateComponents.from(now());
}
