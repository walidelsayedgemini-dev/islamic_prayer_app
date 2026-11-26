import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_home_screen.dart';
import 'firdaws_journey_screen.dart';
import 'qibla_screen.dart';
import 'calendar_screen.dart';
import 'tasbih_screen.dart';
import 'jannati_screen.dart';
import 'help_me_screen.dart';
import 'settings_screen.dart';
import 'quran_azkar_sheet.dart';
import 'islamic_books_sheet.dart';
import 'islamic_stories_screen.dart';
import 'sahih_hadith_screen.dart';
import 'about_me_screen.dart';
import 'family_challenge_screen.dart';
import 'events_missions_screen.dart';
import 'arena_hub_screen.dart';
import 'hasanat_store_screen.dart';
import 'prayer_stats_screen.dart';
import 'backup_screen.dart';
import '../providers/hoor_companion_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/calm_ui.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/calm_page_transition.dart';
import '../services/notification_service.dart';

/// Existing index contract is preserved for content links and prayer-log actions.
class FirdawsNavBridge {
  static void Function(int pageIndex,
      {int? journeyTab,
      DateTime? journeyDate,
      int? jannatiTab,
      bool? openHelpQa})? _navigator;
  static void jumpTo(int pageIndex,
          {int? journeyTab,
          DateTime? journeyDate,
          int? jannatiTab,
          bool? openHelpQa}) =>
      _navigator?.call(pageIndex,
          journeyTab: journeyTab,
          journeyDate: journeyDate,
          jannatiTab: jannatiTab,
          openHelpQa: openHelpQa);
}

class FirdawsDestination {
  final int index;
  final String label;
  final IconData icon;
  const FirdawsDestination(this.index, this.label, this.icon);
}

const firdawsDestinations = [
  FirdawsDestination(0, 'اليوم', Icons.wb_sunny_outlined),
  FirdawsDestination(2, 'القبلة', Icons.explore_outlined),
  FirdawsDestination(4, 'السبحة', Icons.touch_app_outlined),
  FirdawsDestination(9, 'المكتبة', Icons.menu_book_outlined),
  FirdawsDestination(1, 'السجل', Icons.fact_check_outlined),
  FirdawsDestination(3, 'التقويم', Icons.calendar_month_outlined),
  FirdawsDestination(5, 'جنتي', Icons.eco_outlined),
  FirdawsDestination(6, 'سكينة', Icons.favorite_outline_rounded),
  FirdawsDestination(8, 'المزيد', Icons.apps_rounded),
  FirdawsDestination(7, 'الإعدادات', Icons.tune_rounded),
];

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final ValueNotifier<FirdawsJourneyRequest?> _journeyRequest =
      ValueNotifier(null);
  final ValueNotifier<int?> _jannatiTabRequest = ValueNotifier(null);
  final ValueNotifier<bool?> _helpQaRequest = ValueNotifier(null);
  final Map<int, Widget> _loadedPages = {};

  @override
  void initState() {
    super.initState();
    FirdawsNavBridge._navigator = _navigateFromExternal;
    NotificationService().setNavigationHandler(_navigateFromExternal);
    _loadedPages[0] = const PrayerHomeScreen();
  }

  Widget _createPage(int index) => switch (index) {
        0 => const PrayerHomeScreen(),
        1 => FirdawsJourneyScreen(requestNotifier: _journeyRequest),
        2 => const QiblaScreen(),
        3 => const CalendarScreen(),
        4 => const TasbihScreen(),
        5 => JannatiScreen(tabRequestNotifier: _jannatiTabRequest),
        6 => HelpMeScreen(openQaNotifier: _helpQaRequest),
        7 => SettingsScreen(onNavigate: _onTabTapped),
        8 => FirdawsMorePage(onNavigate: _onTabTapped),
        9 => const FirdawsLibraryPage(),
        _ => const SizedBox.shrink(),
      };

  void _navigateFromExternal(int pageIndex,
      {int? journeyTab,
      DateTime? journeyDate,
      int? jannatiTab,
      bool? openHelpQa}) {
    if (!mounted || pageIndex < 0 || pageIndex > 9) return;
    if (journeyTab != null || journeyDate != null) {
      _journeyRequest.value = FirdawsJourneyRequest(
          tabIndex: journeyTab ?? 0, selectedDate: journeyDate);
    }
    if (jannatiTab != null) {
      _jannatiTabRequest.value = null;
      _jannatiTabRequest.value = jannatiTab;
    }
    if (openHelpQa != null) {
      _helpQaRequest.value = null;
      _helpQaRequest.value = openHelpQa;
    }
    _onTabTapped(pageIndex);
  }

  void _onTabTapped(int index) {
    if (!mounted || index < 0 || index > 9) return;
    setState(() {
      _loadedPages.putIfAbsent(index, () => _createPage(index));
      _currentIndex = index;
    });
    const routeKeys = [
      'prayer_home',
      'journey',
      'qibla',
      'calendar',
      'tasbih',
      'jannati',
      'help_me',
      'settings',
      'more',
      'library'
    ];
    try {
      context
          .read<HoorCompanionProvider>()
          .setActiveScreenRoute(routeKeys[index]);
    } catch (_) {/* The optional companion does not own core navigation. */}
  }

  @override
  void dispose() {
    if (FirdawsNavBridge._navigator == _navigateFromExternal) {
      FirdawsNavBridge._navigator = null;
      NotificationService().setNavigationHandler(null);
    }
    _journeyRequest.dispose();
    _jannatiTabRequest.dispose();
    _helpQaRequest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;
        final pages = CalmPageTransition(
          pageIndex: _currentIndex,
          child: IndexedStack(
              index: _currentIndex,
              sizing: StackFit.expand,
              children: List.generate(
                  10,
                  (index) => TickerMode(
                      enabled: index == _currentIndex,
                      child: _loadedPages[index] ?? const SizedBox.shrink()))),
        );
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: desktop
              ? Row(children: [
                  SizedBox(
                      width: 276,
                      child: FirdawsSidebar(
                          selectedIndex: _currentIndex,
                          onNavigate: _onTabTapped)),
                  VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor),
                  Expanded(child: ClipRect(child: pages)),
                ])
              : pages,
          bottomNavigationBar: desktop
              ? null
              : FirdawsBottomNavigation(
                  selectedIndex: _currentIndex, onNavigate: _onTabTapped),
        );
      });
}

class FirdawsBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  const FirdawsBottomNavigation(
      {super.key, required this.selectedIndex, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    const indices = [0, 2, 4, 9, 8];
    final scheme = Theme.of(context).colorScheme;
    final selectedNavigationIndex =
        indices.contains(selectedIndex) ? selectedIndex : 8;
    return SafeArea(
      top: false,
      child: Material(
        color: scheme.surface,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 5, 8, 6),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: const Color(0xFFB99C64).withOpacity(.42)),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(.055),
                blurRadius: 16,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: indices.map((index) {
              final destination =
                  firdawsDestinations.firstWhere((item) => item.index == index);
              return Expanded(
                child: _BottomDestinationButton(
                  destination: destination,
                  selected: selectedNavigationIndex == index,
                  onTap: () => onNavigate(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _BottomDestinationButton extends StatelessWidget {
  final FirdawsDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _BottomDestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        excludeFromSemantics: true,
        borderRadius: BorderRadius.circular(17),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 62),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: MediaQuery.of(context).disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        selected ? scheme.primaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: selected
                        ? Border.all(
                            color: const Color(0xFFB99C64).withOpacity(.38))
                        : null,
                  ),
                  child: Icon(destination.icon, size: 21, color: foreground),
                ),
                const SizedBox(height: 2),
                Text(
                  destination.label,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontSize: 11,
                        height: 1.18,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FirdawsSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  const FirdawsSidebar(
      {super.key, required this.selectedIndex, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(13, 14, 13, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onNavigate(0),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 5, 6, 12),
                    child: Row(
                      children: [
                        const FirdawsBrandLogo(size: 46),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الفردوس',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'العبادة والمعرفة في مكان واحد',
                                softWrap: true,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const NatureSceneryStrip(height: 116, caption: 'مساحتك اليومية'),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 18, 10, 8),
                child: _SidebarSectionLabel('مساراتك'),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final index in const [0, 2, 4, 9])
                      _SidebarDestinationTile(
                        destination: firdawsDestinations
                            .firstWhere((item) => item.index == index),
                        selected: selectedIndex == index,
                        onTap: () => onNavigate(index),
                      ),
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 18, 10, 8),
                      child: _SidebarSectionLabel('متابعة واكتشاف'),
                    ),
                    for (final index in const [1, 3, 5, 6, 8, 7])
                      _SidebarDestinationTile(
                        destination: firdawsDestinations
                            .firstWhere((item) => item.index == index),
                        selected: selectedIndex == index,
                        onTap: () => onNavigate(index),
                      ),
                  ],
                ),
              ),
              const Divider(height: 19),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(9, 0, 9, 1),
                child: Text(
                  'كل وجهة قريبة، واختر ما يناسب يومك.',
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  final String text;
  const _SidebarSectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        softWrap: true,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: .15,
            ),
      );
}

class _SidebarDestinationTile extends StatelessWidget {
  final FirdawsDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarDestinationTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: selected
                ? const Color(0xFFB99C64).withOpacity(.55)
                : Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 9, 10, 9),
            child: Row(
              children: [
                Icon(
                  destination.icon,
                  size: 21,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    softWrap: true,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selected ? scheme.primary : scheme.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.28,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: scheme.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FirdawsLibraryPage extends StatelessWidget {
  const FirdawsLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    void open(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));

    return _DiscoveryScaffold(
      maxWidth: 1120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ParadiseHero(
            title: 'اختر بوابتك إلى المعرفة',
            subtitle: 'مساحة منظّمة للقراءة والذكر والتعلّم، كلٌّ في وجهته.',
            minHeight: 284,
            footer: FilledButton.icon(
              onPressed: () => QuranAzkarSheet.showQuranReader(context, accent),
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFF173429),
                backgroundColor: const Color(0xFFF1E5C8),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsetsDirectional.fromSTEB(18, 11, 20, 11),
              ),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('ابدأ بالمصحف'),
            ),
          ),
          const SizedBox(height: 27),
          ParadiseSection(
            title: 'محطة القراءة',
            child: _QuranEntryPanel(
              onOpen: () => QuranAzkarSheet.showQuranReader(context, accent),
            ),
          ),
          const SizedBox(height: 27),
          ParadiseSection(
            title: 'بوابات المكتبة',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 2 : 1;
                final cardWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 14) / columns;
                final doors = [
                  _LibraryDoorData(
                    icon: Icons.wb_twilight_outlined,
                    title: 'الأذكار والأدعية',
                    subtitle: 'أذكار الصباح والمساء وأدعية يومك.',
                    onTap: () =>
                        QuranAzkarSheet.showAzkarReader(context, accent),
                  ),
                  _LibraryDoorData(
                    icon: Icons.library_books_outlined,
                    title: 'الحديث الصحيح',
                    subtitle: 'أحاديث مرتبة مع شروحها ومصادرها.',
                    onTap: () => open(const SahihHadithScreen()),
                  ),
                  _LibraryDoorData(
                    icon: Icons.auto_stories_outlined,
                    title: 'القصص الإسلامية',
                    subtitle: 'قصص ومواقف للتأمل في معانيها.',
                    onTap: () => open(const IslamicStoriesScreen()),
                  ),
                  _LibraryDoorData(
                    icon: Icons.book_outlined,
                    title: 'الكتب الإسلامية',
                    subtitle: 'تصفّح الكتب المتاحة في المكتبة.',
                    onTap: () => open(IslamicBooksSheet(
                        themeOption: IslamicTheme.getThemeOption(
                            context.read<SettingsProvider>().selectedTheme),
                        isNightMode:
                            context.read<SettingsProvider>().isNightEffective)),
                  ),
                ];
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: doors
                      .map((door) => SizedBox(
                            width: cardWidth,
                            child: _LibraryDoor(data: door),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 27),
          ParadiseSection(
            title: 'اسأل وتعلّم',
            child: _LibraryDoor(
              data: _LibraryDoorData(
                icon: Icons.question_answer_outlined,
                title: 'أسئلة وأجوبة',
                subtitle: 'موضوعات إسلامية ومراجعها في مساحة المساندة.',
                onTap: () => FirdawsNavBridge.jumpTo(6, openHelpQa: true),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _ReadingSurfaceNote(
            icon: Icons.visibility_outlined,
            text: 'تُفتح مواد القراءة في صفحاتها المستقلة لراحة العين.',
          ),
        ],
      ),
    );
  }
}

class _QuranEntryPanel extends StatelessWidget {
  final VoidCallback onOpen;
  const _QuranEntryPanel({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CalmCard(
      color: scheme.surface,
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'القرآن الكريم',
                softWrap: true,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                'قراءة واضحة، والاستماع إلى التلاوة.',
                softWrap: true,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 17),
              FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('افتح المصحف'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 11, 20, 11),
                ),
              ),
            ],
          );
          final identity = CalmIconBadge(
            Icons.menu_book_rounded,
            size: narrow ? 58 : 74,
          );
          return narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(height: 15),
                    text,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(width: 20),
                    Expanded(child: text),
                  ],
                );
        },
      ),
    );
  }
}

