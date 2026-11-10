import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_audio_data.dart';
import '../providers/audio_player_provider.dart';
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withOpacity(0.65)),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الفردوس • المكتبة الصوتية",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "قرآن كريم • رقية شرعية • إبتهالات وتفاسير",
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
    final surahs = IslamicAudioLibrary.allSurahs.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.nameArabic.contains(_searchQuery) ||
          s.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.number.toString() == _searchQuery;
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: surahs.length,
      itemBuilder: (context, idx) {
        final surah = surahs[idx];
        final isCurrent = player.currentAudioId == "surah_${surah.number}";
        final isPlayingThis = isCurrent && player.isPlaying;

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
            leading: Container(
              width: 36,
              height: 36,
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
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              "سورة ${surah.nameArabic}",
              style: TextStyle(
                color: isCurrent ? accent : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              "${surah.isMakki ? 'مكية' : 'مدنية'} • ${surah.versesCount} آيات • ${surah.defaultDuration}",
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 11,
              ),
            ),
            trailing: GestureDetector(
              onTap: () {
                if (isCurrent) {
                  player.togglePlay();
                } else {
                  player.playSurah(surah);
                }
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPlayingThis ? accent : accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.8)),
                ),
                child: Icon(
                  isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isPlayingThis ? palette.onAccentColor : accent,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuqyahList(AudioPlayerProvider player, ThemePalette palette) {
    final accent = palette.accentColor;
    const ruqyahItems = IslamicAudioLibrary.allRuqyah;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: ruqyahItems.length,
      itemBuilder: (context, idx) {
        final item = ruqyahItems[idx];
        final isCurrent = player.currentAudioId == item.id;
        final isPlayingThis = isCurrent && player.isPlaying;

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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${item.reciter} • ${item.duration}",
                          style: TextStyle(color: palette.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPlayingThis ? accent : accent.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent),
                      ),
                      child: Icon(
                        isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: isPlayingThis ? palette.onAccentColor : accent,
                        size: 22,
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
    const ibtihalat = IslamicAudioLibrary.allIbtihalat;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: ibtihalat.length,
      itemBuilder: (context, idx) {
        final item = ibtihalat[idx];
        final isCurrent = player.currentAudioId == item.id;
        final isPlayingThis = isCurrent && player.isPlaying;

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
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "${item.reciter} • ${item.maqam} • ${item.duration}",
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
            trailing: GestureDetector(
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
                child: Icon(
                  isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isPlayingThis ? palette.onAccentColor : accent,
                  size: 20,
                ),
              ),
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
