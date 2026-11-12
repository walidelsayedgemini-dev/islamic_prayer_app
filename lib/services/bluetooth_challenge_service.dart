import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BluetoothPeerDevice {
  final String name;
  final String address;
  final bool isPaired;

  const BluetoothPeerDevice({
    required this.name,
    required this.address,
    required this.isPaired,
  });

  factory BluetoothPeerDevice.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothPeerDevice(
      name: (map['name'] ?? 'جهاز قريب').toString(),
      address: (map['address'] ?? '').toString(),
      isPaired: map['paired']?.toString() == 'true',
    );
  }
}

class BluetoothSyncedProfile {
  final String id;
  final String name;
  final int age;
  final List<String> traits;
  final int avatarIndex;
  final int tasbihCount;
  final int championScore;
  final int winsCount;
  final String groupLabel;
  final String? customPhotoBase64;

  const BluetoothSyncedProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.traits,
    required this.avatarIndex,
    required this.tasbihCount,
    required this.championScore,
    required this.winsCount,
    this.groupLabel = 'خير الأصدقاء والعائلة',
    this.customPhotoBase64,
  });

  Map<String, dynamic> toJson() => {
        'v': 1,
        'id': id,
        'name': name,
        'age': age,
        'traits': traits,
        'avatarIndex': avatarIndex,
        'tasbihCount': tasbihCount,
        'championScore': championScore,
        'winsCount': winsCount,
        'groupLabel': groupLabel,
        if (customPhotoBase64 != null) 'photoB64': customPhotoBase64,
      };

  String encodeShareCode() {
    final jsonStr = jsonEncode(toJson());
    final b64 = base64UrlEncode(utf8.encode(jsonStr));
    return 'FIRDAWS:$b64';
  }

  static BluetoothSyncedProfile? tryDecode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    try {
      String jsonText = trimmed;
      if (trimmed.startsWith('FIRDAWS:')) {
        final b64 = trimmed.substring('FIRDAWS:'.length).trim();
        jsonText = utf8.decode(base64Url.decode(b64));
      }
      final map = jsonDecode(jsonText) as Map<String, dynamic>;
      final name = (map['name'] ?? '').toString().trim();
      if (name.isEmpty) return null;
      return BluetoothSyncedProfile(
        id: (map['id'] ?? 'bt_${name.hashCode.abs()}').toString(),
        name: name,
        age: ((map['age'] as num?)?.toInt() ?? 24).clamp(5, 99),
        traits: (map['traits'] as List?)
                ?.map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList() ??
            const ['متسابق بالخير', 'صديق الفردوس'],
        avatarIndex: ((map['avatarIndex'] as num?)?.toInt() ?? 0).clamp(0, 49),
        tasbihCount: (map['tasbihCount'] as num?)?.toInt() ?? 0,
        championScore: (map['championScore'] as num?)?.toInt() ?? 0,
        winsCount: (map['winsCount'] as num?)?.toInt() ?? 0,
        groupLabel:
            (map['groupLabel'] ?? 'خير الأصدقاء والعائلة').toString(),
        customPhotoBase64: map['photoB64']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}

class BluetoothStatusSnapshot {
  final bool supported;
  final bool enabled;
  final bool hasPermission;

  const BluetoothStatusSnapshot({
    required this.supported,
    required this.enabled,
    required this.hasPermission,
  });
}

class BluetoothChallengeService {
  BluetoothChallengeService._();
  static final BluetoothChallengeService instance =
      BluetoothChallengeService._();

  static const MethodChannel _channel =
      MethodChannel('com.islamic.app/firdaws_bluetooth');

  bool get isNativeAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<BluetoothStatusSnapshot> getStatus() async {
    if (!isNativeAndroid) {
      return const BluetoothStatusSnapshot(
        supported: false,
        enabled: false,
        hasPermission: false,
      );
    }
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getStatus');
      return BluetoothStatusSnapshot(
        supported: res?['supported'] == true,
        enabled: res?['enabled'] == true,
        hasPermission: res?['hasPermission'] == true,
      );
    } catch (_) {
      return const BluetoothStatusSnapshot(
        supported: false,
        enabled: false,
        hasPermission: false,
      );
    }
  }

  Future<bool> requestPermissions() async {
    if (!isNativeAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('requestPermissions');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enableDiscoverable() async {
    if (!isNativeAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('enableDiscoverable');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<BluetoothPeerDevice>> scanDevices() async {
    if (!isNativeAndroid) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>('scanDevices');
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((m) => BluetoothPeerDevice.fromMap(m))
        .where((d) => d.address.isNotEmpty)
        .toList();
  }

  Future<BluetoothSyncedProfile?> startHostExchange(
      BluetoothSyncedProfile localProfile) async {
    if (!isNativeAndroid) return null;
    final raw = await _channel.invokeMethod<String>(
      'startServer',
      {'payload': jsonEncode(localProfile.toJson())},
    );
    if (raw == null) return null;
    return BluetoothSyncedProfile.tryDecode(raw);
  }

  Future<void> stopHostExchange() async {
    if (!isNativeAndroid) return;
    try {
      await _channel.invokeMethod('stopServer');
    } catch (_) {}
  }

  Future<BluetoothSyncedProfile?> connectAndExchange({
    required String address,
    required BluetoothSyncedProfile localProfile,
  }) async {
    if (!isNativeAndroid) return null;
    final raw = await _channel.invokeMethod<String>(
      'connectAndExchange',
      {
        'address': address,
        'payload': jsonEncode(localProfile.toJson()),
      },
    );
    if (raw == null) return null;
    return BluetoothSyncedProfile.tryDecode(raw);
  }
}
