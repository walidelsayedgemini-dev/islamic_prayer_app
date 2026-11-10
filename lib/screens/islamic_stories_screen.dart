import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/islamic_stories_data.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/sacred_reference_widgets.dart';
import '../widgets/story_scene_painter.dart';

class IslamicStoriesScreen extends StatefulWidget {
  final String? initialStoryId;

  const IslamicStoriesScreen({
    super.key,
    this.initialStoryId,
  });

  @override
  State<IslamicStoriesScreen> createState() => _IslamicStoriesScreenState();
}

class _IslamicStoriesScreenState extends State<IslamicStoriesScreen> {
  StoryCategory? _selectedCategory;
  String _searchQuery = '';
  IslamicStory? _activeStory;

  @override
  void initState() {
    super.initState();
    if (widget.initialStoryId != null) {
      _activeStory = IslamicStoriesCatalog.getById(widget.initialStoryId!);
    }
  }

  List<IslamicStory> get _filteredStories {
    final base = IslamicStoriesCatalog.byCategory(_selectedCategory);
    if (_searchQuery.trim().isEmpty) return base;
    final q = _searchQuery.trim();
    return base
        .where(
          (s) =>
              s.title.contains(q) ||
              s.subtitle.contains(q) ||
              s.primarySource.contains(q) ||
              s.chapters.any((c) => c.heading.contains(q) || c.body.contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOpt.resolve(isNight: isNight);
    final accent = palette.accentColor;

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
            child: _activeStory == null
                ? _buildStoriesCatalogView(palette, themeOpt, accent)
                : _buildStoryReaderView(_activeStory!, palette, themeOpt, accent),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesCatalogView(
    ThemePalette palette,
    ThemeOption themeOpt,
    Color accent,
  ) {
    final stories = _filteredStories;

    return Column(
      children: [
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
              const Text('📖', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القصص النبوية وسير الصالحين ✨',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '٥٢ قصة صحيحة وموثقة بالقرآن وصحيح البخاري مع مشاهد حية تفاعلية ${themeOpt.primaryEmoji}',
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
            ],
          ),
        ),

        // البحث
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            style: TextStyle(color: palette.textPrimary, fontSize: 13),
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'ابحث باسم النبي أو الصحابي أو القصة...',
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

        // تصنيفات القصص
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
                    'الكل (٥٢) 🌟',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _selectedCategory == null
                          ? palette.onAccentColor
                          : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: _selectedCategory == null,
                  selectedColor: accent,
                  backgroundColor: palette.cardColor,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
              ),
              for (final cat in StoryCategory.values)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(
                      cat.arabicLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _selectedCategory == cat
                            ? palette.onAccentColor
                            : palette.textPrimary,
                        fontWeight: _selectedCategory == cat
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: _selectedCategory == cat,
                    selectedColor: accent,
                    backgroundColor: palette.cardColor,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: stories.length,
            itemBuilder: (_, idx) {
              final s = stories[idx];
              return GestureDetector(
                onTap: () => setState(() => _activeStory = s),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: palette.cardColor.withOpacity(palette.isDark ? 0.90 : 0.96),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: s.accentColor.withOpacity(0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: s.accentColor.withOpacity(0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(19),
                        ),
                        child: Stack(
                          children: [
                            Image.asset(
                              s.assetImagePath,
                              width: 102,
                              height: 106,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 102,
                                height: 106,
                                color: s.accentColor.withOpacity(0.25),
                                child: Center(
                                  child: Text(
                                    s.emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${s.emoji} #${s.number}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.category.shortLabel,
                                style: TextStyle(
                                  color: s.accentColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.title,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                s.subtitle,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '📖 ${s.chapters.length} فصول • ${s.primarySource}',
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: accent),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryReaderView(
    IslamicStory story,
    ThemePalette palette,
    ThemeOption themeOpt,
    Color accent,
  ) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: story.accentColor.withOpacity(0.55)),
          ),
          child: Row(
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: Icon(Icons.arrow_back_rounded, color: accent),
                onPressed: () => setState(() => _activeStory = null),
              ),
              const SizedBox(width: 6),
              Text(story.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  story.title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '#${story.number} ${themeOpt.primaryEmoji}',
                style: TextStyle(
                  color: story.accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // مسرح الصور ٤K + الأنيميشن الحي متعدد الطبقات
                StorySceneStage(story: story, height: 225),
                const SizedBox(height: 10),

                // شريط الوثوق والربط السريع بالمصحف وصحيح البخاري
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (story.quranSurah != null)
                      QuranRefBadge(
                        surahNumber: story.quranSurah!,
                        ayahNumber: story.quranAyah ?? 1,
                        accentColor: story.accentColor,
                      ),
                    if (story.hadithId != null)
                      HadithRefBadge(
                        referenceText: story.hadithId!,
                        accentColor: story.accentColor,
                        trackInJannati: true,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // فصول القصة الموثقة
                for (int i = 0; i < story.chapters.length; i++) ...[
                  _buildChapterCard(
                    i + 1,
                    story.chapters[i],
                    story,
                    palette,
                  ),
                  const SizedBox(height: 10),
                ],

                // العبر المستفادة
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: story.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: story.accentColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💎 الدروس والعبر المستفادة من القصة:',
                        style: TextStyle(
                          color: story.accentColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final lesson in story.lessons)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✨ ', style: TextStyle(fontSize: 13)),
                              Expanded(
                                child: Text(
                                  lesson,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterCard(
    int number,
    StoryChapter ch,
    IslamicStory story,
    ThemePalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.90 : 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: story.accentColor.withOpacity(0.18),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: story.accentColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ch.heading,
                  style: TextStyle(
                    color: story.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ch.body,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13.5,
              height: 1.75,
            ),
          ),
          if (ch.quranSurah != null || ch.hadithId != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (ch.quranSurah != null)
                  QuranRefBadge(
                    surahNumber: ch.quranSurah!,
                    ayahNumber: ch.quranAyah ?? 1,
                    accentColor: story.accentColor,
                  ),
                if (ch.hadithId != null)
                  HadithRefBadge(
                    referenceText: ch.hadithId!,
                    accentColor: story.accentColor,
                    trackInJannati: true,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
