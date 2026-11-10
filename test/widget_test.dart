import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';
import 'package:islamic_prayer_app/models/font_catalog.dart';
import 'package:islamic_prayer_app/models/islamic_audio_data.dart';
import 'package:islamic_prayer_app/models/prayer_identity_model.dart';
import 'package:islamic_prayer_app/models/prayer_info.dart';
import 'package:islamic_prayer_app/models/prayer_model.dart';
import 'package:islamic_prayer_app/models/quran_model.dart';
import 'package:islamic_prayer_app/models/tasbih_challenge.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/utils/compass_utils.dart';
import 'package:islamic_prayer_app/widgets/tasbih_goal_effects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Prayer times calculation smoke test', () {
    final prayers = AdvancedPrayerTimes.calculate(
      latitude: 24.7136,
      longitude: 46.6753,
      method: CalculationMethod.umm_al_qura,
      madhab: Madhab.shafi,
    );

    expect(prayers.prayerTimes.fajr, isNotNull);
    expect(prayers.prayerTimes.dhuhr, isNotNull);
    expect(prayers.prayerTimes.asr, isNotNull);
    expect(prayers.prayerTimes.maghrib, isNotNull);
    expect(prayers.prayerTimes.isha, isNotNull);
    expect(prayers.qiyamStart, isNotNull);
    expect(prayers.islamicMidnight, isNotNull);
    expect(prayers.duhaStart, isNotNull);
  });

  test('Compass needle smoothing test', () {
    double current = 350.0;
    double newHeading = 10.0;
    double smoothed = smoothHeading(current, newHeading, 0.5);
    expect(smoothed, anyOf(0.0, 360.0));
  });

  test('Al-Firdaws provides exactly 20 unique bundled Arabic fonts', () {
    expect(FontCatalog.allFonts.length, 20);
    final uniqueFamilies = FontCatalog.allFonts.map((f) => f.family).toSet();
    expect(uniqueFamilies.length, 20);
    expect(FontCatalog.getByFamily('non_existent_font').family, 'Aref Ruqaa');
  });

  test('Tasbih provides 20 distinct goal completion effects & challenges', () {
    expect(TasbihGoalEffectsCatalog.allEffects.length, 20);
    final numbers = TasbihGoalEffectsCatalog.allEffects.map((e) => e.number).toSet();
    expect(numbers.length, 20);
    expect(TasbihGoalEffectsCatalog.allEffects.first.number, 1);
    expect(TasbihGoalEffectsCatalog.allEffects.last.number, 20);

    expect(TasbihChallengesCatalog.builtIn.length, greaterThanOrEqualTo(10));
  });

  test('All 12 themes support distinct Day and Night palettes + custom font', () {
    expect(IslamicTheme.allThemes.length, 12);
    for (final theme in IslamicTheme.allThemes) {
      expect(theme.nightPalette.isDark, isTrue);
      expect(theme.dayPalette.isDark, isFalse);

      final nightTheme = IslamicTheme.getTheme(
        theme.key,
        isNight: true,
        fontFamily: 'Cairo',
      );
      final dayTheme = IslamicTheme.getTheme(
        theme.key,
        isNight: false,
        fontFamily: 'Tajawal',
      );
      expect(nightTheme.brightness, Brightness.dark);
      expect(dayTheme.brightness, Brightness.light);
    }
  });

  test('Complete 114-Surah / 6236-Ayah Quran loads cleanly with Basmalah normalization & search',
      () async {
    final raw = await rootBundle.loadString('assets/data/quran_complete.json');
    final surahs = parseQuranJsonString(raw);
    expect(surahs.length, 114);

    final totalAyahs = surahs.fold<int>(0, (sum, s) => sum + s.ayahs.length);
    expect(totalAyahs, 6236);

    // Surah 1 retains Basmalah as Ayah 1 without BOM
    expect(surahs[0].hasOpeningBasmalah, isFalse);
    expect(surahs[0].ayahs.first.text.startsWith('\uFEFF'), isFalse);
    expect(surahs[0].ayahs.first.normalizedText.startsWith('بسم الله'), isTrue);

    // Surah 2 strips prepended Basmalah cleanly
    expect(surahs[1].hasOpeningBasmalah, isTrue);
    expect(surahs[1].ayahs.first.normalizedText.startsWith('بسم'), isFalse);
    expect(surahs[1].ayahs.first.normalizedText, 'الم');

    // Surah 95 handles shadda on ب in Basmalah properly
    expect(surahs[94].ayahs.first.normalizedText.startsWith('والتين'), isTrue);

    // Surah 9 has 129 ayahs and no opening Basmalah
    expect(surahs[8].hasOpeningBasmalah, isFalse);
    expect(surahs[8].ayahs.length, 129);
    expect(surahs[8].ayahs.first.normalizedText.startsWith('براءه'), isTrue);

    // Verify all 112 surahs with prepended Basmalah stripped properly
    for (final s in surahs) {
      if (s.number != 1 && s.number != 9) {
        expect(
          s.ayahs.first.normalizedText.startsWith('بسم الله الرحمن الرحيم'),
          isFalse,
          reason: 'Surah ${s.number} still contains prepended Basmalah',
        );
      }
    }

    // Search Ayat al-Kursi
    final hits = QuranRepository.searchInsideAyahs(surahs, 'الله لا اله الا هو الحي القيوم');
    expect(hits, isNotEmpty);
    expect(hits.first.surah.number, 2);
    expect(hits.first.ayah.number, 255);
  });

  test('All audio library URLs, bundled offline MP3s, theme photos & palace logo exist', () async {
    expect(IslamicAudioLibrary.allSurahs.length, 114);
    expect(IslamicAudioLibrary.reciters.length, 6);

    for (final reciter in IslamicAudioLibrary.reciters) {
      final u1 = IslamicAudioLibrary.getSurahUrl(reciter.id, 1);
      final u114 = IslamicAudioLibrary.getSurahUrl(reciter.id, 114);
      expect(u1, startsWith('https://cdn.mp3quran.net/audio/'));
      expect(u114, endsWith('/114.mp3'));
    }

    // Verify all bundled Quran MP3s exist in assets/
    for (final n in [1, 108, 109, 110, 111, 112, 113, 114]) {
      final rel = IslamicAudioLibrary.getBundledSurahAsset('qatami', n);
      expect(rel, isNotNull);
      final bd = await rootBundle.load('assets/$rel');
      expect(bd.lengthInBytes, greaterThan(10000));
    }
    for (final n in [1, 112, 113, 114]) {
      final rel = IslamicAudioLibrary.getBundledSurahAsset('afasy', n);
      expect(rel, isNotNull);
      final bd = await rootBundle.load('assets/$rel');
      expect(bd.lengthInBytes, greaterThan(10000));
    }

    // Verify Ruqyah & Ibtihalat stream URLs + bundled assets
    for (final r in IslamicAudioLibrary.allRuqyah) {
      expect(r.streamUrl, startsWith('https://archive.org/'));
      if (r.localAsset != null) {
        final bd = await rootBundle.load('assets/${r.localAsset}');
        expect(bd.lengthInBytes, greaterThan(50000));
      }
    }
    for (final ib in IslamicAudioLibrary.allIbtihalat) {
      expect(ib.streamUrl, startsWith('https://archive.org/'));
      if (ib.localAsset != null) {
        final bd = await rootBundle.load('assets/${ib.localAsset}');
        expect(bd.lengthInBytes, greaterThan(50000));
      }
    }

    // Verify Palace logo and all 12 theme background photos exist
    final logoBytes = await rootBundle.load('assets/images/palace_jannah_logo.png');
    expect(logoBytes.lengthInBytes, greaterThan(10000));
    for (final t in IslamicTheme.allThemes) {
      final bgBytes = await rootBundle.load('assets/images/themes/${t.key}.jpg');
      expect(bgBytes.lengthInBytes, greaterThan(10000), reason: 'Missing theme bg for ${t.key}');
    }
  });

  test('PrayerInfo & Prayer22Distinctions cover all daily prayers including special times', () {
    for (final key in [
      'الفجر',
      'الشروق',
      'الظهر',
      'العصر',
      'المغرب',
      'العشاء',
      'صلاة الضحى',
      'منتصف الليل الشرعي',
      'ثلث الليل الأخير',
    ]) {
      expect(PrayerInfo.data[key], isNotNull, reason: 'Missing PrayerInfo for $key');
    }

    for (final p in [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ]) {
      expect(Prayer22Distinctions.data[p], isNotNull, reason: 'Missing 22-distinction for $p');
    }
  });
}
