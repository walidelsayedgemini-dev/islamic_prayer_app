import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CityPreset {
  final String name;
  final double latitude;
  final double longitude;

  const CityPreset({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  String get cityOnly => name.split('،').first.trim();
  String get countryOnly => name.contains('،') ? name.split('،').last.trim() : '';
}

class DetectedLocationResult {
  final bool succeeded;
  final double? latitude;
  final double? longitude;
  final String cityArabic;
  final String countryArabic;
  final String displayName;
  final String sourceLabel; // GPS / IP / Cached
  final String? errorMessage;

  const DetectedLocationResult({
    required this.succeeded,
    this.latitude,
    this.longitude,
    required this.cityArabic,
    required this.countryArabic,
    required this.displayName,
    required this.sourceLabel,
    this.errorMessage,
  });
}

class LocationService {
  static const List<CityPreset> presetCities = [
    CityPreset(name: "مكة المكرمة، السعودية", latitude: 21.4225, longitude: 39.8262),
    CityPreset(name: "المدينة المنورة، السعودية", latitude: 24.4672, longitude: 39.6111),
    CityPreset(name: "الرياض، السعودية", latitude: 24.7136, longitude: 46.6753),
    CityPreset(name: "جدة، السعودية", latitude: 21.5433, longitude: 39.1728),
    CityPreset(name: "الدمام، السعودية", latitude: 26.4207, longitude: 50.0888),
    CityPreset(name: "القاهرة، مصر", latitude: 30.0444, longitude: 31.2357),
    CityPreset(name: "الجيزة، مصر", latitude: 30.0131, longitude: 31.2089),
    CityPreset(name: "الإسكندرية، مصر", latitude: 31.2001, longitude: 29.9187),
    CityPreset(name: "المنصورة، مصر", latitude: 31.0409, longitude: 31.3785),
    CityPreset(name: "طنطا، مصر", latitude: 30.7865, longitude: 31.0004),
    CityPreset(name: "الزقازيق، مصر", latitude: 30.5877, longitude: 31.5020),
    CityPreset(name: "بورسعيد، مصر", latitude: 31.2653, longitude: 32.3019),
    CityPreset(name: "السويس، مصر", latitude: 29.9668, longitude: 32.5498),
    CityPreset(name: "الإسماعيلية، مصر", latitude: 30.5965, longitude: 32.2715),
    CityPreset(name: "أسيوط، مصر", latitude: 27.1809, longitude: 31.1837),
    CityPreset(name: "الأقصر، مصر", latitude: 25.6872, longitude: 32.6396),
    CityPreset(name: "أسوان، مصر", latitude: 24.0889, longitude: 32.8998),
    CityPreset(name: "دمياط، مصر", latitude: 31.4175, longitude: 31.8144),
    CityPreset(name: "الفيوم، مصر", latitude: 29.3084, longitude: 30.8428),
    CityPreset(name: "المنيا، مصر", latitude: 28.1099, longitude: 30.7503),
    CityPreset(name: "سوهاج، مصر", latitude: 26.5591, longitude: 31.6957),
    CityPreset(name: "بنها، مصر", latitude: 30.4660, longitude: 31.1848),
    CityPreset(name: "دمنهور، مصر", latitude: 31.0341, longitude: 30.4682),
    CityPreset(name: "شرم الشيخ، مصر", latitude: 27.9158, longitude: 34.3300),
    CityPreset(name: "القدس الشريف، فلسطين", latitude: 31.7683, longitude: 35.2137),
    CityPreset(name: "غزة، فلسطين", latitude: 31.5017, longitude: 34.4668),
    CityPreset(name: "دبي، الإمارات", latitude: 25.2048, longitude: 55.2708),
    CityPreset(name: "أبوظبي، الإمارات", latitude: 24.4539, longitude: 54.3773),
    CityPreset(name: "الشارقة، الإمارات", latitude: 25.3463, longitude: 55.4209),
    CityPreset(name: "إسطنبول، تركيا", latitude: 41.0082, longitude: 28.9784),
    CityPreset(name: "أنقرة، تركيا", latitude: 39.9334, longitude: 32.8597),
    CityPreset(name: "الرباط، المغرب", latitude: 34.0209, longitude: -6.8416),
    CityPreset(name: "الدار البيضاء، المغرب", latitude: 33.5731, longitude: -7.5898),
    CityPreset(name: "تونس العاصمة، تونس", latitude: 36.8065, longitude: 10.1815),
    CityPreset(name: "الجزائر العاصمة، الجزائر", latitude: 36.7538, longitude: 3.0588),
    CityPreset(name: "طرابلس، ليبيا", latitude: 32.8872, longitude: 13.1913),
    CityPreset(name: "الخرطوم، السودان", latitude: 15.5007, longitude: 32.5599),
    CityPreset(name: "عمّان، الأردن", latitude: 31.9454, longitude: 35.9284),
    CityPreset(name: "دمشق، سوريا", latitude: 33.5138, longitude: 36.2765),
    CityPreset(name: "بيروت، لبنان", latitude: 33.8938, longitude: 35.5018),
    CityPreset(name: "الكويت العاصمة، الكويت", latitude: 29.3759, longitude: 47.9774),
    CityPreset(name: "الدوحة، قطر", latitude: 25.2854, longitude: 51.5310),
    CityPreset(name: "المنامة، البحرين", latitude: 26.2285, longitude: 50.5860),
    CityPreset(name: "مسقط، عُمان", latitude: 23.5880, longitude: 58.3829),
    CityPreset(name: "بغداد، العراق", latitude: 33.3152, longitude: 44.3661),
    CityPreset(name: "أربيل، العراق", latitude: 36.1911, longitude: 44.0092),
    CityPreset(name: "صنعاء، اليمن", latitude: 15.3694, longitude: 44.1910),
    CityPreset(name: "لندن، بريطانيا", latitude: 51.5074, longitude: -0.1278),
    CityPreset(name: "باريس، فرنسا", latitude: 48.8566, longitude: 2.3522),
    CityPreset(name: "برلين، ألمانيا", latitude: 52.5200, longitude: 13.4050),
    CityPreset(name: "روما، إيطاليا", latitude: 41.9028, longitude: 12.4964),
    CityPreset(name: "مدريد، إسبانيا", latitude: 40.4168, longitude: -3.7038),
    CityPreset(name: "نيويورك، أمريكا", latitude: 40.7128, longitude: -74.0060),
    CityPreset(name: "تورونتو، كندا", latitude: 43.6532, longitude: -79.3832),
    CityPreset(name: "كوالالمبور، ماليزيا", latitude: 3.1390, longitude: 101.6869),
    CityPreset(name: "جاكرتا، إندونيسيا", latitude: -6.2088, longitude: 106.8456),
    CityPreset(name: "إسلام آباد، باكستان", latitude: 33.6844, longitude: 73.0479),
    CityPreset(name: "دكا، بنغلاديش", latitude: 23.8103, longitude: 90.4125),
    CityPreset(name: "طوكيو، اليابان", latitude: 35.6762, longitude: 139.6503),
    CityPreset(name: "سيدني، أستراليا", latitude: -33.8688, longitude: 151.2093),
  ];

  /// كشف كامل للموقع (GPS + آخر موقع محفوظ + الشبكة IP + تحديد اسم البلد والمدينة بالعربية) دون تعليق أبداً
  static Future<DetectedLocationResult> detectCurrentLocation() async {
    double? lat;
    double? lng;
    String sourceLabel = 'GPS';
    String? permissionNote;

    // 1) محاولة GPS الفعلي على الجهاز
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission().timeout(
          const Duration(seconds: 3),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission().timeout(
            const Duration(seconds: 6),
            onTimeout: () => LocationPermission.denied,
          );
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          try {
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 8),
            );
            lat = pos.latitude;
            lng = pos.longitude;
            sourceLabel = 'GPS الدقيق';
          } catch (_) {
            // 2) اللجوء لآخر موقع معروف فوراً إذا تأخر القمر الصناعي
            try {
              final lastPos = await Geolocator.getLastKnownPosition().timeout(
                const Duration(seconds: 2),
              );
              if (lastPos != null) {
                lat = lastPos.latitude;
                lng = lastPos.longitude;
                sourceLabel = 'آخر موقع GPS';
              }
            } catch (_) {}
          }
        } else {
          permissionNote = 'يرجى السماح بإذن الموقع لتحديد أدق (جاري استخدام الشبكة)';
        }
      } else {
        permissionNote = 'خدمة GPS مغلقة على الجهاز (جاري التحديد عبر الشبكة)';
      }
    } catch (_) {}

    // 3) إذا تعذر GPS أو لم تتوفر إحداثيات، نستخدم الشبكة (IP Geolocation بالعربية)
    if (lat == null || lng == null) {
      final ipRes = await _detectViaIp();
      if (ipRes != null) {
        return ipRes;
      }
      return DetectedLocationResult(
        succeeded: false,
        cityArabic: '',
        countryArabic: '',
        displayName: '',
        sourceLabel: 'تعذر التحديد',
        errorMessage: permissionNote ??
            'تعذر الوصول للـ GPS والشبكة معاً. يمكنك تفعيل GPS أو اختيار مدينتك يدوياً من القائمة.',
      );
    }

    // 4) ترجمة الإحداثيات إلى اسم المدينة والبلد بالعربية
    final geoName = await reverseGeocodeArabic(lat, lng);
    if (geoName != null) {
      return DetectedLocationResult(
        succeeded: true,
        latitude: lat,
        longitude: lng,
        cityArabic: geoName.city,
        countryArabic: geoName.country,
        displayName: geoName.display,
        sourceLabel: sourceLabel,
      );
    }

    // 5) مطابقة أوفلاين من أقرب مدينة في الـ 60 مدينة عربية وعالمية
    final nearest = findNearestPresetCity(lat, lng);
    if (nearest != null) {
      return DetectedLocationResult(
        succeeded: true,
        latitude: lat,
        longitude: lng,
        cityArabic: nearest.cityOnly,
        countryArabic: nearest.countryOnly,
        displayName: nearest.name,
        sourceLabel: '$sourceLabel (أوفلاين)',
      );
    }

    return DetectedLocationResult(
      succeeded: true,
      latitude: lat,
      longitude: lng,
      cityArabic: 'موقعك الحالي',
      countryArabic: '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}',
      displayName: 'موقعك (${lat.toStringAsFixed(2)}°، ${lng.toStringAsFixed(2)}°)',
      sourceLabel: sourceLabel,
    );
  }

  /// متوافق مع الاستدعاءات القديمة: يجلب الموقع مع بديل الشبكة عند توفره
  static Future<Position?> getCurrentLocation() async {
    try {
      final res = await detectCurrentLocation();
      if (res.succeeded && res.latitude != null && res.longitude != null) {
        return Position(
          latitude: res.latitude!,
          longitude: res.longitude!,
          timestamp: DateTime.now(),
          accuracy: 50,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<DetectedLocationResult?> _detectViaIp() async {
    // المحاولة 1: ipwho.is يدعم العربية مباشرة بدون مفتاح API
    try {
      final resp = await http
          .get(Uri.parse('https://ipwho.is/?lang=ar'))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final ok = data['success'] == true;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (ok && lat != null && lng != null) {
          var city = (data['city'] ?? '').toString().trim();
          var country = (data['country'] ?? '').toString().trim();
          if (city.isEmpty || country.isEmpty) {
            final geo = await reverseGeocodeArabic(lat, lng);
            city = city.isEmpty ? (geo?.city ?? '') : city;
            country = country.isEmpty ? (geo?.country ?? '') : country;
          }
          final nearest = findNearestPresetCity(lat, lng);
          if (city.isEmpty) city = nearest?.cityOnly ?? 'موقعك المكتشف';
          if (country.isEmpty) country = nearest?.countryOnly ?? '';
          final display = country.isNotEmpty ? '$city، $country' : city;
          return DetectedLocationResult(
            succeeded: true,
            latitude: lat,
            longitude: lng,
            cityArabic: city,
            countryArabic: country,
            displayName: display,
            sourceLabel: 'الشبكة (تلقائي)',
          );
        }
      }
    } catch (e) {
      debugPrint('ipwho.is error: $e');
    }

    // المحاولة 2: ipapi.co كبديل ثانٍ
    try {
      final resp = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          final geo = await reverseGeocodeArabic(lat, lng);
          if (geo != null) {
            return DetectedLocationResult(
              succeeded: true,
              latitude: lat,
              longitude: lng,
              cityArabic: geo.city,
              countryArabic: geo.country,
              displayName: geo.display,
              sourceLabel: 'الشبكة (احتياطي)',
            );
          }
          final nearest = findNearestPresetCity(lat, lng);
          final city = nearest?.cityOnly ?? (data['city'] ?? '').toString();
          final country = nearest?.countryOnly ?? (data['country_name'] ?? '').toString();
          return DetectedLocationResult(
            succeeded: true,
            latitude: lat,
            longitude: lng,
            cityArabic: city,
            countryArabic: country,
            displayName: country.isNotEmpty ? '$city، $country' : city,
            sourceLabel: 'الشبكة',
          );
        }
      }
    } catch (e) {
      debugPrint('ipapi.co error: $e');
    }

    return null;
  }

  /// تحويل الإحداثيات إلى المدينة والبلد باللغة العربية عبر BigDataCloud
  static Future<({String city, String country, String display})?> reverseGeocodeArabic(
    double lat,
    double lng,
  ) async {
    try {
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?latitude=$lat&longitude=$lng&localityLanguage=ar',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final cityRaw = (data['city'] ??
                data['locality'] ??
                data['principalSubdivision'] ??
                '')
            .toString()
            .trim();
        final countryRaw = (data['countryName'] ?? '').toString().trim();
        if (cityRaw.isNotEmpty || countryRaw.isNotEmpty) {
          final cleanCountry = countryRaw.replaceAll(' (the)', '').trim();
          final city = cityRaw.isNotEmpty ? cityRaw : cleanCountry;
          final display = (city.isNotEmpty && cleanCountry.isNotEmpty && city != cleanCountry)
              ? '$city، $cleanCountry'
              : (cleanCountry.isNotEmpty ? cleanCountry : city);
          return (city: city, country: cleanCountry, display: display);
        }
      }
    } catch (e) {
      debugPrint('reverseGeocodeArabic error: $e');
    }
    return null;
  }

  /// مطابقة أوفلاين لأقرب مدينة خلال نصف قطر ~350 كم
  static CityPreset? findNearestPresetCity(double lat, double lng, {double maxKm = 350}) {
    CityPreset? best;
    double bestDist = double.infinity;
    for (final city in presetCities) {
      final d = _haversineKm(lat, lng, city.latitude, city.longitude);
      if (d < bestDist) {
        bestDist = d;
        best = city;
      }
    }
    if (best != null && bestDist <= maxKm) {
      return best;
    }
    return null;
  }

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
}
