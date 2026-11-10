import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/sacred_reference_widgets.dart';
import 'quran_reader_screen.dart';

class QuranAzkarSheet {
  static void showQuranReader(
    BuildContext context,
    Color accentColor, {
    int? initialSurahNumber,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReaderScreen(initialSurahNumber: initialSurahNumber),
      ),
    );
  }

  static void showAzkarReader(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final palette = IslamicTheme.resolvePalette(
          settings.selectedTheme,
          isNight: settings.isNightEffective,
        );
        final accent = palette.accentColor;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: (palette.isDark ? Colors.black : palette.primaryColor)
                    .withOpacity(palette.isDark ? 0.85 : 0.22),
                blurRadius: 30,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: palette.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.20),
                      border: Border.all(color: accent, width: 1.2),
                    ),
                    child: Icon(Icons.volunteer_activism_rounded, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📿 أذكار الصباح والمساء وحصن المسلم",
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                          ),
                        ),
                        Text(
                          "«مثل الذي يذكر ربه والذي لا يذكر ربه مثل الحي والميت»",
                          style: TextStyle(color: palette.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => showAudioDownloadManagerSheet(context),
                    icon: Icon(Icons.download_for_offline_rounded, color: accent, size: 17),
                    label: Text(
                      "تحميل ⬇️",
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: palette.dividerColor, height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildDhikrCard(
                      "🌅 أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ",
                      "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.",
                      "يُقال مرة واحدة كل صباح ومساء لحفظ الملك لله والاعتراف بتوحيده (صحيح مسلم).",
                      palette,
                    ),
                    const SizedBox(height: 12),
                    _buildDhikrCard(
                      "💎 سيد الاستغفار",
                      "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.",
                      "من قالها موقناً بها فمات من يومه أو ليلته دخل الجنة — صحيح البخاري (6306).",
                      palette,
                    ),
                    const SizedBox(height: 12),
                    _buildDhikrCard(
                      "🛡️ بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ (3 مرات)",
                      "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.",
                      "من قالها ثلاثاً إذا أصبح وثلاثاً إذا أمسى لم يضره شيء أبداً (حديث صحيح).",
                      palette,
                    ),
                    const SizedBox(height: 12),
                    _buildDhikrCard(
                      "✨ رَضِيتُ بِاللَّهِ رَبًّا (3 مرات)",
                      "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا.",
                      "كان حقاً على الله تعالى أن يرضيه يوم القيامة (حديث حسن).",
                      palette,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDhikrCard(
    String title,
    String text,
    String virtue,
    ThemePalette palette,
  ) {
    final accentColor = palette.accentColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            virtue,
            style: TextStyle(
              color: palette.textMuted,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          SacredEvidenceFooter(
            evidenceText: virtue,
            titleForHadith: title,
            hadithVerbatim: text,
            trackInJannati: true,
          ),
        ],
      ),
    );
  }
}
