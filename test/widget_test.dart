import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/font_catalog.dart';
import 'package:islamic_prayer_app/models/islamic_audio_data.dart';
import 'package:islamic_prayer_app/models/islamic_missions_data.dart';
import 'package:islamic_prayer_app/models/islamic_qa_500.dart';
import 'package:islamic_prayer_app/models/islamic_stories_data.dart';
import 'package:islamic_prayer_app/models/islamic_titles_200.dart';
import 'package:islamic_prayer_app/models/jannati_encyclopedia_data.dart';
import 'package:islamic_prayer_app/models/motivational_phrases_500.dart';
import 'package:islamic_prayer_app/models/prayer_identity_model.dart';
import 'package:islamic_prayer_app/models/prayer_info.dart';
import 'package:islamic_prayer_app/models/prayer_model.dart';
import 'package:islamic_prayer_app/models/quran_model.dart';
import 'package:islamic_prayer_app/models/sacred_reference_parser.dart';
import 'package:islamic_prayer_app/models/sahih_hadith_data.dart';
import 'package:islamic_prayer_app/models/tasbih_3d_phrases_200.dart';
import 'package:islamic_prayer_app/models/tasbih_challenge.dart';
import 'package:islamic_prayer_app/models/touch_effects_200.dart';
import 'package:islamic_prayer_app/providers/firdaws_user_provider.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/utils/compass_utils.dart';
import 'package:islamic_prayer_app/widgets/prayer_time_effects_canvas.dart';
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

  test('Al-Firdaws provides 3 calm readable Arabic fonts defaulting to Cairo', () {
    expect(FontCatalog.allFonts.length, 3);
    final uniqueFamilies = FontCatalog.allFonts.map((f) => f.family).toSet();
    expect(uniqueFamilies.length, 3);
    expect(FontCatalog.getByFamily('non_existent_font').family, 'Cairo');
  });

  test('Tasbih provides 20 distinct goal completion effects & challenges', () {
    expect(TasbihGoalEffectsCatalog.allEffects.length, 20);
    final numbers = TasbihGoalEffectsCatalog.allEffects.map((e) => e.number).toSet();
    expect(numbers.length, 20);
    expect(TasbihGoalEffectsCatalog.allEffects.first.number, 1);
    expect(TasbihGoalEffectsCatalog.allEffects.last.number, 20);

    expect(TasbihChallengesCatalog.builtIn.length, greaterThanOrEqualTo(10));
  });

  test('All 52 themes span 4 categories with distinct Day and Night palettes + custom font', () {
    expect(IslamicTheme.allThemes.length, 52);
    final keys = IslamicTheme.allThemes.map((t) => t.key).toSet();
    expect(keys.length, 52);

    int catTotal = 0;
    for (final cat in ThemeCategory.values) {
      final list = IslamicTheme.themesByCategory(cat);
      expect(list, isNotEmpty, reason: 'Empty ThemeCategory $cat');
      catTotal += list.length;
    }
    expect(catTotal, 52);
    expect(IslamicTheme.themesByCategory(null).length, 52);

    for (final theme in IslamicTheme.allThemes) {
      expect(theme.nightPalette.isDark, isTrue);
      expect(theme.dayPalette.isDark, isFalse);
      expect(theme.name.trim(), isNotEmpty);
      expect(theme.landmarkName.trim(), isNotEmpty);

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

    // Verify Palace logo and all 52 theme background photos exist
    final logoBytes = await rootBundle.load('assets/images/palace_jannah_logo.png');
    expect(logoBytes.lengthInBytes, greaterThan(10000));
    for (final t in IslamicTheme.allThemes) {
      final bgBytes = await rootBundle.load('assets/images/themes/${t.key}.jpg');
      expect(bgBytes.lengthInBytes, greaterThan(15000), reason: 'Missing theme bg for ${t.key}');
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

  test('Exactly 200 distinct Islamic titles exist with unique IDs, genders, and positive targets', () {
    const titles = IslamicTitlesCatalog.allTitles;
    expect(titles.length, 200);

    final ids = titles.map((t) => t.id).toSet();
    final numbers = titles.map((t) => t.number).toSet();
    final males = titles.map((t) => t.titleMale).toSet();
    final females = titles.map((t) => t.titleFemale).toSet();

    expect(ids.length, 200);
    expect(numbers.length, 200);
    expect(titles.first.number, 1);
    expect(titles.last.number, 200);
    expect(males.length, 200);
    expect(females.length, 200);

    for (final t in titles) {
      expect(t.targetValue, greaterThan(0), reason: 'Invalid target for ${t.id}');
      expect(t.missionDescription.trim(), isNotEmpty, reason: 'Empty mission for ${t.id}');
    }
  });

  test('Exactly 500 unique motivational phrases personalize cleanly by name & gender', () {
    final phrases = MotivationalPhrasesCatalog.allPhrases;
    expect(phrases.length, 500);

    final uniqueTemplates = phrases.map((p) => p.template).toSet();
    expect(uniqueTemplates.length, 500, reason: 'Duplicate template detected in 500 phrases');

    for (int i = 0; i < phrases.length; i++) {
      final p = phrases[i];
      expect(p.number, i + 1);
      expect(p.template.contains('{name}'), isTrue, reason: 'Phrase #${p.number} missing {name}');

      final formattedMale = p.format(name: 'وليد', isFemale: false);
      final formattedFemale = p.format(name: 'فاطمة', isFemale: true);
      expect(formattedMale.contains('وليد'), isTrue);
      expect(formattedFemale.contains('فاطمة'), isTrue);
      expect(formattedMale.contains('[['), isFalse, reason: 'Unresolved tag in male #${p.number}');
      expect(formattedFemale.contains('[['), isFalse, reason: 'Unresolved tag in female #${p.number}');
      expect(formattedMale.contains(']]'), isFalse);
      expect(formattedFemale.contains(']]'), isFalse);
    }
  });

  test('Islamic missions cover all 4 categories and Quiz Bank has 50 valid questions', () {
    final missions = IslamicMissionsCatalog.builtInMissions;
    expect(missions.length, 28);
    for (final cat in IslamicMissionCategory.values) {
      expect(missions.where((m) => m.category == cat), isNotEmpty);
    }

    const quiz = IslamicQuizBank.allQuestions;
    expect(quiz.length, 50);
    for (final q in quiz) {
      expect(q.options.length, 4);
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.question.trim(), isNotEmpty);
      expect(q.explanation.trim(), isNotEmpty);
    }
  });

  test('Prayer time atmospheric effects resolve for every override and daylight window', () {
    final prayers = AdvancedPrayerTimes.calculate(
      latitude: 24.7136,
      longitude: 46.6753,
      method: CalculationMethod.umm_al_qura,
      madhab: Madhab.shafi,
    );
    expect(PrayerWindowEffect.values.length, 7);
    for (final eff in PrayerWindowEffect.values) {
      final resolved = PrayerWindowEffectExt.resolveActiveWindow(
        prayerData: prayers,
        overrideKey: eff.name,
      );
      expect(resolved, eff);
    }
    final autoResolved = PrayerWindowEffectExt.resolveActiveWindow(
      prayerData: prayers,
      overrideKey: 'auto',
    );
    expect(PrayerWindowEffect.values.contains(autoResolved), isTrue);
  });

  test('FirdawsUserProvider tracks historical Prayer Log, Qada, Journal, Missions & Title unlocks',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prov = FirdawsUserProvider();
    await prov.init();

    // 1. Profile & Personalized phrase
    await prov.updateProfile(
      name: 'أحمد',
      age: 27,
      gender: 'male',
      preferences: ['الفجر في جماعة', 'قيام الليل والوتر'],
      dailyDhikrGoal: 300,
    );
    expect(prov.displayName, 'أحمد');
    expect(prov.profile.age, 27);
    expect(prov.getPersonalizedMotivation().contains('أحمد'), isTrue);

    // 2. Historical prayer log & Qada recovery
    final pastDay = DateTime.now().subtract(const Duration(days: 4));
    await prov.setPrayerStatus(pastDay, 'fajr', PrayerLogStatus.missed);
    expect(prov.getMissedPrayerEntries().length, 1);

    final unlockedFromQada =
        await prov.setPrayerStatus(pastDay, 'fajr', PrayerLogStatus.prayedQada);
    expect(prov.getMissedPrayerEntries(), isEmpty);
    expect(prov.qadaRecoveredCount, 1);
    expect(prov.totalPrayersLogged, 1);
    expect(unlockedFromQada, isNotEmpty);

    // 3. Today complete 5 prayers streak
    final today = DateTime.now();
    for (final k in FirdawsUserProvider.obligatoryPrayerKeys) {
      await prov.setPrayerStatus(today, k, PrayerLogStatus.prayedInGroup);
    }
    expect(prov.recordForDate(today).allFiveCompleted, isTrue);
    expect(prov.currentPrayerStreak, greaterThanOrEqualTo(1));
    expect(prov.fajrOnTimeCount, greaterThanOrEqualTo(1));
    expect(prov.congregationPrayersCount, 5);

    // 4. Personal Journal CRUD
    await prov.addJournalEntry(
      title: 'خاطرة الفجر',
      content: 'الحمد لله على صلاة الفجر في جماعة اليوم.',
      category: 'خاطرة إيمانية',
      mood: 'طمأنينة',
    );
    expect(prov.journalEntries.length, 1);
    final noteId = prov.journalEntries.first.id;
    await prov.togglePinJournal(noteId);
    expect(prov.journalEntries.first.isPinned, isTrue);
    await prov.updateJournalEntry(
      id: noteId,
      title: 'خاطرة محدثة',
      content: 'محتوى محدث',
      category: 'تأمل قرآني',
      mood: 'شكر',
    );
    expect(prov.journalEntries.first.title, 'خاطرة محدثة');

    // 5. Quiz win & Custom mission & Title equipping
    await prov.recordQuizRoundResult(correctAnswers: 4, totalQuestions: 5);
    expect(prov.competitionsWon, 1);

    await prov.addCustomMission(
      islamicTitle: 'وردُ المراجعة',
      subtitle: 'مراجعة سورة الملك',
      category: IslamicMissionCategory.taat,
      targetCount: 1,
    );
    expect(prov.customMissions.length, 1);
    await prov.advanceMission(prov.customMissions.first.id, amount: 1);
    expect(prov.completedMissionsTotal, greaterThanOrEqualTo(1));

    expect(prov.unlockedTitleIds, isNotEmpty);
    final firstUnlockedId = prov.unlockedTitleIds.first;
    final equipped = await prov.equipTitle(firstUnlockedId);
    expect(equipped, isTrue);
    expect(prov.activeTitle?.id, firstUnlockedId);

    await prov.deleteJournalEntry(noteId);
    expect(prov.journalEntries, isEmpty);
  });

  test('IslamicQaCatalog provides 500 verified Q&A items across 10 categories with smart lookup',
      () {
    final all = IslamicQaCatalog.allQuestions;
    expect(all.length, 500);
    final ids = all.map((q) => q.id).toSet();
    final numbers = all.map((q) => q.number).toSet();
    expect(ids.length, 500);
    expect(numbers.length, 500);
    expect(all.first.number, 1);
    expect(all.last.number, 500);

    for (final cat in IslamicQaCategory.values) {
      expect(
        IslamicQaCatalog.byCategory(cat).length,
        50,
        reason: 'Category $cat should have 50 Q&A items',
      );
    }

    final palaceRes = IslamicQaCatalog.answerAnyQuestion('كيف أبني قصراً في الجنة؟');
    expect(palaceRes.hasDirectAnswer, isTrue);
    expect(palaceRes.matches, isNotEmpty);

    final colloquialRes = IslamicQaCatalog.answerAnyQuestion('ازاي اتوب ربنا؟');
    expect(colloquialRes.hasDirectAnswer, isTrue);
    expect(colloquialRes.smartSummary.trim(), isNotEmpty);
  });

  test('JannatiCatalog encyclopedia and JannatiProvider state persistence & rank progression',
      () async {
    expect(JannatiCatalog.investments.length, 14);
    expect(JannatiCatalog.gatesOfJannah.length, 8);
    expect(JannatiCatalog.levelsAndNames.length, 12);
    expect(JannatiCatalog.riversAndSprings.length, 8);
    expect(JannatiCatalog.atlasOfDelights.length, 18);
    expect(JannatiCatalog.dailyArchitectChecklist.length, 16);
    expect(JannatiCatalog.companionshipPaths.length, 10);
    expect(JannatiCatalog.ranks.length, 12);
    expect(JannatiCatalog.quizQuestions.length, 25);

    SharedPreferences.setMockInitialValues({});
    final jp = JannatiProvider();
    await jp.init();
    expect(jp.isInitialized, isTrue);
    expect(jp.currentRank.level, 1);

    // 1. Direct palm tap builds 1 palm immediately
    final palmRes = await jp.performInvestmentTap('palms');
    expect(palmRes.completedCycle, isTrue);
    expect(jp.palmsCount, 1);

    // 2. Ikhlas palace requires 10 recitations per palace
    for (int i = 0; i < 9; i++) {
      final stepRes = await jp.performInvestmentTap('ikhlas_palaces');
      expect(stepRes.completedCycle, isFalse);
      expect(jp.cycleProgressFor('ikhlas_palaces'), i + 1);
    }
    final palaceComplete = await jp.performInvestmentTap('ikhlas_palaces');
    expect(palaceComplete.completedCycle, isTrue);
    expect(jp.palacesCount, 1);
    expect(jp.totalJannahPoints, greaterThanOrEqualTo(135));

    // 3. Daily architect checklist & Q&A bookmark & Aspirations & Quiz
    final addedDaily =
        await jp.toggleDailyAction(JannatiCatalog.dailyArchitectChecklist.first.id);
    expect(addedDaily, isTrue);
    expect(jp.currentRank.level, greaterThanOrEqualTo(2));

    await jp.addPersonalAspiration('دخول الفردوس بلا حساب');
    expect(jp.personalAspirations.contains('دخول الفردوس بلا حساب'), isTrue);

    final bookmarked = await jp.toggleQaBookmark('qa_1');
    expect(bookmarked, isTrue);
    expect(jp.bookmarkedQaIds.contains('qa_1'), isTrue);

    await jp.recordQuizResult(score: 25, total: 25);
    expect(jp.bestQuizScore, 25);
    expect(jp.quizzesCompleted, 1);

    // 4. Hadith-read kinetic counter
    final prevTick = jp.statsKineticTick;
    final firstRead = await jp.markJannahHadithRead('jannah_h_1', title: 'حديث الفردوس');
    expect(firstRead, isTrue);
    expect(jp.hadithsReadCount, 1);
    expect(jp.statsKineticTick, prevTick + 1);
  });

  test('All 5 Adhan voice MP3s & offline Tafsir Muyassar (6236 ayahs) load properly',
      () async {
    expect(IslamicAudioLibrary.adhanVoices.length, 5);
    for (final v in IslamicAudioLibrary.adhanVoices) {
      final bd = await rootBundle.load('assets/${v.assetPath}');
      expect(bd.lengthInBytes, greaterThan(10000), reason: 'Missing Adhan audio ${v.assetPath}');
    }

    final tafsirMap = await TafsirRepository.loadOfflineMuyassar();
    expect(tafsirMap.length, 114);
    final totalTafsirAyahs = tafsirMap.values.fold<int>(0, (sum, list) => sum + list.length);
    expect(totalTafsirAyahs, 6236);
    expect(tafsirMap['1']!.first.trim(), isNotEmpty);

    final prayers = AdvancedPrayerTimes.calculate(
      latitude: 24.7136,
      longitude: 46.6753,
      method: CalculationMethod.umm_al_qura,
      madhab: Madhab.shafi,
    );
    expect(prayers.tomorrowFajr.isAfter(prayers.prayerTimes.fajr), isTrue);
  });

  test('Authentic Islamic Stories (52), Sahih Bukhari (120) & SacredReferenceParser work accurately',
      () async {
    expect(IslamicStoriesCatalog.allStories.length, 52);
    for (final cat in StoryCategory.values) {
      expect(IslamicStoriesCatalog.byCategory(cat), isNotEmpty);
    }
    for (final st in IslamicStoriesCatalog.allStories) {
      expect(st.chapters, isNotEmpty, reason: 'Empty chapters for ${st.id}');
      expect(st.lessons, isNotEmpty, reason: 'Empty lessons for ${st.id}');
      final imgBytes = await rootBundle.load('assets/images/themes/${st.themeImageKey}.jpg');
      expect(imgBytes.lengthInBytes, greaterThan(5000),
          reason: 'Missing story background ${st.themeImageKey}.jpg');
    }

    expect(SahihHadithCatalog.allHadiths.length, 120);
    for (final ch in SahihHadithCatalog.chapters) {
      expect(SahihHadithCatalog.byChapter(ch.id), isNotEmpty);
    }
    expect(SahihHadithCatalog.resolveReference('صحيح البخاري (1)').id, 'b_1');

    final refs1 = SacredReferenceParser.extractQuranReferences('تأمل في البقرة: 255 وسورة الإخلاص: 1');
    expect(refs1.any((r) => r.surahNumber == 2 && r.ayahNumber == 255), isTrue);
    expect(refs1.any((r) => r.surahNumber == 112 && r.ayahNumber == 1), isTrue);

    final refs2 = SacredReferenceParser.extractQuranReferences('في سورة غافر — الآية (٨) و آية الكرسي');
    expect(refs2.any((r) => r.surahNumber == 40 && r.ayahNumber == 8), isTrue);
    expect(refs2.any((r) => r.surahNumber == 2 && r.ayahNumber == 255), isTrue);

    expect(SacredReferenceParser.containsHadithReference('رواه البخاري (6306)'), isTrue);
    final hResolved = SacredReferenceParser.resolveHadith('رواه البخاري (1)');
    expect(hResolved.sourceReference.contains('1'), isTrue);
  });

  test('200 Touch Effects, 200 3D Tasbih Phrases, Per-Theme Emojis, Avatar & About Me persistence',
      () async {
    expect(TouchEffectsCatalog.allEffects.length, 200);
    expect(TouchEffectsCatalog.allEffects.map((e) => e.number).toSet().length, 200);
    expect(TouchEffectsCatalog.allEffects.map((e) => e.id).toSet().length, 200);
    for (final cat in TouchEffectCategory.values) {
      expect(TouchEffectsCatalog.allEffects.where((e) => e.category == cat), isNotEmpty);
    }

    expect(Tasbih3DPhrasesCatalog.allPhrases.length, 200);
    expect(Tasbih3DPhrasesCatalog.allPhrases.map((p) => p.number).toSet().length, 200);

    for (final t in IslamicTheme.allThemes) {
      expect(t.primaryEmoji.trim(), isNotEmpty, reason: 'Empty primaryEmoji for ${t.key}');
      expect(t.signatureEmojis.length, 8, reason: 'Expected 8 emojis for ${t.key}');
    }

    SharedPreferences.setMockInitialValues({});
    final userProv = FirdawsUserProvider();
    await userProv.init();

    final sampleB64 = base64Encode([137, 80, 78, 71, 13, 10, 26, 10]);
    await userProv.updateAvatarBase64(sampleB64);
    expect(userProv.avatarBytes, isNotNull);
    expect(userProv.avatarBytes!.length, 8);

    await userProv.updateAboutInfo(
      creatorName: 'وليد',
      creatorTitle: 'مطور تطبيق الفردوس',
      bio: 'نسألكم الدعاء بالقبول والتوفيق',
      duaRequest: 'اللهم اغفر لي ولوالدي',
    );
    expect(userProv.aboutCreatorName, 'وليد');
    await userProv.incrementCreatorDua();
    expect(userProv.creatorDuasCount, 1);
  });
}
