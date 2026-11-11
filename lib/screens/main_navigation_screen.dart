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
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

class FirdawsNavBridge {
  static void Function(
    int pageIndex, {
    int? journeyTab,
    DateTime? journeyDate,
    int? jannatiTab,
    bool? openHelpQa,
  })? _navigator;

  static void jumpTo(
    int pageIndex, {
    int? journeyTab,
    DateTime? journeyDate,
    int? jannatiTab,
    bool? openHelpQa,
  }) {
    _navigator?.call(
      pageIndex,
      journeyTab: journeyTab,
      journeyDate: journeyDate,
      jannatiTab: jannatiTab,
      openHelpQa: openHelpQa,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  final ValueNotifier<FirdawsJourneyRequest?> _journeyRequest =
      ValueNotifier<FirdawsJourneyRequest?>(null);
  final ValueNotifier<int?> _jannatiTabRequest = ValueNotifier<int?>(null);
  final ValueNotifier<bool?> _helpQaRequest = ValueNotifier<bool?>(null);

  late final List<Widget> _screens = [
    const PrayerHomeScreen(),
    FirdawsJourneyScreen(requestNotifier: _journeyRequest),
    const QiblaScreen(),
    const CalendarScreen(),
    const TasbihScreen(),
    JannatiScreen(tabRequestNotifier: _jannatiTabRequest),
    HelpMeScreen(openQaNotifier: _helpQaRequest),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    FirdawsNavBridge._navigator = _navigateFromExternal;
  }

  void _navigateFromExternal(
    int pageIndex, {
    int? journeyTab,
    DateTime? journeyDate,
    int? jannatiTab,
    bool? openHelpQa,
  }) {
    if (!mounted) return;
    if (journeyTab != null || journeyDate != null) {
      _journeyRequest.value = FirdawsJourneyRequest(
        tabIndex: journeyTab ?? 0,
        selectedDate: journeyDate,
      );
    }
    if (jannatiTab != null) {
      _jannatiTabRequest.value = jannatiTab;
    }
    if (openHelpQa != null) {
      _helpQaRequest.value = openHelpQa;
    }
    _onTabTapped(pageIndex);
  }

  @override
  void dispose() {
    if (FirdawsNavBridge._navigator == _navigateFromExternal) {
      FirdawsNavBridge._navigator = null;
    }
    _journeyRequest.dispose();
    _jannatiTabRequest.dispose();
    _helpQaRequest.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final palette =
        IslamicTheme.resolvePalette(settings.selectedTheme, isNight: isNight);
    final accentColor = palette.accentColor;

    final journeyAccent =
        isNight ? const Color(0xFF34D399) : const Color(0xFF047857);
    final calAccent =
        isNight ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
    final jannaAccent =
        isNight ? const Color(0xFF10B981) : const Color(0xFF059669);
    final helpAccent =
        isNight ? const Color(0xFFF472B6) : const Color(0xFFBE185D);

    final navItems = [
      _buildNavItem(
        0,
        Icons.access_time_filled_rounded,
        'المواقيت',
        accentColor,
        palette,
      ),
      _buildNavItem(
        1,
        Icons.fact_check_rounded,
        'السجل والمهام',
        journeyAccent,
        palette,
      ),
      _buildNavItem(
        2,
        Icons.explore_rounded,
        'القبلة',
        accentColor,
        palette,
      ),
      _buildNavItem(
        3,
        Icons.calendar_month_rounded,
        'التقويم',
        calAccent,
        palette,
      ),
      _buildNavItem(
        4,
        Icons.fingerprint_rounded,
        'السبحة',
        accentColor,
        palette,
      ),
      _buildNavItem(
        5,
        Icons.workspace_premium_rounded,
        'جَنَّتِي',
        jannaAccent,
        palette,
      ),
      _buildNavItem(
        6,
        Icons.favorite_rounded,
        'سَاعِدْنِي',
        helpAccent,
        palette,
      ),
      _buildNavItem(
        7,
        Icons.tune_rounded,
        'الإعدادات',
        accentColor,
        palette,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isNight
                ? [
                    const Color(0xFF172236).withOpacity(0.96),
                    const Color(0xFF0A101D).withOpacity(0.98),
                  ]
                : [
                    Colors.white.withOpacity(0.98),
                    palette.elevatedCardColor.withOpacity(0.95),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: (isNight ? Colors.white : accentColor).withOpacity(isNight ? 0.16 : 0.35),
            width: 1.3,
          ),
          boxShadow: [
            // قاعدة 3D صلبة تمنح الشريط ارتفاعاً مجسماً
            BoxShadow(
              color: isNight
                  ? Colors.black.withOpacity(0.85)
                  : palette.primaryColor.withOpacity(0.24),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: (isNight ? Colors.black : palette.primaryColor)
                  .withOpacity(isNight ? 0.65 : 0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: accentColor.withOpacity(isNight ? 0.14 : 0.10),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 460) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: navItems,
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: navItems
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: item,
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    ThemePalette palette,
  ) {
    final isSelected = _currentIndex == index;
    final inactiveColor = palette.textMuted;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    activeColor.withOpacity(palette.isDark ? 0.28 : 0.20),
                    activeColor.withOpacity(palette.isDark ? 0.12 : 0.08),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withOpacity(0.65)
                : Colors.transparent,
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.28),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.16 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 19,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 9.5,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
