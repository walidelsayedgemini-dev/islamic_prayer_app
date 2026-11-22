import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/islamic_audio_data.dart';
import '../models/quran_model.dart';
import '../providers/audio_player_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/persistent_audio_player_bar.dart';
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';

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
        _fontSize =
            (prefs.getDouble('quran_font_size') ?? 23.0).clamp(16.0, 36.0);
        _mushafContinuousMode = prefs.getBool('quran_mushaf_mode') ?? true;
        _useTraditionalMushafFont =
            prefs.getBool('quran_use_amiri_font') ?? true;
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
        final idx =
            (widget.initialSurahNumber! - 1).clamp(0, surahs.length - 1);
        initial = surahs[idx];
      }
      setState(() {
        _surahs = surahs;
        _activeSurah = initial;
        _highlightedAyahNumber = widget.initialHighlightAyah;
      });
      if (initial != null && widget.initialHighlightAyah != null) {
        final startSurah = initial;
        final targetAyah =
            widget.initialHighlightAyah!.clamp(1, startSurah.ayahs.length);
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
    final palette = IslamicTheme.getThemeOption(settings.selectedTheme)
        .resolve(isNight: settings.isNightEffective);

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(palette, settings, player),
            Expanded(
                child: _buildBodyContent(
                    palette, settings, player, palette.accentColor)),
            PersistentAudioPlayerBar(
              themeOption: IslamicTheme.getThemeOption(settings.selectedTheme),
              isNightMode: settings.isNightEffective,
              onOpenDrawer: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    ThemePalette palette,
    SettingsProvider settings,
    AudioPlayerProvider player,
  ) {
    final inSurahView = _activeSurah != null;
    final accent = palette.accentColor;
    final title =
        inSurahView ? 'سورة ${_activeSurah!.cleanName}' : 'المصحف الشريف';
    final subtitle = inSurahView
        ? '${_activeSurah!.isMakki ? 'مكية' : 'مدنية'} • ${toArabicIndicDigits(_activeSurah!.versesCount)} آية'
        : 'قراءة القرآن الكريم';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.cardColor,
        border: Border(bottom: BorderSide(color: palette.dividerColor)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            tooltip: inSurahView ? 'العودة إلى فهرس السور' : 'رجوع',
            icon: Icon(
              inSurahView ? Icons.menu_book_rounded : Icons.arrow_back_rounded,
              color: accent,
            ),
            onPressed: () {
              if (inSurahView) {
                setState(() => _activeSurah = null);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (inSurahView) ...[
            IconButton(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip:
                  _mushafContinuousMode ? 'عرض آية بآية' : 'عرض صفحات المصحف',
              icon: Icon(
                _mushafContinuousMode
                    ? Icons.view_agenda_outlined
                    : Icons.auto_stories_rounded,
                color: accent,
              ),
              onPressed: () {
                setState(() => _mushafContinuousMode = !_mushafContinuousMode);
                _saveSettingsPrefs();
              },
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'استماع لتلاوة السورة',
              icon: Icon(
                player.currentSurahNumber == _activeSurah!.number &&
                        player.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: accent,
                size: 27,
              ),
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
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'إدارة التنزيلات الصوتية',
              icon: Icon(Icons.download_for_offline_outlined, color: accent),
              onPressed: () => showAudioDownloadManagerSheet(context),
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'إغلاق المصحف',
              icon: Icon(Icons.close_rounded, color: palette.textSecondary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _readingSurface({
    required Widget child,
    required ThemePalette palette,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 12),
    VoidCallback? onTap,
    Key? key,
    double radius = 20,
    Color? borderColor,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? palette.dividerColor),
    );
    return Container(
      key: key,
      margin: margin,
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? palette.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: palette.cardColor,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(padding: padding, child: child),
        ),
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
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: _readingSurface(
              palette: palette,
              margin: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, color: accent, size: 42),
                  const SizedBox(height: 14),
                  Text(
                    'تعذّر فتح المصحف',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(color: palette.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadQuranData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                    style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: palette.onAccentColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_surahs == null) {
      return Center(
        child: _readingSurface(
          palette: palette,
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(height: 16),
              Text(
                'جارٍ تحميل بيانات المصحف…',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textPrimary, fontSize: 15),
              ),
            ],
          ),
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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final filteredSurahs = allSurahs.where((s) {
      if (_filterType == 'makki' && !s.isMakki) return false;
      if (_filterType == 'madani' && s.isMakki) return false;
      if (_filterType == 'short' && s.number < 78) return false;
      if (normQuery.isEmpty) return true;
      return s.normalizedName.contains(normQuery) ||
          s.number.toString() == _searchQuery.trim();
    }).toList();
    final ayahHits = normQuery.length >= 2
        ? QuranRepository.searchInsideAyahs(allSurahs, _searchQuery, limit: 25)
        : const <QuranSearchHit>[];
    final lastSurahObj = (_lastReadSurah != null &&
            _lastReadSurah! >= 1 &&
            _lastReadSurah! <= allSurahs.length)
        ? allSurahs[_lastReadSurah! - 1]
        : null;
    final totalAyahs =
        allSurahs.fold<int>(0, (sum, surah) => sum + surah.ayahs.length);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ParadiseHero(
                  title: 'المصحف الشريف',
                  subtitle:
                      'ابحث عن سورة أو آية، ثم تابع القراءة أو استمع إلى التلاوة.',
                  imageAsset:
                      FirdawsParadiseRegistry.imageFor(settings.selectedTheme),
                  minHeight: 218,
                  footer: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _indexMetric(
                          '${toArabicIndicDigits(allSurahs.length)} سورة',
                          Icons.menu_book_outlined),
                      _indexMetric('${toArabicIndicDigits(totalAyahs)} آية',
                          Icons.format_align_right_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (lastSurahObj != null && _searchQuery.isEmpty)
                  _readingSurface(
                    palette: palette,
                    borderColor: accent.withOpacity(.65),
                    onTap: () =>
                        _openSurah(lastSurahObj, highlightAyah: _lastReadAyah),
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 15, 14, 15),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.bookmark_rounded, color: accent),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('متابعة القراءة',
                                  style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 12)),
                              const SizedBox(height: 3),
                              Text(
                                'سورة ${lastSurahObj.cleanName} • الآية ${toArabicIndicDigits(_lastReadAyah ?? 1)}',
                                softWrap: true,
                                style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: accent),
                      ],
                    ),
                  ),
                _readingSurface(
                  palette: palette,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.record_voice_over_rounded,
                              color: accent, size: 21),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('القارئ',
                                    style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                Text('اختر التلاوة الصوتية',
                                    style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsetsDirectional.only(
                            start: 12, end: 10),
                        decoration: BoxDecoration(
                          color: palette.elevatedCardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.dividerColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ReciterInfo>(
                            value: player.selectedReciter,
                            isExpanded: true,
                            dropdownColor: palette.cardColor,
                            icon:
                                Icon(Icons.expand_more_rounded, color: accent),
                            items: IslamicAudioLibrary.reciters
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: palette.textPrimary,
                                              fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (r) {
                              if (r != null) player.selectReciter(r);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _readingSurface(
                  palette: palette,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 5, 8, 5),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: palette.textPrimary, fontSize: 15),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم السورة أو رقمها أو بكلمة من آية',
                      hintStyle:
                          TextStyle(color: palette.textSecondary, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: accent),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              tooltip: 'مسح البحث',
                              icon: Icon(Icons.clear_rounded,
                                  color: palette.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(start: 2, bottom: 8),
                  child: Text('تصفية السور',
                      style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                        'all',
                        'الكل (${toArabicIndicDigits(allSurahs.length)})',
                        palette),
                    _buildFilterChip('makki', 'مكية', palette),
                    _buildFilterChip('madani', 'مدنية', palette),
                    _buildFilterChip('short', 'جزء عمّ', palette),
                  ],
                ),
                const SizedBox(height: 14),
                if (ayahHits.isNotEmpty) ...[
                  _indexSectionHeading('نتائج الآيات',
                      '${toArabicIndicDigits(ayahHits.length)} نتيجة', palette),
                  ...ayahHits.map((hit) => _readingSurface(
                        palette: palette,
                        onTap: () => _openSurah(hit.surah,
                            highlightAyah: hit.ayah.number),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SelectableText(
                              '${hit.ayah.text} ﴿${toArabicIndicDigits(hit.ayah.number)}﴾',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: palette.textPrimary,
                                  fontSize: 19,
                                  height: 1.8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'سورة ${hit.surah.cleanName} • الآية ${toArabicIndicDigits(hit.ayah.number)} • الجزء ${toArabicIndicDigits(hit.ayah.juz)}',
                                softWrap: true,
                                style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ],
                        ),
                      )),
                ],
                _indexSectionHeading(
                    'فهرس السور',
                    '${toArabicIndicDigits(filteredSurahs.length)} سورة',
                    palette),
                if (filteredSurahs.isEmpty)
                  _readingSurface(
                    palette: palette,
                    child: Column(
                      children: [
                        Icon(Icons.manage_search_rounded,
                            size: 36, color: accent),
                        const SizedBox(height: 10),
                        Text('لا توجد نتائج مطابقة',
                            style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('جرّب كلمة أخرى أو غيّر نوع السورة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: palette.textSecondary, height: 1.4)),
                      ],
                    ),
                  ),
                ...filteredSurahs.map(
                    (surah) => _buildSurahIndexTile(surah, palette, player)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _indexMetric(String label, IconData icon) => Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.14),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.32)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: const Color(0xFFE8D6A7)),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ]),
      );

  Widget _indexSectionHeading(
          String title, String count, ThemePalette palette) =>
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(2, 12, 2, 10),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  softWrap: true,
                  style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Text(count,
              style: TextStyle(color: palette.textSecondary, fontSize: 12)),
        ]),
      );

  Widget _buildSurahIndexTile(
      QuranSurah surah, ThemePalette palette, AudioPlayerProvider player) {
    final accent = palette.accentColor;
    final isPlayingThis =
        player.currentSurahNumber == surah.number && player.isPlaying;
    final isOffline = player.isSurahOfflineReady(surah.number);
    return _readingSurface(
      palette: palette,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 8, 12),
      onTap: () => _openSurah(surah),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accent.withOpacity(.45)),
            ),
            child: Center(
                child: Text(toArabicIndicDigits(surah.number),
                    style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سورة ${surah.cleanName}',
                    softWrap: true,
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(surah.isMakki ? 'مكية' : 'مدنية',
                          style: TextStyle(
                              color: palette.textSecondary, fontSize: 12)),
                      Text('•', style: TextStyle(color: palette.textMuted)),
                      Text('${toArabicIndicDigits(surah.versesCount)} آية',
                          style: TextStyle(
                              color: palette.textSecondary, fontSize: 12)),
                      if (isOffline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE7F3EA),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('متاحة دون اتصال',
                              style: TextStyle(
                                  color: Color(0xFF23643F),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ]),
              ],
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            tooltip: isPlayingThis ? 'إيقاف التلاوة' : 'تشغيل التلاوة',
            icon: Icon(
                isPlayingThis
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_outline_rounded,
                color: accent,
                size: 27),
            onPressed: () {
              if (player.currentSurahNumber == surah.number) {
                player.togglePlay();
              } else {
                player.playSurahByNumber(surah.number);
              }
            },
          ),
        ],
      ),
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
    final readerFont =
        _useTraditionalMushafFont ? 'Amiri' : settings.selectedFont;
    final allSurahs = _surahs!;
    final prevSurah = surah.number > 1 ? allSurahs[surah.number - 2] : null;
    final nextSurah =
        surah.number < allSurahs.length ? allSurahs[surah.number] : null;
    final pages = _groupPagesForSurah(surah);
    final accent = palette.accentColor;

    return Column(
      children: [
        _readingSurface(
          palette: palette,
          margin: const EdgeInsets.fromLTRB(14, 12, 14, 2),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('أدوات القراءة',
                  style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(
                          () => _mushafContinuousMode = !_mushafContinuousMode);
                      _saveSettingsPrefs();
                    },
                    icon: Icon(
                        _mushafContinuousMode
                            ? Icons.view_agenda_outlined
                            : Icons.auto_stories_rounded,
                        size: 18),
                    label: Text(_mushafContinuousMode
                        ? 'عرض آية بآية'
                        : 'عرض صفحات المصحف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent.withOpacity(.55)),
                      minimumSize: const Size(44, 44),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
                    decoration: BoxDecoration(
                      color: palette.elevatedCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.dividerColor),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('حجم الخط',
                          style: TextStyle(
                              color: palette.textSecondary, fontSize: 13)),
                      IconButton(
                        tooltip: 'تصغير الخط',
                        constraints:
                            const BoxConstraints(minWidth: 40, minHeight: 40),
                        icon: Icon(Icons.remove_rounded, color: accent),
                        onPressed: () {
                          setState(() =>
                              _fontSize = (_fontSize - 2).clamp(16.0, 36.0));
                          _saveSettingsPrefs();
                        },
                      ),
                      Text('${_fontSize.toInt()}',
                          style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        tooltip: 'تكبير الخط',
                        constraints:
                            const BoxConstraints(minWidth: 40, minHeight: 40),
                        icon: Icon(Icons.add_rounded, color: accent),
                        onPressed: () {
                          setState(() =>
                              _fontSize = (_fontSize + 2).clamp(16.0, 36.0));
                          _saveSettingsPrefs();
                        },
                      ),
                    ]),
                  ),
                  ChoiceChip(
                    label: Text(
                        _useTraditionalMushafFont ? 'خط المصحف' : 'خط التطبيق'),
                    selected: _useTraditionalMushafFont,
                    selectedColor: accent,
                    backgroundColor: palette.elevatedCardColor,
                    labelStyle: TextStyle(
                      color: _useTraditionalMushafFont
                          ? palette.onAccentColor
                          : palette.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      setState(() => _useTraditionalMushafFont = val);
                      _saveSettingsPrefs();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _readerScrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount:
                2 + (_mushafContinuousMode ? pages.length : surah.ayahs.length),
            itemBuilder: (context, idx) {
              if (idx == 0) {
                return _buildSurahOpeningBanner(
                    surah, palette, readerFont, player);
              }
              final bodyLength =
                  _mushafContinuousMode ? pages.length : surah.ayahs.length;
              if (idx == bodyLength + 1) {
                return _buildSurahBottomNav(prevSurah, nextSurah, palette);
              }
              if (_mushafContinuousMode) {
                return _buildMushafPageBlock(
                    surah, pages[idx - 1], palette, readerFont);
              }
              return _buildSingleAyahCard(
                  surah, surah.ayahs[idx - 1], palette, readerFont);
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
    final cacheKey = IslamicAudioLibrary.surahCacheKey(
        player.selectedReciter.id, surah.number);
    final isOffline = player.isSurahOfflineReady(surah.number);
    final progress = player.downloadProgressFor(cacheKey);
    final isPlayingThis =
        player.currentSurahNumber == surah.number && player.isPlaying;
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NatureSceneryStrip(
          assetPath: FirdawsParadiseRegistry.imageFor(settings.selectedTheme),
          height: 142,
          caption:
              'الجزء ${toArabicIndicDigits(surah.startingJuz)} • الصفحة ${toArabicIndicDigits(surah.startingPage)}',
        ),
        const SizedBox(height: 12),
        _readingSurface(
          palette: palette,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                surah.ornateName,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                    fontFamily: readerFont,
                    color: palette.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                '${surah.isMakki ? 'سورة مكية' : 'سورة مدنية'} • ${toArabicIndicDigits(surah.versesCount)} آية • الجزء ${toArabicIndicDigits(surah.startingJuz)}',
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                    color: palette.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      if (player.currentSurahNumber == surah.number) {
                        player.togglePlay();
                      } else {
                        player.playSurahByNumber(surah.number);
                      }
                    },
                    icon: Icon(isPlayingThis
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded),
                    label: Text(
                        isPlayingThis
                            ? 'إيقاف التلاوة'
                            : 'استماع • ${player.selectedReciter.name}',
                        softWrap: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: palette.onAccentColor,
                      minimumSize: const Size(44, 44),
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
                                    player.selectedReciter.id, surah.number),
                              );
                              if (ok && mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: palette.cardColor,
                                  content: Text(
                                      'تم حفظ سورة ${surah.cleanName} للاستماع بدون إنترنت ✓',
                                      style: TextStyle(
                                          color: palette.textPrimary)),
                                ));
                              }
                            },
                      icon: progress != null
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2,
                                  color: accent))
                          : Icon(Icons.download_for_offline_outlined,
                              color: accent),
                      label: Text(progress != null
                          ? 'جارٍ التحميل ${(progress * 100).toInt()}%'
                          : 'تحميل للاستماع دون اتصال'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent.withOpacity(.55)),
                        minimumSize: const Size(44, 44),
                      ),
                    ),
                  if (isOffline)
                    Chip(
                      avatar: Icon(Icons.offline_pin_rounded,
                          color: accent, size: 18),
                      label: const Text('محفوظة دون اتصال'),
                      backgroundColor: palette.elevatedCardColor,
                      side: BorderSide(color: palette.dividerColor),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (surah.hasOpeningBasmalah)
          _readingSurface(
            palette: palette,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontFamily: readerFont,
                  color: palette.textPrimary,
                  fontSize: (_fontSize + 2).clamp(20.0, 38.0),
                  fontWeight: FontWeight.bold,
                  height: 1.8),
            ),
          )
        else if (surah.number == 9)
          _readingSurface(
            palette: palette,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Text(
              'أَعُوذُ بِٱللَّهِ مِنَ ٱلشَّيْطَٰنِ ٱلرَّجِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontFamily: readerFont,
                  color: palette.textPrimary,
                  fontSize: 18,
                  height: 1.8),
            ),
          ),
      ],
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

    return _readingSurface(
      key: GlobalObjectKey('page_${surah.number}_$pageNum'),
      palette: palette,
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
      borderColor: accent.withOpacity(.34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                  'الجزء ${toArabicIndicDigits(juzNum)} • الصفحة ${toArabicIndicDigits(pageNum)}',
                  style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              Wrap(spacing: 4, runSpacing: 4, children: [
                TextButton.icon(
                  onPressed: () => _showAyahTafsirModal(surah, pageAyahs.first),
                  icon: Icon(Icons.menu_book_outlined, size: 18, color: accent),
                  label: Text('التفسير', style: TextStyle(color: accent)),
                  style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await _saveReadingBookmark(surah.number, firstAyahNum);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: palette.cardColor,
                      content: Text(
                          'تم حفظ موضع القراءة: سورة ${surah.cleanName} (ص $pageNum) ✓',
                          style: TextStyle(color: palette.textPrimary)),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  icon: Icon(Icons.bookmark_add_outlined,
                      size: 18, color: accent),
                  label: Text('حفظ الموضع', style: TextStyle(color: accent)),
                  style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                ),
              ]),
            ],
          ),
          Divider(color: palette.dividerColor, height: 20),
          _MushafInteractivePageText(
            pageAyahs: pageAyahs,
            highlightedAyahNumber: _highlightedAyahNumber,
            fontSize: _fontSize,
            readerFont: readerFont,
            palette: palette,
            onTapAyah: (ayah) => _showAyahTafsirModal(surah, ayah),
          ),
          const SizedBox(height: 13),
          Text(
            'الآيات ${toArabicIndicDigits(firstAyahNum)}–${toArabicIndicDigits(lastAyahNum)} • اضغط على الآية لفتح التفسير',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
                color: palette.textSecondary, fontSize: 12, height: 1.4),
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

    return _readingSurface(
      key: GlobalObjectKey('ayah_${surah.number}_${ayah.number}'),
      palette: palette,
      onTap: () => _showAyahTafsirModal(surah, ayah),
      borderColor: (isHighlighted || isBookmarked)
          ? accent.withOpacity(.72)
          : palette.dividerColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: accent.withOpacity(.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withOpacity(.35))),
                      child: Text('الآية ${toArabicIndicDigits(ayah.number)}',
                          style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                    Text(
                        'ج ${toArabicIndicDigits(ayah.juz)} • ص ${toArabicIndicDigits(ayah.page)}',
                        style: TextStyle(
                            color: palette.textSecondary, fontSize: 12)),
                  ]),
              Wrap(spacing: 0, children: [
                IconButton(
                  tooltip: 'فتح التفسير',
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: Icon(Icons.menu_book_outlined, color: accent),
                  onPressed: () => _showAyahTafsirModal(surah, ayah),
                ),
                IconButton(
                  tooltip: 'حفظ موضع القراءة عند هذه الآية',
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isBookmarked ? accent : palette.textSecondary),
                  onPressed: () =>
                      _saveReadingBookmark(surah.number, ayah.number),
                ),
                IconButton(
                  tooltip: 'نسخ الآية',
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: Icon(Icons.copy_rounded, color: palette.textSecondary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            '${ayah.text} ﴿${surah.cleanName}: ${ayah.number}﴾'));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: palette.cardColor,
                      content: Text('تم نسخ الآية الكريمة ✓',
                          style: TextStyle(color: palette.textPrimary)),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            '${ayah.text} ﴿${toArabicIndicDigits(ayah.number)}﴾',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: readerFont,
              color: palette.textPrimary,
              fontSize: _fontSize,
              height: 1.95,
              backgroundColor: isHighlighted ? accent.withOpacity(.08) : null,
            ),
          ),
        ],
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
            final themeOpt =
                IslamicTheme.getThemeOption(settings.selectedTheme);
            final palette =
                themeOpt.resolve(isNight: settings.isNightEffective);
            final accent = palette.accentColor;
            final sheetHeight = MediaQuery.sizeOf(ctx).height * .88;

            return SafeArea(
              top: false,
              child: Container(
                height: sheetHeight,
                decoration: BoxDecoration(
                  color: palette.scaffoldColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(
                      top: BorderSide(
                          color: accent.withOpacity(.7), width: 1.5)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                            color: palette.dividerColor,
                            borderRadius: BorderRadius.circular(8))),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 6),
                      child: Row(children: [
                        FirdawsBrandLogo(
                            size: 34,
                            borderColor: accent,
                            borderWidth: 1.2,
                            fallbackIcon: Icons.menu_book_rounded),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('تفسير سورة ${surah.cleanName}',
                                    softWrap: true,
                                    style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'الآية ${toArabicIndicDigits(activeAyah.number)} • الجزء ${toArabicIndicDigits(activeAyah.juz)} • الصفحة ${toArabicIndicDigits(activeAyah.page)}',
                                    softWrap: true,
                                    style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 12)),
                              ]),
                        ),
                        IconButton(
                            tooltip: 'إغلاق',
                            icon: Icon(Icons.close_rounded,
                                color: palette.textSecondary),
                            onPressed: () => Navigator.of(ctx).pop()),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(children: [
                        Expanded(
                            child: OutlinedButton.icon(
                          onPressed: activeAyah.number <= 1
                              ? null
                              : () {
                                  final prev =
                                      surah.ayahs[activeAyah.number - 2];
                                  setSheetState(() => activeAyah = prev);
                                  setState(() =>
                                      _highlightedAyahNumber = prev.number);
                                },
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('الآية السابقة'),
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: OutlinedButton.icon(
                          onPressed: activeAyah.number >= surah.ayahs.length
                              ? null
                              : () {
                                  final next = surah.ayahs[activeAyah.number];
                                  setSheetState(() => activeAyah = next);
                                  setState(() =>
                                      _highlightedAyahNumber = next.number);
                                },
                          icon:
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('الآية التالية'),
                        )),
                      ]),
                    ),
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          for (final ed in TafsirEdition.values)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 7),
                              child: ChoiceChip(
                                label: Text('${ed.title} • ${ed.badge}'),
                                selected: activeEdition == ed,
                                selectedColor: accent,
                                backgroundColor: palette.cardColor,
                                labelStyle: TextStyle(
                                    color: activeEdition == ed
                                        ? palette.onAccentColor
                                        : palette.textPrimary,
                                    fontWeight: activeEdition == ed
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                                onSelected: (_) =>
                                    setSheetState(() => activeEdition = ed),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(color: palette.dividerColor, height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _readingSurface(
                              palette: palette,
                              borderColor: accent.withOpacity(.42),
                              child: SelectableText(
                                '${activeAyah.text} ﴿${toArabicIndicDigits(activeAyah.number)}﴾',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontFamily: _useTraditionalMushafFont
                                        ? 'Amiri'
                                        : settings.selectedFont,
                                    fontSize: 23,
                                    height: 1.9,
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FutureBuilder<String>(
                              future: TafsirRepository.getTafsir(
                                  surah: surah.number,
                                  ayah: activeAyah.number,
                                  edition: activeEdition),
                              builder: (_, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return _readingSurface(
                                    palette: palette,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                              color: accent),
                                          const SizedBox(height: 12),
                                          Text('جارٍ تحميل التفسير…',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color:
                                                      palette.textSecondary)),
                                        ]),
                                  );
                                }
                                if (snap.hasError) {
                                  return _readingSurface(
                                    palette: palette,
                                    child: Text(
                                        'تعذّر تحميل التفسير لهذه الآية.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: palette.textSecondary,
                                            height: 1.5)),
                                  );
                                }
                                final text = snap.data ??
                                    'التفسير الميسر غير متوفر حالياً لهذه الآية.';
                                return _readingSurface(
                                  palette: palette,
                                  borderColor: palette.dividerColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                            child: Text(activeEdition.title,
                                                softWrap: true,
                                                style: TextStyle(
                                                    color: accent,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        IconButton(
                                          tooltip: 'نسخ الآية والتفسير',
                                          constraints: const BoxConstraints(
                                              minWidth: 44, minHeight: 44),
                                          icon: Icon(Icons.copy_rounded,
                                              color: palette.textSecondary),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text:
                                                    '﴿${activeAyah.text}﴾ [${surah.cleanName}: ${activeAyah.number}]\n\n${activeEdition.title}:\n$text'));
                                            ScaffoldMessenger.of(ctx)
                                                .showSnackBar(SnackBar(
                                              backgroundColor:
                                                  palette.cardColor,
                                              content: Text(
                                                  'تم نسخ الآية والتفسير ✓',
                                                  style: TextStyle(
                                                      color:
                                                          palette.textPrimary)),
                                            ));
                                          },
                                        ),
                                      ]),
                                      const SizedBox(height: 8),
                                      SelectableText(text,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                              color: palette.textPrimary,
                                              fontSize: 16,
                                              height: 1.8)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (prevSurah != null)
            OutlinedButton.icon(
              onPressed: () => _openSurah(prevSurah),
              icon: Icon(Icons.arrow_back_rounded, color: accent),
              label: Text('السورة السابقة: ${prevSurah.cleanName}',
                  softWrap: true, style: TextStyle(color: palette.textPrimary)),
              style: OutlinedButton.styleFrom(
                backgroundColor: palette.cardColor,
                side: BorderSide(color: accent.withOpacity(.5)),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                minimumSize: const Size(44, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          if (prevSurah != null && nextSurah != null) const SizedBox(height: 8),
          if (nextSurah != null)
            FilledButton.icon(
              onPressed: () => _openSurah(nextSurah),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text('السورة التالية: ${nextSurah.cleanName}',
                  softWrap: true),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: palette.onAccentColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                minimumSize: const Size(44, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
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
                color:
                    widget.highlightedAyahNumber == widget.pageAyahs[i].number
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