class _LibraryDoorData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LibraryDoorData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _LibraryDoor extends StatelessWidget {
  final _LibraryDoorData data;
  const _LibraryDoor({required this.data});

  @override
  Widget build(BuildContext context) => CalmCard(
        padding: EdgeInsets.zero,
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(13, 14, 15, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CalmIconBadge(data.icon, size: 48),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      );
}

class FirdawsMorePage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const FirdawsMorePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    void open(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));

    return _DiscoveryScaffold(
      maxWidth: 1180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ParadiseHero(
            title: 'كل وجهات الفردوس، في متناولك',
            subtitle: 'رتّب يومك، تابع مسارك، وانتقل إلى ما تبحث عنه مباشرة.',
            minHeight: 276,
            footer: Wrap(
              spacing: 9,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => onNavigate(0),
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFF173429),
                    backgroundColor: const Color(0xFFF1E5C8),
                    minimumSize: const Size(0, 46),
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 10, 18, 10),
                  ),
                  icon: const Icon(Icons.wb_sunny_outlined),
                  label: const Text('العودة إلى اليوم'),
                ),
                TextButton.icon(
                  onPressed: () => onNavigate(9),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(12, 10, 14, 10),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('المكتبة'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 27),
          ParadiseSection(
            title: 'العبادة والاتجاه',
            child: _DestinationGroup(
              destinationIndices: const [0, 2, 4],
              onNavigate: onNavigate,
            ),
          ),
          const SizedBox(height: 26),
          ParadiseSection(
            title: 'متابعة يومك ورحلتك',
            child: _DestinationGroup(
              destinationIndices: const [1, 3, 5],
              onNavigate: onNavigate,
            ),
          ),
          const SizedBox(height: 26),
          ParadiseSection(
            title: 'المساندة والخيارات',
            child: _DestinationGroup(
              destinationIndices: const [6, 7, 9],
              onNavigate: onNavigate,
            ),
          ),
          const SizedBox(height: 28),
          ParadiseSection(
            title: 'أنشطة اختيارية',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760
                    ? 3
                    : constraints.maxWidth >= 500
                        ? 2
                        : 1;
                const spacing = 13.0;
                final cardWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                final activities = [
                  _ActivityDoorData(
                    icon: Icons.groups_outlined,
                    title: 'تحدي العائلة',
                    subtitle: 'أنشطة للمشاركة مع العائلة.',
                    onTap: () => open(const FamilyChallengeScreen()),
                  ),
                  _ActivityDoorData(
                    icon: Icons.checklist_rounded,
                    title: 'أعمال المناسبات',
                    subtitle: 'تصفّح المهمات والأنشطة المتاحة.',
                    onTap: () => open(const EventsMissionsScreen()),
                  ),
                  _ActivityDoorData(
                    icon: Icons.sports_esports_outlined,
                    title: 'صالة الألعاب والرحلات',
                    subtitle: 'استكشف الألعاب وخيارات اللعب مع العائلة.',
                    onTap: () => open(const ArenaHubScreen()),
                  ),
                  _ActivityDoorData(
                    icon: Icons.storefront_outlined,
                    title: 'مقتنيات الإنجاز',
                    subtitle: 'المقتنيات والسجل السابق.',
                    onTap: () => open(const HasanatStoreScreen()),
                  ),
                  _ActivityDoorData(
                    icon: Icons.bar_chart_rounded,
                    title: 'إحصائيات الصلاة',
                    subtitle: 'التزامك خلال الأسبوع والشهر.',
                    onTap: () => open(const PrayerStatsScreen()),
                  ),
                  _ActivityDoorData(
                    icon: Icons.backup_outlined,
                    title: 'النسخ الاحتياطي',
                    subtitle: 'صدّر بياناتك أو استعدها.',
                    onTap: () => open(const BackupScreen()),
                  ),
                  _ActivityDoorData(
                    icon: Icons.person_outline_rounded,
                    title: 'الملف الشخصي',
                    subtitle: 'معلوماتك وأهدافك الشخصية.',
                    onTap: () => open(const AboutMeScreen()),
                  ),
                ];
                return Wrap(
                  spacing: spacing,
                  runSpacing: 13,
                  children: activities
                      .map((activity) => SizedBox(
                            width: cardWidth,
                            child: _ActivityDoor(data: activity),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const _ReadingSurfaceNote(
            icon: Icons.tune_rounded,
            text: 'خيارات المظهر والموقع والتنبيهات في صفحة الإعدادات.',
          ),
        ],
      ),
    );
  }
}

