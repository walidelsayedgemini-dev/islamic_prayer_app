import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/islamic_audio_data.dart';
import '../providers/audio_player_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../screens/about_me_screen.dart';
import '../screens/arena_hub_screen.dart';
import '../screens/events_missions_screen.dart';
import '../screens/family_challenge_screen.dart';
import '../screens/hasanat_store_screen.dart';
import '../screens/islamic_stories_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/millionaire_quiz_screen.dart';
import '../screens/quran_reader_screen.dart';
import '../screens/sahih_hadith_screen.dart';
import '../services/suggestions_service.dart';
import '../theme/islamic_theme.dart';
import 'audio_download_manager_sheet.dart';
import 'firdaws_3d_ui.dart';
import 'firdaws_brand_logo.dart';
import 'firdaws_resilient_image.dart';
import 'firdaws_themed_icon.dart';
import 'unified_theme_hub.dart';
import 'user_profile_editor_sheet.dart';

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
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = firdawsModernAccent(palette);
    final avatarBytes = userProv.avatarBytes;

    return Drawer(
      backgroundColor: palette.scaffoldColor,
      child: SafeArea(
        child: Column(
          children: [
            // 1. رأس القائمة الفاخر مع اسم التطبيق "الفردوس" وصورة المستخدم وبياناته واللقب
            Firdaws4KCardShell(
              backdrop: Background500Catalog.forExtraSection(1),
              isDark: palette.isDark,
              borderColor: accent.withOpacity(0.35),
              borderRadius: 0,
              borderWidth: 1.0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              imageOpacity: 0.40,
              child: Column(
                children: [
                  Row(
                    children: [
                      FirdawsBrandLogo(
                        size: 48,
                        borderColor: accent,
                        borderWidth: 1.8,
                        userAvatarBytes: avatarBytes,
                        fallbackIcon: Icons.menu_book_rounded,
                        onTap: () {
                          Navigator.of(context).pop();
                          UserProfileEditorSheet.show(context);
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProv.profile.hasCustomName
                                  ? '${widget.themeOption.primaryEmoji} أهلاً يا ${userProv.displayName}'
                                  : "${widget.themeOption.primaryEmoji} الفردوس • الواحة المباركة",
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userProv.activeTitleLabel != null
                                  ? '${userProv.activeTitleLabel} ${widget.themeOption.emojiStrip}'
                                  : "المصحف الكامل • القصص • صحيح البخاري ${widget.themeOption.emojiStrip}",
                              style: TextStyle(
                                color: userProv.activeTitleLabel != null
                                    ? accent
                                    : palette.textSecondary,
                                fontSize: 11,
                                fontWeight: userProv.activeTitleLabel != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _drawerShortcutChip(
                          label: '🎨 الثيمات (${IslamicTheme.allThemes.length})',
                          icon: Icons.palette_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            ThemeHubSheet.show(context);
                          },
                        ),
                        _drawerShortcutChip(
                          label: '💎 من سيربح المليون',
                          icon: Icons.quiz_rounded,
                          accent: const Color(0xFF38BDF8),
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(builder: (_) => const MillionaireQuizScreen()),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: '🎮 ٣٠ لعبة',
                          icon: Icons.sports_esports_rounded,
                          accent: const Color(0xFF8B5CF6),
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(builder: (_) => const ArenaHubScreen()),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: '🛍️ متجر السكنات',
                          icon: Icons.storefront_rounded,
                          accent: const Color(0xFFF59E0B),
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(
                                builder: (_) => const HasanatStoreScreen(),
                              ),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: '⚡ المهام والأحداث',
                          icon: Icons.bolt_rounded,
                          accent: const Color(0xFF38BDF8),
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(
                                builder: (_) => const EventsMissionsScreen(),
                              ),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: '🏆 تحدي العائلة',
                          icon: Icons.emoji_events_rounded,
                          accent: const Color(0xFF10B981),
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(builder: (_) => const FamilyChallengeScreen()),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'سجل الصلوات',
                          icon: Icons.fact_check_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            FirdawsNavBridge.jumpTo(1, journeyTab: 0);
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'المهام والطاعات',
                          icon: Icons.task_alt_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            FirdawsNavBridge.jumpTo(1, journeyTab: 1);
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'الـ 200 لقب',
                          icon: Icons.workspace_premium_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            FirdawsNavBridge.jumpTo(1, journeyTab: 2);
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'مذكرتي و500 عبارة',
                          icon: Icons.edit_note_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            FirdawsNavBridge.jumpTo(1, journeyTab: 3);
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'جَنَّتِي الفردوس',
                          icon: Icons.park_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            FirdawsNavBridge.jumpTo(5, jannatiTab: 0);
                          },
                        ),
                        _drawerShortcutChip(
                          label: '٥٠٠٠ سؤال وجواب',
                          icon: Icons.question_answer_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            FirdawsNavBridge.jumpTo(6, openHelpQa: true);
                          },
                        ),
                        _drawerShortcutChip(
                          label: '📖 القصص النبوية',
                          icon: Icons.history_edu_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(builder: (_) => const IslamicStoriesScreen()),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: '📜 صحيح البخاري',
                          icon: Icons.verified_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(builder: (_) => const SahihHadithScreen()),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: '⬇️ مركز التحميل',
                          icon: Icons.download_for_offline_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            showAudioDownloadManagerSheet(context);
                          },
                        ),
                        _drawerShortcutChip(
                          label: '🤲 عنّي والدعاء',
                          icon: Icons.favorite_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            nav.push(
                              MaterialPageRoute(builder: (_) => const AboutMeScreen()),
                            );
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'صندوق الاقتراحات 💌',
                          icon: Icons.mark_email_unread_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            final nav = Navigator.of(context);
                            final parentCtx = nav.context;
                            nav.pop();
                            SuggestionsService.showComposerSheet(
                                parentCtx, palette);
                          },
                        ),
                        _drawerShortcutChip(
                          label: 'بياناتي',
                          icon: Icons.person_rounded,
                          accent: accent,
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).pop();
                            UserProfileEditorSheet.show(context);
                          },
                        ),
                      ],
                    ),
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
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  nav.push(MaterialPageRoute(builder: (_) => const QuranReaderScreen()));
                },
                child: Firdaws4KCardShell(
                  backdrop: Background500Catalog.forExtraSection(1),
                  isDark: palette.isDark,
                  borderColor: accent,
                  borderRadius: 16,
                  borderWidth: 1.4,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  imageOpacity: 0.42,
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
                              "📖 قراءة المصحف الشريف كاملاً (١١٤ سورة)",
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "مراجعة Quran.com • تفسير • علامة القراءة",
                              style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 15),
                    ],
                  ),
                ),
              ),
              if (player.supportsOfflineDownload)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    showAudioDownloadManagerSheet(context);
                  },
                  child: Firdaws4KCardShell(
                    backdrop: Background500Catalog.forExtraSection(3),
                    isDark: palette.isDark,
                    borderColor: offlineBadgeColor.withOpacity(0.55),
                    borderRadius: 14,
                    borderWidth: 1.1,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    imageOpacity: 0.34,
                    child: Row(
                      children: [
                        Icon(Icons.download_for_offline_rounded, color: offlineBadgeColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "⬇️ مدير التحميل بدون إنترنت (حمّل ما تريد فقط)",
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_left_rounded, color: offlineBadgeColor, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
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

        return Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(surah.number),
          isDark: palette.isDark,
          borderColor: isCurrent ? accent : palette.dividerColor,
          borderRadius: 14,
          borderWidth: isCurrent ? 1.4 : 0.8,
          margin: const EdgeInsets.only(bottom: 6),
          padding: EdgeInsets.zero,
          imageOpacity: isCurrent ? 0.38 : 0.25,
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

        return Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(10 + idx),
          isDark: palette.isDark,
          borderColor: isCurrent ? accent : palette.dividerColor,
          borderRadius: 16,
          borderWidth: isCurrent ? 1.5 : 1.0,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          imageOpacity: isCurrent ? 0.40 : 0.28,
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
                    color: palette.isDark ? const Color(0xFFE2E8F0) : palette.primaryColor,
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

        return Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(25 + idx),
          isDark: palette.isDark,
          borderColor: isCurrent ? accent : palette.dividerColor,
          borderRadius: 14,
          borderWidth: isCurrent ? 1.4 : 0.8,
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          imageOpacity: isCurrent ? 0.38 : 0.26,
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
          icon: Icons.palette_rounded,
          title: "🎨 بوابة الثيمات الموحدة (٥٢ ثيماً + ٢٠ خطاً)",
          subtitle: "تحكم كامل في كل الألوان والوضع الليلي العصري والخطوط من مكان واحد",
          palette: palette,
          onTap: () {
            Navigator.of(context).pop();
            ThemeHubSheet.show(context);
          },
        ),
        _buildShortcutTile(
          icon: Icons.quiz_rounded,
          title: "💎 مسابقة من سيربح المليون (١٠٠٠ سؤال)",
          subtitle: "١٥ مرحلة وسلّم المليون و٤ وسائل مساعدة ومنافسون افتراضيون ومشاركة ٢ لاعبين",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const MillionaireQuizScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.sports_esports_rounded,
          title: "🎮 صالة الـ ٣٠ لعبة التنافسية",
          subtitle: "٩٠ عالماً • ٩٠ بطلاً • ٣٠ زعيماً شريراً • ٤ مستويات صعوبة • مشاركة ٢ لاعبين",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const ArenaHubScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.emoji_events_rounded,
          title: "🏆 تحدي العائلة والصحبة (مين سبّح / مين بطل أكتر)",
          subtitle: "سباق التسبيح الجماعي + لوحة الأبطال + ٨٠٠ عبارة تحفيز عند الفوز والخسارة",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const FamilyChallengeScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.auto_stories_rounded,
          title: "📖 المصحف الشريف الكامل (١١٤ سورة)",
          subtitle: "مراجعة Quran.com • التفسير الميسر • القفز المباشر لأي آية",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const QuranReaderScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.history_edu_rounded,
          title: "🌙 القصص النبوية وسير الصحابة والصالحين",
          subtitle: "٥٢ قصة موثقة بالصور والمشاهد الحية المتدرجة وربط الآيات والأحاديث",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const IslamicStoriesScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.verified_rounded,
          title: "📜 صحيح البخاري ومسلم وشروحهما",
          subtitle: "١٢٠ حديثاً موثقاً بالباب والشرح وارتباطات الآيات",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const SahihHadithScreen()));
          },
        ),
        _buildShortcutTile(
          icon: Icons.download_for_offline_rounded,
          title: "⬇️ مركز التحميل بدون إنترنت",
          subtitle: "حمّل السور والرقية والأدعية حسب رغبتك وبحجم تطبيق خفيف",
          palette: palette,
          onTap: () {
            Navigator.of(context).pop();
            showAudioDownloadManagerSheet(context);
          },
        ),
        _buildShortcutTile(
          icon: Icons.favorite_rounded,
          title: "🤲 عنّي وبياناتي والدعاء",
          subtitle: "إن وجدت التطبيق مفيداً فلا تنسَنا من صالح دعائك",
          palette: palette,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => const AboutMeScreen()));
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
    final accent = firdawsModernAccent(palette);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Firdaws3DCard(
        palette: palette,
        glowColor: accent,
        padding: EdgeInsets.zero,
        borderRadius: 16,
        depth: 4.0,
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
            style: TextStyle(
              color: firdawsCrispSecondaryText(palette),
              fontSize: 11,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 14),
        ),
      ),
    );
  }

  Widget _drawerShortcutChip({
    required String label,
    required IconData icon,
    required Color accent,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FirdawsThemedIcon(
                icon: icon,
                themeOption: widget.themeOption,
                palette: palette,
                size: 13.5,
                color: accent,
                showEnvironmentAura: false,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
