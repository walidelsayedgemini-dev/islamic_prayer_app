import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/islamic_stories_data.dart';
import '../providers/settings_provider.dart';
import '../services/offline_content_download_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_resilient_image.dart';
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
  bool _batchDownloading = false;
  final _downloads = OfflineContentDownloadService.instance;

  @override
  void initState() {
    super.initState();
    _downloads.init();
    _downloads.addListener(_onDownloadChange);
    if (widget.initialStoryId != null) {
      _activeStory = IslamicStoriesCatalog.getById(widget.initialStoryId!);
    }
  }

  @override
  void dispose() {
    _downloads.removeListener(_onDownloadChange);
    super.dispose();
  }

  void _onDownloadChange() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleStoryDownload(IslamicStory story) async {
    if (_downloads.isDownloaded(story.id)) {
      await _downloads.removeDownload(story.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إزالة «${story.title}» من المحمّلات بدون نت'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final ok = await _downloads.downloadContent(
        id: story.id,
        offlineBundleJson: story.toOfflineJson(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'تم تحميل قصة «${story.title}» للقراءة بدون نت ✅📥'
                : 'تعذر التحميل حالياً',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _downloadAllStories() async {
    if (_batchDownloading) return;
    setState(() => _batchDownloading = true);
    try {
      for (final s in IslamicStoriesCatalog.allStories) {
        if (!_downloads.isDownloaded(s.id)) {
          await _downloads.downloadContent(
            id: s.id,
            offlineBundleJson: s.toOfflineJson(),
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحميل جميع القصص (٦١ قصة) للعمل بدون إنترنت 📖✅'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _batchDownloading = false);
    }
  }

  static String _normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  List<IslamicStory> get _filteredStories {
    final base = IslamicStoriesCatalog.byCategory(_selectedCategory);
    if (_searchQuery.trim().isEmpty) return base;
    final q = _normalizeArabic(_searchQuery.trim());
    return base
        .where(
          (s) =>
              _normalizeArabic(s.title).contains(q) ||
              _normalizeArabic(s.subtitle).contains(q) ||
              _normalizeArabic(s.primarySource).contains(q) ||
              s.chapters.any(
                (c) =>
                    _normalizeArabic(c.heading).contains(q) ||
                    _normalizeArabic(c.body).contains(q),
              ),
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
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(90),
          isDark: palette.isDark,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          borderRadius: 18,
          borderColor: accent.withOpacity(0.55),
          imageOpacity: 0.45,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${IslamicStoriesCatalog.allStories.length} قصة موثقة بالقرآن والبخاري (الأنبياء الـ٢٥ + الصحابة) ${themeOpt.primaryEmoji}',
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
              IconButton(
                tooltip: 'تحميل كل القصص بدون نت 📥',
                onPressed: _batchDownloading ? null : _downloadAllStories,
                icon: _batchDownloading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      )
                    : Icon(Icons.download_for_offline_rounded, color: accent),
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
                    'الكل (${IslamicStoriesCatalog.allStories.length}) 🌟',
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
              return Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(92 + (idx % 30)),
                isDark: palette.isDark,
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                borderRadius: 20,
                borderWidth: 1.2,
                borderColor: s.accentColor.withOpacity(0.55),
                imageOpacity: palette.isDark ? 0.42 : 0.34,
                onTap: () => setState(() => _activeStory = s),
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
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tooltip: _downloads.isDownloaded(s.id)
                            ? 'محمّلة بدون نت ✓'
                            : 'تحميل القصة بدون نت 📥',
                        onPressed: _downloads.isDownloading(s.id)
                            ? null
                            : () => _toggleStoryDownload(s),
                        icon: _downloads.isDownloading(s.id)
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: s.accentColor,
                                ),
                              )
                            : Icon(
                                _downloads.isDownloaded(s.id)
                                    ? Icons.offline_pin_rounded
                                    : Icons.download_rounded,
                                color: _downloads.isDownloaded(s.id)
                                    ? const Color(0xFF10B981)
                                    : accent,
                                size: 20,
                              ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: accent),
                      const SizedBox(width: 8),
                    ],
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
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(91),
          isDark: palette.isDark,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          borderRadius: 18,
          borderColor: story.accentColor.withOpacity(0.55),
          imageOpacity: 0.45,
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
              IconButton(
                tooltip: _downloads.isDownloaded(story.id)
                    ? 'محمّلة بدون نت ✓ (حذف)'
                    : 'تحميل للعمل بدون نت 📥',
                onPressed: _downloads.isDownloading(story.id)
                    ? null
                    : () => _toggleStoryDownload(story),
                icon: Icon(
                  _downloads.isDownloaded(story.id)
                      ? Icons.offline_pin_rounded
                      : Icons.download_rounded,
                  color: _downloads.isDownloaded(story.id)
                      ? const Color(0xFF10B981)
                      : accent,
                  size: 20,
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
                Firdaws4KCardShell(
                  backdrop: Background500Catalog.forExtraSection(125),
                  isDark: palette.isDark,
                  padding: const EdgeInsets.all(14),
                  borderRadius: 18,
                  borderColor: story.accentColor.withOpacity(0.55),
                  imageOpacity: palette.isDark ? 0.36 : 0.30,
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
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(100 + number),
      isDark: palette.isDark,
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      borderColor: story.accentColor.withOpacity(0.45),
      imageOpacity: palette.isDark ? 0.34 : 0.28,
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
