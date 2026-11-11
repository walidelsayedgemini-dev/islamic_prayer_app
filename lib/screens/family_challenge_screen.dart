import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/arena_game_models.dart';
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
import '../widgets/real_mosque_background.dart';
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

  // تصفح موسوعة الـ 800 عبارة
  bool _showWinPhrases = true;
  String _phraseSearch = '';

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
            onPressed: () => _showAddChallengerDialog(palette, challenge),
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
            child: RealMosqueBackground(
              currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
              themeOption: IslamicTheme.getThemeOption(settings.selectedTheme),
              isNightMode: isNight,
              customAssetOverride: settings.selectedAppWallpaperAsset ??
                  'assets/images/themes/cordoba_arches.jpg',
              dimFactor: 0.90,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        Firdaws3DCard(
          palette: palette,
          glowColor: accent,
          padding: const EdgeInsets.all(14),
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
                                'تمت إضافة ٣٣ تسبيحة لرصيدك وبستان جنتي 3D 🌳✨',
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
                'ترتيب جميع المتنافسين (${entries.length})',
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
              onPressed: () => _showAddChallengerDialog(palette, challenge),
              icon: Icon(Icons.add_circle_outline_rounded,
                  size: 16, color: accent),
              label: Text(
                'إضافة منافس',
                style: TextStyle(color: accent, fontSize: 11.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...entries.asMap().entries.map((item) {
          final rank = item.key + 1;
          final e = item.value;
          final isSelectedRival =
              !e.isCurrentUser && challenge.selectedRivalId == e.id;
          final rowAccent = e.isCurrentUser
              ? const Color(0xFF10B981)
              : (isSelectedRival ? accent : palette.dividerColor);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Firdaws3DCard(
              palette: palette,
              glowColor: rowAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderRadius: 18,
              onTap: e.isCurrentUser
                  ? null
                  : () {
                      challenge.selectRival(e.id);
                      HapticFeedback.selectionClick();
                    },
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: rowAccent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: rowAccent.withOpacity(0.6)),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: rowAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FirdawsPortraitAvatar(
                    entityId: e.isCurrentUser
                        ? 'you'
                        : (e.emoji.contains('_') ? e.emoji : e.id),
                    displayName: e.name,
                    customBytes: e.isCurrentUser ? userProv.avatarBytes : null,
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                e.name,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSelectedRival) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Firdaws3DPill(
                                  label: 'المنافس المختار',
                                  accentColor: accent,
                                  palette: palette,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${e.relation} • فوز ${e.wins} | خسارة ${e.losses}',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 10.5,
                          ),
                        ),
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
                  if (!e.isCurrentUser && isTasbihTab) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'تسجيل +33 تسبيحة لهذا المنافس',
                      icon: Icon(
                        Icons.add_circle_rounded,
                        color: accent,
                        size: 20,
                      ),
                      onPressed: () => challenge.addMemberTasbihManual(e.id, 33),
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
        Firdaws3DCard(
          palette: palette,
          glowColor: accent,
          padding: const EdgeInsets.all(14),
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

  void _showAddChallengerDialog(
    ThemePalette palette,
    FamilyChallengeProvider challenge,
  ) {
    final nameCtrl = TextEditingController();
    final relCtrl = TextEditingController(text: 'الأصدقاء');
    ChallengerGroup group = ChallengerGroup.friend;
    String selectedPortraitId = 'fr_omar';
    const portraitChoices = [
      (id: 'fam_father', label: 'الوالد'),
      (id: 'fam_mother', label: 'الوالدة'),
      (id: 'fam_brother', label: 'أخ'),
      (id: 'fam_sister', label: 'أخت'),
      (id: 'fr_omar', label: 'عمر'),
      (id: 'fr_kareem', label: 'كريم'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          backgroundColor: firdaws3DSurfaceColor(palette),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: firdawsModernAccent(palette), width: 1.4),
          ),
          title: Text(
            'إضافة فرد من العائلة أو صديق 🤝',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    labelStyle: TextStyle(color: palette.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: relCtrl,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'صلة القرابة / الوصف',
                    labelStyle: TextStyle(color: palette.textSecondary),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('عائلة'),
                        selected: group == ChallengerGroup.family,
                        onSelected: (_) => setModal(() {
                          group = ChallengerGroup.family;
                          relCtrl.text = 'العائلة';
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('صديق'),
                        selected: group == ChallengerGroup.friend,
                        onSelected: (_) => setModal(() {
                          group = ChallengerGroup.friend;
                          relCtrl.text = 'الأصدقاء';
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: portraitChoices
                      .map(
                        (p) => GestureDetector(
                          onTap: () => setModal(() => selectedPortraitId = p.id),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedPortraitId == p.id
                                    ? firdawsModernAccent(palette)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: FirdawsPortraitAvatar(
                              entityId: p.id,
                              size: 40,
                              isHighlighted: selectedPortraitId == p.id,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: TextStyle(color: palette.textMuted)),
            ),
            Firdaws3DButton(
              baseColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              onPressed: () {
                challenge.addChallenger(
                  name: nameCtrl.text,
                  group: group,
                  relationLabel: relCtrl.text,
                  avatarEmoji: selectedPortraitId,
                );
                Navigator.pop(ctx);
              },
              child: const Text(
                'حفظ المنافس',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