class _DestinationGroup extends StatelessWidget {
  final List<int> destinationIndices;
  final ValueChanged<int> onNavigate;
  const _DestinationGroup({
    required this.destinationIndices,
    required this.onNavigate,
  });

  static const Map<int, String> _descriptions = {
    0: 'الصفحة الرئيسية ومواقيت الصلاة.',
    1: 'متابعة سجل الصلاة والأعمال.',
    2: 'الانتقال إلى شاشة اتجاه القبلة.',
    3: 'التاريخ الهجري ومواعيد التقويم.',
    4: 'عداد الذكر ومتابعة التسبيح.',
    5: 'مساحة جنتي والأعمال اليومية.',
    6: 'المساندة والمعرفة والأسئلة.',
    7: 'المظهر والموقع والتنبيهات.',
    9: 'القرآن والأذكار والقراءة والتعلّم.',
  };

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760
              ? 3
              : constraints.maxWidth >= 500
                  ? 2
                  : 1;
          const spacing = 13.0;
          final cardWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: destinationIndices.map((index) {
              final destination =
                  firdawsDestinations.firstWhere((item) => item.index == index);
              return SizedBox(
                width: cardWidth,
                child: _NavigationDoor(
                  destination: destination,
                  subtitle: _descriptions[index] ?? '',
                  onTap: () => onNavigate(index),
                ),
              );
            }).toList(),
          );
        },
      );
}

