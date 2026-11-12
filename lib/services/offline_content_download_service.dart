import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التحميل الاختياري للكتب والقصص للعمل بدون إنترنت
/// تُبقي حجم التطبيق خفيفاً وتُحمّل فقط ما يختاره المستخدم وتخزنه محلياً مع دعم التحديث من الشبكة
class OfflineContentDownloadService extends ChangeNotifier {
  OfflineContentDownloadService._();
  static final OfflineContentDownloadService instance =
      OfflineContentDownloadService._();

  static const String _prefsIndexKey = 'firdaws_offline_downloads_index_v1';
  static const String _prefsPayloadPrefix = 'firdaws_offline_payload_v1_';

  final Map<String, int> _downloadedSizes = {}; // id -> bytes
  final Set<String> _downloadingIds = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;
  Set<String> get downloadedIds => Set.unmodifiable(_downloadedSizes.keys);
  int get totalDownloadedCount => _downloadedSizes.length;
  int get totalDownloadedBytes =>
      _downloadedSizes.values.fold<int>(0, (a, b) => a + b);

  bool isDownloaded(String id) => _downloadedSizes.containsKey(id);
  bool isDownloading(String id) => _downloadingIds.contains(id);
  int downloadedSizeBytes(String id) => _downloadedSizes[id] ?? 0;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsIndexKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _downloadedSizes.clear();
        for (final e in decoded.entries) {
          _downloadedSizes[e.key] = (e.value as num).toInt();
        }
      }
    } catch (e) {
      debugPrint('OfflineContentDownloadService init: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// تنزيل كتاب أو قصة وتخزينها محلياً للقراءة بدون إنترنت
  Future<bool> downloadContent({
    required String id,
    required Map<String, dynamic> offlineBundleJson,
    String? remoteVerificationUrl,
  }) async {
    await init();
    if (_downloadingIds.contains(id)) return false;

    _downloadingIds.add(id);
    notifyListeners();

    try {
      final enrichedBundle = Map<String, dynamic>.from(offlineBundleJson);
      enrichedBundle['downloadedAt'] = DateTime.now().toIso8601String();
      enrichedBundle['offlineReady'] = true;

      // محاولة التحقق أو جلب ملحق إضافي عبر الشبكة عند توفرها بمهلة قصيرة
      if (remoteVerificationUrl != null && remoteVerificationUrl.isNotEmpty) {
        try {
          final resp = await http
              .get(Uri.parse(remoteVerificationUrl))
              .timeout(const Duration(seconds: 4));
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            enrichedBundle['remoteVerified'] = true;
          }
        } catch (_) {
          // نكتفي بالنسخة الموثقة المعتمدة حتى بدون اتصال بالإنترنت
          enrichedBundle['remoteVerified'] = false;
        }
      }

      final encoded = jsonEncode(enrichedBundle);
      final bytesLen = utf8.encode(encoded).length;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefsPayloadPrefix$id', encoded);
      _downloadedSizes[id] = bytesLen;
      await prefs.setString(_prefsIndexKey, jsonEncode(_downloadedSizes));
      return true;
    } catch (e) {
      debugPrint('OfflineContentDownloadService download error ($id): $e');
      return false;
    } finally {
      _downloadingIds.remove(id);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> readOfflineBundle(String id) async {
    await init();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefsPayloadPrefix$id');
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeDownload(String id) async {
    await init();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefsPayloadPrefix$id');
      _downloadedSizes.remove(id);
      await prefs.setString(_prefsIndexKey, jsonEncode(_downloadedSizes));
      notifyListeners();
    } catch (e) {
      debugPrint('OfflineContentDownloadService remove error: $e');
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '٠ ك.ب';
    if (bytes < 1024) return '$bytes بايت';
    final kb = (bytes / 1024).toStringAsFixed(1);
    return '$kb ك.ب';
  }
}
