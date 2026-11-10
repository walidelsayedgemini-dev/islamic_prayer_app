class AudioCacheHelper {
  static bool get supportsOfflineFileCache => false;

  static Future<String?> getExistingFilePath(String trackKey) async => null;

  static Future<Set<String>> listCachedTrackKeys() async => <String>{};

  static Future<String?> downloadTrack(
    String trackKey,
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    return null;
  }

  static Future<void> deleteCachedTrack(String trackKey) async {}

  static Future<int> getCacheSizeBytes() async => 0;

  static Future<void> clearAllCache() async {}
}
