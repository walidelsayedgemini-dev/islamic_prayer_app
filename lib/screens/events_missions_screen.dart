import 'package:adhan/adhan.dart';
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
import '../widgets/real_mosque_background.dart';
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
            fontSize: 12.5,
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
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final isNight = settings.isNightEffective;
    final accent = firdawsModernAccent(palette);
    final activeEv = hasanat.activeEvent;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.scaffoldColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: settings.selectedAppWallpaperAsset != null
                  ? RealMosqueBackground(
                      currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
                      themeOption: themeOption,
                      isNightMode: isNight,
                      customAssetOverride: settings.selectedAppWallpaperAsset,
                      dimFactor: 0.90,
                    )
                  : FirdawsResilientImage.entry(
                      Background500Catalog.forEventItem(0),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(isNight ? 0.62 : 0.30),
                      Colors.black.withOpacity(isNight ? 0.78 : 0.45),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, palette, accent, hasanat),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildActiveEventHero(palette, accent, hasanat, activeEv),
                        const SizedBox(height: 12),
                        _buildViewToggle(palette, accent, hasanat),
                        const SizedBox(height: 12),
                        if (_activeView == 1) ...[
                          ...EventsMissionsCatalog.events
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildEventCard(
                                      entry.value,
                                      hasanat,
                                      palette,
                                      eventIndex: entry.key,
                                    ),
                                  )),
                          const SizedBox(height: 10),
                          _sectionTitle('المهام الـ ١٦ المرتبطة بالأحداث', Icons.task_alt_rounded, accent, palette),
                          const SizedBox(height: 8),
                          ...EventsMissionsCatalog.missions
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildMissionCard(
                                      entry.value,
                                      hasanat,
                                      palette,
                                      missionIndex: entry.key,
                                    ),
                                  )),
                        ] else ...[
                          _sectionTitle(
                            'المهام النشطة (${hasanat.claimedMissionIds.length} / ${EventsMissionsCatalog.missions.length} مكتملة)',
                            Icons.flag_rounded,
                            accent,
                            palette,
                          ),
                          const SizedBox(height: 8),
                          ...EventsMissionsCatalog.missions
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildMissionCard(
                                      entry.value,
                                      hasanat,
                                      palette,
                                      missionIndex: entry.key,
                                    ),
                                  )),
                          const SizedBox(height: 12),
                          _sectionTitle(
                            'الأحداث الـ ٨ القابلة للفتح (${hasanat.unlockedEventIds.length} / ${EventsMissionsCatalog.events.length})',
                            Icons.flash_on_rounded,
                            const Color(0xFFF59E0B),
                            palette,
                          ),
                          const SizedBox(height: 8),
                          ...EventsMissionsCatalog.events
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildEventCard(
                                      entry.value,
                                      hasanat,
                                      palette,
                                      eventIndex: entry.key,
                                    ),
                                  )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          Firdaws3DPill(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'رجوع',
            accentColor: accent,
            palette: palette,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'المهام والأحداث ⚡🎯',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Firdaws3DPill(
            icon: Icons.storefront_rounded,
            label: '${hasanat.hasanatBalance} 🪙',
            accentColor: const Color(0xFFF59E0B),
            palette: palette,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HasanatStoreScreen()),
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
      return Firdaws4KCardShell(
        backdrop: Background500Catalog.forEventItem(1),
        isDark: palette.isDark,
        borderColor: const Color(0xFF38BDF8).withOpacity(0.55),
        padding: const EdgeInsets.all(14),
        borderRadius: 20,
        imageOpacity: 0.60,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
                border: Border.all(color: const Color(0xFF38BDF8)),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFF38BDF8), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أكمل المهام لفتح الأحداث المضاعفة للحسنات ⚡',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'مهمتك الأولى «بشائر الذاكرين» تفتح «مهرجان فجر السبّاقين ×1.5» فوراً بعد ١٠ تسبيحات!',
                    style: TextStyle(
                      color: firdawsCrispSecondaryText(palette),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forEventItem(1),
      isDark: palette.isDark,
      borderColor: activeEv.primaryColor.withOpacity(0.65),
      padding: const EdgeInsets.all(12),
      borderRadius: 22,
      imageOpacity: 0.56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 108,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FirdawsResilientImage(
                    networkUrl: Background500Catalog.forEventItem(19).url,
                    fallbackAsset: activeEv.backdropAsset,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '⚡ الحدث المُفعَّل الآن',
                          style: TextStyle(
                            color: activeEv.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          activeEv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            activeEv.ruleDescription,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Firdaws3DButton(
                  baseColor: activeEv.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  onPressed: () => _launchEventGame(activeEv, hasanat),
                  child: const Text(
                    'انطلق للعبة الحدث 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Firdaws3DPill(
                label: 'إلغاء التفعيل',
                accentColor: palette.textMuted,
                palette: palette,
                onTap: () => hasanat.activateEvent(null),
              ),
            ],
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
    return Row(
      children: [
        Expanded(
          child: Firdaws3DButton(
            baseColor: _activeView == 0
                ? accent
                : firdaws3DElevatedSurfaceColor(palette),
            padding: const EdgeInsets.symmetric(vertical: 10),
            onPressed: () => setState(() => _activeView = 0),
            child: Text(
              'المهام (${hasanat.claimableMissionsCount} جاهزة)',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _activeView == 0
                    ? palette.onAccentColor
                    : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Firdaws3DButton(
            baseColor: _activeView == 1
                ? const Color(0xFFF59E0B)
                : firdaws3DElevatedSurfaceColor(palette),
            padding: const EdgeInsets.symmetric(vertical: 10),
            onPressed: () => setState(() => _activeView = 1),
            child: Text(
              'الأحداث (${hasanat.unlockedEventIds.length}/${EventsMissionsCatalog.events.length})',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _activeView == 1 ? Colors.white : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
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
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ],
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
    final borderCol = claimed
        ? const Color(0xFF10B981)
        : (ready ? const Color(0xFFF59E0B) : m.accentColor);

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forMissionItem(missionIndex),
      isDark: palette.isDark,
      borderColor: borderCol.withOpacity(0.60),
      padding: const EdgeInsets.all(13),
      borderRadius: 18,
      imageOpacity: 0.54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: m.accentColor.withOpacity(0.18),
                  border: Border.all(color: m.accentColor.withOpacity(0.6)),
                ),
                child: Icon(m.icon, color: m.accentColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$prog / ${m.targetValue} ${m.metric.unitLabel}',
                      style: TextStyle(
                        color: m.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Firdaws3DPill(
                label: '+${m.hasanatReward} 🪙',
                accentColor: const Color(0xFFF59E0B),
                palette: palette,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            m.description,
            style: TextStyle(
              color: firdawsCrispSecondaryText(palette),
              fontSize: 11.2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: palette.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                claimed ? const Color(0xFF10B981) : m.accentColor,
              ),
            ),
          ),
          if (unlocksEv != null) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(Icons.lock_open_rounded,
                    size: 14, color: unlocksEv.primaryColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'يفتح حدث: ${unlocksEv.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unlocksEv.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (ready || claimed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Firdaws3DButton(
                baseColor:
                    claimed ? const Color(0xFF065F46) : const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 9),
                elevationDepth: claimed ? 1 : 3.5,
                onPressed: claimed
                    ? null
                    : () => _onClaimMission(m, hasanat, palette),
                child: Text(
                  claimed
                      ? 'تم استلام الجائزة ✓'
                      : (unlocksEv != null
                          ? 'استلام الجائزة وفتح الحدث 🎁'
                          : 'استلام +${m.hasanatReward} حسنة 🎁'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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

    return Firdaws4KCardShell(
      backdrop: evBackdrop,
      isDark: palette.isDark,
      borderColor: (isActive ? const Color(0xFF10B981) : ev.primaryColor).withOpacity(0.62),
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      imageOpacity: 0.48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 102,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FirdawsResilientImage(
                    networkUrl: evBackdrop.url,
                    fallbackAsset: ev.backdropAsset,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? const Color(0xFF10B981).withOpacity(0.85)
                                      : Colors.black.withOpacity(0.68),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isActive
                                      ? 'مُفعَّل حالياً ⚡'
                                      : (unlocked ? 'مفتوح 🔓' : 'مقفل 🔒'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ev.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ev.primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '×${ev.hasanatMultiplier}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ev.subtitle,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            ev.ruleDescription,
            style: TextStyle(
              color: ev.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          if (unlocked)
            Row(
              children: [
                Expanded(
                  child: Firdaws3DButton(
                    baseColor:
                        isActive ? const Color(0xFF10B981) : ev.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    onPressed: () async {
                      await hasanat.activateEvent(isActive ? null : ev.id);
                    },
                    child: Text(
                      isActive ? 'إيقاف الحدث مؤقتاً' : 'تفعيل هذا الحدث ⚡',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    onPressed: () => _launchEventGame(ev, hasanat),
                    child: const Text(
                      'العب الآن 🚀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: palette.textPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.dividerColor),
              ),
              child: Text(
                'لفتح الحدث أكمل مهمة: ${reqMission?.title ?? ev.requiredMissionId}',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
