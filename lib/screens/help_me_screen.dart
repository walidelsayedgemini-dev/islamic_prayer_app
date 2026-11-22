import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/help_me_1000_catalog.dart';
import '../models/help_me_model.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/islamic_qa_explorer_widget.dart';
import '../widgets/sacred_reference_widgets.dart';

class HelpMeScreen extends StatefulWidget {
  final ValueNotifier<bool?>? openQaNotifier;

  const HelpMeScreen({super.key, this.openQaNotifier});

  @override
  State<HelpMeScreen> createState() => _HelpMeScreenState();
}

class _HelpMeScreenState extends State<HelpMeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathingController;
  final TextEditingController _searchController = TextEditingController();

  int _modeIndex = 0;
  String _selectedDomainId = 'all';
  String? _selectedSubCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    widget.openQaNotifier?.addListener(_consumeOpenQaRequest);
    _consumeOpenQaRequest();
  }

  void _consumeOpenQaRequest() {
    final notifier = widget.openQaNotifier;
    if (notifier == null) return;
    final requestedMode = notifier.value;
    if (requestedMode == null) return;

    if (mounted) {
      setState(() => _modeIndex = requestedMode ? 1 : 0);
    } else {
      _modeIndex = requestedMode ? 1 : 0;
    }
    notifier.value = null;
  }

  @override
  void didUpdateWidget(covariant HelpMeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openQaNotifier != widget.openQaNotifier) {
      oldWidget.openQaNotifier?.removeListener(_consumeOpenQaRequest);
      widget.openQaNotifier?.addListener(_consumeOpenQaRequest);
      _consumeOpenQaRequest();
    }
  }

  @override
  void dispose() {
    widget.openQaNotifier?.removeListener(_consumeOpenQaRequest);
    _searchController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final palette = IslamicTheme.getThemeOption(settings.selectedTheme)
        .resolve(isNight: settings.isNightEffective);
    final scene = FirdawsParadiseRegistry.imageFor(settings.selectedTheme);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 24,
                    compact ? 8 : 16,
                    compact ? 16 : 24,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPageMasthead(),
                      const SizedBox(height: 12),
                      _buildModeSelector(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _modeIndex == 0
                            ? _buildTopicsMode(scene)
                            : SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: IslamicQaExplorerWidget(
                                  palette: palette,
                                  headerTitle: 'الأسئلة والأجوبة',
                                  headerSubtitle:
                                      'ابحث في مسائل العقيدة والعبادة والحياة اليومية',
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageMasthead() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        const CalmIconBadge(Icons.volunteer_activism_outlined, size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المساندة والأسئلة',
                softWrap: true,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'اختر موضوعاً للإرشاد أو افتح موسوعة الأسئلة',
                softWrap: true,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .75)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildModeButton(
            index: 0,
            label: 'موضوعات وإرشاد',
            icon: Icons.spa_outlined,
          ),
          const SizedBox(width: 5),
          _buildModeButton(
            index: 1,
            label: 'أسئلة وأجوبة',
            icon: Icons.forum_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final selected = _modeIndex == index;
    return Expanded(
      child: Material(
        color: selected ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _modeIndex = index),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: selected ? scheme.onPrimary : scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? scheme.onPrimary : scheme.onSurface,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2,
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

  Widget _buildTopicsMode(String scene) {
    final query = _searchQuery.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),
        const SizedBox(height: 10),
        Expanded(
          child: query.isNotEmpty
              ? _buildSearchResults(query)
              : _selectedDomainId == 'all'
                  ? _buildDirectoryOverview(scene)
                  : _selectedSubCategory == null
                      ? _buildSubCategoryDirectory()
                      : _buildTopicList(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final scheme = Theme.of(context).colorScheme;
    final isSearching = _searchQuery.trim().isNotEmpty;
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      textInputAction: TextInputAction.search,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'ابحث عن موضوع أو موقف',
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
        suffixIcon: isSearching
            ? IconButton(
                tooltip: 'مسح البحث',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDirectoryOverview(String scene) {
    const domains = HelpMe1000Catalog.domains;
    const categories = HelpMeCategory.categories;
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: [
        ParadiseHero(
          title: 'خذ خطوة واضحة، على مهل',
          subtitle: 'اختر مجالاً قريباً من سؤالك، أو استكشف الإرشاد بحسب الحال.',
          imageAsset: scene,
          minHeight: 178,
          footer: const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ParadiseChip(label: 'موضوعات ومواقف', icon: Icons.menu_book_outlined),
              ParadiseChip(label: 'إرشاد بحسب الحال', icon: Icons.favorite_border),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ParadiseMetric(
                value: '${domains.length}',
                label: 'مجالات للإرشاد',
                icon: Icons.explore_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ParadiseMetric(
                value: '${categories.length}',
                label: 'موضوعات بحسب الحال',
                icon: Icons.favorite_border_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ParadiseSection(
          title: 'اختر المجال الأقرب',
          child: _buildDomainGrid(domains),
        ),
        const SizedBox(height: 24),
        ParadiseSection(
          title: 'إرشاد بحسب الحال',
          child: _buildCategoryGrid(categories),
        ),
      ],
    );
  }

  Widget _buildDomainGrid(List<HelpMeDomain> domains) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 3
            : constraints.maxWidth >= 540
                ? 2
                : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final domain in domains)
              SizedBox(width: width, child: _buildDomainTile(domain)),
          ],
        );
      },
    );
  }

  Widget _buildCategoryGrid(List<HelpMeCategory> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 3
            : constraints.maxWidth >= 540
                ? 2
                : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final category in categories)
              SizedBox(width: width, child: _buildEmotionalCategoryTile(category)),
          ],
        );
      },
    );
  }

  Widget _buildDomainTile(HelpMeDomain domain) {
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        setState(() {
          _selectedDomainId = domain.id;
          _selectedSubCategory = null;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CalmIconBadge(domain.icon, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domain.label,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'استكشف الموضوعات',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmotionalCategoryTile(HelpMeCategory category) {
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showCategoryDetails(category),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmIconBadge(category.icon, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  category.subtitle,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSubCategoryDirectory() {
    final domain = HelpMe1000Catalog.domains.firstWhere(
      (item) => item.id == _selectedDomainId,
      orElse: () => HelpMe1000Catalog.domains.first,
    );
    final subCategories = HelpMe1000Catalog.subCategoriesForDomain(domain.id);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildDirectoryBackHeader(
          title: domain.label,
          subtitle: 'اختر موضوعاً فرعياً لعرض الحالات والإرشادات المرتبطة به.',
          onBack: () => setState(() {
            _selectedDomainId = 'all';
            _selectedSubCategory = null;
          }),
        ),
        const SizedBox(height: 18),
        ParadiseSection(
          title: 'تصفّح الموضوعات',
          child: Column(
            children: [
              for (final subCategory in subCategories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CalmCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    onTap: () => setState(() => _selectedSubCategory = subCategory),
                    child: Row(
                      children: [
                        const CalmIconBadge(Icons.article_outlined, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subCategory,
                            softWrap: true,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                          ),
                        ),
                        Icon(Icons.arrow_back_rounded,
                            color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectoryBackHeader({
    required String title,
    required String subtitle,
    required VoidCallback onBack,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CalmCard(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: 'رجوع إلى المستوى السابق',
            onPressed: onBack,
            icon: Icon(Icons.arrow_forward_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    softWrap: true,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicList() {
    final domain = HelpMe1000Catalog.domains.firstWhere(
      (item) => item.id == _selectedDomainId,
      orElse: () => HelpMe1000Catalog.domains.first,
    );
    final entries = HelpMe1000Catalog.filter(
      domainId: domain.id,
      subCategory: _selectedSubCategory!,
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildDirectoryBackHeader(
              title: _selectedSubCategory!,
              subtitle: domain.label,
              onBack: () => setState(() => _selectedSubCategory = null),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTopicTile(entries[index - 1]),
        );
      },
    );
  }

  Widget _buildSearchResults(String query) {
    final results = HelpMe1000Catalog.filter(
      domainId: _selectedDomainId,
      query: query,
    );
    if (results.isEmpty) {
      final theme = Theme.of(context);
      return ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        children: [
          CalmCard(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              children: [
                const CalmEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'لا توجد نتيجة بهذه الصياغة',
                  subtitle: 'جرّب كلمة أقصر أو عبارة مختلفة للعثور على موضوع قريب.',
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('مسح البحث والعودة إلى المجالات'),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => setState(() => _modeIndex = 1),
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('جرّب البحث في الأسئلة والأجوبة'),
                ),
                Text(
                  'يمكنك البحث بكلمة أو بوصف موجز للموقف.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: results.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(2, 10, 2, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'موضوعات مقترحة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                ParadiseChip(
                  label: '${results.length} نتيجة',
                  icon: Icons.manage_search_rounded,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTopicTile(results[index - 1]),
        );
      },
    );
  }

  Widget _buildTopicTile(HelpMeCaseEntry entry) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _showCaseDetails(entry),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${entry.domainLabel}  /  ${entry.subCategory}',
                  softWrap: true,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.number}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.title,
            softWrap: true,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            entry.summary,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.arrow_back_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'عرض الإرشاد والمراجع',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCaseDetails(HelpMeCaseEntry entry) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.48,
        maxChildSize: 0.95,
        builder: (context, controller) => Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildSheetHandle(),
              const SizedBox(height: 20),
              Text(entry.domainLabel,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 6),
              Text(entry.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(entry.summary,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.55)),
              const SizedBox(height: 20),
              _buildEvidenceCard(
                label: 'من القرآن الكريم',
                text: entry.quranAyah,
                evidenceText: entry.quranAyah,
                title: entry.title,
              ),
              const SizedBox(height: 12),
              _buildEvidenceCard(
                label: 'من السنة النبوية',
                text: entry.hadithReference,
                evidenceText: entry.hadithReference,
                title: entry.title,
                hadithVerbatim: entry.hadithReference,
              ),
              const SizedBox(height: 16),
              _buildAdviceCard(
                title: 'ما يمكن فعله',
                text: entry.doAction,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 10),
              _buildAdviceCard(
                title: 'ما يُستحسن اجتنابه',
                text: entry.dontAction,
                icon: Icons.remove_circle_outline_rounded,
              ),
              const SizedBox(height: 12),
              _buildEvidenceCard(
                label: 'دعاء',
                text: entry.dua,
                evidenceText: entry.dua,
                title: entry.title,
              ),
              if (entry.hasBreathingGuide) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _openBreathingExercise();
                  },
                  icon: const Icon(Icons.air_rounded),
                  label: const Text('تمرين تنفس هادئ'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(HelpMeCategory category) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.84,
        minChildSize: 0.48,
        maxChildSize: 0.95,
        builder: (context, controller) => Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildSheetHandle(),
              const SizedBox(height: 20),
              Text(category.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(category.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
              const SizedBox(height: 20),
              _buildEvidenceCard(
                label: 'من القرآن الكريم',
                text: category.quranAyah,
                evidenceText: category.quranAyah,
                title: category.title,
              ),
              const SizedBox(height: 12),
              _buildEvidenceCard(
                label: 'من السنة النبوية',
                text: category.hadithReference,
                evidenceText: category.hadithReference,
                title: category.title,
                hadithVerbatim: category.hadithReference,
              ),
              const SizedBox(height: 12),
              _buildEvidenceCard(
                label: 'دعاء',
                text: category.mainDuha,
                evidenceText: category.hadithReference,
                title: category.title,
                hadithVerbatim: category.mainDuha,
              ),
              if (category.hasBreathingGuide) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _openBreathingExercise();
                  },
                  icon: const Icon(Icons.air_rounded),
                  label: const Text('تمرين تنفس هادئ'),
                ),
              ],
              if (category.sunnahSteps.isNotEmpty) ...[
                const CalmSectionTitle('خطوات عملية'),
                for (final step in category.sunnahSteps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CalmCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CalmIconBadge(step.icon, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(step.title,
                                    style: theme.textTheme.titleSmall),
                                const SizedBox(height: 5),
                                Text(step.description,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildEvidenceCard({
    required String label,
    required String text,
    required String evidenceText,
    required String title,
    String? hadithVerbatim,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CalmIconBadge(Icons.auto_stories_outlined, size: 38),
              const SizedBox(width: 11),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    label,
                    softWrap: true,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            softWrap: true,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const SizedBox(height: 12),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: 8),
          SacredEvidenceFooter(
            evidenceText: evidenceText,
            titleForHadith: title,
            hadithVerbatim: hadithVerbatim,
            trackInJannati: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard({
    required String title,
    required String text,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmIconBadge(icon, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openBreathingExercise() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('لحظة هدوء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اتبع إيقاعاً مريحاً لنَفَسك، واستحضر ذكر الله بهدوء.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                final value = _breathingController.value;
                final inhaling =
                    _breathingController.status == AnimationStatus.forward;
                final diameter = 118 + value * 28;
                return SizedBox(
                  width: 168,
                  height: 168,
                  child: Center(
                    child: Container(
                      width: diameter,
                      height: diameter,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary),
                      ),
                      child: Text(
                        inhaling ? 'شهيق هادئ' : 'زفير ببطء',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