class _NavigationDoor extends StatelessWidget {
  final FirdawsDestination destination;
  final String subtitle;
  final VoidCallback onTap;
  const _NavigationDoor({
    required this.destination,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => CalmCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(13, 14, 15, 14),
          child: Row(
            children: [
              CalmIconBadge(destination.icon, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.label,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.42,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      );
}

class _ActivityDoorData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActivityDoorData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ActivityDoor extends StatelessWidget {
  final _ActivityDoorData data;
  const _ActivityDoor({required this.data});

  @override
  Widget build(BuildContext context) => CalmCard(
        padding: EdgeInsets.zero,
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(13, 14, 15, 14),
          child: Row(
            children: [
              CalmIconBadge(data.icon, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.42,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      );
}

class _ReadingSurfaceNote extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ReadingSurfaceNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 16, 13),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB99C64).withOpacity(.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryScaffold extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const _DiscoveryScaffold({required this.child, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
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
                final compact = constraints.maxWidth < 420;
                final width = constraints.maxWidth < maxWidth
                    ? constraints.maxWidth
                    : maxWidth;
                return Center(
                  child: SizedBox(
                    width: width,
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        compact ? 16 : 28,
                        compact ? 12 : 24,
                        compact ? 16 : 28,
                        34,
                      ),
                      child: child,
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
}
