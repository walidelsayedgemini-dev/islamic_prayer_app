import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/sahih_hadith_data.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import 'quran_reader_screen.dart';

class SahihHadithScreen extends StatefulWidget {
  final String? initialHadithId;

  const SahihHadithScreen({
    super.key,
    this.initialHadithId,
  });

  @override
  State<SahihHadithScreen> createState() => _SahihHadithScreenState();
}

class _SahihHadithScreenState extends State<SahihHadithScreen> {
  String _selectedChapterId = 'all';
  String _searchQuery = '';
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _expandedId = widget.initialHadithId;
    if (widget.initialHadithId != null) {
      final found = SahihHadithCatalog.getById(widget.initialHadithId!);
      _selectedChapterId = found.chapterId;
    }
  }

  List<SahihHadithEntry> get _filteredHadiths {
    final base = SahihHadithCatalog.byChapter(_selectedChapterId);
    if (_searchQuery.trim().isEmpty) return base;
    final q = _searchQuery.trim();
    return base
        .where(
          (h) =>
              h.title.contains(q) ||
              h.arabicText.contains(q) ||
              h.sourceReference.contains(q) ||
              h.sharhAndTafsir.contains(q) ||
              h.narrator.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final jannati = Provider.of<JannatiProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOpt.resolve(isNight: isNight);
    final accent = palette.accentColor;

    final list = _filteredHadiths;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: Prayer.isha,
              themeOption: themeOpt,
              isNightMode: isNight,
            ),
          ),
          Positioned.fill(
            child: IslamicThemeEffectsCanvas(
              themeOption: themeOpt,
              isNightMode: isNight,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // الشريط العلوي
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.cardColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: Icon(Icons.arrow_back_rounded, color: accent),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 6),
                      const Text('📜', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'موسوعة صحيح البخاري ومسلم 👑',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '١٢٠ حديثاً موثقاً بالشرح والربط المباشر بالقرآن • قرأت ${jannati.readJannahHadithIds.length} حديثاً ✨',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${themeOpt.primaryEmoji} ${list.length}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // البحث السريع
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    style: TextStyle(color: palette.textPrimary, fontSize: 13),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث في نص الحديث أو رقم البخاري أو الراوي...',
                      hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                      prefixIcon: Icon(Icons.search_rounded, color: accent),
                      isDense: true,
                      filled: true,
                      fillColor: palette.cardColor.withOpacity(0.92),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: palette.dividerColor),
                      ),
                    ),
                  ),
                ),

                // شريط أبواب البخاري
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(
                            'كل الأبواب (١٢٠) 🌟',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _selectedChapterId == 'all'
                                  ? palette.onAccentColor
                                  : palette.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: _selectedChapterId == 'all',
                          selectedColor: accent,
                          backgroundColor: palette.cardColor,
                          onSelected: (_) =>
                              setState(() => _selectedChapterId = 'all'),
                        ),
                      ),
                      for (final ch in SahihHadithCatalog.chapters)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ChoiceChip(
                            label: Text(
                              '${ch.emoji} ${ch.title}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _selectedChapterId == ch.id
                                    ? palette.onAccentColor
                                    : palette.textPrimary,
                                fontWeight: _selectedChapterId == ch.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: _selectedChapterId == ch.id,
                            selectedColor: accent,
                            backgroundColor: palette.cardColor,
                            onSelected: (_) =>
                                setState(() => _selectedChapterId = ch.id),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (_, idx) {
                      final h = list[idx];
                      final isExpanded = _expandedId == h.id;
                      final isRead = jannati.readJannahHadithIds.contains(h.id);
                      return _buildHadithCard(
                        h,
                        isExpanded: isExpanded,
                        isRead: isRead,
                        palette: palette,
                        accent: accent,
                        jannati: jannati,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    SahihHadithEntry h, {
    required bool isExpanded,
    required bool isRead,
    required ThemePalette palette,
    required Color accent,
    required JannatiProvider jannati,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _expandedId = isExpanded ? null : h.id);
        jannati.markJannahHadithRead(
          h.id,
          title: h.title,
          sourceRef: h.sourceReference,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.cardColor.withOpacity(palette.isDark ? 0.90 : 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpanded
                ? accent
                : (isRead ? accent.withOpacity(0.5) : palette.dividerColor),
            width: isExpanded ? 1.7 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(h.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${h.sourceReference} • ${h.narrator}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRead)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('✅', style: TextStyle(fontSize: 14)),
                  ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: accent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.25)),
              ),
              child: Text(
                h.arabicText,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  height: 1.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Text(
                '📖 الشرح والتفسير الميسر:',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                h.sharhAndTafsir,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Text(
                        'الفائدة العملية: ${h.practicalBenefit}',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (h.linkedSurah != null) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuranReaderScreen(
                          initialSurahNumber: h.linkedSurah,
                          initialHighlightAyah: h.linkedAyah ?? 1,
                          openTafsirOnStart: true,
                        ),
                      ),
                    );
                  },
                  icon: FirdawsBrandLogo(
                    size: 22,
                    borderColor: palette.onAccentColor,
                    borderWidth: 1.0,
                    fallbackIcon: Icons.menu_book_rounded,
                  ),
                  label: Text(
                    'فتح الآية المرتبطة في المصحف الشريف 📖 (${h.linkedSurah}:${h.linkedAyah ?? 1})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: palette.onAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
