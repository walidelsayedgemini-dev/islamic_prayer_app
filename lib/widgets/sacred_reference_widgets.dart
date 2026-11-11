import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_audio_data.dart';
import '../models/sacred_reference_parser.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/quran_reader_screen.dart';
import '../screens/sahih_hadith_screen.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_brand_logo.dart';

class SacredNavigator {
  /// يفتح المصحف الشريف مباشرةً عند السورة والآية المحددة مع التمرير والتظليل + فتح التفسير الموثق اختيارياً
  static Future<void> openQuranAyah(
    BuildContext context, {
    required int surahNumber,
    int ayahNumber = 1,
    bool openTafsirOnStart = true,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReaderScreen(
          initialSurahNumber: surahNumber,
          initialHighlightAyah: ayahNumber,
          openTafsirOnStart: openTafsirOnStart,
        ),
      ),
    );
  }

  /// يفتح نافذة الحديث النبوي الموثق من صحيح البخاري ومسلم مع الشرح والتفسير والربط بآيات القرآن
  static void openHadithSheet(
    BuildContext context,
    String referenceOrId, {
    String? titleOverride,
    String? verbatimText,
    bool trackInJannati = true,
  }) {
    final resolved = SacredReferenceParser.resolveHadith(referenceOrId);
    if (trackInJannati) {
      try {
        Provider.of<JannatiProvider>(context, listen: false).markJannahHadithRead(
          resolved.id,
          title: titleOverride ?? resolved.title,
          sourceRef: resolved.sourceReference,
        );
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final settings = Provider.of<SettingsProvider>(ctx);
        final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
        final palette = themeOpt.resolve(isNight: settings.isNightEffective);
        final accent = palette.accentColor;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: accent, width: 1.8)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(resolved.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleOverride ?? resolved.title,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📜 ${resolved.sourceReference}',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: palette.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'عن ${resolved.narrator}:',
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withOpacity(0.48)),
                  ),
                  child: SelectableText(
                    verbatimText != null && verbatimText.trim().isNotEmpty
                        ? verbatimText
                        : resolved.arabicText,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      height: 1.75,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '📖 الشرح والتفسير الميسر:',
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resolved.sharhAndTafsir,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13.5,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🌟 ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          resolved.practicalBenefit,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (resolved.linkedSurah != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            openQuranAyah(
                              context,
                              surahNumber: resolved.linkedSurah!,
                              ayahNumber: resolved.linkedAyah ?? 1,
                            );
                          },
                          icon: FirdawsBrandLogo(
                            size: 19,
                            borderColor: palette.onAccentColor,
                            borderWidth: 1.0,
                            fallbackIcon: Icons.menu_book_rounded,
                          ),
                          label: Text(
                            'المصحف (${resolved.linkedSurah}:${resolved.linkedAyah ?? 1}) 📖',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: palette.onAccentColor,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (resolved.linkedSurah != null) const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SahihHadithScreen(
                                initialHadithId: resolved.id,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.library_books_rounded, color: accent, size: 17),
                        label: Text(
                          'موسوعة البخاري 📜',
                          style: TextStyle(
                            color: accent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accent),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// زر ولوجو المصحف القابل للنقر للانتقال الفوري للآية الدقيقة + التفسير
class QuranRefBadge extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final String? customLabel;
  final Color? accentColor;
  final bool openTafsir;

  const QuranRefBadge({
    super.key,
    required this.surahNumber,
    this.ayahNumber = 1,
    this.customLabel,
    this.accentColor,
    this.openTafsir = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final palette = IslamicTheme.getThemeOption(settings.selectedTheme)
        .resolve(isNight: settings.isNightEffective);
    final accent = accentColor ?? palette.accentColor;
    final surahName =
        IslamicAudioLibrary.getSurahByNumber(surahNumber)?.nameArabic ??
            '$surahNumber';

    return InkWell(
      onTap: () => SacredNavigator.openQuranAyah(
        context,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        openTafsirOnStart: openTafsir,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FirdawsBrandLogo(
              size: 18,
              borderColor: accent,
              borderWidth: 1.0,
              fallbackIcon: Icons.menu_book_rounded,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                customLabel ?? '📖 $surahName: $ayahNumber',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر الحديث النبوي القابل للنقر لفتح الشرح والتوثيق من صحيح البخاري ومسلم
class HadithRefBadge extends StatelessWidget {
  final String referenceText;
  final String? customLabel;
  final String? titleOverride;
  final String? verbatimText;
  final Color? accentColor;
  final bool trackInJannati;

  const HadithRefBadge({
    super.key,
    required this.referenceText,
    this.customLabel,
    this.titleOverride,
    this.verbatimText,
    this.accentColor,
    this.trackInJannati = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final palette = IslamicTheme.getThemeOption(settings.selectedTheme)
        .resolve(isNight: settings.isNightEffective);
    final accent = accentColor ?? palette.primaryColor;

    return InkWell(
      onTap: () => SacredNavigator.openHadithSheet(
        context,
        referenceText,
        titleOverride: titleOverride,
        verbatimText: verbatimText,
        trackInJannati: trackInJannati,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📜', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                customLabel ?? 'الشرح والتوثيق • صحيح البخاري',
                style: TextStyle(
                  color: palette.isDark ? Colors.white : palette.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// يستخرج تلقائياً كل روابط الآيات القرآنية والأحاديث النبوية من أي نص ويحوّلها لأزرار تفاعلية مباشرة
class SacredEvidenceFooter extends StatelessWidget {
  final String evidenceText;
  final String? titleForHadith;
  final String? hadithVerbatim;
  final bool trackInJannati;

  const SacredEvidenceFooter({
    super.key,
    required this.evidenceText,
    this.titleForHadith,
    this.hadithVerbatim,
    this.trackInJannati = true,
  });

  @override
  Widget build(BuildContext context) {
    final quranRefs = SacredReferenceParser.extractQuranReferences(evidenceText);
    final hasHadith = SacredReferenceParser.containsHadithReference(evidenceText);

    if (quranRefs.isEmpty && !hasHadith) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final ref in quranRefs.take(3))
          QuranRefBadge(
            surahNumber: ref.surahNumber,
            ayahNumber: ref.ayahNumber,
          ),
        if (hasHadith)
          HadithRefBadge(
            referenceText: evidenceText,
            titleOverride: titleForHadith,
            verbatimText: hadithVerbatim,
            trackInJannati: trackInJannati,
          ),
      ],
    );
  }
}
