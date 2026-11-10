import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_audio_data.dart';
import '../providers/audio_player_provider.dart';
import '../screens/quran_reader_screen.dart';
import '../theme/islamic_theme.dart';

class IslamicSideDrawer extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;
  final VoidCallback? onOpenQuranAzkarSheet;
  final VoidCallback? onOpenGreetingCards;
  final VoidCallback? onOpenBooks;

  const IslamicSideDrawer({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
    this.onOpenQuranAzkarSheet,
    this.onOpenGreetingCards,
    this.onOpenBooks,
  });

  @override
  State<IslamicSideDrawer> createState() => _IslamicSideDrawerState();
}

class _IslamicSideDrawerState extends State<IslamicSideDrawer> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    "القرآن الكريم",
    "الرقية الشرعية",
    "إبتهالات وأدعية",
    "حصن المسلم",
    "كتب وتفاسير",
    "كروت تهنئة",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<AudioPlayerProvider>(context);
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;

    return Drawer(
      backgroundColor: palette.scaffoldColor,
      child: SafeArea(
        child: Column(
          children: [
            // 1. رأس القائمة الفاخر مع اسم التطبيق "الفردوس"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: palette.cardColor.withOpacity(0.95),
                border: Border(bottom: BorderSide(color: accent.withOpacity(0.35))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 1.6),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.32),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/palace_jannah_logo.png',
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: accent.withOpacity(0.18),
                          child: Icon(Icons.menu_book_rounded, color: accent, size: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الفردوس • المكتبة الشاملة",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "المصحف الكامل • رقية شرعية • إبتهالات",
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: palette.elevatedCardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.dividerColor),
                      ),
                      child: Icon(Icons.close_rounded, color: palette.textSecondary, size: 18),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 2. تصنيفات القائمة العلوية
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: List.generate(_categories.length, (idx) {
                    final isSel = _selectedCategoryIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategoryIndex = idx);
                          if (idx == 3 && widget.onOpenQuranAzkarSheet != null) {
                            Navigator.of(context).pop();
                            widget.onOpenQuranAzkarSheet!();
                          } else if (idx == 4 && widget.onOpenBooks != null) {
                            Navigator.of(context).pop();
                            widget.onOpenBooks!();
                          } else if (idx == 5 && widget.onOpenGreetingCards != null) {
                            Navigator.of(context).pop();
                            widget.onOpenGreetingCards!();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? accent : palette.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel ? accent : palette.dividerColor,
                              width: isSel ? 1.5 : 1.0,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: accent.withOpacity(0.35),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            _categories[idx],
                            style: TextStyle(
                              color: isSel ? palette.onAccentColor : palette.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // 3. شريط اختيار القارئ
            if (_selectedCategoryIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: accent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "القارئ:",
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: palette.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withOpacity(0.4)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ReciterInfo>(
                            value: player.selectedReciter,
                            isExpanded: true,
                            dropdownColor: palette.cardColor,
                            icon: Icon(Icons.arrow_drop_down, color: accent),
                            items: IslamicAudioLibrary.reciters.map((reciter) {
                              return DropdownMenuItem(
                                value: reciter,
                                child: Text(
                                  reciter.name,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (newReciter) {
                              if (newReciter != null) player.selectReciter(newReciter);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // حقل البحث في السور
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: "ابحث عن اسم السورة أو رقمها...",
                    hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded, color: accent, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: palette.textMuted, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: palette.cardColor.withOpacity(0.75),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: palette.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: palette.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accent),
                    ),
                  ),
                ),
              ),
            ],

            if (player.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.45)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        player.errorMessage!,
                        style: TextStyle(color: palette.textPrimary, fontSize: 11),
                      ),
                    ),
                    GestureDetector(
                      onTap: player.clearError,
                      child: Icon(Icons.close_rounded, color: palette.textSecondary, size: 16),
                    ),
                  ],
                ),
              ),

            // 4. المحتوى المتغير حسب التصنيف المختار
            Expanded(
              child: _buildCategoryContent(player, palette),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent(AudioPlayerProvider player, ThemePalette palette) {
    if (_selectedCategoryIndex == 0) {
      return _buildQuranSurahsList(player, palette);
    } else if (_selectedCategoryIndex == 1) {
      return _buildRuqyahList(player, palette);
    } else if (_selectedCategoryIndex == 2) {
      return _buildIbtihalatList(player, palette);
    } else {
      return _buildQuickShortcutsList(palette);
    }
  }

  Widget _buildQuranSurahsList(AudioPlayerProvider player, ThemePalette palette) {
    final accent = palette.accentColor;
    final offlineBadgeColor = palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
    final surahs = IslamicAudioLibrary.allSurahs.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.nameArabic.contains(_searchQuery) ||
          s.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.number.toString() == _searchQuery;
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: surahs.length + 1,
      itemBuilder: (context, rawIdx) {
        if (rawIdx == 0) {
          return GestureDetector(
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(MaterialPageRoute(builder: (_) => const QuranReaderScreen()));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(palette.isDark ? 0.28 : 0.18),
                    palette.cardColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent, width: 1.4),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_stories_rounded, color: palette.onAccentColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "قراءة المصحف الشريف كاملاً (١١٤ سورة)",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "بحث في الآيات • علامة القراءة • تلاوة القراء",
                          style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 15),
                ],
              ),
            ),
          );
        }

        final surah = surahs[rawIdx - 1];
        final isCurrent = player.currentAudioId == "surah_${surah.number}";
        final isPlayingThis = isCurrent && player.isPlaying;
        final isLoadingThis = isCurrent && player.isLoading;
        final cacheKey = IslamicAudioLibrary.surahCacheKey(
          player.selectedReciter.id,
          surah.number,
        );
        final streamUrl = IslamicAudioLibrary.getSurahUrl(
          player.selectedReciter.id,
          surah.number,
        );
        final isOfflineReady = player.isSurahOfflineReady(surah.number);
        final downloadProg = player.downloadProgressFor(cacheKey);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: isCurrent
                ? accent.withOpacity(palette.isDark ? 0.18 : 0.14)
                : palette.cardColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? accent : palette.dividerColor,
              width: isCurrent ? 1.4 : 0.8,
            ),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isCurrent ? accent : palette.dividerColor),
                color: isCurrent ? accent.withOpacity(0.2) : palette.elevatedCardColor,
              ),
              child: Center(
                child: Text(
                  "${surah.number}",
                  style: TextStyle(
                    color: isCurrent ? accent : palette.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
            title: Text(
              "سورة ${surah.nameArabic}",
              style: TextStyle(
                color: isCurrent ? accent : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            subtitle: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 2,
              children: [
                Text(
                  "${surah.isMakki ? 'مكية' : 'مدنية'} • ${surah.versesCount} آية • ${surah.defaultDuration}",
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
                if (isOfflineReady)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: offlineBadgeColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: offlineBadgeColor.withOpacity(0.5), width: 0.7),
                    ),
                    child: Text(
                      "بدون نت ✓",
                      style: TextStyle(
                        color: offlineBadgeColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(5),
                  icon: Icon(Icons.auto_stories_rounded, color: accent.withOpacity(0.9), size: 19),
                  tooltip: "قراءة السورة",
                  onPressed: () {
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => QuranReaderScreen(initialSurahNumber: surah.number),
                      ),
                    );
                  },
                ),
                if (player.supportsOfflineDownload && !isOfflineReady)
                  downloadProg != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              value: downloadProg,
                              strokeWidth: 2.2,
                              color: accent,
                            ),
                          ),
                        )
                      : IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(5),
                          icon: Icon(
                            Icons.download_for_offline_rounded,
                            color: palette.textSecondary,
                            size: 19,
                          ),
                          tooltip: "حفظ للاستماع بدون نت",
                          onPressed: () => player.downloadTrackForOffline(cacheKey, streamUrl),
                        ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () {
                    if (isCurrent) {
                      player.togglePlay();
                    } else {
                      player.playSurah(surah);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPlayingThis ? accent : accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withOpacity(0.8)),
                    ),
                    child: Center(
                      child: isLoadingThis
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                          : Icon(
                              isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: isPlayingThis ? palette.onAccentColor : accent,
                              size: 21,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuqyahList(AudioPlayerProvider player, ThemePalette palette) {
    final accent = palette.accentColor;
    final offlineBadgeColor = palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
    const ruqyahItems = IslamicAudioLibrary.allRuqyah;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: ruqyahItems.length,
      itemBuilder: (context, idx) {
        final item = ruqyahItems[idx];
        final isCurrent = player.currentAudioId == item.id;
        final isPlayingThis = isCurrent && player.isPlaying;
        final isLoadingThis = isCurrent && player.isLoading;
        final isOfflineReady = player.isItemOfflineReady(item.id, item.localAsset);
        final downloadProg = player.downloadProgressFor(item.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent
                ? accent.withOpacity(palette.isDark ? 0.18 : 0.14)
                : palette.cardColor.withOpacity(0.90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? accent : palette.dividerColor,
              width: isCurrent ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent),
                    ),
                    child: Icon(Icons.healing_rounded, color: accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: isCurrent ? accent : palette.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "${item.reciter} • ${item.duration}",
                              style: TextStyle(color: palette.textSecondary, fontSize: 11),
                            ),
                            if (isOfflineReady)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: offlineBadgeColor.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: offlineBadgeColor.withOpacity(0.5),
                                    width: 0.7,
                                  ),
                                ),
                                child: Text(
                                  "بدون نت ✓",
                                  style: TextStyle(
                                    color: offlineBadgeColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (player.supportsOfflineDownload && !isOfflineReady)
                    downloadProg != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                value: downloadProg,
                                strokeWidth: 2.2,
                                color: accent,
                              ),
                            ),
                          )
                        : IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: Icon(
                              Icons.download_for_offline_rounded,
                              color: palette.textSecondary,
                              size: 20,
                            ),
                            tooltip: "تحميل للاستماع بدون نت",
                            onPressed: () =>
                                player.downloadTrackForOffline(item.id, item.streamUrl),
                          ),
                  GestureDetector(
                    onTap: () {
                      if (isCurrent) {
                        player.togglePlay();
                      } else {
                        player.playRuqyah(item);
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isPlayingThis ? accent : accent.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent),
                      ),
                      child: Center(
                        child: isLoadingThis
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accent,
                                ),
                              )
                            : Icon(
                                isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: isPlayingThis ? palette.onAccentColor : accent,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.purpose,
                  style: TextStyle(
                    color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIbtihalatList(AudioPlayerProvider player, ThemePalette palette) {
    final accent = palette.accentColor;
    final offlineBadgeColor = palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
    const ibtihalat = IslamicAudioLibrary.allIbtihalat;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: ibtihalat.length,
      itemBuilder: (context, idx) {
        final item = ibtihalat[idx];
        final isCurrent = player.currentAudioId == item.id;
        final isPlayingThis = isCurrent && player.isPlaying;
        final isLoadingThis = isCurrent && player.isLoading;
        final isOfflineReady = player.isItemOfflineReady(item.id, item.localAsset);
        final downloadProg = player.downloadProgressFor(item.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? accent.withOpacity(palette.isDark ? 0.18 : 0.14)
                : palette.cardColor.withOpacity(0.88),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? accent : palette.dividerColor,
              width: isCurrent ? 1.4 : 0.8,
            ),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.music_note_rounded, color: isCurrent ? accent : palette.textSecondary),
            title: Text(
              item.title,
              style: TextStyle(
                color: isCurrent ? accent : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            subtitle: Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "${item.reciter} • ${item.maqam} • ${item.duration}",
                  style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                ),
                if (isOfflineReady)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: offlineBadgeColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: offlineBadgeColor.withOpacity(0.5), width: 0.7),
                    ),
                    child: Text(
                      "بدون نت ✓",
                      style: TextStyle(
                        color: offlineBadgeColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (player.supportsOfflineDownload && !isOfflineReady)
                  downloadProg != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              value: downloadProg,
                              strokeWidth: 2.2,
                              color: accent,
                            ),
                          ),
                        )
                      : IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(5),
                          icon: Icon(
                            Icons.download_for_offline_rounded,
                            color: palette.textSecondary,
                            size: 19,
                          ),
                          tooltip: "تحميل للاستماع بدون نت",
                          onPressed: () =>
                              player.downloadTrackForOffline(item.id, item.streamUrl),
                        ),
                GestureDetector(
                  onTap: () {
                    if (isCurrent) {
                      player.togglePlay();
                    } else {
                      player.playIbtihal(item);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPlayingThis ? accent : accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent),
                    ),
                    child: Center(
                      child: isLoadingThis
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                          : Icon(
                              isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: isPlayingThis ? palette.onAccentColor : accent,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickShortcutsList(ThemePalette palette) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShortcutTile(
          icon: Icons.auto_stories_rounded,
          title: "المصحف الشريف الكامل (١١٤ سورة)",
          subtitle: "تلاوة وقراءة بالبحث وتحديد الآيات",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const QuranReaderScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.wb_sunny_rounded,
          title: "أذكار الصباح والمساء المصورة",
          subtitle: "الحصن الحصين لكل مسلم صباحاً ومساءً",
          palette: palette,
          onTap: () {
            Navigator.of(context).pop();
            widget.onOpenQuranAzkarSheet?.call();
          },
        ),
        _buildShortcutTile(
          icon: Icons.menu_book_rounded,
          title: "الأربعين النووية ورياض الصالحين",
          subtitle: "شروح الأحاديث النبوية الشريفة وأبواب الخير",
          palette: palette,
          onTap: () {
            Navigator.of(context).pop();
            widget.onOpenBooks?.call();
          },
        ),
        _buildShortcutTile(
          icon: Icons.mark_email_read_rounded,
          title: "كروت تهنئة إسلامية جاهزة",
          subtitle: "بطاقات الجمعة المباركة والأعياد لمشاركتها",
          palette: palette,
          onTap: () {
            Navigator.of(context).pop();
            widget.onOpenGreetingCards?.call();
          },
        ),
      ],
    );
  }

  Widget _buildShortcutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final accent = palette.accentColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: accent),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: palette.textSecondary, fontSize: 11),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 14),
      ),
    );
  }
}
