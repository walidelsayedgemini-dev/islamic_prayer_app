import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/arena_games_catalog.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/events_missions_catalog.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/paradise_ui.dart';
import 'arena_game_play_screen.dart';
import 'hasanat_store_screen.dart';

/// شاشة «المهام والأحداث الخاصة»:
/// - إنجاز 16 مهمة لربح الحسنات وفتح 8 أحداث مضاعفة للحسنات والكنوز داخل الألعاب الـ 30!
class EventsMissionsScreen extends StatefulWidget {
  final int initialTab; // 0: المهام، 1: الأحداث

  const EventsMissionsScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<EventsMissionsScreen> createState() => _EventsMissionsScreenState();
}

class _EventsMissionsScreenState extends State<EventsMissionsScreen> {
  late int _activeView; // 0 = كلاهما / المهام ثم الأحداث

  @override
  void initState() {
    super.initState();
    _activeView = widget.initialTab;
  }

  Future<void> _onClaimMission(
    HasanatMissionSpec mission,
    HasanatProvider hasanat,
    ThemePalette palette,
  ) async {
    HapticFeedback.heavyImpact();
    final res = await hasanat.claimMission(mission.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: firdaws3DSurfaceColor(palette),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: res.success ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            width: 1.5,
          ),
        ),
        content: Text(
          res.message,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: FirdawsType.label,
          ),
        ),
      ),
    );
  }

  Future<void> _launchEventGame(
    UnlockableGameEvent event,
    HasanatProvider hasanat,
  ) async {
    await hasanat.activateEvent(event.id);
    if (!mounted) return;
    final game = ArenaGamesCatalog.byId(event.recommendedGameId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArenaGamePlayScreen(game: game),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final hasanat = context.watch<HasanatProvider>();
    final palette = settings.currentPalette;
    final accent = firdawsModernAccent(palette);
    final activeEv = hasanat.activeEvent;
    final pageGutter = MediaQuery.sizeOf(context).width < 440 ? 16.0 : 28.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.scaffoldColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, palette, accent, hasanat),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        pageGutter,
                        10,
                        pageGutter,
                        36,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildActiveEventHero(
                                  palette,
                                  accent,
                                  hasanat,
                                  activeEv,
                                ),
                                const SizedBox(height: 22),
                                _sectionTitle(
                                  'نظرة على تقدمك',
                                  Icons.insights_rounded,
                                  accent,
                                  palette,
                                ),
                                const SizedBox(height: 12),
                                _buildOverview(hasanat, palette),
                                const SizedBox(height: 22),
                                _buildViewToggle(palette, accent, hasanat),
                                const SizedBox(height: 26),
                                if (_activeView == 0) ...[
                                  ParadiseSection(
                                    title: 'مسار المهام',
                                    action: _sectionCount(
                                      '${EventsMissionsCatalog.missions.length} مهمة',
                                      Icons.flag_outlined,
                                      palette,
                                    ),
                                    child: _buildCatalogGrid<HasanatMissionSpec>(
                                      EventsMissionsCatalog.missions,
                                      palette,
                                      emptyTitle: 'لا توجد مهام حالياً',
                                      emptyDescription:
                                          'ستظهر هنا المهام المتاحة لمتابعة تقدمك.',
                                      itemBuilder: (mission, index) =>
                                          _buildMissionCard(
                                        mission,
                                        hasanat,
                                        palette,
                                        missionIndex: index,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  ParadiseSection(
                                    title: 'أحداث الألعاب',
                                    action: _sectionCount(
                                      '${EventsMissionsCatalog.events.length} أحداث',
                                      Icons.bolt_rounded,
                                      palette,
                                    ),
                                    child: _buildCatalogGrid<UnlockableGameEvent>(
                                      EventsMissionsCatalog.events,
                                      palette,
                                      emptyTitle: 'لا توجد أحداث متاحة',
                                      emptyDescription:
                                          'عند توفر أحداث جديدة ستجد تفاصيلها هنا.',
                                      itemBuilder: (event, index) =>
                                          _buildEventCard(
                                        event,
                                        hasanat,
                                        palette,
                                        eventIndex: index,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  ParadiseSection(
                                    title: 'بوابات الأحداث',
                                    action: _sectionCount(
                                      '${hasanat.unlockedEventIds.length} من ${EventsMissionsCatalog.events.length} مفتوحة',
                                      Icons.bolt_rounded,
                                      palette,
                                    ),
                                    child: _buildCatalogGrid<UnlockableGameEvent>(
                                      EventsMissionsCatalog.events,
                                      palette,
                                      emptyTitle: 'لا توجد أحداث متاحة',
                                      emptyDescription:
                                          'عند توفر أحداث جديدة ستجد تفاصيلها هنا.',
                                      itemBuilder: (event, index) =>
                                          _buildEventCard(
                                        event,
                                        hasanat,
                                        palette,
                                        eventIndex: index,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  ParadiseSection(
                                    title: 'المهام التي تفتح الطريق',
                                    action: _sectionCount(
                                      '${hasanat.claimedMissionIds.length} من ${EventsMissionsCatalog.missions.length} مكتملة',
                                      Icons.task_alt_rounded,
                                      palette,
                                    ),
                                    child: _buildCatalogGrid<HasanatMissionSpec>(
                                      EventsMissionsCatalog.missions,
                                      palette,
                                      emptyTitle: 'لا توجد مهام حالياً',
                                      emptyDescription:
                                          'ستظهر هنا المهام المتاحة لمتابعة تقدمك.',
                                      itemBuilder: (mission, index) =>
                                          _buildMissionCard(
                                        mission,
                                        hasanat,
                                        palette,
                                        missionIndex: index,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    ThemePalette palette,
    Color accent,
    HasanatProvider hasanat,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_forward_rounded, color: palette.textPrimary),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: palette.cardColor,
              side: BorderSide(color: palette.dividerColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'المهمات والأحداث',
              softWrap: true,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'فتح متجر الحسنات، الرصيد ${hasanat.hasanatBalance}',
            child: SizedBox(
              height: 48,
              child: Firdaws3DPill(
                icon: Icons.savings_outlined,
                label: '${hasanat.hasanatBalance}',
                accentColor: const Color(0xFFB4862F),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HasanatStoreScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEventHero(
    ThemePalette palette,
    Color accent,
    HasanatProvider hasanat,
    UnlockableGameEvent? activeEv,
  ) {
    if (activeEv == null) {
      return ParadiseHero(
        title: 'كل خطوة تفتح باباً جديداً',
        subtitle:
            'تابع تقدمك في المهام، وافتح أحداثاً خاصة داخل الألعاب الثلاثين. اختر مسارك وابدأ من حيث أنت.',
        minHeight: 248,
        footer: Wrap(
          spacing: 9,
          runSpacing: 9,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _heroPill(
              '${hasanat.claimableMissionsCount} مهام جاهزة',
              Icons.task_alt_rounded,
            ),
            _heroPill(
              '${hasanat.unlockedEventIds.length} من ${EventsMissionsCatalog.events.length} أحداث مفتوحة',
              Icons.lock_open_rounded,
            ),
            FilledButton.icon(
              onPressed: () => setState(() => _activeView = 1),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('اكتشف الأحداث', softWrap: true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF2D79A),
                foregroundColor: const Color(0xFF18372A),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final eventInk = ThemeData.estimateBrightnessForColor(activeEv.primaryColor) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF17251E);
    return ParadiseHero(
      title: activeEv.title,
      subtitle: activeEv.ruleDescription,
      minHeight: 248,
      footer: Wrap(
        spacing: 9,
        runSpacing: 9,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _heroPill('الحدث النشط', Icons.bolt_rounded),
          _heroPill('×${activeEv.hasanatMultiplier}', Icons.trending_up_rounded),
          Firdaws3DButton(
            baseColor: activeEv.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onPressed: () => _launchEventGame(activeEv, hasanat),
            child: Text(
              'ابدأ لعبة الحدث',
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: eventInk,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => hasanat.activateEvent(null),
            icon: const Icon(Icons.pause_circle_outline_rounded),
            label: const Text('إيقاف الحدث', softWrap: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(.7)),
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPill(String label, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.42)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFF2D79A)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(HasanatProvider hasanat, ThemePalette palette) {
    final metrics = [
      (
        '${hasanat.claimedMissionIds.length}/${EventsMissionsCatalog.missions.length}',
        'مهام مكتملة',
        Icons.task_alt_rounded,
      ),
      (
        '${hasanat.claimableMissionsCount}',
        'جاهزة للاستلام',
        Icons.redeem_rounded,
      ),
      (
        '${hasanat.unlockedEventIds.length}/${EventsMissionsCatalog.events.length}',
        'أحداث مفتوحة',
        Icons.lock_open_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700
            ? 3
            : (constraints.maxWidth < 340 ? 1 : 2);
        const spacing = 10.0;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: _overviewMetric(
                  metric.$1,
                  metric.$2,
                  metric.$3,
                  palette,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _overviewMetric(
    String value,
    String label,
    IconData icon,
    ThemePalette palette,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.accentColor.withOpacity(.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: palette.accentColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: FirdawsType.caption,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(
    ThemePalette palette,
    Color accent,
    HasanatProvider hasanat,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _viewTab(
              title: 'المهام',
              detail: '${hasanat.claimableMissionsCount} جاهزة',
              icon: Icons.flag_outlined,
              selected: _activeView == 0,
              selectedColor: accent,
              palette: palette,
              onTap: () => setState(() => _activeView = 0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _viewTab(
              title: 'الأحداث',
              detail:
                  '${hasanat.unlockedEventIds.length} / ${EventsMissionsCatalog.events.length} مفتوحة',
              icon: Icons.bolt_rounded,
              selected: _activeView == 1,
              selectedColor: const Color(0xFFAE7B22),
              palette: palette,
              onTap: () => setState(() => _activeView = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewTab({
    required String title,
    required String detail,
    required IconData icon,
    required bool selected,
    required Color selectedColor,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final foreground = selected ? Colors.white : palette.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 62),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Icon(icon, size: 18, color: foreground),
                      Text(
                        title,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foreground.withOpacity(selected ? .92 : .76),
                      fontSize: FirdawsType.micro,
                      height: 1.2,
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

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
    ThemePalette palette,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: FirdawsType.label,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCount(String label, IconData icon, ThemePalette palette) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Icon(icon, size: 16, color: palette.accentColor),
          Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.caption,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogGrid<T>(
    List<T> items,
    ThemePalette palette, {
    required String emptyTitle,
    required String emptyDescription,
    required Widget Function(T item, int index) itemBuilder,
  }) {
    if (items.isEmpty) {
      return _emptyCatalogState(emptyTitle, emptyDescription, palette);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        const gap = 16.0;
        final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: itemWidth,
                child: itemBuilder(items[index], index),
              ),
          ],
        );
      },
    );
  }

  Widget _emptyCatalogState(
    String title,
    String description,
    ThemePalette palette,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.inbox_outlined, color: palette.accentColor, size: 25),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
    HasanatMissionSpec m,
    HasanatProvider hasanat,
    ThemePalette palette, {
    int missionIndex = 0,
  }) {
    final prog = hasanat.missionProgressValue(m);
    final ratio = (prog / m.targetValue).clamp(0.0, 1.0);
    final ready = hasanat.isMissionReadyToClaim(m);
    final claimed = hasanat.claimedMissionIds.contains(m.id);
    final unlocksEv = m.unlocksEventId != null
        ? EventsMissionsCatalog.eventById(m.unlocksEventId)
        : null;
    final statusColor = claimed
        ? const Color(0xFF168557)
        : (ready ? const Color(0xFFAE7B22) : m.accentColor);
    final statusLabel = claimed
        ? 'مكتملة'
        : (ready ? 'جاهزة للاستلام' : 'قيد التقدم');

    return Firdaws3DCard(
      palette: palette,
      glowColor: statusColor,
      padding: const EdgeInsets.all(19),
      borderRadius: 25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: m.accentColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: m.accentColor.withOpacity(.28)),
                ),
                child: Icon(m.icon, color: m.accentColor, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.title,
                        softWrap: true,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: FirdawsType.label,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _statusBadge(statusLabel, statusColor, palette),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            m.description,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.caption,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'التقدم الحالي',
                        softWrap: true,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: FirdawsType.caption,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$prog من ${m.targetValue} ${m.metric.unitLabel}',
                        textAlign: TextAlign.end,
                        softWrap: true,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: FirdawsType.caption,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 9,
                    backgroundColor: palette.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      claimed ? const Color(0xFF168557) : m.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _detailPill(
                'مكافأة: +${m.hasanatReward} حسنة',
                Icons.savings_outlined,
                const Color(0xFFAE7B22),
                palette,
              ),
              if (missionIndex >= 0)
                _detailPill(
                  'المهمة ${missionIndex + 1}',
                  Icons.route_outlined,
                  palette.accentColor,
                  palette,
                ),
            ],
          ),
          if (unlocksEv != null) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: unlocksEv.primaryColor.withOpacity(.09),
                borderRadius: BorderRadius.circular(15),
                border: BorderDirectional(
                  start: BorderSide(color: unlocksEv.primaryColor, width: 3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_open_rounded,
                      size: 18, color: unlocksEv.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تفتح حدث: ${unlocksEv.title}',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: FirdawsType.caption,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (ready || claimed) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: Firdaws3DButton(
                baseColor:
                    claimed ? const Color(0xFF17684B) : const Color(0xFFAE7B22),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                elevationDepth: claimed ? 1 : 3.5,
                onPressed:
                    claimed ? null : () => _onClaimMission(m, hasanat, palette),
                child: Text(
                  claimed
                      ? 'تم استلام الجائزة'
                      : (unlocksEv != null
                          ? 'استلام الجائزة وفتح الحدث'
                          : 'استلام +${m.hasanatReward} حسنة'),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: FirdawsType.caption,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(
    UnlockableGameEvent ev,
    HasanatProvider hasanat,
    ThemePalette palette, {
    int eventIndex = 0,
  }) {
    final unlocked = hasanat.isEventUnlocked(ev.id);
    final isActive = hasanat.activeEventId == ev.id;
    final reqMission = EventsMissionsCatalog.missionById(ev.requiredMissionId);
    final evBackdrop = Background500Catalog.forEventItem(2 + (eventIndex % 16));
    final statusColor = isActive
        ? const Color(0xFF168557)
        : (unlocked ? const Color(0xFF168557) : palette.textMuted);

    return Firdaws3DCard(
      palette: palette,
      glowColor: statusColor,
      padding: EdgeInsets.zero,
      borderRadius: 25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FirdawsResilientImage(
                    networkUrl: evBackdrop.url,
                    fallbackAsset: ev.backdropAsset,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x46000000),
                          Color(0x08000000),
                          Color(0xE6000000),
                        ],
                        stops: [0, .38, 1],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: _statusBadge(
                      isActive
                          ? 'مفعّل الآن'
                          : (unlocked ? 'مفتوح' : 'مقفل'),
                      statusColor,
                      palette,
                      onDark: true,
                    ),
                  ),
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 38),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ev.primaryColor.withOpacity(.94),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '×${ev.hasanatMultiplier}',
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 15,
                    end: 15,
                    bottom: 13,
                    child: Text(
                      ev.title,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: FirdawsType.body,
                        height: 1.25,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ev.subtitle,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: FirdawsType.caption,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: palette.elevatedCardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    ev.ruleDescription,
                    softWrap: true,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: FirdawsType.caption,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (unlocked)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonWidth = constraints.maxWidth < 360
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 8) / 2;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: buttonWidth,
                            child: Firdaws3DButton(
                              baseColor: isActive
                                  ? const Color(0xFF168557)
                                  : ev.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 11),
                              onPressed: () async {
                                await hasanat.activateEvent(isActive ? null : ev.id);
                              },
                              child: Text(
                                isActive ? 'إيقاف الحدث' : 'تفعيل الحدث',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: FirdawsType.caption,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: Firdaws3DButton(
                              baseColor: const Color(0xFF304F78),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 11),
                              onPressed: () => _launchEventGame(ev, hasanat),
                              child: const Text(
                                'العب الآن',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: FirdawsType.caption,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: palette.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: palette.dividerColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 19, color: palette.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لفتح الحدث، أكمل مهمة: ${reqMission?.title ?? ev.requiredMissionId}',
                            softWrap: true,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: FirdawsType.caption,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(
    String label,
    Color color,
    ThemePalette palette, {
    bool onDark = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onDark ? color.withOpacity(.92) : color.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: onDark ? Colors.white.withOpacity(.28) : color.withOpacity(.3),
        ),
      ),
      child: Text(
        label,
        softWrap: true,
        style: TextStyle(
          color: onDark ? Colors.white : color,
          fontWeight: FontWeight.w700,
          fontSize: FirdawsType.micro,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _detailPill(
    String label,
    IconData icon,
    Color accent,
    ThemePalette palette,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: accent.withOpacity(.22)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Icon(icon, size: 16, color: accent),
          Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.caption,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
