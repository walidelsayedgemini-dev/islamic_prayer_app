enum PrayerAlarmMode { adhan, vibrationOnly, off }

class PrayerAlarmPreference {
  const PrayerAlarmPreference({
    this.mode = PrayerAlarmMode.adhan,
    this.voiceId,
    this.volumePercent = 100,
  });

  final PrayerAlarmMode mode;
  final String? voiceId;
  final int volumePercent;

  bool get isEnabled => mode != PrayerAlarmMode.off;

  PrayerAlarmPreference copyWith({
    PrayerAlarmMode? mode,
    String? voiceId,
    bool clearVoiceId = false,
    int? volumePercent,
  }) {
    return PrayerAlarmPreference(
      mode: mode ?? this.mode,
      voiceId: clearVoiceId ? null : (voiceId ?? this.voiceId),
      volumePercent: (volumePercent ?? this.volumePercent).clamp(0, 100),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'mode': mode.name,
        'voiceId': voiceId,
        'volumePercent': volumePercent.clamp(0, 100),
      };

  factory PrayerAlarmPreference.fromJson(Object? value) {
    if (value is! Map) return const PrayerAlarmPreference();
    final rawMode = value['mode']?.toString();
    final mode = PrayerAlarmMode.values.firstWhere(
      (candidate) => candidate.name == rawMode,
      orElse: () => PrayerAlarmMode.adhan,
    );
    final rawVoice = value['voiceId']?.toString();
    const validVoices = <String>{'madinah', 'makkah', 'aqsa', 'cairo', 'afasy'};
    final volumeValue = value['volumePercent'];
    final volume = volumeValue is num ? volumeValue.round() : 100;
    return PrayerAlarmPreference(
      mode: mode,
      voiceId: validVoices.contains(rawVoice) ? rawVoice : null,
      volumePercent: volume.clamp(0, 100),
    );
  }
}
