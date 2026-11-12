import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/arena_game_models.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/challenge_phrases_800.dart';
import '../models/events_missions_catalog.dart';
import '../providers/family_challenge_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_portrait_avatar.dart';
import '../widgets/firdaws_resilient_image.dart';
import 'arena_hub_screen.dart';
import 'events_missions_screen.dart';
import 'hasanat_store_screen.dart';
import 'millionaire_quiz_screen.dart';

class FamilyChallengeScreen extends StatefulWidget {
  final int initialTab;

  const FamilyChallengeScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<FamilyChallengeScreen> createState() => _FamilyChallengeScreenState();
}

class _FamilyChallengeScreenState extends State<FamilyChallengeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // حالة السباق الثنائي المحلي في التسبيح (مشاركة ٢ لاعبين)
  bool _duelRunning = false;
  int _duelSecondsLeft = 20;
  int _p1DuelCount = 0;
  int _p2DuelCount = 0;
  Timer? _duelTimer;
  final TextEditingController _p2NameCtrl = TextEditingController(text: 'صديقي');
  DualPlayerPhraseOutcome? _lastDualOutcome;

  // تصفح موسوعة الـ 800 عبارة وبحث وتصفية المتنافسين
  bool _showWinPhrases = true;
  String _phraseSearch = '';
  String _memberSearch = '';
  String _memberGroupFilter = 'all'; // all, family, friend

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
  }

  @override
  void dispose() {
    _duelTimer?.cancel();
    _tabCtrl.dispose();
    _p2NameCtrl.dispose();
    super.dispose();
  }

  void _startTasbihDuel() {
    _duelTimer?.cancel();
    setState(() {
      _duelRunning = true;
      _duelSecondsLeft = 20;
      _p1DuelCount = 0;
      _p2DuelCount = 0;
      _lastDualOutcome = null;
    });
    _duelTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_duelSecondsLeft <= 1) {
        t.cancel();
        _finishTasbihDuel();
      } else {
        setState(() => _duelSecondsLeft--);
      }
    });
  }

  void _finishTasbihDuel() {
    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    final challenge =
        Provider.of<FamilyChallengeProvider>(context, listen: false);
    final jannati = Provider.of<JannatiProvider>(context, listen: false);

    final p1 = userProv.displayName;
    final p2 =
        _p2NameCtrl.text.trim().isEmpty ? 'اللاعب ٢' : _p2NameCtrl.text.trim();

    if (_p1DuelCount > 0) {
      challenge.recordUserTasbih(_p1DuelCount);
      jannati.recordTasbihForGarden(
        'سبحان الله وبحمده',
        count: _p1DuelCount,
      );
    }

    final outcome = challenge.recordDualPlayerMatch(
      player1Name: p1,
      player1Score: _p1DuelCount,
      player2Name: p2,
      player2Score: _p2DuelCount,
      modeTitle: 'سباق التسبيح الثنائي',
    );

    try {
      final hasanat = Provider.of<HasanatProvider>(context, listen: false);
      final earned = 18 + (_p1DuelCount ~/ 2).clamp(2, 40);
      hasanat.earnHasanat(
        earned,
        reason: 'مبارزة تسبيح ثنائية ($p1 ضد $p2)',
        sourceTag: 'العائلة',
      );
      if (_p1DuelCount > 0) {
        hasanat.recordMetric(
          EventMissionMetric.tasbihCount,
          delta: _p1DuelCount,
        );
      }
      hasanat.recordMetric(EventMissionMetric.dualPlayerMatches, delta: 1);
    } catch (_) {}

    HapticFeedback.heavyImpact();
    setState(() {
      _duelRunning = false;
      _duelSecondsLeft = 0;
      _lastDualOutcome = outcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final challenge = Provider.of<FamilyChallengeProvider>(context);
    final isNight = settings.isNightEffective;
    final palette =
        IslamicTheme.resolvePalette(settings.selectedTheme, isNight: isNight);
    final accent = firdawsModernAccent(palette);

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      appBar: AppBar(
        backgroundColor: firdaws3DSurfaceColor(palette),
        elevation: 0,
        title: const Text(
          'تحدي العائلة والصحبة 3D 🏆',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Builder(
            builder: (ctx) {
              int bal = 0;
              try {
                bal = ctx.watch<HasanatProvider>().hasanatBalance;
              } catch (_) {}
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Firdaws3DPill(
                    label: '$bal 🪙',
                    accentColor: const Color(0xFFF59E0B),
                    palette: palette,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HasanatStoreScreen(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'المهام والأحداث ⚡',
            icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF38BDF8)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EventsMissionsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'إضافة فرد من العائلة أو صديق',
            icon: Icon(Icons.person_add_alt_1_rounded, color: accent),
            onPressed: () => _showChallengerEditorSheet(palette, challenge),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: accent,
          labelColor: accent,
          unselectedLabelColor: palette.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: '📿 مين سبّح أكتر؟'),
            Tab(text: '👑 مين بطل أكتر؟'),
            Tab(text: '⚔️ مبارزة ثنائية ٢ ضد ٢'),
            Tab(text: '📜 الـ 800 عبارة تحفيزية'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: settings.selectedAppWallpaperAsset != null
                ? Image.asset(
                    settings.selectedAppWallpaperAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => FirdawsResilientImage.entry(
                      Background500Catalog.forFamilySection(0),
                      fit: BoxFit.cover,
                    ),
                  )
                : FirdawsResilientImage.entry(
                    Background500Catalog.forFamilySection(0),
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.scaffoldColor.withOpacity(isNight ? 0.78 : 0.78),
                    palette.scaffoldColor.withOpacity(isNight ? 0.90 : 0.88),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              if (challenge.lastMatchPhrase != null)
                _buildLastResultBanner(palette, accent, challenge),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                _buildLeaderboardTab(
                  palette: palette,
                  accent: accent,
                  title: 'سباق التسبيح والذكر: مين سبّح أكتر؟ 🌿',
                  subtitle:
                      'كل تسبيحة في السبحة أو جنتي ترفع رصيدك مباشرة أمام الأهل والصحبة!',
                  unitLabel: 'تسبيحة',
                  entries: challenge.buildTasbihLeaderboard(userProv.displayName),
                  isTasbihTab: true,
                  challenge: challenge,
                  userProv: userProv,
                ),
                _buildLeaderboardTab(
                  palette: palette,
                  accent: accent,
                  title: 'ساحة الأبطال: مين بطل أكتر؟ 🏆',
                  subtitle:
                      'مجموع نقاط المسابقات والـ 30 لعبة ومن سيربح المليون والتحديات!',
                  unitLabel: 'نقطة مجد',
                  entries:
                      challenge.buildChampionLeaderboard(userProv.displayName),
                  isTasbihTab: false,
                  challenge: challenge,
                  userProv: userProv,
                ),
                _buildTwoPlayerTasbihDuelTab(
                  palette: palette,
                  accent: accent,
                  userProv: userProv,
                ),
                _build800PhrasesExplorerTab(
                  palette: palette,
                  accent: accent,
                  userProv: userProv,
                  challenge: challenge,
                ),
              ],
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildLastResultBanner(
    ThemePalette palette,
    Color accent,
    FamilyChallengeProvider challenge,
  ) {
    final won = challenge.lastMatchWon ?? true;
    final bannerAccent =
        won ? const Color(0xFF10B981) : const Color(0xFF38BDF8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: Firdaws3DCard(
        palette: palette,
        glowColor: bannerAccent,
        padding: const EdgeInsets.all(12),
        borderRadius: 18,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bannerAccent.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: bannerAccent.withOpacity(0.55)),
              ),
              child: Icon(
                won ? Icons.emoji_events_rounded : Icons.bolt_rounded,
                color: bannerAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${challenge.lastModeTitle ?? 'آخر تحدٍّ'} • ${won ? 'فوز مستحق' : 'تحفيز العودة'}',
                    style: TextStyle(
                      color: bannerAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    challenge.lastMatchPhrase ?? '',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab({
    required ThemePalette palette,
    required Color accent,
    required String title,
    required String subtitle,
    required String unitLabel,
    required List<LeaderboardEntry> entries,
    required bool isTasbihTab,
    required FamilyChallengeProvider challenge,
    required FirdawsUserProvider userProv,
  }) {
    final top3 = entries.take(3).toList();
    final mq = _memberSearch.trim();
    final filteredEntries = entries.where((e) {
      if (_memberGroupFilter == 'family' &&
          !e.isCurrentUser &&
          e.group != ChallengerGroup.family) {
        return false;
      }
      if (_memberGroupFilter == 'friend' &&
          !e.isCurrentUser &&
          e.group != ChallengerGroup.friend) {
        return false;
      }
      if (mq.isEmpty) return true;
      return e.name.contains(mq) ||
          e.relation.contains(mq) ||
          e.traits.any((t) => t.contains(mq));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forFamilySection(isTasbihTab ? 1 : 2),
          isDark: palette.isDark,
          borderColor: accent.withOpacity(0.5),
          borderRadius: 22,
          padding: const EdgeInsets.all(14),
          imageOpacity: 0.44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: firdawsCrispSecondaryText(palette),
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 14),
              // منصة تتويج 3D لأول 3 متسابقين
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (top3.length > 1)
                    Expanded(
                      child: _buildPodiumColumn(
                        entry: top3[1],
                        rank: 2,
                        height: 82,
                        medalColor: const Color(0xFF94A3B8),
                        unitLabel: unitLabel,
                        palette: palette,
                      ),
                    ),
                  if (top3.isNotEmpty)
                    Expanded(
                      child: _buildPodiumColumn(
                        entry: top3[0],
                        rank: 1,
                        height: 108,
                        medalColor: const Color(0xFF10B981),
                        unitLabel: unitLabel,
                        palette: palette,
                      ),
                    ),
                  if (top3.length > 2)
                    Expanded(
                      child: _buildPodiumColumn(
                        entry: top3[2],
                        rank: 3,
                        height: 68,
                        medalColor: const Color(0xFF38BDF8),
                        unitLabel: unitLabel,
                        palette: palette,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Firdaws3DButton(
                      baseColor: const Color(0xFF10B981),
                      onPressed: () {
                        if (isTasbihTab) {
                          challenge.recordUserTasbih(33);
                          Provider.of<JannatiProvider>(context, listen: false)
                              .recordTasbihForGarden(
                            'سبحان الله وبحمده',
                            count: 33,
                          );
                          try {
                            final hp = Provider.of<HasanatProvider>(
                              context,
                              listen: false,
                            );
                            hp.earnHasanat(
                              12,
                              reason: 'ورد ٣٣ تسبيحة في سباق العائلة',
                              sourceTag: 'العائلة',
                            );
                            hp.recordMetric(
                              EventMissionMetric.tasbihCount,
                              delta: 33,
                            );
                          } catch (_) {}
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: firdaws3DSurfaceColor(palette),
                              content: Text(
                                'تمت إضافة ٣٣ تسبيحة لرصيدك ولرفيقك في جنتي ✨',
                                style: TextStyle(color: palette.textPrimary),
                              ),
                            ),
                          );
                        } else {
                          _simulateQuickChallengeDuel(
                            palette,
                            challenge,
                            userProv,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isTasbihTab
                                ? Icons.fingerprint_rounded
                                : Icons.sports_esports_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isTasbihTab
                                  ? 'سبّح ٣٣ الآن وارفع رصيدك 📿'
                                  : 'تحدَّ المنافس المختار الآن ⚔️',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ترتيب جميع المتنافسين (${filteredEntries.length}/${entries.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showChallengerEditorSheet(palette, challenge),
              icon: Icon(Icons.add_circle_outline_rounded,
                  size: 16, color: accent),
              label: Text(
                'إضافة وتخصيص فرد',
                style: TextStyle(color: accent, fontSize: 11.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(color: palette.textPrimary, fontSize: 12.5),
                onChanged: (v) => setState(() => _memberSearch = v),
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الصفة أو القرابة...',
                  hintStyle: TextStyle(color: palette.textMuted, fontSize: 11.5),
                  prefixIcon: Icon(Icons.search_rounded, color: accent, size: 19),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  filled: true,
                  fillColor: firdaws3DElevatedSurfaceColor(palette),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _groupFilterChip('all', 'الكل (${entries.length})', palette, accent),
              _groupFilterChip('family', 'العائلة 👨‍👩‍👧‍👦', palette, accent),
              _groupFilterChip('friend', 'الأصدقاء 🤝', palette, accent),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...filteredEntries.asMap().entries.map((item) {
          final e = item.value;
          final rank = entries.indexWhere((x) => x.id == e.id) + 1;
          final isSelectedRival =
              !e.isCurrentUser && challenge.selectedRivalId == e.id;
          final rowAccent = e.isCurrentUser
              ? const Color(0xFF10B981)
              : (isSelectedRival ? accent : palette.dividerColor);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Firdaws4KCardShell(
              backdrop: Background500Catalog.forFamilySection(3 + (rank % 20)),
              isDark: palette.isDark,
              borderColor: rowAccent.withOpacity(0.55),
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              imageOpacity: 0.28,
              onTap: e.isCurrentUser
                  ? null
                  : () {
                      challenge.selectRival(e.id);
                      HapticFeedback.selectionClick();
                    },
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rowAccent.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(color: rowAccent.withOpacity(0.65)),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: rowAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  FirdawsPortraitAvatar(
                    entityId: e.isCurrentUser
                        ? 'you'
                        : (e.emoji.contains('_') ? e.emoji : e.id),
                    displayName: e.name,
                    customBytes: e.isCurrentUser ? userProv.avatarBytes : null,
                    customPhotoBase64:
                        e.isCurrentUser ? null : e.customPhotoBase64,
                    networkPhotoUrl:
                        e.isCurrentUser ? null : e.networkPhotoUrl,
                    size: 46,
                    ringColor: rowAccent,
                    showCrown: rank == 1,
                    isHighlighted: e.isCurrentUser || isSelectedRival,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              e.name,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!e.isCurrentUser)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${e.age} سنة',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isSelectedRival)
                              Firdaws3DPill(
                                label: 'المنافس المختار',
                                accentColor: accent,
                                palette: palette,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${e.relation} • فوز ${e.wins} | خسارة ${e.losses}${!e.isCurrentUser ? ' • هدف ${e.dailyTasbihGoal}' : ''}',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 10.5,
                          ),
                        ),
                        if (e.traits.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: e.traits.take(3).map((t) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: accent.withOpacity(0.32)),
                                ),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 9.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${e.value}',
                        style: TextStyle(
                          color: e.isCurrentUser
                              ? const Color(0xFF10B981)
                              : accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        unitLabel,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                  if (!e.isCurrentUser) ...[
                    if (isTasbihTab)
                      IconButton(
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(30, 30),
                          padding: EdgeInsets.zero,
                        ),
                        tooltip: 'تسجيل +33 تسبيحة لهذا المنافس',
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        onPressed: () => challenge.addMemberTasbihManual(e.id, 33),
                      ),
                    if (e.memberRef != null)
                      IconButton(
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(30, 30),
                          padding: EdgeInsets.zero,
                        ),
                        tooltip: 'تعديل الاسم والصورة والصفات',
                        icon: Icon(
                          Icons.tune_rounded,
                          color: accent,
                          size: 19,
                        ),
                        onPressed: () => _showChallengerEditorSheet(
                          palette,
                          challenge,
                          existing: e.memberRef,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        }),
        if (!isTasbihTab && challenge.history.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'سجل أحدث التحديات والنتائج 📜',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...challenge.history.take(10).map((h) {
            final c = h.won ? const Color(0xFF10B981) : const Color(0xFF38BDF8);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Firdaws3DCard(
                palette: palette,
                glowColor: c,
                padding: const EdgeInsets.all(11),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${h.modeTitle} ضد ${h.rivalName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${h.userScore} - ${h.rivalScore}',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      h.phraseShown,
                      style: TextStyle(
                        color: firdawsCrispSecondaryText(palette),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardEntry entry,
    required int rank,
    required double height,
    required Color medalColor,
    required String unitLabel,
    required ThemePalette palette,
  }) {
    final userProv = context.read<FirdawsUserProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          FirdawsPortraitAvatar(
            entityId: entry.id,
            displayName: entry.name,
            customBytes: entry.isCurrentUser ? userProv.avatarBytes : null,
            customPhotoBase64:
                entry.isCurrentUser ? null : entry.customPhotoBase64,
            networkPhotoUrl:
                entry.isCurrentUser ? null : entry.networkPhotoUrl,
            size: rank == 1 ? 52 : 42,
            ringColor: medalColor,
            showCrown: rank == 1,
            isHighlighted: rank == 1,
          ),
          const SizedBox(height: 5),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${entry.value} $unitLabel',
            style: TextStyle(
              color: medalColor,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  medalColor.withOpacity(0.85),
                  medalColor.withOpacity(0.32),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border.all(color: Colors.white.withOpacity(0.28)),
              boxShadow: [
                BoxShadow(
                  color: medalColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉'),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateQuickChallengeDuel(
    ThemePalette palette,
    FamilyChallengeProvider challenge,
    FirdawsUserProvider userProv,
  ) async {
    final rival = challenge.selectedRival;
    final userScore = 70 + (DateTime.now().millisecond % 55);
    final rivalScore = 65 + (DateTime.now().second % 55);
    final phrase = await challenge.recordChallengeMatchResult(
      userName: userProv.displayName,
      rivalId: rival.id,
      modeTitle: 'تحدي الهمة السريع',
      userScore: userScore,
      rivalScore: rivalScore,
    );
    if (!mounted) return;
    final won = userScore >= rivalScore;
    try {
      final hp = Provider.of<HasanatProvider>(context, listen: false);
      hp.earnHasanat(
        won ? 28 : 12,
        reason: won
            ? 'فوز في تحدي الهمة ضد ${rival.name}'
            : 'مشاركة تحدي الهمة مع ${rival.name}',
        sourceTag: 'العائلة',
      );
      hp.recordMetric(EventMissionMetric.arenaMatchesPlayed, delta: 1);
      if (won) hp.recordMetric(EventMissionMetric.arenaMatchesWon, delta: 1);
    } catch (_) {}
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: firdaws3DSurfaceColor(palette),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: won ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
            width: 1.6,
          ),
        ),
        title: Text(
          won ? '🏆 فزت على ${rival.name}!' : '⚡ تقدم ${rival.name} عليك!',
          style: TextStyle(
            color: won ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نتيجة الجولة: $userScore مقابل $rivalScore',
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Firdaws3DCard(
              palette: palette,
              glowColor:
                  won ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
              padding: const EdgeInsets.all(12),
              child: Text(
                phrase,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Firdaws3DButton(
            baseColor:
                won ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'متابعة التحدي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoPlayerTasbihDuelTab({
    required ThemePalette palette,
    required Color accent,
    required FirdawsUserProvider userProv,
  }) {
    final p1 = userProv.displayName;
    final p2 =
        _p2NameCtrl.text.trim().isEmpty ? 'اللاعب ٢' : _p2NameCtrl.text.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
      children: [
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forFamilySection(23),
          isDark: palette.isDark,
          borderColor: accent.withOpacity(0.5),
          borderRadius: 20,
          padding: const EdgeInsets.all(14),
          imageOpacity: 0.38,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مبارزة التسبيح الثنائية (لاعب ١ ضد لاعب ٢ على نفس الجهاز) ⚔️📿',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'اضبط اسم منافسك (أخوك، صاحبك، أو أحد والديك) ثم تسابقا لمدة ٢٠ ثانية من يسبّح أكثر! الفائز ينال عبارة من الـ ٤٠٠ فوز والخاسر ينال عبارة تحفيزية من الـ ٤٠٠ خسارة.',
                style: TextStyle(
                  color: firdawsCrispSecondaryText(palette),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _p2NameCtrl,
                enabled: !_duelRunning,
                style: TextStyle(color: palette.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'اسم اللاعب ٢ (أفراد العائلة / الصديق)',
                  labelStyle: TextStyle(color: palette.textSecondary),
                  prefixIcon: Icon(Icons.person_rounded, color: accent),
                  filled: true,
                  fillColor: firdaws3DElevatedSurfaceColor(palette),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Firdaws3DPill(
                    label: _duelRunning
                        ? '⏱️ متبقي: $_duelSecondsLeft ث'
                        : 'جاهز للانطلاق',
                    accentColor: _duelRunning ? const Color(0xFF10B981) : accent,
                    palette: palette,
                  ),
                  Firdaws3DButton(
                    baseColor:
                        _duelRunning ? Colors.grey : const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    onPressed: _duelRunning ? null : _startTasbihDuel,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _duelRunning
                                ? 'الجولة شغالة 🔥'
                                : 'بدء سباق ٢٠ ثانية',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDualPad(
                playerTitle: 'اللاعب ١: $p1',
                portraitId: 'you',
                portraitName: p1,
                count: _p1DuelCount,
                color: const Color(0xFF10B981),
                palette: palette,
                onTap: _duelRunning
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() => _p1DuelCount++);
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDualPad(
                playerTitle: 'اللاعب ٢: $p2',
                portraitId: 'p2',
                portraitName: p2,
                count: _p2DuelCount,
                color: const Color(0xFF38BDF8),
                palette: palette,
                onTap: _duelRunning
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() => _p2DuelCount++);
                      }
                    : null,
              ),
            ),
          ],
        ),
        if (_lastDualOutcome != null) ...[
          const SizedBox(height: 14),
          Firdaws3DCard(
            palette: palette,
            glowColor: const Color(0xFF10B981),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 الفائز: ${_lastDualOutcome!.winnerName}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastDualOutcome!.winnerPhrase,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const Divider(height: 18),
                Text(
                  '⚡ تحفيز العودة لـ ${_lastDualOutcome!.loserName}:',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastDualOutcome!.loserPhrase,
                  style: TextStyle(
                    color: firdawsCrispSecondaryText(palette),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Firdaws3DCard(
          palette: palette,
          glowColor: const Color(0xFF8B5CF6),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مشاركة ٢ في نفس الألعاب والمسابقات 👥🎮',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تحدَّ صديقك أو أحد أفراد عائلتك الآن على نفس الجهاز في مسابقة المليون أو أي لعبة من الـ ٣٠ لعبة ثلاثية الأبعاد:',
                style: TextStyle(
                  color: firdawsCrispSecondaryText(palette),
                  fontSize: 11.2,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Firdaws3DButton(
                baseColor: const Color(0xFF0EA5E9),
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MillionaireQuizScreen(
                        initialMode: MillionairePlayMode.dualPlayerLocal,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💎', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'من سيربح المليون — مشاركة ٢ لاعبين',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Firdaws3DButton(
                baseColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ArenaHubScreen(
                        initialPlayMode: ArenaPlayMode.dualPlayerLocal,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🕹️', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'صالة الـ ٣٠ لعبة 3D — مشاركة ٢ لاعبين',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
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
    );
  }

  Widget _buildDualPad({
    required String playerTitle,
    required String portraitId,
    required String portraitName,
    required int count,
    required Color color,
    required ThemePalette palette,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Firdaws3DCard(
        palette: palette,
        glowColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          children: [
            FirdawsPortraitAvatar(
              entityId: portraitId,
              displayName: portraitName,
              size: 46,
              ringColor: color,
            ),
            const SizedBox(height: 8),
            Text(
              playerTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Firdaws3DPill(
              label:
                  onTap != null ? 'اضغط سُبْحَانَ اللَّه! 👆' : 'سُبْحَانَ اللَّه',
              accentColor: color,
              palette: palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _build800PhrasesExplorerTab({
    required ThemePalette palette,
    required Color accent,
    required FirdawsUserProvider userProv,
    required FamilyChallengeProvider challenge,
  }) {
    final source = _showWinPhrases
        ? ChallengePhrasesCatalog.winPhrases
        : ChallengePhrasesCatalog.losePhrases;
    final rivalName = challenge.selectedRival.name;
    final userName = userProv.displayName;
    final q = _phraseSearch.trim();

    final indexed = <MapEntry<int, String>>[];
    for (int i = 0; i < source.length; i++) {
      final formatted = ChallengePhrasesCatalog.formatPhrase(
        source[i],
        name: userName,
        rival: rivalName,
      );
      if (q.isEmpty || formatted.contains(q) || '${i + 1}' == q) {
        indexed.add(MapEntry(i + 1, formatted));
      }
    }

    final tabColor =
        _showWinPhrases ? const Color(0xFF10B981) : const Color(0xFF38BDF8);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: Firdaws3DButton(
                  baseColor: _showWinPhrases
                      ? const Color(0xFF10B981)
                      : firdaws3DElevatedSurfaceColor(palette),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () => setState(() => _showWinPhrases = true),
                  child: Text(
                    '🏆 400 عبارة فوز',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _showWinPhrases ? Colors.white : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Firdaws3DButton(
                  baseColor: !_showWinPhrases
                      ? const Color(0xFF38BDF8)
                      : firdaws3DElevatedSurfaceColor(palette),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () => setState(() => _showWinPhrases = false),
                  child: Text(
                    '⚡ 400 عبارة تحفيز الخسارة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          !_showWinPhrases ? Colors.white : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            style: TextStyle(color: palette.textPrimary, fontSize: 13),
            onChanged: (v) => setState(() => _phraseSearch = v),
            decoration: InputDecoration(
              hintText: 'ابحث داخل الـ 800 عبارة باسمك أو برقم العبارة...',
              hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
              prefixIcon: Icon(Icons.search_rounded, color: tabColor),
              filled: true,
              fillColor: firdaws3DElevatedSurfaceColor(palette),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            itemCount: indexed.length,
            itemBuilder: (_, idx) {
              final entry = indexed[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Firdaws3DCard(
                  palette: palette,
                  glowColor: tabColor,
                  padding: const EdgeInsets.all(12),
                  borderRadius: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Firdaws3DPill(
                        label: '#${entry.key}',
                        accentColor: tabColor,
                        palette: palette,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'نسخ ومشاركة',
                        icon: Icon(Icons.copy_rounded,
                            size: 18, color: palette.textMuted),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: entry.value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: firdaws3DSurfaceColor(palette),
                              content: Text(
                                'تم نسخ العبارة #${entry.key} لمشاركتها 📋✨',
                                style: TextStyle(color: palette.textPrimary),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _groupFilterChip(
    String value,
    String label,
    ThemePalette palette,
    Color accent,
  ) {
    final isSel = _memberGroupFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSel ? palette.onAccentColor : palette.textPrimary,
            fontSize: 11,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isSel,
        selectedColor: accent,
        backgroundColor: firdaws3DElevatedSurfaceColor(palette),
        onSelected: (_) => setState(() => _memberGroupFilter = value),
      ),
    );
  }

  Future<void> _showChallengerEditorSheet(
    ThemePalette palette,
    FamilyChallengeProvider challenge, {
    ChallengerMember? existing,
  }) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final relCtrl = TextEditingController(
      text: existing?.relationLabel ?? 'العائلة • قريب',
    );
    final bioCtrl = TextEditingController(text: existing?.bioNote ?? '');
    final customTraitCtrl = TextEditingController();

    ChallengerGroup group = existing?.group ?? ChallengerGroup.family;
    int age = (existing?.age ?? 25).clamp(5, 99);
    int dailyGoal = existing?.dailyTasbihGoal ?? 100;
    int tasbihVal = existing?.tasbihCount ?? 0;
    int scoreVal = existing?.championScore ?? 120;
    String? customPhotoB64 = existing?.customPhotoBase64;
    String? networkUrl = existing?.networkPhotoUrl ??
        Background500Catalog.personaPortraits50.first;
    final List<String> selectedTraits = List<String>.from(
      existing?.traits ?? const ['صاحب همة'],
    );
    final accent = firdawsModernAccent(palette);

    const suggestedTraits = [
      'محافظ على الفجر',
      'سبّاح كثير الذكر',
      'حافظ للقرآن',
      'واصل للرحم',
      'بارّ بوالديه',
      'قائم الليل',
      'كريم النفس',
      'منافس شرس',
      'صاحب أخلاق رفيعة',
      'معين على الخير',
      'متفائل دائماً',
      'هادئ الطبع',
    ];
    final ImagePicker picker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.88,
                minChildSize: 0.55,
                maxChildSize: 0.96,
                builder: (_, sc) {
                  return Container(
                    decoration: BoxDecoration(
                      color: firdaws3DSurfaceColor(palette),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: accent.withOpacity(0.55),
                        width: 1.5,
                      ),
                    ),
                    child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                      children: [
                        Center(
                          child: Container(
                            width: 46,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: palette.dividerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            FirdawsPortraitAvatar(
                              entityId: existing?.id ?? 'custom_preview',
                              displayName: nameCtrl.text,
                              customPhotoBase64: customPhotoB64,
                              networkPhotoUrl:
                                  customPhotoB64 == null ? networkUrl : null,
                              size: 62,
                              ringColor: accent,
                              isHighlighted: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEdit
                                        ? 'تخصيص وتعديل: ${existing.name} ✨'
                                        : 'إضافة فرد عائلة أو صديق جديد 🤝',
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'تحكم كامل في الاسم، الشارة أو الصورة، العمر، الصفات، والأهداف',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final XFile? file = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 420,
                                    maxHeight: 420,
                                    imageQuality: 80,
                                  );
                                  if (file == null) return;
                                  final bytes = await file.readAsBytes();
                                  setModal(() {
                                    customPhotoB64 = base64Encode(bytes);
                                  });
                                } catch (_) {}
                              },
                              icon: const Icon(Icons.photo_camera_rounded,
                                  size: 16),
                              label: const Text(
                                'رفع صورة من المعرض 📸',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            if (customPhotoB64 != null)
                              TextButton.icon(
                                onPressed: () =>
                                    setModal(() => customPhotoB64 = null),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 16, color: Colors.orangeAccent),
                                label: const Text(
                                  'استخدام صورة من المكتبة',
                                  style: TextStyle(
                                      color: Colors.orangeAccent, fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'أو اختر من ٥٠ معلم وشعار إسلامي نقي 4K:',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 64,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                Background500Catalog.personaPortraits50.length,
                            itemBuilder: (_, idx) {
                              final url =
                                  Background500Catalog.personaPortraits50[idx];
                              final sel =
                                  customPhotoB64 == null && networkUrl == url;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setModal(() {
                                      customPhotoB64 = null;
                                      networkUrl = url;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: sel
                                            ? const Color(0xFF10B981)
                                            : Colors.transparent,
                                        width: 2.2,
                                      ),
                                    ),
                                    child: FirdawsPortraitAvatar(
                                      entityId: 'preset_$idx',
                                      networkPhotoUrl: url,
                                      size: 52,
                                      isHighlighted: sel,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameCtrl,
                          style: TextStyle(color: palette.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'الاسم الكامل أو اللقب',
                            labelStyle: TextStyle(color: palette.textSecondary),
                            filled: true,
                            fillColor: firdaws3DElevatedSurfaceColor(palette),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: relCtrl,
                          style: TextStyle(color: palette.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'صلة القرابة أو الوصف (مثل: العائلة • الأخ)',
                            labelStyle: TextStyle(color: palette.textSecondary),
                            filled: true,
                            fillColor: firdaws3DElevatedSurfaceColor(palette),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('العائلة 👨‍👩‍👧‍👦')),
                                selected: group == ChallengerGroup.family,
                                onSelected: (_) => setModal(() {
                                  group = ChallengerGroup.family;
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('الأصدقاء 🤝')),
                                selected: group == ChallengerGroup.friend,
                                onSelected: (_) => setModal(() {
                                  group = ChallengerGroup.friend;
                                }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'العمر:',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Firdaws3DPill(
                              label: '$age سنة',
                              accentColor: accent,
                              palette: palette,
                            ),
                          ],
                        ),
                        Slider(
                          value: age.toDouble(),
                          min: 5,
                          max: 99,
                          divisions: 94,
                          activeColor: accent,
                          onChanged: (v) => setModal(() => age = v.round()),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الصفات والأخلاق (اختر أو أضف صفة مخصصة):',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: {
                            ...suggestedTraits,
                            ...selectedTraits,
                          }.map((tr) {
                            final isSel = selectedTraits.contains(tr);
                            return FilterChip(
                              label: Text(
                                tr,
                                style: TextStyle(
                                  color: isSel
                                      ? palette.onAccentColor
                                      : palette.textPrimary,
                                  fontSize: 11,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: accent,
                              backgroundColor:
                                  firdaws3DElevatedSurfaceColor(palette),
                              onSelected: (v) => setModal(() {
                                if (v) {
                                  if (!selectedTraits.contains(tr)) {
                                    selectedTraits.add(tr);
                                  }
                                } else {
                                  selectedTraits.remove(tr);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: customTraitCtrl,
                                style: TextStyle(
                                    color: palette.textPrimary, fontSize: 12.5),
                                decoration: InputDecoration(
                                  hintText: 'أضف صفة جديدة (مثلاً: ملازم الضحى)...',
                                  hintStyle: TextStyle(
                                      color: palette.textMuted, fontSize: 11.5),
                                  isDense: true,
                                  filled: true,
                                  fillColor:
                                      firdaws3DElevatedSurfaceColor(palette),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final t = customTraitCtrl.text.trim();
                                if (t.isNotEmpty) {
                                  setModal(() {
                                    if (!selectedTraits.contains(t)) {
                                      selectedTraits.add(t);
                                    }
                                    customTraitCtrl.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: palette.onAccentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('إضافة'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'الهدف اليومي للتسبيح:',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [33, 100, 200, 300, 500, 1000].map((g) {
                            final sel = dailyGoal == g;
                            return ChoiceChip(
                              label: Text('$g 📿'),
                              selected: sel,
                              selectedColor: const Color(0xFF10B981),
                              onSelected: (_) => setModal(() => dailyGoal = g),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _scoreStepperBox(
                                label: 'التسبيحات: $tasbihVal',
                                palette: palette,
                                onMinus: () => setModal(() => tasbihVal =
                                    (tasbihVal - 33).clamp(0, 999999)),
                                onPlus: () =>
                                    setModal(() => tasbihVal += 33),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _scoreStepperBox(
                                label: 'نقاط المجد: $scoreVal',
                                palette: palette,
                                onMinus: () => setModal(() => scoreVal =
                                    (scoreVal - 50).clamp(0, 999999)),
                                onPlus: () => setModal(() => scoreVal += 50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: bioCtrl,
                          maxLines: 2,
                          style: TextStyle(
                              color: palette.textPrimary, fontSize: 12.5),
                          decoration: InputDecoration(
                            labelText: 'ملاحظة أو دعوة تحفيزية عن هذا الفرد',
                            labelStyle: TextStyle(color: palette.textSecondary),
                            filled: true,
                            fillColor: firdaws3DElevatedSurfaceColor(palette),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (isEdit && challenge.members.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await challenge.removeChallenger(existing.id);
                                    if (sheetCtx.mounted) {
                                      Navigator.pop(sheetCtx);
                                    }
                                  },
                                  icon: const Icon(Icons.delete_rounded,
                                      color: Colors.redAccent, size: 18),
                                  label: const Text(
                                    'حذف',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Firdaws3DButton(
                                baseColor: const Color(0xFF10B981),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                onPressed: () async {
                                  final cleanName = nameCtrl.text.trim();
                                  if (cleanName.isEmpty) return;
                                  final finalTraits = selectedTraits.isEmpty
                                      ? const ['صاحب همة']
                                      : List<String>.from(selectedTraits);
                                  if (isEdit) {
                                    await challenge.updateChallenger(
                                      existing.copyWith(
                                        name: cleanName,
                                        group: group,
                                        relationLabel: relCtrl.text.trim().isEmpty
                                            ? existing.relationLabel
                                            : relCtrl.text.trim(),
                                        age: age,
                                        traits: finalTraits,
                                        customPhotoBase64: customPhotoB64,
                                        clearCustomPhoto: customPhotoB64 == null,
                                        networkPhotoUrl: networkUrl,
                                        dailyTasbihGoal: dailyGoal,
                                        tasbihCount: tasbihVal,
                                        championScore: scoreVal,
                                        bioNote: bioCtrl.text.trim(),
                                      ),
                                    );
                                  } else {
                                    await challenge.addChallenger(
                                      name: cleanName,
                                      group: group,
                                      relationLabel: relCtrl.text,
                                      age: age,
                                      traits: finalTraits,
                                      customPhotoBase64: customPhotoB64,
                                      networkPhotoUrl: networkUrl,
                                      dailyTasbihGoal: dailyGoal,
                                      initialTasbih: tasbihVal,
                                      initialScore: scoreVal,
                                      bioNote: bioCtrl.text.trim(),
                                    );
                                  }
                                  if (sheetCtx.mounted) {
                                    Navigator.pop(sheetCtx);
                                  }
                                },
                                child: Text(
                                  isEdit
                                      ? 'حفظ التعديلات ✨'
                                      : 'إضافة إلى التحدي 🏆',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _scoreStepperBox({
    required String label,
    required ThemePalette palette,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: firdaws3DElevatedSurfaceColor(palette),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onMinus,
            child: const Icon(Icons.remove_circle_outline_rounded, size: 20),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: onPlus,
            child: const Icon(Icons.add_circle_outline_rounded,
                size: 20, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}
