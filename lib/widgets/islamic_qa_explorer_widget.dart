import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/islamic_qa_500.dart';
import '../providers/jannati_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_resilient_image.dart';
import 'sacred_reference_widgets.dart';

/// واجهة بحث ذكية وتفاعلية منظمة للـ 5000 سؤال وجواب في الإسلام عبر 10 أقسام رئيسية و50 قسماً فرعياً
class IslamicQaExplorerWidget extends StatefulWidget {
  final ThemePalette palette;
  final IslamicQaCategory? initialCategory;
  final String headerTitle;
  final String headerSubtitle;

  const IslamicQaExplorerWidget({
    super.key,
    required this.palette,
    this.initialCategory,
    this.headerTitle = 'مَوْسُوعَةُ الفَرْدَوْسِ • ٥٠٠٠ سُؤَالٍ وَجَوَابٍ مُنَظَّمَةٍ',
    this.headerSubtitle = 'مقسمة على ١٠ أقسام رئيسية و٥٠ قسماً فرعياً حتى تجد ضالتك بسهولة ويسر',
  });

  @override
  State<IslamicQaExplorerWidget> createState() => _IslamicQaExplorerWidgetState();
}

class _IslamicQaExplorerWidgetState extends State<IslamicQaExplorerWidget> {
  final TextEditingController _searchController = TextEditingController();
  IslamicQaCategory? _selectedCategory;
  String? _selectedSection;
  bool _onlyBookmarked = false;
  String _query = '';
  int _visibleLimit = 40;
  final Set<String> _expandedIds = {};

