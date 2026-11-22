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
import '../services/bluetooth_challenge_service.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/firdaws_portrait_avatar.dart';
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
  final TextEditingController _p2NameCtrl =
      TextEditingController(text: 'صديقي');
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
    final palette = FirdawsParadiseRegistry.paletteFor(
      settings.selectedTheme,
      isNight,
    );
    final accent = firdawsModernAccent(palette);

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      appBar: AppBar(
        backgroundColor: palette.cardColor,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        title: const Text(
          'تحدي العائلة',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'تحدٍّ قريب عبر البلوتوث',
            icon: Icon(Icons.bluetooth_searching_rounded, color: accent),
            onPressed: () => _showBluetoothChallengeSheet(
                palette, accent, challenge, userProv),
          ),
          PopupMenuButton<String>(
            tooltip: 'المزيد من خيارات التحدي',
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              switch (value) {
                case 'store':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HasanatStoreScreen(),
                    ),
                  );
                  break;
                case 'missions':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EventsMissionsScreen(),
                    ),
                  );
                  break;
                case 'member':
                  _showChallengerEditorSheet(palette, challenge);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'store',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.savings_outlined),
                  title: Text('رصيد الحسنات والمتجر'),
                ),
              ),
              PopupMenuItem(
                value: 'missions',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.flag_outlined),
                  title: Text('المهام والأحداث'),
                ),
              ),
              PopupMenuItem(
                value: 'member',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.person_add_alt_1_rounded),
                  title: Text('إضافة مشارك'),
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Material(
            color: palette.cardColor,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: accent,
              labelColor: accent,
              unselectedLabelColor: palette.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: FirdawsType.caption,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.auto_awesome_outlined), text: 'التسبيح'),
                Tab(icon: Icon(Icons.emoji_events_outlined), text: 'الأبطال'),
                Tab(
                    icon: Icon(Icons.touch_app_outlined),
                    text: 'مبارزة ثنائية'),
                Tab(icon: Icon(Icons.format_quote_rounded), text: 'العبارات'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (challenge.lastMatchPhrase != null)
            _buildLastResultBanner(palette, accent, challenge),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: ParadiseHero(
                  title: 'منافسة تقرّبكم',
                  subtitle:
                      'تابعوا الذكر والإنجازات معاً، واختاروا تحدياً يناسب لَمّتكم.',
                  imageAsset:
                      FirdawsParadiseRegistry.imageFor(settings.selectedTheme),
                  minHeight: 188,
                  footer: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ParadiseChip(
                        label: '${challenge.members.length} مشارك',
                        icon: Icons.groups_outlined,
                      ),
                      ParadiseChip(
                        label: '${challenge.userTasbihCount} تسبيحة',
                        icon: Icons.spa_outlined,
                      ),
                      ParadiseChip(
                        label: '${challenge.userWins} فوز',
                        icon: Icons.emoji_events_outlined,
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _showChallengerEditorSheet(palette, challenge),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(.12),
                          minimumSize: const Size(44, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: const StadiumBorder(
                            side: BorderSide(color: Color(0x88E8D6A7)),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('أضف شخصاً'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildLeaderboardTab(
                  palette: palette,
                  accent: accent,
                  title: 'مسار الذكر',
                  subtitle:
                      'تتبعوا التسبيح المسجّل لكل فرد، وأضيفوا ورداً جديداً متى شئتم.',
                  unitLabel: 'تسبيحة',
                  entries:
                      challenge.buildTasbihLeaderboard(userProv.displayName),
                  isTasbihTab: true,
                  challenge: challenge,
                  userProv: userProv,
                ),
                _buildLeaderboardTab(
                  palette: palette,
                  accent: accent,
                  title: 'لوحة الإنجاز',
                  subtitle:
                      'ترتيب يجمع نقاط المسابقات والألعاب والتحديات المسجّلة.',
                  unitLabel: 'نقطة',
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
    );
  }

  Widget _buildLastResultBanner(
    ThemePalette palette,
    Color accent,
    FamilyChallengeProvider challenge,
  ) {
    final won = challenge.lastMatchWon ?? true;
    final bannerAccent =
        won ? const Color(0xFF18805F) : const Color(0xFF2877A3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: CalmCard(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            color: palette.cardColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  won ? Icons.emoji_events_outlined : Icons.trending_up_rounded,
                  color: bannerAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${challenge.lastModeTitle ?? 'آخر تحدٍّ'} · ${won ? 'فوز مستحق' : 'فرصة جديدة للمحاولة'}',
                        softWrap: true,
                        style: TextStyle(
                          color: bannerAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: FirdawsType.caption,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.lastMatchPhrase ?? '',
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: FirdawsType.caption,
                          height: 1.45,
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
    final query = _memberSearch.trim();
    final filteredEntries = entries.where((entry) {
      if (_memberGroupFilter == 'family' &&
          !entry.isCurrentUser &&
          entry.group != ChallengerGroup.family) {
        return false;
      }
      if (_memberGroupFilter == 'friend' &&
          !entry.isCurrentUser &&
          entry.group != ChallengerGroup.friend) {
        return false;
      }
      if (_memberGroupFilter == 'customGroup' &&
          !entry.isCurrentUser &&
          entry.group != ChallengerGroup.customGroup) {
        return false;
      }
      if (query.isEmpty) return true;
      return entry.name.contains(query) ||
          entry.relation.contains(query) ||
          entry.traits.any((trait) => trait.contains(query));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalmCard(
                  color: palette.cardColor,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        softWrap: true,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: FirdawsType.caption,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ParadiseSection(
                        title: 'المراكز الأولى',
                        child: top3.isEmpty
                            ? const CalmEmptyState(
                                icon: Icons.groups_outlined,
                                title: 'لا يوجد ترتيب بعد',
                                subtitle:
                                    'أضيفوا أفراد العائلة أو الأصدقاء لبدء لوحة التحدي.',
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < top3.length; i++) ...[
                                    if (i > 0) const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildPodiumColumn(
                                        entry: top3[i],
                                        rank: i + 1,
                                        height:
                                            i == 0 ? 108 : (i == 1 ? 88 : 76),
                                        medalColor: i == 0
                                            ? const Color(0xFFB18B3C)
                                            : (i == 1
                                                ? const Color(0xFF728495)
                                                : const Color(0xFF986E4C)),
                                        unitLabel: unitLabel,
                                        palette: palette,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                isTasbihTab ? const Color(0xFF176B5B) : accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            if (isTasbihTab) {
                              challenge.recordUserTasbih(33);
                              Provider.of<JannatiProvider>(context,
                                      listen: false)
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
                                  backgroundColor: palette.cardColor,
                                  content: Text(
                                    'أُضيفت ٣٣ تسبيحة إلى رصيدك ورفيقك في جنتي.',
                                    style:
                                        TextStyle(color: palette.textPrimary),
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
                          icon: Icon(
                            isTasbihTab
                                ? Icons.add_circle_outline_rounded
                                : Icons.sports_esports_outlined,
                          ),
                          label: Text(
                            isTasbihTab
                                ? 'إضافة ورد من ٣٣ تسبيحة'
                                : 'ابدأ تحدياً سريعاً مع المنافس المختار',
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ParadiseSection(
                  title: 'قائمة المشاركين',
                  action: TextButton.icon(
                    onPressed: () =>
                        _showChallengerEditorSheet(palette, challenge),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('إضافة مشارك'),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${filteredEntries.length} من ${entries.length} مشاركاً',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: FirdawsType.caption,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: FirdawsType.label,
                        ),
                        onChanged: (value) =>
                            setState(() => _memberSearch = value),
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم أو القرابة أو الصفة',
                          hintStyle: TextStyle(
                            color: palette.textMuted,
                            fontSize: FirdawsType.caption,
                          ),
                          prefixIcon: Icon(Icons.search_rounded, color: accent),
                          isDense: true,
                          filled: true,
                          fillColor: palette.cardColor,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.dividerColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _groupFilterChip('all', 'الكل (${entries.length})',
                              palette, accent),
                          _groupFilterChip(
                              'family', 'العائلة', palette, accent),
                          _groupFilterChip(
                              'friend', 'الأصدقاء', palette, accent),
                          _groupFilterChip(
                            'customGroup',
                            challenge.customGroupName,
                            palette,
                            accent,
                          ),
                          TextButton.icon(
                            onPressed: () => _showRenameCustomGroupDialog(
                                palette, challenge),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('تسمية المجموعة'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filteredEntries.isEmpty)
                        CalmCard(
                          color: palette.cardColor,
                          child: const CalmEmptyState(
                            icon: Icons.person_search_outlined,
                            title: 'لا توجد نتائج مطابقة',
                            subtitle:
                                'غيّر كلمة البحث أو اختر مجموعة أخرى لعرض أفرادها.',
                          ),
                        )
                      else
                        ...filteredEntries.map((entry) {
                          final rank = entries
                                  .indexWhere((item) => item.id == entry.id) +
                              1;
                          final isSelectedRival = !entry.isCurrentUser &&
                              challenge.selectedRivalId == entry.id;
                          final rowAccent = entry.isCurrentUser
                              ? const Color(0xFF176B5B)
                              : (isSelectedRival
                                  ? accent
                                  : palette.dividerColor);
                          void selectRival() {
                            if (entry.isCurrentUser) return;
                            challenge.selectRival(entry.id);
                            HapticFeedback.selectionClick();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CalmCard(
                              color: palette.cardColor,
                              padding: const EdgeInsets.all(14),
                              onTap: entry.isCurrentUser ? null : selectRival,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints:
                                            const BoxConstraints(minWidth: 35),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: rowAccent.withOpacity(.11),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '#$rank',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: rowAccent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      FirdawsPortraitAvatar(
                                        entityId: entry.isCurrentUser
                                            ? 'you'
                                            : (entry.emoji.contains('_')
                                                ? entry.emoji
                                                : entry.id),
                                        displayName: entry.name,
                                        customBytes: entry.isCurrentUser
                                            ? userProv.avatarBytes
                                            : null,
                                        customPhotoBase64: entry.isCurrentUser
                                            ? null
                                            : entry.customPhotoBase64,
                                        networkPhotoUrl: entry.isCurrentUser
                                            ? null
                                            : entry.networkPhotoUrl,
                                        size: 44,
                                        ringColor: rowAccent,
                                        showCrown: rank == 1,
                                        isHighlighted: entry.isCurrentUser ||
                                            isSelectedRival,
                                      ),
                                      const SizedBox(width: 11),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 7,
                                              runSpacing: 5,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  entry.name,
                                                  softWrap: true,
                                                  style: TextStyle(
                                                    color: palette.textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: FirdawsType.label,
                                                  ),
                                                ),
                                                if (isSelectedRival)
                                                  const ParadiseChip(
                                                    label: 'المنافس المختار',
                                                    selected: true,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${entry.relation} · فوز ${entry.wins} · خسارة ${entry.losses}${!entry.isCurrentUser ? ' · هدف ${entry.dailyTasbihGoal}' : ''}',
                                              softWrap: true,
                                              style: TextStyle(
                                                color: palette.textSecondary,
                                                fontSize: FirdawsType.caption,
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${entry.value}',
                                            style: TextStyle(
                                              color: entry.isCurrentUser
                                                  ? const Color(0xFF176B5B)
                                                  : accent,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 19,
                                            ),
                                          ),
                                          Text(
                                            unitLabel,
                                            style: TextStyle(
                                              color: palette.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (entry.traits.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children:
                                          entry.traits.take(4).map((trait) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: palette.elevatedCardColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            trait,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: palette.textPrimary,
                                              fontSize: FirdawsType.caption,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  if (!entry.isCurrentUser &&
                                      (isTasbihTab ||
                                          entry.memberRef != null)) ...[
                                    const SizedBox(height: 7),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        TextButton.icon(
                                          onPressed: selectRival,
                                          icon: Icon(
                                            isSelectedRival
                                                ? Icons
                                                    .check_circle_outline_rounded
                                                : Icons.sports_kabaddi_outlined,
                                            size: 18,
                                          ),
                                          label: Text(isSelectedRival
                                              ? 'محدد للتحدي'
                                              : 'اختيار المنافس'),
                                        ),
                                        if (isTasbihTab)
                                          TextButton.icon(
                                            onPressed: () =>
                                                challenge.addMemberTasbihManual(
                                                    entry.id, 33),
                                            icon: const Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('+٣٣ تسبيحة'),
                                          ),
                                        if (entry.memberRef != null)
                                          TextButton.icon(
                                            onPressed: () =>
                                                _showChallengerEditorSheet(
                                              palette,
                                              challenge,
                                              existing: entry.memberRef,
                                            ),
                                            icon: const Icon(
                                              Icons.tune_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('تعديل'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      if (!isTasbihTab && challenge.history.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        ParadiseSection(
                          title: 'أحدث المواجهات',
                          child: Column(
                            children: challenge.history.take(10).map((match) {
                              final matchColor = match.won
                                  ? const Color(0xFF18805F)
                                  : const Color(0xFF2877A3);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CalmCard(
                                  color: palette.cardColor,
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${match.modeTitle} · ${match.rivalName}',
                                              softWrap: true,
                                              style: TextStyle(
                                                color: matchColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${match.userScore} – ${match.rivalScore}',
                                            style: TextStyle(
                                              color: palette.textPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        match.phraseShown,
                                        softWrap: true,
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final rankLabel = rank == 1 ? 'الأول' : (rank == 2 ? 'الثاني' : 'الثالث');
    return CalmCard(
      color: palette.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FirdawsPortraitAvatar(
            entityId: entry.id,
            displayName: entry.name,
            customBytes: entry.isCurrentUser ? userProv.avatarBytes : null,
            customPhotoBase64:
                entry.isCurrentUser ? null : entry.customPhotoBase64,
            networkPhotoUrl: entry.isCurrentUser ? null : entry.networkPhotoUrl,
            size: 42,
            ringColor: medalColor,
            showCrown: rank == 1,
            isHighlighted: rank == 1,
          ),
          const SizedBox(height: 8),
          Text(
            rankLabel,
            style: TextStyle(
              color: medalColor,
              fontSize: FirdawsType.caption,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: FirdawsType.caption,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${entry.value} $unitLabel',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 11,
              height: 1.25,
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
                fontSize: FirdawsType.body,
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
                  fontSize: FirdawsType.label,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Firdaws3DButton(
            baseColor: won ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalmCard(
                  color: palette.cardColor,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.touch_app_outlined,
                              color: accent, size: 27),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'سباق التسبيح على جهاز واحد',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'سمّ اللاعب الثاني، ثم اضغط كل لاعب على مساحته خلال جولة مدتها ٢٠ ثانية.',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: FirdawsType.caption,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _p2NameCtrl,
                        enabled: !_duelRunning,
                        style: TextStyle(color: palette.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'اسم اللاعب الثاني',
                          hintText: 'مثال: أحد أفراد العائلة أو الأصدقاء',
                          labelStyle: TextStyle(color: palette.textSecondary),
                          prefixIcon:
                              Icon(Icons.person_outline_rounded, color: accent),
                          filled: true,
                          fillColor: palette.elevatedCardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.dividerColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  value: _duelRunning
                                      ? (_duelSecondsLeft / 20).clamp(0.0, 1.0)
                                      : 0,
                                  strokeWidth: 3,
                                  backgroundColor: palette.dividerColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _duelRunning
                                        ? const Color(0xFF176B5B)
                                        : accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                _duelRunning
                                    ? 'متبقي $_duelSecondsLeft ثانية'
                                    : 'الجولة جاهزة · ٢٠ ثانية',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _duelRunning ? null : _startTasbihDuel,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF176B5B),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          icon: Icon(_duelRunning
                              ? Icons.hourglass_top_rounded
                              : Icons.play_arrow_rounded),
                          label: Text(
                            _duelRunning ? 'الجولة جارية' : 'ابدأ السباق',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ParadiseSection(
                  title: 'مساحتا اللعب',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildDualPad(
                          playerTitle: 'اللاعب الأول · $p1',
                          portraitId: 'you',
                          portraitName: p1,
                          count: _p1DuelCount,
                          color: const Color(0xFF176B5B),
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
                          playerTitle: 'اللاعب الثاني · $p2',
                          portraitId: 'p2',
                          portraitName: p2,
                          count: _p2DuelCount,
                          color: const Color(0xFF2877A3),
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
                ),
                if (_lastDualOutcome != null) ...[
                  const SizedBox(height: 14),
                  CalmCard(
                    color: palette.cardColor,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نتيجة الجولة',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الفائز: ${_lastDualOutcome!.winnerName}',
                          softWrap: true,
                          style: const TextStyle(
                            color: Color(0xFF176B5B),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastDualOutcome!.winnerPhrase,
                          softWrap: true,
                          style: TextStyle(
                            color: palette.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const Divider(height: 24),
                        Text(
                          'تشجيع ${_lastDualOutcome!.loserName}',
                          style: const TextStyle(
                            color: Color(0xFF2877A3),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _lastDualOutcome!.loserPhrase,
                          softWrap: true,
                          style: TextStyle(
                            color: palette.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                ParadiseSection(
                  title: 'تحديات أخرى للاعبين',
                  child: Text(
                    'تابعوا المنافسة على الجهاز نفسه في المسابقة أو صالة الألعاب.',
                    softWrap: true,
                    style: TextStyle(
                      color: palette.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MillionaireQuizScreen(
                          initialMode: MillionairePlayMode.dualPlayerLocal,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF176B5B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('من سيربح المليون · لاعبان'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ArenaHubScreen(
                          initialPlayMode: ArenaPlayMode.dualPlayerLocal,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.sports_esports_outlined),
                  label: const Text('صالة الألعاب · لاعبان'),
                ),
              ],
            ),
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
    final radius = BorderRadius.circular(24);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$playerTitle، $count تسبيحة',
      hint: onTap == null
          ? 'ابدأ الجولة لتفعيل مساحة العدّ'
          : 'اضغط لتسجيل تسبيحة',
      child: Material(
        color: palette.cardColor,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: color.withOpacity(onTap == null ? .35 : .78),
                width: 1.5,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 214),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FirdawsPortraitAvatar(
                      entityId: portraitId,
                      displayName: portraitName,
                      size: 46,
                      ringColor: color,
                      isHighlighted: onTap != null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      playerTitle,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: FirdawsType.caption,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: color,
                        fontSize: 38,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      onTap != null
                          ? 'اضغط لتسجيل تسبيحة'
                          : 'بانتظار بدء الجولة',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
    final query = _phraseSearch.trim();
    final indexed = <MapEntry<int, String>>[];
    for (var i = 0; i < source.length; i++) {
      final formatted = ChallengePhrasesCatalog.formatPhrase(
        source[i],
        name: userName,
        rival: rivalName,
      );
      if (query.isEmpty || formatted.contains(query) || '${i + 1}' == query) {
        indexed.add(MapEntry(i + 1, formatted));
      }
    }

    final tabColor =
        _showWinPhrases ? const Color(0xFF18805F) : const Color(0xFF2877A3);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ParadiseSection(
                    title: 'عبارات التشجيع',
                    child: Text(
                      'استعرضوا رسائل الفوز والتحفيز، وابحثوا بالاسم أو برقم العبارة.',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ParadiseChip(
                          label: 'عبارات الفوز · ٤٠٠',
                          icon: Icons.emoji_events_outlined,
                          selected: _showWinPhrases,
                          onTap: () => setState(() => _showWinPhrases = true),
                        ),
                        const SizedBox(width: 8),
                        ParadiseChip(
                          label: 'عبارات التحفيز · ٤٠٠',
                          icon: Icons.trending_up_rounded,
                          selected: !_showWinPhrases,
                          onTap: () => setState(() => _showWinPhrases = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  TextField(
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: FirdawsType.label,
                    ),
                    onChanged: (value) => setState(() => _phraseSearch = value),
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو رقم العبارة',
                      hintStyle: TextStyle(
                        color: palette.textMuted,
                        fontSize: FirdawsType.caption,
                      ),
                      prefixIcon: Icon(Icons.search_rounded, color: tabColor),
                      filled: true,
                      fillColor: palette.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: palette.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: palette.dividerColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'عرض ${indexed.length} من ${source.length} عبارة',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: FirdawsType.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: indexed.isEmpty
              ? const Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: CalmEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'لم نعثر على عبارة مطابقة',
                      subtitle:
                          'جرّب كلمة أقصر أو ابحث برقم ضمن مجموعة العبارات المختارة.',
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 24),
                  itemCount: indexed.length,
                  itemBuilder: (_, index) {
                    final entry = indexed[index];
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: CalmCard(
                            color: palette.cardColor,
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tabColor.withOpacity(.10),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'رقم ${entry.key}',
                                        style: TextStyle(
                                          color: tabColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: FirdawsType.caption,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: entry.value));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: palette.cardColor,
                                            content: Text(
                                              'نُسخت العبارة رقم ${entry.key}.',
                                              style: TextStyle(
                                                  color: palette.textPrimary),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.copy_outlined,
                                          size: 18),
                                      label: const Text('نسخ'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.value,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: FirdawsType.label,
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    return ParadiseChip(
      label: label,
      selected: _memberGroupFilter == value,
      onTap: () => setState(() => _memberGroupFilter = value),
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
                      padding: const EdgeInsets.fromLTRB(
                          FirdawsSpace.pageGutter,
                          12,
                          FirdawsSpace.pageGutter,
                          28),
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
                                      fontSize: FirdawsType.body,
                                    ),
                                  ),
                                  Text(
                                    'تحكم كامل في الاسم، الشارة أو الصورة، العمر، الصفات، والأهداف',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: FirdawsType.caption,
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: FirdawsType.caption),
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
                                      color: Colors.orangeAccent,
                                      fontSize: FirdawsType.caption),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: FirdawsSpace.md),
                        Text(
                          'أو اختر من ٥٠ صورة شخصية حقيقية 👥:',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: FirdawsType.caption,
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
                        const SizedBox(height: FirdawsSpace.md),
                        TextField(
                          controller: relCtrl,
                          style: TextStyle(color: palette.textPrimary),
                          decoration: InputDecoration(
                            labelText:
                                'صلة القرابة أو الوصف (مثل: العائلة • الأخ)',
                            labelStyle: TextStyle(color: palette.textSecondary),
                            filled: true,
                            fillColor: firdaws3DElevatedSurfaceColor(palette),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: FirdawsSpace.md),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ChoiceChip(
                              label: const Text('العائلة 👨‍👩‍👧‍👦'),
                              selected: group == ChallengerGroup.family,
                              onSelected: (_) => setModal(() {
                                group = ChallengerGroup.family;
                              }),
                            ),
                            ChoiceChip(
                              label: const Text('الأصدقاء 🤝'),
                              selected: group == ChallengerGroup.friend,
                              onSelected: (_) => setModal(() {
                                group = ChallengerGroup.friend;
                              }),
                            ),
                            ChoiceChip(
                              label: Text('${challenge.customGroupName} 🌟'),
                              selected: group == ChallengerGroup.customGroup,
                              onSelected: (_) => setModal(() {
                                group = ChallengerGroup.customGroup;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: FirdawsSpace.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'العمر:',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: FirdawsType.label,
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
                            fontSize: FirdawsType.label,
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
                                  fontSize: FirdawsType.caption,
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
                                    color: palette.textPrimary,
                                    fontSize: FirdawsType.label),
                                decoration: InputDecoration(
                                  hintText:
                                      'أضف صفة جديدة (مثلاً: ملازم الضحى)...',
                                  hintStyle: TextStyle(
                                      color: palette.textMuted,
                                      fontSize: FirdawsType.caption),
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
                            fontSize: FirdawsType.label,
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
                        const SizedBox(height: FirdawsSpace.md),
                        Row(
                          children: [
                            Expanded(
                              child: _scoreStepperBox(
                                label: 'التسبيحات: $tasbihVal',
                                palette: palette,
                                onMinus: () => setModal(() => tasbihVal =
                                    (tasbihVal - 33).clamp(0, 999999)),
                                onPlus: () => setModal(() => tasbihVal += 33),
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
                        const SizedBox(height: FirdawsSpace.md),
                        TextField(
                          controller: bioCtrl,
                          maxLines: 2,
                          style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: FirdawsType.label),
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
                        const SizedBox(height: FirdawsSpace.lg),
                        Row(
                          children: [
                            if (isEdit && challenge.members.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await challenge
                                        .removeChallenger(existing.id);
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
                                        relationLabel:
                                            relCtrl.text.trim().isEmpty
                                                ? existing.relationLabel
                                                : relCtrl.text.trim(),
                                        age: age,
                                        traits: finalTraits,
                                        customPhotoBase64: customPhotoB64,
                                        clearCustomPhoto:
                                            customPhotoB64 == null,
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
                                    fontSize: FirdawsType.label,
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
                fontSize: FirdawsType.caption,
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

  Future<void> _showRenameCustomGroupDialog(
    ThemePalette palette,
    FamilyChallengeProvider challenge,
  ) async {
    final ctrl = TextEditingController(text: challenge.customGroupName);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: firdaws3DSurfaceColor(palette),
        title: Text(
          'تسمية المجموعة المخصّصة 🌟',
          style:
              TextStyle(color: palette.textPrimary, fontSize: FirdawsType.body),
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: palette.textPrimary),
          decoration: const InputDecoration(
            labelText: 'اسم المجموعة (مثلاً: خير الأصدقاء والعائلة)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await challenge.renameCustomGroup(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حفظ الاسم ✨'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<void> _showBluetoothChallengeSheet(
    ThemePalette palette,
    Color accent,
    FamilyChallengeProvider challenge,
    FirdawsUserProvider userProv,
  ) async {
    final bt = BluetoothChallengeService.instance;
    final codeImportCtrl = TextEditingController();

    final localProfile = BluetoothSyncedProfile(
      id: 'usr_${userProv.displayName.hashCode.abs()}',
      name: userProv.displayName,
      age: userProv.profile.age,
      traits: userProv.profile.preferences.take(4).toList(),
      avatarIndex: userProv.displayName.hashCode.abs() % 50,
      tasbihCount: challenge.userTasbihCount,
      championScore: challenge.userChampionScore,
      winsCount: challenge.userWins,
      groupLabel: challenge.customGroupName,
    );
    final shareCode = localProfile.encodeShareCode();

    bool scanning = false;
    bool hosting = false;
    String statusMsg = bt.isNativeAndroid
        ? 'اضغط «البحث عن أجهزة قريبة» أو «استقبال تحدٍّ» لتبادل البيانات والصور عبر البلوتوث 📡'
        : 'في المتصفح أو دون بلوتوث مدمج: انسخ كود ملفك أو الصق كود صديقك لإضافته فوراً ✨';
    List<BluetoothPeerDevice> devices = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.82,
                minChildSize: 0.50,
                maxChildSize: 0.95,
                builder: (_, sc) {
                  return Container(
                    decoration: BoxDecoration(
                      color: firdaws3DSurfaceColor(palette),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.55),
                        width: 1.4,
                      ),
                    ),
                    child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.fromLTRB(
                          FirdawsSpace.pageGutter,
                          12,
                          FirdawsSpace.pageGutter,
                          28),
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
                            const Icon(Icons.bluetooth_connected_rounded,
                                color: Color(0xFF10B981), size: 26),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تحدي البلوتوث القريب ومشاركة البيانات 📡',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: FirdawsType.body,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'تبادل الاسم والعمر والصفات والصورة ورصيد التسبيح والانتصارات مع صديقك القريب وضمه مباشرة إلى «${challenge.customGroupName}».',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11.8,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: FirdawsSpace.md),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color:
                                    const Color(0xFF10B981).withOpacity(0.4)),
                          ),
                          child: Text(
                            statusMsg,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 11.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (bt.isNativeAndroid) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: scanning
                                      ? null
                                      : () async {
                                          setModal(() {
                                            scanning = true;
                                            statusMsg =
                                                'جاري فحص الأجهزة القريبة والمقترنة بالبلوتوث...';
                                          });
                                          try {
                                            await bt.requestPermissions();
                                            final list = await bt.scanDevices();
                                            setModal(() {
                                              devices = list;
                                              scanning = false;
                                              statusMsg = list.isEmpty
                                                  ? 'لم يتم العثور على أجهزة بعد — تأكد من فتح البلوتوث والظهور على جهاز صديقك'
                                                  : 'تم العثور على ${list.length} جهاز — اضغط على جهاز للاتصال والمنافسة';
                                            });
                                          } catch (e) {
                                            setModal(() {
                                              scanning = false;
                                              statusMsg = 'تنبيه البلوتوث: $e';
                                            });
                                          }
                                        },
                                  icon:
                                      const Icon(Icons.radar_rounded, size: 18),
                                  label: Text(scanning
                                      ? 'جاري البحث...'
                                      : 'بحث أجهزة قريبة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    if (hosting) {
                                      await bt.stopHostExchange();
                                      setModal(() {
                                        hosting = false;
                                        statusMsg = 'تم إيقاف وضع الاستقبال.';
                                      });
                                      return;
                                    }
                                    setModal(() {
                                      hosting = true;
                                      statusMsg =
                                          'جهازك مرئي الآن! اطلب من صديقك الضغط على اسم جهازك للاتصال...';
                                    });
                                    await bt.enableDiscoverable();
                                    try {
                                      final peer = await bt
                                          .startHostExchange(localProfile);
                                      if (peer != null) {
                                        await challenge
                                            .upsertBluetoothPeerProfile(
                                          peer,
                                          targetGroup:
                                              ChallengerGroup.customGroup,
                                        );
                                        setModal(() {
                                          hosting = false;
                                          statusMsg =
                                              'تم استلام ملف «${peer.name}» وإضافته للتحدي! 🎉';
                                        });
                                      }
                                    } catch (e) {
                                      setModal(() {
                                        hosting = false;
                                        statusMsg = 'تعذر الاستقبال: $e';
                                      });
                                    }
                                  },
                                  icon: Icon(hosting
                                      ? Icons.stop_circle_outlined
                                      : Icons.wifi_tethering_rounded),
                                  label: Text(hosting
                                      ? 'إيقاف الاستقبال'
                                      : 'استقبال تحدٍّ 📡'),
                                ),
                              ),
                            ],
                          ),
                          if (devices.isNotEmpty) ...[
                            const SizedBox(height: FirdawsSpace.md),
                            ...devices.map((dev) => Card(
                                  color: firdaws3DElevatedSurfaceColor(palette),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.bluetooth_rounded,
                                      color: Color(0xFF38BDF8),
                                    ),
                                    title: Text(
                                      dev.name,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: FirdawsType.label,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${dev.address} • ${dev.isPaired ? "مقترن" : "جديد"}',
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: FirdawsType.caption,
                                      ),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () async {
                                        setModal(() => statusMsg =
                                            'جاري تبادل البيانات مع ${dev.name}...');
                                        try {
                                          final peer =
                                              await bt.connectAndExchange(
                                            address: dev.address,
                                            localProfile: localProfile,
                                          );
                                          if (peer != null) {
                                            await challenge
                                                .upsertBluetoothPeerProfile(
                                              peer,
                                              targetGroup:
                                                  ChallengerGroup.customGroup,
                                            );
                                            setModal(() => statusMsg =
                                                'تمت المزامنة مع «${peer.name}» (${peer.tasbihCount} تسبيحة) وإضافته للمنافسة! 🏆');
                                          }
                                        } catch (e) {
                                          setModal(() => statusMsg =
                                              'تأكد من تفعيل «استقبال تحدٍّ» عند ${dev.name}: $e');
                                        }
                                      },
                                      child: const Text('تحدّي ⚔️'),
                                    ),
                                  ),
                                )),
                          ],
                        ],
                        const SizedBox(height: FirdawsSpace.lg),
                        Divider(color: palette.dividerColor),
                        const SizedBox(height: 8),
                        Text(
                          'مشاركة سريعة بكود الفردوس (لأي جهاز):',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: FirdawsType.label,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: shareCode));
                                  setModal(() => statusMsg =
                                      'تم نسخ كود بطاقتك! أرسله لصديقك ليضيفك فوراً 📋');
                                },
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                label: const Text('نسخ كود بطاقتي'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: codeImportCtrl,
                                style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: FirdawsType.caption),
                                decoration: InputDecoration(
                                  hintText: 'الصق كود صديقك (FIRDAWS:...) هنا',
                                  hintStyle: TextStyle(
                                      color: palette.textMuted,
                                      fontSize: FirdawsType.caption),
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
                              onPressed: () async {
                                final parsed = BluetoothSyncedProfile.tryDecode(
                                    codeImportCtrl.text);
                                if (parsed == null) {
                                  setModal(() => statusMsg =
                                      'الكود غير صالح — تأكد من نسخه كاملاً.');
                                  return;
                                }
                                await challenge.upsertBluetoothPeerProfile(
                                  parsed,
                                  targetGroup: ChallengerGroup.customGroup,
                                );
                                codeImportCtrl.clear();
                                setModal(() => statusMsg =
                                    'تمت إضافة «${parsed.name}» بنجاح إلى «${challenge.customGroupName}»! 🎉');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: palette.onAccentColor,
                              ),
                              child: const Text('إضافة'),
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
    await bt.stopHostExchange();
    codeImportCtrl.dispose();
  }
}
