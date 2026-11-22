import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/events_missions_catalog.dart';
import '../models/hasanat_store_catalog.dart';
import '../models/islamic_qa_500.dart';
import '../models/jannati_encyclopedia_data.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/hoor_companion_provider.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/calm_ui.dart';
import '../widgets/islamic_qa_explorer_widget.dart';
import '../widgets/jannati_atlas_and_covenant_views.dart';
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/sacred_reference_widgets.dart';
import '../widgets/wallpaper_70_picker_sheet.dart';
import 'events_missions_screen.dart';
import 'hasanat_store_screen.dart';

enum _JannatiMenuAction {
  dailyPlan,
  atlas,
  covenant,
  questions,
  events,
  store,
  scenery
}

class JannatiScreen extends StatefulWidget {
  final ValueNotifier<int?>? tabRequestNotifier;

  const JannatiScreen({super.key, this.tabRequestNotifier});

  @override
  State<JannatiScreen> createState() => _JannatiScreenState();
}

class _JannatiScreenState extends State<JannatiScreen> {
  int _activeTab = 0;

  static const List<({String label, IconData icon})> _tabSpecs = [
    (label: 'يومك مع الخير', icon: Icons.checklist_rounded),
    (label: 'خطة اليوم', icon: Icons.event_note_rounded),
    (label: 'أطلس المعرفة', icon: Icons.menu_book_rounded),
    (label: 'الميثاق والاختبار', icon: Icons.fact_check_outlined),
    (label: 'أسئلة وأجوبة', icon: Icons.question_answer_outlined),
  ];

  @override
  void initState() {
    super.initState();
    widget.tabRequestNotifier?.addListener(_consumeTabRequest);
    _consumeTabRequest();
  }

  void _consumeTabRequest() {
    final notifier = widget.tabRequestNotifier;
    if (notifier == null) return;
    final request = notifier.value;
    if (request != null && request >= 0 && request < _tabSpecs.length) {
      if (mounted) {
        setState(() => _activeTab = request);
      } else {
        _activeTab = request;
      }
      notifier.value = null;
    }
  }