  static const List<String> _quickPrompts = [
    'أعلى درجات الجنة؟',
    'ما حكم صلاة الفائتة؟',
    'هل يبطل الوضوء بالشك؟',
    'كيف أبني قصراً في الجنة؟',
    'ما فضل آية الكرسي؟',
    'كفارة اليمين إيه؟',
    'ازاي أتوب توبة نصوح؟',
    'حكم زكاة الذهب الملبوس؟',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final accent = palette.accentColor;
    final jannatiProv = Provider.of<JannatiProvider>(context);
    final bookmarks = jannatiProv.bookmarkedQaIds;

    final bool hasQuery = _query.trim().isNotEmpty;
    final IslamicQaSearchResult? searchResult = hasQuery
        ? IslamicQaCatalog.answerAnyQuestion(_query, maxResults: 80)
        : null;

    List<IslamicQaItem> visibleItems;
    if (searchResult != null) {
      visibleItems = searchResult.matches.map((m) => m.item).toList();
      if (_selectedCategory != null) {
        visibleItems = visibleItems.where((q) => q.category == _selectedCategory).toList();
      }
      if (_selectedSection != null) {
        visibleItems = visibleItems.where((q) => q.sectionTitle == _selectedSection).toList();
      }
      if (_onlyBookmarked) {
        visibleItems = visibleItems.where((q) => bookmarks.contains(q.id)).toList();
      }
    } else {
      visibleItems = _selectedCategory == null
          ? IslamicQaCatalog.allQuestions
          : IslamicQaCatalog.byCategoryAndSection(_selectedCategory!, _selectedSection);
      if (_onlyBookmarked) {
        visibleItems = visibleItems.where((q) => bookmarks.contains(q.id)).toList();
      }
    }
    final List<IslamicQaItem> pagedItems = visibleItems.take(_visibleLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. بطاقة الترحيب وحقل السؤال الذكي
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forHelpMeBanner(5),
          isDark: palette.isDark,
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          borderColor: accent.withOpacity(0.55),
          imageOpacity: 0.54,
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
                    child: Icon(Icons.question_answer_rounded, color: accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.headerTitle,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          widget.headerSubtitle,
                          style: TextStyle(color: palette.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                style: TextStyle(color: palette.textPrimary, fontSize: 13.5),
                textInputAction: TextInputAction.search,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'اكتب سؤالك هنا (مثلاً: كيف أبني قصراً؟ أو حكم سجود السهو؟)...',
                  hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                  prefixIcon: Icon(Icons.search_rounded, color: accent, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: palette.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: palette.elevatedCardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    borderSide: BorderSide(color: accent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // أسئلة سريعة مقترحة
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickPrompts.length,
                  itemBuilder: (_, idx) {
                    final prompt = _quickPrompts[idx];
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ActionChip(
                        label: Text(
                          prompt,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: palette.elevatedCardColor,
                        side: BorderSide(color: accent.withOpacity(0.35)),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _searchController.text = prompt;
                          setState(() => _query = prompt);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2. شريط التصنيفات العشرة + المفضلة
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilterChip(
                  label: Text(
                    'الكل (٥٠٠٠)',
                    style: TextStyle(
                      color: _selectedCategory == null && !_onlyBookmarked
                          ? palette.onAccentColor
                          : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                  selected: _selectedCategory == null && !_onlyBookmarked,
                  selectedColor: accent,
                  backgroundColor: palette.cardColor,
                  side: BorderSide(color: palette.dividerColor),
                  onSelected: (_) => setState(() {
                    _selectedCategory = null;
                    _selectedSection = null;
                    _onlyBookmarked = false;
                    _visibleLimit = 40;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilterChip(
                  avatar: Icon(
                    Icons.bookmark_rounded,
                    size: 15,
                    color: _onlyBookmarked ? palette.onAccentColor : accent,
                  ),
                  label: Text(
                    'محفوظاتي (${bookmarks.length})',
                    style: TextStyle(
                      color: _onlyBookmarked ? palette.onAccentColor : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                  selected: _onlyBookmarked,
                  selectedColor: accent,
                  backgroundColor: palette.cardColor,
                  side: BorderSide(color: palette.dividerColor),
                  onSelected: (v) => setState(() => _onlyBookmarked = v),
                ),
              ),
              ...IslamicQaCategory.values.map((cat) {
                final isSel = _selectedCategory == cat;
                final catCol = cat.color;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 15,
                      color: isSel ? Colors.white : catCol,
                    ),
                    label: Text(
                      '${cat.arabicTitle} (٥٠٠)',
                      style: TextStyle(
                        color: isSel ? Colors.white : palette.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11.5,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: catCol,
                    backgroundColor: palette.cardColor,
                    side: BorderSide(color: isSel ? catCol : palette.dividerColor),
                    onSelected: (_) => setState(() {
                      _selectedCategory = isSel ? null : cat;
                      _selectedSection = null;
                      _visibleLimit = 40;
                    }),
                  ),
                );
              }),
            ],
          ),
        ),

        // 2.5 شريط الأقسام الفرعية المنظمة داخل القسم المختار (حتى لا يتوه المستخدم)
        if (_selectedCategory != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(
                      'كل فروع ${_selectedCategory!.arabicTitle}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: _selectedSection == null,
                    selectedColor: _selectedCategory!.color.withOpacity(0.85),
                    onSelected: (_) => setState(() {
                      _selectedSection = null;
                      _visibleLimit = 40;
                    }),
                  ),
                ),
                ...IslamicQaCatalog.sectionsForCategory(_selectedCategory!).map((sec) {
                  final sel = _selectedSection == sec;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(
                        sec,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? Colors.white : palette.textPrimary,
                        ),
                      ),
                      selected: sel,
                      selectedColor: _selectedCategory!.color,
                      onSelected: (_) => setState(() {
                        _selectedSection = sel ? null : sec;
                        _visibleLimit = 40;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        const SizedBox(height: 10),

        // 3. بطاقة الإجابة المباشرة الفورية عند البحث
        if (searchResult != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(palette.isDark ? 0.24 : 0.16),
                  palette.cardColor,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      searchResult.hasDirectAnswer
                          ? Icons.auto_awesome_rounded
                          : Icons.help_outline_rounded,
                      color: accent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        searchResult.hasDirectAnswer
                            ? 'أقرب إجابة لسؤالك (${searchResult.matches.length} نتيجة):'
                            : 'مقترحات وتوجيه عام لسؤالك:',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  searchResult.smartSummary,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],

        // 4. عدد النتائج الحالية
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'عرض ${pagedItems.length} من أصل ${visibleItems.length} سؤالاً (الموسوعة: ٥٠٠٠)',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
              if (_expandedIds.isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _expandedIds.clear()),
                  child: Text(
                    'طيّ الكل',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 5. قائمة البطاقات (داخل ListView أو Sliver / Column)
        if (visibleItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.cardColor.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.dividerColor),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, color: accent, size: 36),
                const SizedBox(height: 8),
                Text(
                  _onlyBookmarked
                      ? 'لم تحفظ أي سؤال في المفضلة بعد — اضغط أيقونة الحفظ على أي سؤال لإضافته.'
                      : 'لم نجد تطابقاً حرفياً في القسم المحدد. جرّب «الكل (٥٠٠٠)» أو استخدم كلمات أبسط (مثل: صلاة، زكاة، جنة، توبة).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          )
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pagedItems.length,
            itemBuilder: (_, idx) {
              final item = pagedItems[idx];
              final isExpanded = _expandedIds.contains(item.id) || (idx == 0 && hasQuery);
              final isSaved = bookmarks.contains(item.id);
              final catCol = item.category.color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Firdaws4KCardShell(
                  backdrop: Background500Catalog.forHelpMeCategory(35 + (idx % 15)),
                  isDark: palette.isDark,
                  padding: EdgeInsets.zero,
                  borderRadius: 18,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  imageOpacity: 0.44,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (_expandedIds.contains(item.id)) {
                            _expandedIds.remove(item.id);
                          } else {
                            _expandedIds.add(item.id);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: catCol.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.number}',
                                style: TextStyle(
                                  color: catCol,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.question,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.category.arabicTitle} • ${item.sectionTitle}',
                                    style: TextStyle(
                                      color: catCol,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              icon: Icon(
                                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: isSaved ? accent : palette.textMuted,
                                size: 20,
                              ),
                              onPressed: () => jannatiProv.toggleQaBookmark(item.id),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: palette.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: palette.dividerColor),
                            const SizedBox(height: 6),
                            Text(
                              item.answer,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: catCol.withOpacity(palette.isDark ? 0.14 : 0.09),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: catCol.withOpacity(0.35)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.menu_book_rounded, color: catCol, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '📜 الدليل والمرجع: ${item.evidence}',
                                          style: TextStyle(
                                            color: palette.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.5,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  SacredEvidenceFooter(
                                    evidenceText: '${item.evidence}\n${item.answer}',
                                    titleForHadith: item.question,
                                    trackInJannati: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: item.tags
                                        .take(4)
                                        .map(
                                          (t) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: palette.elevatedCardColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '#$t',
                                              style: TextStyle(
                                                color: palette.textMuted,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            'س: ${item.question}\nج: ${item.answer}\nالدليل: ${item.evidence}\n— من تطبيق الفردوس',
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ السؤال والإجابة بنجاح 📋'),
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.copy_rounded, color: accent, size: 16),
                                  label: Text(
                                    'نسخ',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
            },
          ),
          if (pagedItems.length < visibleItems.length)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _visibleLimit += 40),
                  icon: const Icon(Icons.expand_more_rounded),
                  label: Text(
                    'عرض ٤٠ سؤالاً إضافياً (متبقي ${visibleItems.length - pagedItems.length})',
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
