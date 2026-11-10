import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AudioCacheHelper {
  static bool get supportsOfflineFileCache => true;

  static String _sanitizeKey(String trackKey) {
    return trackKey.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
  }

  static Future<Directory> _getCacheDir() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${baseDir.path}${Platform.pathSeparator}audio_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  static Future<String?> getExistingFilePath(String trackKey) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}${Platform.pathSeparator}${_sanitizeKey(trackKey)}.mp3');
      if (await file.exists() && await file.length() > 10240) {
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  static Future<Set<String>> listCachedTrackKeys() async {
    final keys = <String>{};
    try {
      final dir = await _getCacheDir();
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
          if (await entity.length() > 10240) {
            final name = entity.uri.pathSegments.last;
            keys.add(name.substring(0, name.length - 4));
          }
        }
      }
    } catch (_) {}
    return keys;
  }

  static Future<String?> downloadTrack(
    String trackKey,
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final client = http.Client();
    try {
      final dir = await _getCacheDir();
      final finalPath = '${dir.path}${Platform.pathSeparator}${_sanitizeKey(trackKey)}.mp3';
      final tempFile = File('$finalPath.part');

      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = 'AlFirdawsIslamicApp/1.0';
      final response = await client.send(request).timeout(const Duration(seconds: 45));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress((receivedBytes / totalBytes).clamp(0.0, 1.0));
        }
      }

      await sink.flush();
      await sink.close();

      if (await tempFile.length() <= 4096) {
        await tempFile.delete();
        throw Exception('Downloaded file too small');
      }

      final targetFile = File(finalPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(finalPath);
      onProgress?.call(1.0);
      return finalPath;
    } finally {
      client.close();
    }
  }

  static Future<void> deleteCachedTrack(String trackKey) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}${Platform.pathSeparator}${_sanitizeKey(trackKey)}.mp3');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static Future<int> getCacheSizeBytes() async {
    int total = 0;
    try {
      final dir = await _getCacheDir();
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
          total += await entity.length();
        }
      }
    } catch (_) {}
    return total;
  }

  static Future<void> clearAllCache() async {
    try {
      final dir = await _getCacheDir();
      await for (final entity in dir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }
}
