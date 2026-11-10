import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/islamic_audio_data.dart';
import '../models/quran_model.dart';
import '../providers/audio_player_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/persistent_audio_player_bar.dart';
import '../widgets/real_mosque_background.dart';

class QuranReaderScreen extends StatefulWidget {
  final int? initialSurahNumber;
  final int? initialHighlightAyah;
  final bool openTafsirOnStart;

  const QuranReaderScreen({
    super.key,
    this.initialSurahNumber,
    this.initialHighlightAyah,
    this.openTafsirOnStart = false,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  List<QuranSurah>? _surahs;
  String? _loadError;

  QuranSurah? _activeSurah;
  int? _highlightedAyahNumber;
  String _searchQuery = '';
  String _filterType = 'all'; // all, makki, madani, short
  bool _mushafContinuousMode = true;
  bool _useTraditionalMushafFont = true;
  double _fontSize = 23.0;

  int? _lastReadSurah;
  int? _lastReadAyah;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _readerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadQuranData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _readerScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _fontSize = (prefs.getDouble('quran_font_size') ?? 23.0).clamp(16.0, 36.0);
        _mushafContinuousMode = prefs.getBool('quran_mushaf_mode') ?? true;
        _useTraditionalMushafFont = prefs.getBool('quran_use_amiri_font') ?? true;
        _lastReadSurah = prefs.getInt('quran_last_surah');
        _lastReadAyah = prefs.getInt('quran_last_ayah');
      });
    } catch (_) {}
  }

  Future<void> _saveReadingBookmark(int surahNumber, int ayahNumber) async {
    setState(() {
      _lastReadSurah = surahNumber;
      _lastReadAyah = ayahNumber;
      _highlightedAyahNumber = ayahNumber;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quran_last_surah', surahNumber);
      await prefs.setInt('quran_last_ayah', ayahNumber);
    } catch (_) {}
  }

  Future<void> _saveSettingsPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('quran_font_size', _fontSize);
      await prefs.setBool('quran_mushaf_mode', _mushafContinuousMode);
      await prefs.setBool('quran_use_amiri_font', _useTraditionalMushafFont);
    } catch (_) {}
  }

  Future<void> _loadQuranData() async {
    try {
      final surahs = await QuranRepository.loadCompleteQuran();
      if (!mounted) return;
      QuranSurah? initial;
      if (widget.initialSurahNumber != null) {
        final idx = (widget.initialSurahNumber! - 1).clamp(0, surahs.length - 1);
        initial = surahs[idx];
      }
      setState(() {
        _surahs = surahs;
        _activeSurah = initial;
        _highlightedAyahNumber = widget.initialHighlightAyah;
      });
      if (initial != null && widget.initialHighlightAyah != null) {
        final startSurah = initial;
        final targetAyah = widget.initialHighlightAyah!.clamp(1, startSurah.ayahs.length);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _scrollToAyah(startSurah, targetAyah);
          if (widget.openTafsirOnStart && mounted) {
            final ayahObj = startSurah.ayahs[targetAyah - 1];
            _showAyahTafsirModal(startSurah, ayahObj);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'تعذر تحميل بيانات المصحف الشريف: $e';
      });
    }
  }

  List<List<QuranAyah>> _groupPagesForSurah(QuranSurah surah) {
    final pages = <List<QuranAyah>>[];
    for (final ayah in surah.ayahs) {
      if (pages.isEmpty || pages.last.first.page != ayah.page) {
        pages.add([ayah]);
      } else {
        pages.last.add(ayah);
      }
    }
    return pages;
  }

  Future<void> _scrollToAyah(QuranSurah surah, int targetAyah) async {
    if (!mounted) return;
    final clamped = targetAyah.clamp(1, surah.ayahs.length);
    final ayahObj = surah.ayahs[clamped - 1];
    final targetKey = _mushafContinuousMode
        ? GlobalObjectKey('page_${surah.number}_${ayahObj.page}')
        : GlobalObjectKey('ayah_${surah.number}_$clamped');

    if (targetKey.currentContext != null) {
      await Scrollable.ensureVisible(
        targetKey.currentContext!,
        alignment: 0.14,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    if (!_readerScrollController.hasClients) return;
    final pages = _groupPagesForSurah(surah);
    int targetItemIndex = clamped;
    if (_mushafContinuousMode) {
      final pIdx = pages.indexWhere((pg) => pg.any((a) => a.number == clamped));
      targetItemIndex = (pIdx < 0 ? 0 : pIdx) + 1;
    }
    final approxExtent = _mushafContinuousMode ? 310.0 : 180.0;
    final maxExtent = _readerScrollController.position.maxScrollExtent;
    final estOffset = (targetItemIndex * approxExtent).clamp(0.0, maxExtent);
    _readerScrollController.jumpTo(estOffset);

    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    if (targetKey.currentContext != null) {
      await Scrollable.ensureVisible(
        targetKey.currentContext!,
        alignment: 0.14,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openSurah(QuranSurah surah, {int? highlightAyah}) {
    setState(() {
      _activeSurah = surah;
      _highlightedAyahNumber = highlightAyah;
    });
    _saveReadingBookmark(surah.number, highlightAyah ?? 1);
    try {
      Provider.of<FirdawsUserProvider>(context, listen: false)
          .recordSurahRead(surah.number);
    } catch (_) {}
    if (highlightAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(surah, highlightAyah);
      });
    } else if (_readerScrollController.hasClients) {
      _readerScrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final player = Provider.of<AudioPlayerProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accent = palette.accentColor;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: Prayer.isha,
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          ),
          Positioned.fill(
            child: IslamicThemeEffectsCanvas(
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(palette, settings, player),
                Expanded(
                  child: _buildBodyContent(palette, settings, player, accent),
                ),
                PersistentAudioPlayerBar(
                  themeOption: themeOption,
                  isNightMode: isNight,
                  onOpenDrawer: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    ThemePalette palette,
    SettingsProvider settings,
    AudioPlayerProvider player,
  ) {
    final accent = palette.accentColor;
    final inSurahView = _activeSurah != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
            icon: Icon(
              inSurahView ? Icons.menu_book_rounded : Icons.arrow_back_rounded,
              color: accent,
              size: 22,
            ),
            tooltip: inSurahView ? "فهرس السور الـ 114" : "رجوع",
            onPressed: () {
              if (inSurahView) {
                setState(() => _activeSurah = null);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 6),
          ClipOval(
            child: Image.asset(
              'assets/images/palace_jannah_logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.menu_book_rounded, color: accent, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inSurahView
                      ? "سورة ${_activeSurah!.cleanName}"
                      : "المصحف الشريف كامل (١١٤ سورة)",
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  inSurahView
                      ? "${_activeSurah!.isMakki ? 'مكية' : 'مدنية'} • ${_activeSurah!.versesCount} آية • الجزء ${toArabicIndicDigits(_activeSurah!.startingJuz)}"
                      : "الفردوس • ٦٢٣٦ آية بالرسم العثماني الواضح",
                  style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (inSurahView) ...[
            IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              icon: Icon(
                _mushafContinuousMode
                    ? Icons.view_agenda_outlined
                    : Icons.auto_stories_rounded,
                color: accent,
                size: 20,
              ),
              tooltip: _mushafContinuousMode ? "عرض آية بآية" : "عرض صفحات المصحف",
              onPressed: () {
                setState(() => _mushafContinuousMode = !_mushafContinuousMode);
                _saveSettingsPrefs();
              },
            ),
            IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              icon: Icon(
                (player.currentSurahNumber == _activeSurah!.number && player.isPlaying)
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: accent,
                size: 26,
              ),
              tooltip: "استماع لتلاوة السورة",
              onPressed: () {
                if (player.currentSurahNumber == _activeSurah!.number) {
                  player.togglePlay();
                } else {
                  player.playSurahByNumber(_activeSurah!.number);
                }
              },
            ),
          ] else ...[
            IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              icon: Icon(Icons.cloud_download_rounded, color: accent, size: 22),
              tooltip: "إدارة التحميل بدون إنترنت ⬇️",
              onPressed: () => showAudioDownloadManagerSheet(context),
            ),
            IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              icon: Icon(Icons.close_rounded, color: palette.textSecondary, size: 22),
              tooltip: "إغلاق المصحف",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    ThemePalette palette,
    SettingsProvider settings,
    AudioPlayerProvider player,
    Color accent,
  ) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _loadError!,
            style: TextStyle(color: palette.textPrimary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_surahs == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accent),
            const SizedBox(height: 14),
            Text(
              "جاري فتح المصحف الشريف كاملاً (١١٤ سورة)...",
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_activeSurah != null) {
      return _buildSurahReaderView(_activeSurah!, palette, settings, player);
    }
    return _buildSurahIndexView(_surahs!, palette, player);
  }

  Widget _buildSurahIndexView(
    List<QuranSurah> allSurahs,
    ThemePalette palette,
    AudioPlayerProvider player,
  ) {
    final accent = palette.accentColor;
    final normQuery = normalizeArabicForSearch(_searchQuery);

    final filteredSurahs = allSurahs.where((s) {
      if (_filterType == 'makki' && !s.isMakki) return false;
      if (_filterType == 'madani' && s.isMakki) return false;
      if (_filterType == 'short' && s.number < 78) return false;
      if (normQuery.isEmpty) return true;
      return s.normalizedName.contains(normQuery) || s.number.toString() == _searchQuery.trim();
    }).toList();

    final ayahHits = normQuery.length >= 2
        ? QuranRepository.searchInsideAyahs(allSurahs, _searchQuery, limit: 25)
        : const <QuranSearchHit>[];

    final lastSurahObj = (_lastReadSurah != null &&
            _lastReadSurah! >= 1 &&
            _lastReadSurah! <= allSurahs.length)
        ? allSurahs[_lastReadSurah! - 1]
        : null;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      children: [
        // 1. بطاقة متابعة القراءة المحفوظة
        if (lastSurahObj != null && _searchQuery.isEmpty)
          GestureDetector(
            onTap: () => _openSurah(lastSurahObj, highlightAyah: _lastReadAyah),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: accent.withOpacity(palette.isDark ? 0.22 : 0.16),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent, width: 1.4),
              ),
              child: Row(
                children: [
                  Icon(Icons.bookmark_rounded, color: accent, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "متابعة آخر قراءة • سورة ${lastSurahObj.cleanName}",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          "توقفت عند الآية ${_lastReadAyah ?? 1} • اضغط للاستئناف",
                          style: TextStyle(color: accent, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 15),
                ],
              ),
            ),
          ),

        // 2. شريط القارئ السريع أثناء التصفح
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.record_voice_over_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ReciterInfo>(
                    value: player.selectedReciter,
                    isExpanded: true,
                    dropdownColor: palette.cardColor,
                    icon: Icon(Icons.keyboard_arrow_down, color: accent),
                    items: IslamicAudioLibrary.reciters.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(
                          r.name,
                          style: TextStyle(color: palette.textPrimary, fontSize: 12.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (r) {
                      if (r != null) player.selectReciter(r);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. مربع البحث الشامل (في أسماء السور أو داخل نص الآيات)
        TextField(
          controller: _searchController,
          style: TextStyle(color: palette.textPrimary, fontSize: 13.5),
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: "ابحث باسم السورة، رقمها، أو أي كلمة من القرآن الكريم...",
            hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
            prefixIcon: Icon(Icons.search_rounded, color: accent, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: palette.textMuted, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.94),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: palette.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: palette.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 4. فلاتر التصنيف
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'الكل (١١٤)', palette),
              _buildFilterChip('makki', 'مكية', palette),
              _buildFilterChip('madani', 'مدنية', palette),
              _buildFilterChip('short', 'جزء عمّ (٧٨-١١٤)', palette),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 5. نتائج البحث في الآيات إن وجدت
        if (ayahHits.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              "نتائج مطابقة في الآيات (${ayahHits.length}):",
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),
          ...ayahHits.map((hit) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.35)),
              ),
              child: ListTile(
                onTap: () => _openSurah(hit.surah, highlightAyah: hit.ayah.number),
                title: Text(
                  "${hit.ayah.text} ﴿${toArabicIndicDigits(hit.ayah.number)}﴾",
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: palette.textPrimary,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                subtitle: Text(
                  "سورة ${hit.surah.cleanName} • الآية ${hit.ayah.number} • الجزء ${hit.ayah.juz}",
                  style: TextStyle(color: accent, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // 6. قائمة السور الـ 114
        ...filteredSurahs.map((surah) {
          final isPlayingThis =
              player.currentSurahNumber == surah.number && player.isPlaying;
          final isOffline = player.isSurahOfflineReady(surah.number);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlayingThis ? accent : palette.dividerColor,
                width: isPlayingThis ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              onTap: () => _openSurah(surah),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.16),
                  border: Border.all(color: accent.withOpacity(0.75)),
                ),
                child: Center(
                  child: Text(
                    toArabicIndicDigits(surah.number),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      "سورة ${surah.cleanName}",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  if (isOffline)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        "بدون نت",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                "${surah.isMakki ? 'مكية' : 'مدنية'} • ${surah.versesCount} آية • ص ${surah.startingPage} (${surah.englishName})",
                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isPlayingThis
                          ? Icons.pause_circle_filled_rounded
                          : Icons.volume_up_rounded,
                      color: accent,
                      size: 24,
                    ),
                    tooltip: "تشغيل صوتي",
                    onPressed: () {
                      if (player.currentSurahNumber == surah.number) {
                        player.togglePlay();
                      } else {
                        player.playSurahByNumber(surah.number);
                      }
                    },
                  ),
                  Icon(Icons.chevron_left_rounded, color: palette.textMuted),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, ThemePalette palette) {
    final accent = palette.accentColor;
    final isSel = _filterType == key;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSel ? palette.onAccentColor : palette.textPrimary,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        selected: isSel,
        selectedColor: accent,
        backgroundColor: palette.cardColor.withOpacity(0.85),
        side: BorderSide(color: isSel ? accent : palette.dividerColor),
        onSelected: (_) => setState(() => _filterType = key),
      ),
    );
  }

  Widget _buildSurahReaderView(
    QuranSurah surah,
    ThemePalette palette,
    SettingsProvider settings,
    AudioPlayerProvider player,
  ) {
    final accent = palette.accentColor;
    final readerFont = _useTraditionalMushafFont ? 'Amiri' : settings.selectedFont;
    final allSurahs = _surahs!;
    final prevSurah = surah.number > 1 ? allSurahs[surah.number - 2] : null;
    final nextSurah = surah.number < allSurahs.length ? allSurahs[surah.number] : null;

    // تجميع الآيات حسب رقم صفحة المصحف لأداء سلس وسريع حتى في سورة البقرة
    final List<List<QuranAyah>> pages = [];
    for (final ayah in surah.ayahs) {
      if (pages.isEmpty || pages.last.first.page != ayah.page) {
        pages.add([ayah]);
      } else {
        pages.last.add(ayah);
      }
    }

    return Column(
      children: [
        // شريط أدوات القراءة: حجم الخط، نوع خط المصحف، السورة السابقة/التالية
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.dividerColor),
          ),
          child: Row(
            children: [
              Text(
                "حجم الخط:",
                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(Icons.remove_circle_outline_rounded, color: accent, size: 20),
                onPressed: () {
                  setState(() => _fontSize = (_fontSize - 2).clamp(16.0, 36.0));
                  _saveSettingsPrefs();
                },
              ),
              Text(
                "${_fontSize.toInt()}",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(Icons.add_circle_outline_rounded, color: accent, size: 20),
                onPressed: () {
                  setState(() => _fontSize = (_fontSize + 2).clamp(16.0, 36.0));
                  _saveSettingsPrefs();
                },
              ),
              const Spacer(),
              ChoiceChip(
                label: Text(
                  _useTraditionalMushafFont ? "خط المصحف" : "خط التطبيق",
                  style: TextStyle(
                    color: _useTraditionalMushafFont
                        ? palette.onAccentColor
                        : palette.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _useTraditionalMushafFont,
                selectedColor: accent,
                backgroundColor: palette.elevatedCardColor,
                onSelected: (val) {
                  setState(() => _useTraditionalMushafFont = val);
                  _saveSettingsPrefs();
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            controller: _readerScrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: 2 + (_mushafContinuousMode ? pages.length : surah.ayahs.length),
            itemBuilder: (context, idx) {
              // العنصر 0: لوحة افتتاح السورة والبسملة
              if (idx == 0) {
                return _buildSurahOpeningBanner(surah, palette, readerFont, player);
              }

              final bodyLength =
                  _mushafContinuousMode ? pages.length : surah.ayahs.length;

              // العنصر الأخير: أزرار الانتقال للسورة التالية والسابقة
              if (idx == bodyLength + 1) {
                return _buildSurahBottomNav(prevSurah, nextSurah, palette);
              }

              if (_mushafContinuousMode) {
                final pageAyahs = pages[idx - 1];
                return _buildMushafPageBlock(
                  surah,
                  pageAyahs,
                  palette,
                  readerFont,
                );
              } else {
                final ayah = surah.ayahs[idx - 1];
                return _buildSingleAyahCard(surah, ayah, palette, readerFont);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurahOpeningBanner(
    QuranSurah surah,
    ThemePalette palette,
    String readerFont,
    AudioPlayerProvider player,
  ) {
    final accent = palette.accentColor;
    final cacheKey = IslamicAudioLibrary.surahCacheKey(player.selectedReciter.id, surah.number);
    final isOffline = player.isSurahOfflineReady(surah.number);
    final progress = player.downloadProgressFor(cacheKey);
    final isPlayingThis =
        player.currentSurahNumber == surah.number && player.isPlaying;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.88 : 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.65), width: 1.6),
      ),
      child: Column(
        children: [
          Text(
            surah.ornateName,
            style: TextStyle(
              fontFamily: readerFont,
              color: accent,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "${surah.isMakki ? 'سورة مكية' : 'سورة مدنية'} • ${toArabicIndicDigits(surah.versesCount)} آية • الجزء ${toArabicIndicDigits(surah.startingJuz)} • صفحة ${toArabicIndicDigits(surah.startingPage)}",
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (player.currentSurahNumber == surah.number) {
                    player.togglePlay();
                  } else {
                    player.playSurahByNumber(surah.number);
                  }
                },
                icon: Icon(
                  isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(
                  isPlayingThis ? "إيقاف التلاوة" : "استماع (${player.selectedReciter.name})",
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: palette.onAccentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (player.supportsOfflineDownload && !isOffline)
                OutlinedButton.icon(
                  onPressed: progress != null
                      ? null
                      : () async {
                          final ok = await player.downloadTrackForOffline(
                            cacheKey,
                            IslamicAudioLibrary.getSurahUrl(
                              player.selectedReciter.id,
                              surah.number,
                            ),
                          );
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: palette.cardColor,
                                content: Text(
                                  "تم حفظ سورة ${surah.cleanName} للاستماع بدون إنترنت ✓",
                                  style: TextStyle(color: palette.textPrimary),
                                ),
                              ),
                            );
                          }
                        },
                  icon: progress != null
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2,
                            color: accent,
                          ),
                        )
                      : Icon(Icons.download_for_offline_rounded, color: accent, size: 17),
                  label: Text(
                    progress != null
                        ? "جاري التحميل ${(progress * 100).toInt()}%"
                        : "تحميل بدون نت",
                    style: TextStyle(color: accent, fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent.withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          if (surah.hasOpeningBasmalah) ...[
            const SizedBox(height: 12),
            Divider(color: accent.withOpacity(0.35)),
            const SizedBox(height: 6),
            Text(
              "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: readerFont,
                color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                fontSize: (_fontSize + 2).clamp(20.0, 38.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (surah.number == 9) ...[
            const SizedBox(height: 10),
            Text(
              "أَعُوذُ بِٱللَّهِ مِنَ ٱلشَّيْطَٰنِ ٱلرَّجِيمِ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: readerFont,
                color: palette.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMushafPageBlock(
    QuranSurah surah,
    List<QuranAyah> pageAyahs,
    ThemePalette palette,
    String readerFont,
  ) {
    final accent = palette.accentColor;
    final pageNum = pageAyahs.first.page;
    final juzNum = pageAyahs.first.juz;
    final firstAyahNum = pageAyahs.first.number;
    final lastAyahNum = pageAyahs.last.number;

    return Container(
      key: GlobalObjectKey('page_${surah.number}_$pageNum'),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.88 : 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.45), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                "الجزء ${toArabicIndicDigits(juzNum)} • صفحة ${toArabicIndicDigits(pageNum)}",
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showAyahTafsirModal(surah, pageAyahs.first),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded, color: accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "التفسير 📖",
                        style: TextStyle(
                          color: accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () async {
                  await _saveReadingBookmark(surah.number, firstAyahNum);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: palette.cardColor,
                      content: Text(
                        "تم حفظ موضع القراءة: سورة ${surah.cleanName} (ص $pageNum) ✓",
                        style: TextStyle(color: palette.textPrimary),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_add_outlined, color: accent, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        "حفظ العلامة",
                        style: TextStyle(color: accent, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(color: palette.dividerColor, height: 14),
          _MushafInteractivePageText(
            pageAyahs: pageAyahs,
            highlightedAyahNumber: _highlightedAyahNumber,
            fontSize: _fontSize,
            readerFont: readerFont,
            palette: palette,
            onTapAyah: (ayah) => _showAyahTafsirModal(surah, ayah),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "اضغط على أي آية لعرض تفسيرها الموثق ✨ • الآيات ${toArabicIndicDigits(firstAyahNum)} – ${toArabicIndicDigits(lastAyahNum)}",
              style: TextStyle(color: palette.textMuted, fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleAyahCard(
    QuranSurah surah,
    QuranAyah ayah,
    ThemePalette palette,
    String readerFont,
  ) {
    final accent = palette.accentColor;
    final isBookmarked =
        _lastReadSurah == surah.number && _lastReadAyah == ayah.number;
    final isHighlighted = _highlightedAyahNumber == ayah.number;

    return GestureDetector(
      key: GlobalObjectKey('ayah_${surah.number}_${ayah.number}'),
      onTap: () => _showAyahTafsirModal(surah, ayah),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? accent.withOpacity(palette.isDark ? 0.22 : 0.16)
              : palette.cardColor.withOpacity(palette.isDark ? 0.86 : 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (isHighlighted || isBookmarked) ? accent : palette.dividerColor,
            width: (isHighlighted || isBookmarked) ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.45)),
                  ),
                  child: Text(
                    "الآية ${toArabicIndicDigits(ayah.number)}",
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "ج ${toArabicIndicDigits(ayah.juz)} • ص ${toArabicIndicDigits(ayah.page)}",
                  style: TextStyle(color: palette.textMuted, fontSize: 11),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _showAyahTafsirModal(surah, ayah),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "التفسير 📖",
                      style: TextStyle(
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isBookmarked ? accent : palette.textMuted,
                    size: 19,
                  ),
                  tooltip: "حفظ موضع القراءة عند هذه الآية",
                  onPressed: () => _saveReadingBookmark(surah.number, ayah.number),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: Icon(Icons.copy_rounded, color: palette.textMuted, size: 18),
                  tooltip: "نسخ الآية",
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: "${ayah.text} ﴿${surah.cleanName}: ${ayah.number}﴾",
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: palette.cardColor,
                        content: Text(
                          "تم نسخ الآية الكريمة ✓",
                          style: TextStyle(color: palette.textPrimary),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              "${ayah.text} ﴿${toArabicIndicDigits(ayah.number)}﴾",
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: readerFont,
                color: palette.textPrimary,
                fontSize: _fontSize,
                height: 1.95,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAyahTafsirModal(QuranSurah surah, QuranAyah initialAyah) {
    setState(() => _highlightedAyahNumber = initialAyah.number);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        QuranAyah activeAyah = initialAyah;
        TafsirEdition activeEdition = TafsirEdition.muyassar;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final settings = Provider.of<SettingsProvider>(ctx);
            final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
            final palette = themeOpt.resolve(isNight: settings.isNightEffective);
            final accent = palette.accentColor;

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.80,
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: accent, width: 1.8)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/palace_jannah_logo.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.menu_book_rounded, color: accent),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تفسير سورة ${surah.cleanName} • الآية ${toArabicIndicDigits(activeAyah.number)} 📖',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'مراجعة ومطابقة Quran.com • الجزء ${toArabicIndicDigits(activeAyah.juz)} • ص ${toArabicIndicDigits(activeAyah.page)}',
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded, color: accent, size: 17),
                          tooltip: 'الآية السابقة',
                          onPressed: activeAyah.number <= 1
                              ? null
                              : () {
                                  final prev = surah.ayahs[activeAyah.number - 2];
                                  setSheetState(() => activeAyah = prev);
                                  setState(() => _highlightedAyahNumber = prev.number);
                                },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 17),
                          tooltip: 'الآية التالية',
                          onPressed: activeAyah.number >= surah.ayahs.length
                              ? null
                              : () {
                                  final next = surah.ayahs[activeAyah.number];
                                  setSheetState(() => activeAyah = next);
                                  setState(() => _highlightedAyahNumber = next.number);
                                },
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: palette.textSecondary),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),

                  // اختيار كتاب التفسير
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: [
                        for (final ed in TafsirEdition.values)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                              label: Text(
                                '${ed.title} • ${ed.badge}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: activeEdition == ed
                                      ? palette.onAccentColor
                                      : palette.textPrimary,
                                  fontWeight: activeEdition == ed
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: activeEdition == ed,
                              selectedColor: accent,
                              backgroundColor: palette.cardColor,
                              onSelected: (_) =>
                                  setSheetState(() => activeEdition = ed),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: accent.withOpacity(0.5)),
                            ),
                            child: SelectableText(
                              '${activeAyah.text} ﴿${toArabicIndicDigits(activeAyah.number)}﴾',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: _useTraditionalMushafFont
                                    ? 'Amiri'
                                    : settings.selectedFont,
                                fontSize: 22,
                                height: 1.9,
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<String>(
                            future: TafsirRepository.getTafsir(
                              surah: surah.number,
                              ayah: activeAyah.number,
                              edition: activeEdition,
                            ),
                            builder: (_, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(color: accent),
                                  ),
                                );
                              }
                              final text = snap.data ??
                                  'التفسير الميسر غير متوفر حالياً لهذه الآية.';
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: palette.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: palette.dividerColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          activeEdition.title,
                                          style: TextStyle(
                                            color: accent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.copy_rounded,
                                            color: palette.textMuted,
                                            size: 18,
                                          ),
                                          tooltip: 'نسخ الآية والتفسير',
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text:
                                                    '﴿${activeAyah.text}﴾ [${surah.cleanName}: ${activeAyah.number}]\n\n${activeEdition.title}:\n$text',
                                              ),
                                            );
                                            ScaffoldMessenger.of(ctx).showSnackBar(
                                              SnackBar(
                                                backgroundColor: palette.cardColor,
                                                content: Text(
                                                  'تم نسخ الآية والتفسير ✓',
                                                  style: TextStyle(color: palette.textPrimary),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      text,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 15,
                                        height: 1.75,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSurahBottomNav(
    QuranSurah? prevSurah,
    QuranSurah? nextSurah,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: prevSurah == null
                ? const SizedBox.shrink()
                : OutlinedButton.icon(
                    onPressed: () => _openSurah(prevSurah),
                    icon: Icon(Icons.arrow_back_rounded, color: accent, size: 18),
                    label: Text(
                      "السابقة: ${prevSurah.cleanName}",
                      style: TextStyle(color: palette.textPrimary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: palette.cardColor.withOpacity(0.88),
                      side: BorderSide(color: accent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
          ),
          if (prevSurah != null && nextSurah != null) const SizedBox(width: 10),
          Expanded(
            child: nextSurah == null
                ? const SizedBox.shrink()
                : ElevatedButton.icon(
                    onPressed: () => _openSurah(nextSurah),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      "التالية: ${nextSurah.cleanName}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: palette.onAccentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MushafInteractivePageText extends StatefulWidget {
  final List<QuranAyah> pageAyahs;
  final int? highlightedAyahNumber;
  final double fontSize;
  final String readerFont;
  final ThemePalette palette;
  final ValueChanged<QuranAyah> onTapAyah;

  const _MushafInteractivePageText({
    required this.pageAyahs,
    required this.highlightedAyahNumber,
    required this.fontSize,
    required this.readerFont,
    required this.palette,
    required this.onTapAyah,
  });

  @override
  State<_MushafInteractivePageText> createState() =>
      _MushafInteractivePageTextState();
}

class _MushafInteractivePageTextState
    extends State<_MushafInteractivePageText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _rebuildRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    for (final ayah in widget.pageAyahs) {
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => widget.onTapAyah(ayah),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _rebuildRecognizers();
  }

  @override
  void didUpdateWidget(covariant _MushafInteractivePageText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageAyahs != widget.pageAyahs) {
      _rebuildRecognizers();
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.palette.accentColor;
    return SelectableText.rich(
      TextSpan(
        children: [
          for (int i = 0; i < widget.pageAyahs.length; i++) ...[
            TextSpan(
              text: '${widget.pageAyahs[i].text} ',
              recognizer: i < _recognizers.length ? _recognizers[i] : null,
              style: TextStyle(
                fontFamily: widget.readerFont,
                fontSize: widget.fontSize,
                height: 2.05,
                color: widget.highlightedAyahNumber == widget.pageAyahs[i].number
                    ? accent
                    : widget.palette.textPrimary,
                backgroundColor:
                    widget.highlightedAyahNumber == widget.pageAyahs[i].number
                        ? accent.withOpacity(0.16)
                        : null,
              ),
            ),
            TextSpan(
              text: '﴿${toArabicIndicDigits(widget.pageAyahs[i].number)}﴾ ',
              recognizer: i < _recognizers.length ? _recognizers[i] : null,
              style: TextStyle(
                fontFamily: widget.readerFont,
                fontSize: (widget.fontSize * 0.86).clamp(14.0, 30.0),
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ],
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }
}
