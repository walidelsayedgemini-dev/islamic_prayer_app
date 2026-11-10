import 'package:geolocator/geolocator.dart';

class CityPreset {
  final String name;
  final double latitude;
  final double longitude;

  const CityPreset({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static const List<CityPreset> presetCities = [
    CityPreset(name: "مكة المكرمة، السعودية", latitude: 21.4225, longitude: 39.8262),
    CityPreset(name: "المدينة المنورة، السعودية", latitude: 24.4672, longitude: 39.6111),
    CityPreset(name: "الرياض، السعودية", latitude: 24.7136, longitude: 46.6753),
    CityPreset(name: "القاهرة، مصر", latitude: 30.0444, longitude: 31.2357),
    CityPreset(name: "القدس الشريف، فلسطين", latitude: 31.7683, longitude: 35.2137),
    CityPreset(name: "دبي، الإمارات", latitude: 25.2048, longitude: 55.2708),
    CityPreset(name: "إسطنبول، تركيا", latitude: 41.0082, longitude: 28.9784),
    CityPreset(name: "الرباط، المغرب", latitude: 34.0209, longitude: -6.8416),
    CityPreset(name: "عمان، الأردن", latitude: 31.9454, longitude: 35.9284),
    CityPreset(name: "الكويت العاصمة، الكويت", latitude: 29.3759, longitude: 47.9774),
    CityPreset(name: "الدوحة، قطر", latitude: 25.2854, longitude: 51.5310),
    CityPreset(name: "بغداد، العراق", latitude: 33.3152, longitude: 44.3661),
    CityPreset(name: "لندن، بريطانيا", latitude: 51.5074, longitude: -0.1278),
    CityPreset(name: "نيويورك، أمريكا", latitude: 40.7128, longitude: -74.0060),
    CityPreset(name: "جاكرتا، إندونيسيا", latitude: -6.2088, longitude: 106.8456),
  ];

  /// جلب الموقع الجغرافي الحالي للجهاز عبر الـ GPS بأمان ودون تعليق
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 3),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 3),
      );
    } catch (_) {
      return null;
    }
  }
}
