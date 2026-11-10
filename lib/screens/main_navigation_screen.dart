import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_home_screen.dart';
import 'qibla_screen.dart';
import 'calendar_screen.dart';
import 'tasbih_screen.dart';
import 'jannati_screen.dart';
import 'help_me_screen.dart';
import 'settings_screen.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    PrayerHomeScreen(),
    QiblaScreen(),
    CalendarScreen(),
    TasbihScreen(),
    JannatiScreen(),
    HelpMeScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
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
    final palette = IslamicTheme.resolvePalette(settings.selectedTheme, isNight: isNight);
    final accentColor = palette.accentColor;

    final calAccent = isNight ? const Color(0xFF34D399) : const Color(0xFF047857);
    final jannaAccent = isNight ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    final helpAccent = isNight ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);

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
          color: palette.cardColor.withOpacity(0.96),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: accentColor.withOpacity(isNight ? 0.35 : 0.45),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: (isNight ? Colors.black : palette.primaryColor)
                  .withOpacity(isNight ? 0.7 : 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.access_time_filled_rounded, "المواقيت", accentColor, palette),
                _buildNavItem(1, Icons.explore_rounded, "القبلة", accentColor, palette),
                _buildNavItem(2, Icons.calendar_month_rounded, "التقويم", calAccent, palette),
                _buildNavItem(3, Icons.fingerprint_rounded, "السبحة", accentColor, palette),
                _buildNavItem(4, Icons.workspace_premium_rounded, "جَنَّتِي", jannaAccent, palette),
                _buildNavItem(5, Icons.favorite_rounded, "سَاعِدْنِي", helpAccent, palette),
                _buildNavItem(6, Icons.tune_rounded, "الإعدادات", accentColor, palette),
              ],
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(palette.isDark ? 0.18 : 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.55) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
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
