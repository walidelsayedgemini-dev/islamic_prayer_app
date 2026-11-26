import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AzkarReaderSheet(),
    );
  }

  static Widget _buildDhikrCard(
    String title,
    String text,
    String virtue,
    ThemePalette palette,
  ) {
    final accentColor = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CalmCard(
        padding: const EdgeInsets.all(18),
        color: palette.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(palette.isDark ? .17 : .09),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor.withOpacity(.28)),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: accentColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      title,
                      softWrap: true,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              decoration: BoxDecoration(
                color: palette.elevatedCardColor,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: palette.dividerColor),
              ),
              child: SelectableText(
                text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 21,
                  height: 1.95,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline_rounded,
                      size: 18, color: accentColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    virtue,
                    softWrap: true,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                      height: 1.65,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SacredEvidenceFooter(
              evidenceText: virtue,
              titleForHadith: title,
              hadithVerbatim: text,
              trackInJannati: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _AzkarReaderSheet extends StatefulWidget {
  const _AzkarReaderSheet();

  @override
  State<_AzkarReaderSheet> createState() => _AzkarReaderSheetState();
}

class _AzkarReaderSheetState extends State<_AzkarReaderSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final palette = IslamicTheme.resolvePalette(
      settings.selectedTheme,
      isNight: settings.isNightEffective,
    );
    final scene = FirdawsParadiseRegistry.imageFor(settings.selectedTheme);
    final media = MediaQuery.of(context);
    final compact = media.size.width < 420;
    final gutter = compact ? 16.0 : 26.0;
    final sheetHeight = (media.size.height - media.viewInsets.bottom - 12)
        .clamp(240.0, media.size.height * .94)
        .toDouble();
    final query = _searchQuery.trim();
    final visibleAdhkar = _selectedAdhkar.where((item) {
      if (query.isEmpty) return true;
      return item.title.contains(query) ||
          item.text.contains(query) ||
          item.virtue.contains(query);
    }).toList();

    return SafeArea(
      top: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Container(
              width: double.infinity,
              height: sheetHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(color: palette.accentColor, width: 1.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (palette.isDark ? Colors.black : palette.primaryColor)
                        .withOpacity(palette.isDark ? .48 : .16),
                    blurRadius: 28,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.dividerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: palette.elevatedCardColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: palette.accentColor.withOpacity(.35)),
                          ),
                          child: Icon(Icons.spa_outlined,
                              color: palette.accentColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مكتبة الأذكار',
                                softWrap: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'مختارات للقراءة مع إحالاتها المتاحة',
                                softWrap: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: palette.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'إغلاق',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close_rounded,
                              color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    child: ParadiseHero(
                      title: 'أذكار الصباح والمساء',
                      subtitle:
                          '«مثل الذي يذكر ربه والذي لا يذكر ربه مثل الحي والميت»',
                      imageAsset: scene,
                      minHeight: compact ? 168 : 184,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => showAudioDownloadManagerSheet(context),
                        icon: Icon(Icons.download_for_offline_rounded,
                            color: palette.accentColor, size: 19),
                        label: const Text(
                          'إدارة التنزيلات الصوتية',
                          softWrap: true,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.textPrimary,
                          side: BorderSide(
                              color: palette.accentColor.withOpacity(.52)),
                          minimumSize: const Size(44, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 6),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'ابحث في عنوان الذكر أو نصه',
                        prefixIcon: Icon(Icons.search_rounded,
                            color: palette.accentColor),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'مسح البحث',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: Icon(Icons.close_rounded,
                                    color: palette.textMuted),
                              ),
                        filled: true,
                        fillColor: palette.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide:
                              BorderSide(color: palette.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide:
                              BorderSide(color: palette.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide(
                              color: palette.accentColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 28),
                      child: ParadiseSection(
                        title: 'النصوص المختارة',
                        action: Text(
                          '${visibleAdhkar.length} من ${_selectedAdhkar.length}',
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: palette.textSecondary),
                        ),
                        child: visibleAdhkar.isEmpty
                            ? Column(
                                children: [
                                  const CalmEmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: 'لم تظهر نتائج مطابقة',
                                    subtitle:
                                        'جرّب عبارة أقصر للعثور على الذكر الذي تبحث عنه.',
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('عرض كل الأذكار'),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final item in visibleAdhkar) ...[
                                    QuranAzkarSheet._buildDhikrCard(
                                      item.title,
                                      item.text,
                                      item.virtue,
                                      palette,
                                    ),
                                    _DhikrCounter(
                                      storageKey: item.title,
                                      accent: palette.accentColor,
                                      textColor: palette.textPrimary,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDhikr {
  final String title;
  final String text;
  final String virtue;

  const _SelectedDhikr(this.title, this.text, this.virtue);
}

const List<_SelectedDhikr> _selectedAdhkar = [
  _SelectedDhikr(
    '😴 ذكر النوم',
    'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.',
    'كان النبي ﷺ يقولها إذا أراد أن ينام (صحيح البخاري 6324).',
  ),
  _SelectedDhikr(
    '🌤️ ذكر الاستيقاظ',
    'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.',
    'كان النبي ﷺ يقولها إذا استيقظ من نومه (صحيح البخاري 6312).',
  ),
  _SelectedDhikr(
    '🌅 أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
    'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
    'يُقال مرة واحدة كل صباح ومساء لحفظ الملك لله والاعتراف بتوحيده (صحيح مسلم).',
  ),
  _SelectedDhikr(
    '💎 سيد الاستغفار',
    'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
    'من قالها موقناً بها فمات من يومه أو ليلته دخل الجنة — صحيح البخاري (6306).',
  ),
  _SelectedDhikr(
    '🛡️ بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٍ (3 مرات)',
    'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
    'من قالها ثلاثاً إذا أصبح وثلاثاً إذا أمسى لم يضره شيء أبداً (حديث صحيح).',
  ),
  _SelectedDhikr(
    '✨ رَضِيتُ بِاللَّهِ رَبًّا (3 مرات)',
    'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا.',
    'كان حقاً على الله تعالى أن يرضيه يوم القيامة (حديث حسن).',
  ),
];

/// عدّاد يومي لكل ذكر: يُحفظ العدد ويُصفَّر تلقائيًا مع بداية كل يوم.
class _DhikrCounter extends StatefulWidget {
  final String storageKey;
  final Color accent;
  final Color textColor;
  const _DhikrCounter({
    required this.storageKey,
    required this.accent,
    required this.textColor,
  });

  @override
  State<_DhikrCounter> createState() => _DhikrCounterState();
}

class _DhikrCounterState extends State<_DhikrCounter> {
  int _count = 0;

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  String get _prefsKey => 'azkar_counter_${widget.storageKey.hashCode}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && saved.startsWith('$_todayKey|')) {
        final value = int.tryParse(saved.split('|').last) ?? 0;
        if (mounted) setState(() => _count = value);
      }
    } catch (_) {}
  }

  Future<void> _set(int value) async {
    setState(() => _count = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, '$_todayKey|$value');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _set(_count + 1),
            icon: const Icon(Icons.touch_app_rounded),
            label: Text('عدّ  •  $_count'),
            style: FilledButton.styleFrom(
              backgroundColor: widget.accent,
              minimumSize: const Size(44, 48),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'تصفير العدّاد',
          onPressed: _count == 0 ? null : () => _set(0),
          icon: Icon(Icons.restart_alt_rounded, color: widget.textColor),
        ),
      ],
    );
  }
}