  @override
  void didUpdateWidget(covariant JannatiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabRequestNotifier != widget.tabRequestNotifier) {
      oldWidget.tabRequestNotifier?.removeListener(_consumeTabRequest);
      widget.tabRequestNotifier?.addListener(_consumeTabRequest);
      _consumeTabRequest();
    }
  }

  @override
  void dispose() {
    widget.tabRequestNotifier?.removeListener(_consumeTabRequest);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final jannati = context.watch<JannatiProvider>();
    final user = context.watch<FirdawsUserProvider>();
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: settings.isNightEffective);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: BotanicalBackdrop()),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final horizontal = constraints.maxWidth < 420 ? 14.0 : 22.0;
                final activeBody = _buildActiveTabBody(
                  palette: palette,
                  jannati: jannati,
                  user: user,
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPageHeader(theme.colorScheme, palette),
                          const SizedBox(height: 14),
                          if (!wide) ...[
                            _buildTabsBar(),
                            const SizedBox(height: 14),
                          ],
                          Expanded(
                            child: wide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        width: 224,
                                        child: _buildWideTabsRail(),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(child: activeBody),
                                    ],
                                  )
                                : activeBody,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(ColorScheme scheme, ThemePalette palette) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB99C64).withOpacity(.42)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CalmIconBadge(Icons.spa_outlined, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'جنتي',
                  softWrap: true,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'أعمال اليوم، المعرفة، وخياراتك',
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_JannatiMenuAction>(
            tooltip: 'خيارات إضافية',
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (action) => _handleMenuAction(action, palette),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _JannatiMenuAction.dailyPlan,
                child: Text('خطة الأعمال والاستثمارات'),
              ),
              PopupMenuItem(
                value: _JannatiMenuAction.atlas,
                child: Text('أطلس المعرفة'),
              ),
              PopupMenuItem(
                value: _JannatiMenuAction.covenant,
                child: Text('الميثاق والاختبار'),
              ),
              PopupMenuItem(
                value: _JannatiMenuAction.questions,
                child: Text('موسوعة الأسئلة'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _JannatiMenuAction.events,
                child: Text('المهام والفعاليات'),
              ),
              PopupMenuItem(
                value: _JannatiMenuAction.store,
                child: Text('متجر الحسنات'),
              ),
              PopupMenuItem(
                value: _JannatiMenuAction.scenery,
                child: Text('اختيار خلفية جنتي'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(_JannatiMenuAction action, ThemePalette palette) {
    switch (action) {
      case _JannatiMenuAction.dailyPlan:
        _selectTab(1);
      case _JannatiMenuAction.atlas:
        _selectTab(2);
      case _JannatiMenuAction.covenant:
        _selectTab(3);
      case _JannatiMenuAction.questions:
        _selectTab(4);
      case _JannatiMenuAction.events:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EventsMissionsScreen()),
        );
      case _JannatiMenuAction.store:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const HasanatStoreScreen(
              initialCategory: StoreItemCategory.gardenSkin,
            ),
          ),
        );
      case _JannatiMenuAction.scenery:
        _showJannatiSceneryPicker(palette);
    }
  }

  void _selectTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _activeTab = index);
  }

  Widget _buildTabsBar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(_tabSpecs.length, (index) {
        final tab = _tabSpecs[index];
        return ParadiseChip(
          label: tab.label,
          icon: tab.icon,
          selected: _activeTab == index,
          onTap: () => _selectTab(index),
        );
      }),
    );
  }

  Widget _buildWideTabsRail() {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 12),
          child: Text(
            'مسارات جنتي',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ...List<Widget>.generate(_tabSpecs.length, (index) {
          final tab = _tabSpecs[index];
          final selected = _activeTab == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Semantics(
              button: true,
              selected: selected,
              child: Material(
                color: selected ? scheme.primaryContainer : scheme.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _selectTab(index),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 64),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFB99C64).withOpacity(.74)
                            : const Color(0xFFB99C64).withOpacity(.32),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.icon,
                          size: 21,
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tab.label,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  height: 1.3,
                                ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.check_circle_rounded,
                              color: scheme.primary, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActiveTabBody({
    required ThemePalette palette,
    required JannatiProvider jannati,
    required FirdawsUserProvider user,
  }) {
    switch (_activeTab) {
      case 0:
        return _buildDailyHome(jannati, palette);
      case 1:
        return JannatiArchitectTabView(
          palette: palette,
          jannati: jannati,
          onTapInvestment: (investment) =>
              _handleInvestmentTap(investment, palette),
          onInspectInvestment: (investment) =>
              _inspectInvestmentSheet(investment, jannati, palette),
        );
      case 2:
        return JannatiAtlasTabView(palette: palette);
      case 3:
        return JannatiCovenantAndQuizTabView(
          palette: palette,
          jannati: jannati,
          user: user,
        );
      case 4:
      default:
        return IslamicQaExplorerWidget(
          palette: palette,
          initialCategory: IslamicQaCategory.jannah,
          headerTitle: 'معرفة نافعة عن الجنة',
          headerSubtitle: 'تصفّح الأسئلة أو ابحث عمّا تريد معرفته.',
        );
    }
  }

  Widget _buildDailyHome(JannatiProvider jannati, ThemePalette palette) {
    final settings = context.watch<SettingsProvider>();
    final themeScene =
        Theme.of(context).extension<FirdawsNatureLook>()?.sceneryAsset;
    final sceneryAsset = settings.selectedGardenWallpaperAsset ??
        (settings.selectedJannatiSceneryIndex == 0
            ? themeScene ??
                (settings.isNightEffective
                    ? 'assets/images/garden/garden_night_starlight.jpg'
                    : settings.activeJannatiScenery.fallbackAsset)
            : settings.activeJannatiScenery.fallbackAsset);
    const actions = JannatiCatalog.dailyArchitectChecklist;
    final checkedIds = jannati.dailyCheckedIds;
    final checkedCount =
        actions.where((action) => checkedIds.contains(action.id)).length;
    final remainingCount = actions.length - checkedCount;
    final progress = actions.isEmpty ? 0.0 : checkedCount / actions.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        return ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            ParadiseHero(
              title: 'يومك، خطوةً خطوة',
              subtitle: 'تابع ما أنجزته واختر من قائمتك ما يلائم وقتك.',
              imageAsset: sceneryAsset,
              minHeight: wide ? 276 : 248,
              footer: Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  FilledButton.icon(
                    onPressed: () => _selectTab(1),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E8C8),
                      foregroundColor: const Color(0xFF17382C),
                      minimumSize: const Size(44, 46),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    icon: const Icon(Icons.event_note_rounded),
                    label: const Text('فتح خطة اليوم'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showJannatiSceneryPicker(palette),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(.82)),
                      minimumSize: const Size(44, 46),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    icon: const Icon(Icons.landscape_outlined),
                    label: const Text('تغيير المشهد'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildDailySummary(
              actionCount: actions.length,
              checkedCount: checkedCount,
              remainingCount: remainingCount,
              progress: progress,
            ),
            const SizedBox(height: 24),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildDailyChecklist(actions, checkedIds),
                  ),
                  const SizedBox(width: 18),
                  Expanded(child: _buildDiscoverySection()),
                ],
              )
            else ...[
              _buildDailyChecklist(actions, checkedIds),
              const SizedBox(height: 24),
              _buildDiscoverySection(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDailySummary({
    required int actionCount,
    required int checkedCount,
    required int remainingCount,
    required double progress,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = actionCount == 0
        ? 'لا توجد عناصر في القائمة الآن.'
        : remainingCount == 0
            ? 'اكتملت قائمة اليوم.'
            : checkedCount == 0
                ? 'ابدأ بعنصر واحد يناسب وقتك.'
                : 'بقي $remainingCount من عناصر القائمة.';

    return CalmCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخّص اليوم',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$checkedCount من $actionCount أعمال أُنجزت',
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: scheme.primary,
                      semanticsLabel: 'نسبة إنجاز قائمة اليوم',
                    ),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${(progress * 100).round()}٪',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
              semanticsLabel: 'التقدم في أعمال اليوم',
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ParadiseChip(
                label: '$checkedCount مكتمل',
                icon: Icons.check_circle_outline_rounded,
              ),
              ParadiseChip(
                label: '$remainingCount متبقٍ',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'اختر ما تيسّر لك؛ يُحفظ إنجازك لهذا اليوم على جهازك.',
            softWrap: true,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChecklist(
    List<DailyJannahAction> actions,
    Iterable<String> checkedIds,
  ) {
    return ParadiseSection(
      title: 'خطوات اليوم',
      action: TextButton.icon(
        onPressed: () => _selectTab(1),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('خطة أوسع'),
      ),
      child: actions.isEmpty
          ? const CalmEmptyState(
              icon: Icons.checklist_rounded,
              title: 'لا توجد خطوات معروضة',
              subtitle: 'يمكنك الانتقال إلى خطة اليوم لمراجعة التفاصيل.',
            )
          : CalmCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List<Widget>.generate(actions.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    return Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    );
                  }
                  final action = actions[index ~/ 2];
                  return _buildDailyActionRow(
                    action,
                    checkedIds.contains(action.id),
                  );
                }),
              ),
            ),
    );
  }

  Widget _buildDailyActionRow(DailyJannahAction action, bool isDone) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDailyAction(action.id),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 8, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CalmIconBadge(action.icon, size: 42),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        softWrap: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: isDone ? scheme.onSurfaceVariant : null,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [action.timeWindow, action.rewardPromise]
                            .map(
                              (detail) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  detail,
                                  softWrap: true,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Checkbox.adaptive(
                  value: isDone,
                  onChanged: (_) => _toggleDailyAction(action.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverySection() {
    return ParadiseSection(
      title: 'استكشف جنتي',
      child: Column(
        children: [
          _buildKnowledgeLink(
            icon: Icons.menu_book_outlined,
            title: 'أبواب الجنة ودرجاتها',
            subtitle: 'تصفّح الموضوعات في أطلس المعرفة.',
            onTap: () => _selectTab(2),
          ),
          const SizedBox(height: 9),
          _buildKnowledgeLink(
            icon: Icons.fact_check_outlined,
            title: 'ميثاقك واختبار قصير',
            subtitle: 'راجع ما أعددته وتابع اختبار المعرفة.',
            onTap: () => _selectTab(3),
          ),
          const SizedBox(height: 9),
          _buildKnowledgeLink(
            icon: Icons.question_answer_outlined,
            title: 'ابحث في الأسئلة والأجوبة',
            subtitle: 'موسوعة منظّمة للقراءة والبحث.',
            onTap: () => _selectTab(4),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CalmCard(
      padding: EdgeInsets.zero,
      child: CalmActionTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      ),
    );
  }

  Future<void> _toggleDailyAction(String actionId) async {
    HapticFeedback.selectionClick();
    await context.read<JannatiProvider>().toggleDailyAction(actionId);
  }

  Future<void> _handleInvestmentTap(
    JannahInvestment investment,
    ThemePalette palette,
  ) async {
    final jannati = context.read<JannatiProvider>();
    final user = context.read<FirdawsUserProvider>();
    final outcome = await jannati.performInvestmentTap(investment.id);
    if (!mounted) return;

    try {
      context.read<HoorCompanionProvider>().onJannahDeedPerformed(
            deedTitle: investment.shortLabel,
            userName: user.displayName,
            isFemale: user.isFemale,
          );
    } catch (_) {}

    try {
      final hasanat = context.read<HasanatProvider>();
      final delta = outcome.completedCycle
          ? investment.pointsPerCompletion.clamp(6, 40)
          : investment.pointsPerTap.clamp(2, 12);
      hasanat.earnHasanat(
        delta,
        reason: 'غراس جنتي: ${investment.shortLabel}',
        sourceTag: 'جنتي',
      );
      hasanat.recordMetric(EventMissionMetric.jannahDeedsCount, delta: 1);
    } catch (_) {}

    if (outcome.completedCycle) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    _showToast(
      outcome.completedCycle
          ? 'تم تسجيل العمل، تقبّل الله منك.'
          : 'حُفظ تقدمك في هذا العمل.',
      palette,
    );

    if (outcome.promotedToRank != null && mounted) {
      HapticFeedback.heavyImpact();
      await _showProgressDialog(outcome.promotedToRank!, palette);
    }
  }

  Future<void> _showProgressDialog(
    JannahRankTier rank,
    ThemePalette palette,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: CalmIconBadge(rank.icon, size: 52),
        title: const Text('تقدّم في سجلّ أعمالك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rank.arabicTitle,
              style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(rank.arabicSubtitle, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, ThemePalette palette) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: palette.cardColor,
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: TextStyle(color: palette.textPrimary),
          ),
        ),
      );
  }

  void _inspectInvestmentSheet(
    JannahInvestment investment,
    JannatiProvider jannati,
    ThemePalette palette,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.82,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CalmIconBadge(investment.icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      investment.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CalmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(investment.dhikrOrAction,
                        style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 14),
                    Text(
                      '${investment.exactHadith}\n${investment.sourceReference}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    SacredEvidenceFooter(
                      evidenceText:
                          '${investment.exactHadith}\n${investment.sourceReference}',
                      titleForHadith: investment.title,
                      hadithVerbatim: investment.exactHadith,
                      trackInJannati: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CalmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المعنى والأثر', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(investment.paradiseDescription),
                    const SizedBox(height: 12),
                    Text(
                      'المحفوظ: ${jannati.countFor(investment.id)} ${investment.unitPlural}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (investment.cycleTarget > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'التقدم الحالي: ${jannati.cycleProgressFor(investment.id)} من ${investment.cycleTarget}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _handleInvestmentTap(investment, palette);
                },
                icon: Icon(investment.icon),
                label: const Text('تسجيل هذا العمل'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showJannatiSceneryPicker(ThemePalette palette) async {
    var query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        final settings = context.read<SettingsProvider>();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final matchingIndices = List<int>.generate(
              Background500Catalog.jannati100.length,
              (index) => index,
            ).where((index) {
              final entry = Background500Catalog.jannati100[index];
              return query.isEmpty ||
                  entry.title.contains(query) ||
                  '${index + 1}' == query;
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.78,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('اختيار خلفية جنتي'),
                      subtitle: const Text('يمكنك تغيير اختيارك في أي وقت.'),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Wallpaper70PickerSheet.show(
                            this.context,
                            initialTarget: WallpaperTarget.garden,
                          );
                        },
                        child: const Text('خلفيات إضافية'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextField(
                        onChanged: (value) =>
                            setSheetState(() => query = value.trim()),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'ابحث بالاسم أو الرقم',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: matchingIndices.length,
                        itemBuilder: (context, index) {
                          final sceneryIndex = matchingIndices[index];
                          final entry =
                              Background500Catalog.jannati100[sceneryIndex];
                          final selected =
                              settings.selectedJannatiSceneryIndex ==
                                      sceneryIndex &&
                                  settings.selectedGardenWallpaperAsset == null;
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${sceneryIndex + 1}'),
                            ),
                            title: Text(entry.title),
                            trailing: selected
                                ? const Icon(Icons.check_rounded)
                                : null,
                            selected: selected,
                            onTap: () {
                              settings.setJannatiSceneryIndex(sceneryIndex);
                              Navigator.pop(sheetContext);
                              _showToast('تم تحديث اختيار الخلفية.', palette);
                            },
                          );
                        },
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
}
