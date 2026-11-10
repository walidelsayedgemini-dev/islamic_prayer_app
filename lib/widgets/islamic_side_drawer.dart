import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_audio_data.dart';
import '../providers/audio_player_provider.dart';
import '../theme/islamic_theme.dart';

class IslamicSideDrawer extends StatefulWidget {
  final ThemeOption themeOption;
  final VoidCallback? onOpenQuranAzkarSheet;
  final VoidCallback? onOpenGreetingCards;
  final VoidCallback? onOpenBooks;

  const IslamicSideDrawer({
    super.key,
    required this.themeOption,
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
    final accent = widget.themeOption.accentColor;
    final scaffoldBg = widget.themeOption.scaffoldColor;
    final cardBg = widget.themeOption.cardColor;

    return Drawer(
      backgroundColor: scaffoldBg,
      child: SafeArea(
        child: Column(
          children: [
            // 1. رأس القائمة الفاخر: عنوان القائمة، الزخرفة، وزر الإغلاق X (مطابق للصورة 2 و 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardBg.withOpacity(0.92),
                border: Border(bottom: BorderSide(color: accent.withOpacity(0.35))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withOpacity(0.6)),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "المكتبة الصوتية الشاملة",
                          style: TextStyle(
                            fontFamily: 'Aref Ruqaa',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "قرآن كريم • رقية شرعية • إبتهالات وتفاسير",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
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
                        color: Colors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 2. تصنيفات القائمة العلوية بشكل أزرار دائرية/بيضاوية (مطابق لأعلى الصورتين 2 و 3)
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
                            color: isSel ? accent : cardBg.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel ? accent : Colors.white24,
                              width: isSel ? 1.5 : 1.0,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: accent.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            _categories[idx],
                            style: TextStyle(
                              fontFamily: 'Aref Ruqaa',
                              color: isSel ? Colors.black87 : Colors.white,
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

            // 3. شريط اختيار القارئ (عند اختيار القرآن الكريم)
            if (_selectedCategoryIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: accent, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      "القارئ:",
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withOpacity(0.4)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ReciterInfo>(
                            value: player.selectedReciter,
                            isExpanded: true,
                            dropdownColor: cardBg,
                            icon: Icon(Icons.arrow_drop_down, color: accent),
                            items: IslamicAudioLibrary.reciters.map((reciter) {
                              return DropdownMenuItem(
                                value: reciter,
                                child: Text(
                                  reciter.name,
                                  style: const TextStyle(
                                    fontFamily: 'Aref Ruqaa',
                                    color: Colors.white,
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
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: "ابحث عن اسم السورة أو رقمها...",
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded, color: accent, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: cardBg.withOpacity(0.6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
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
              child: _buildCategoryContent(player, accent, cardBg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent(AudioPlayerProvider player, Color accent, Color cardBg) {
    if (_selectedCategoryIndex == 0) {
      return _buildQuranSurahsList(player, accent, cardBg);
    } else if (_selectedCategoryIndex == 1) {
      return _buildRuqyahList(player, accent, cardBg);
    } else if (_selectedCategoryIndex == 2) {
      return _buildIbtihalatList(player, accent, cardBg);
    } else {
      return _buildQuickShortcutsList(accent, cardBg);
    }
  }

  // قائمة سور القرآن الكريم (114 سورة)
  Widget _buildQuranSurahsList(AudioPlayerProvider player, Color accent, Color cardBg) {
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
            color: isCurrent ? accent.withOpacity(0.18) : cardBg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? accent : Colors.white10,
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
                border: Border.all(color: isCurrent ? accent : Colors.white24),
                color: isCurrent ? accent.withOpacity(0.2) : Colors.black26,
              ),
              child: Center(
                child: Text(
                  "${surah.number}",
                  style: TextStyle(
                    fontFamily: 'Aref Ruqaa',
                    color: isCurrent ? accent : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              "سورة ${surah.nameArabic}",
              style: TextStyle(
                fontFamily: 'Aref Ruqaa',
                color: isCurrent ? accent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              "${surah.isMakki ? 'مكية' : 'مدنية'} • ${surah.versesCount} آيات • ${surah.defaultDuration}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
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
                  color: isPlayingThis ? Colors.black87 : accent,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // قائمة الرقية الشرعية المعتمدة
  Widget _buildRuqyahList(AudioPlayerProvider player, Color accent, Color cardBg) {
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
            color: isCurrent ? accent.withOpacity(0.18) : cardBg.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? accent : Colors.white12,
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
                            fontFamily: 'Aref Ruqaa',
                            color: isCurrent ? accent : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${item.reciter} • ${item.duration}",
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
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
                        color: isPlayingThis ? accent : accent.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent),
                      ),
                      child: Icon(
                        isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: isPlayingThis ? Colors.black87 : accent,
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
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.purpose,
                  style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // قائمة الإبتهالات والأدعية النبوية
  Widget _buildIbtihalatList(AudioPlayerProvider player, Color accent, Color cardBg) {
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
            color: isCurrent ? accent.withOpacity(0.18) : cardBg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? accent : Colors.white10,
              width: isCurrent ? 1.4 : 0.8,
            ),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.music_note_rounded, color: isCurrent ? accent : Colors.white70),
            title: Text(
              item.title,
              style: TextStyle(
                fontFamily: 'Aref Ruqaa',
                color: isCurrent ? accent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "${item.reciter} • ${item.maqam} • ${item.duration}",
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11),
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
                  color: isPlayingThis ? Colors.black87 : accent,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // اختصارات إسلامية سريعة
  Widget _buildQuickShortcutsList(Color accent, Color cardBg) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShortcutTile(
          icon: Icons.wb_sunny_rounded,
          title: "أذكار الصباح والمساء المصورة",
          subtitle: "الحصن الحصين لكل مسلم صباحاً ومساءً",
          accent: accent,
          cardBg: cardBg,
          onTap: () {
            Navigator.of(context).pop();
            if (widget.onOpenQuranAzkarSheet != null) widget.onOpenQuranAzkarSheet!();
          },
        ),
        _buildShortcutTile(
          icon: Icons.menu_book_rounded,
          title: "الأربعين النووية ورياض الصالحين",
          subtitle: "شروح الأحاديث النبوية الشريفة وأبواب الخير",
          accent: accent,
          cardBg: cardBg,
          onTap: () {
            Navigator.of(context).pop();
            if (widget.onOpenBooks != null) widget.onOpenBooks!();
          },
        ),
        _buildShortcutTile(
          icon: Icons.mark_email_read_rounded,
          title: "كروت تهنئة إسلامية جاهزة",
          subtitle: "بطاقات الجمعة المباركة والأعياد لمشاركتها",
          accent: accent,
          cardBg: cardBg,
          onTap: () {
            Navigator.of(context).pop();
            if (widget.onOpenGreetingCards != null) widget.onOpenGreetingCards!();
          },
        ),
      ],
    );
  }

  Widget _buildShortcutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.75),
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
          style: const TextStyle(
            fontFamily: 'Aref Ruqaa',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 14),
      ),
    );
  }
}
