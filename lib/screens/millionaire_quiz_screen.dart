import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/events_missions_catalog.dart';
import '../models/millionaire/millionaire_models.dart';
import '../models/millionaire/millionaire_question_bank.dart';
import '../providers/family_challenge_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../services/arena_sfx_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_portrait_avatar.dart';
import '../widgets/paradise_ui.dart';
import 'hasanat_store_screen.dart';

enum MillionairePlayMode { vsAiRivals, dualPlayerLocal, familyChallenge }

class MillionaireQuizScreen extends StatefulWidget {
  final MillionairePlayMode initialMode;
  final String? initialRivalId;

  const MillionaireQuizScreen({
    super.key,
    this.initialMode = MillionairePlayMode.vsAiRivals,
    this.initialRivalId,
  });

  @override
  State<MillionaireQuizScreen> createState() => _MillionaireQuizScreenState();
}

class _MillionaireQuizScreenState extends State<MillionaireQuizScreen> {
  // إعدادات المسابقة
  bool _inLobby = true;
  MillionairePlayMode _playMode = MillionairePlayMode.vsAiRivals;
  String? _selectedCategory; // null = ١٠٠٠ سؤال متنوعة
  MillionaireVirtualOpponent _selectedAiRival =
      MillionaireLadderConfig.virtualRivals.first;
  String? _selectedFamilyRivalId;
  final TextEditingController _p1NameCtrl =
      TextEditingController(text: 'اللاعب ١');
  final TextEditingController _p2NameCtrl =
      TextEditingController(text: 'اللاعب ٢');

  // حالة اللعب الفعلية
  late MillionaireSessionBundle _bundle;
  late List<MillionaireQuestion> _questions;
  int _currentRungIndex = 0; // 0..14 (السؤال الحالي ١..١٥)
  int _guaranteedAmount = 0;
  int _currentEarnedAmount = 0;

  // وضع ٢ لاعبين (مشاركة ٢ في نفس اللعبة)
  int _activePlayerTurn = 1; // 1 أو 2
  int _p1Score = 0;
  int _p2Score = 0;
  int _p1CorrectCount = 0;
  int _p2CorrectCount = 0;

  // حالة السؤال
  int? _lockedOptionIndex;
  bool _answerRevealed = false;
  bool _matchFinished = false;
  bool _walkedAway = false;
  bool _gameOverLost = false;
  String _postMatchPhrase = '';
  String _postMatchSecondPhrase = '';

  // المؤقت ٣٥ ثانية
  static const int _maxSecondsPerQuestion = 35;
  int _secondsLeft = _maxSecondsPerQuestion;
  Timer? _countdownTimer;
  final List<Timer> _pendingTimers = [];

  void _schedule(Duration delay, VoidCallback fn) {
    late Timer timer;
    timer = Timer(delay, () {
      _pendingTimers.remove(timer);
      if (mounted) fn();
    });
    _pendingTimers.add(timer);
  }

  // وسائل المساعدة الأربع
  bool _used5050 = false;
  bool _usedCallFriend = false;
  bool _usedAudiencePoll = false;
  bool _usedSwapQuestion = false;
  final Set<int> _eliminatedOptions = {};

  // تقدم المنافس الافتراضي / العائلي
  int _aiRivalStep = 0;
  int _aiRivalScore = 0;

  @override
  void initState() {
    super.initState();
    _playMode = widget.initialMode;
    _selectedFamilyRivalId = widget.initialRivalId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<FirdawsUserProvider>();
      if (user.displayName.trim().isNotEmpty) {
        _p1NameCtrl.text = user.displayName.trim();
      }
      final fam = context.read<FamilyChallengeProvider>();
      if (_selectedFamilyRivalId == null && fam.members.isNotEmpty) {
        setState(() {
          _selectedFamilyRivalId = fam.selectedRivalId;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    _p1NameCtrl.dispose();
    _p2NameCtrl.dispose();
    super.dispose();
  }

  void _startMatch() {
    _countdownTimer?.cancel();
    _bundle = MillionaireQuestionBank.generateSessionLadder(
      categoryFilter: _selectedCategory,
    );
    _questions = List<MillionaireQuestion>.from(_bundle.ladderQuestions);

    setState(() {
      _inLobby = false;
      _currentRungIndex = 0;
      _guaranteedAmount = 0;
      _currentEarnedAmount = 0;
      _activePlayerTurn = 1;
      _p1Score = 0;
      _p2Score = 0;
      _p1CorrectCount = 0;
      _p2CorrectCount = 0;
      _lockedOptionIndex = null;
      _answerRevealed = false;
      _matchFinished = false;
      _walkedAway = false;
      _gameOverLost = false;
      _postMatchPhrase = '';
      _postMatchSecondPhrase = '';
      _used5050 = false;
      _usedCallFriend = false;
      _usedAudiencePoll = false;
      _usedSwapQuestion = false;
      _eliminatedOptions.clear();
      _aiRivalStep = 0;
      _aiRivalScore = 0;
    });

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = _maxSecondsPerQuestion);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _answerRevealed || _matchFinished || _inLobby) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _handleTimeExpired();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _handleTimeExpired() {
    HapticFeedback.heavyImpact();
    ArenaSfxService.instance.playDamage();
    if (_playMode == MillionairePlayMode.dualPlayerLocal) {
      // في وضع لاعبين محلي، انتهاء الوقت يفقد اللاعب دوره ويكمل الصاحبه الدور
      setState(() {
        _answerRevealed = true;
        _lockedOptionIndex = null;
      });
      _schedule(const Duration(milliseconds: 1600), () {
        if (mounted && !_matchFinished) _advanceNextRung(wasCorrect: false);
      });
    } else {
      setState(() {
        _answerRevealed = true;
        _gameOverLost = true;
        _currentEarnedAmount = _guaranteedAmount;
      });
      _finalizeMatch();
    }
  }

  void _onSelectOption(int idx) {
    if (_answerRevealed || _matchFinished || _eliminatedOptions.contains(idx)) {
      return;
    }
    _countdownTimer?.cancel();
    HapticFeedback.mediumImpact();
    ArenaSfxService.instance.playTap();

    final q = _questions[_currentRungIndex];
    final isCorrect = idx == q.correctIndex;

    setState(() {
      _lockedOptionIndex = idx;
    });

    // تشويق لحظة التثبيت ثم الكشف
    _schedule(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _answerRevealed = true;
      });
      HapticFeedback.lightImpact();

      // تحريك المنافس الافتراضي أو العائلي في كل خطوة
      _simulateRivalStep(rungIndex: _currentRungIndex);

      if (isCorrect) {
        if (_currentRungIndex >= 5) {
          ArenaSfxService.instance.playCombo();
        } else {
          ArenaSfxService.instance.playScore();
        }
        try {
          final hasanat = Provider.of<HasanatProvider>(context, listen: false);
          hasanat.earnHasanat(
            12,
            reason: 'إجابة صحيحة في من سيربح المليون',
            sourceTag: 'المليونير',
          );
          hasanat.recordMetric(
            EventMissionMetric.millionaireRungs,
            delta: 1,
          );
        } catch (_) {}

        final rung = MillionaireLadderConfig.rungs[_currentRungIndex];
        setState(() {
          _currentEarnedAmount = rung.amount;
          if (rung.isSafeHaven) {
            _guaranteedAmount = rung.amount;
          }
          if (_playMode == MillionairePlayMode.dualPlayerLocal) {
            final gain = 100 + (_secondsLeft * 3) + (_currentRungIndex * 40);
            if (_activePlayerTurn == 1) {
              _p1Score += gain;
              _p1CorrectCount++;
            } else {
              _p2Score += gain;
              _p2CorrectCount++;
            }
          }
        });

        _schedule(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          if (_currentRungIndex >= _questions.length - 1) {
            _finalizeMatch();
          } else {
            _advanceNextRung(wasCorrect: true);
          }
        });
      } else {
        ArenaSfxService.instance.playDamage();
        if (_playMode == MillionairePlayMode.dualPlayerLocal) {
          // في وضع مشاركة ٢ يستمر التنافس حتى نهاية الـ ١٥ سؤالاً
          _schedule(const Duration(milliseconds: 1700), () {
            if (!mounted) return;
            if (_currentRungIndex >= _questions.length - 1) {
              _finalizeMatch();
            } else {
              _advanceNextRung(wasCorrect: false);
            }
          });
        } else {
          // في الفردي / التحدي يرجع لأقرب محطة أمان
          setState(() {
            _gameOverLost = true;
            _currentEarnedAmount = _guaranteedAmount;
          });
          _schedule(const Duration(milliseconds: 1800), () {
            if (mounted) _finalizeMatch();
          });
        }
      }
    });
  }

  void _simulateRivalStep({required int rungIndex}) {
    if (_playMode == MillionairePlayMode.dualPlayerLocal) return;
    final rng = math.Random(rungIndex * 97 + DateTime.now().millisecond);
    final penalty = rungIndex * 0.022;
    final hitChance =
        (_selectedAiRival.accuracyRate - penalty).clamp(0.35, 0.94);
    if (rng.nextDouble() <= hitChance && _aiRivalStep == rungIndex) {
      _aiRivalStep++;
      _aiRivalScore = MillionaireLadderConfig.rungs[rungIndex].amount;
    }
  }

  void _advanceNextRung({required bool wasCorrect}) {
    if (!mounted || _matchFinished) return;
    if (_currentRungIndex >= _questions.length - 1) {
      _finalizeMatch();
      return;
    }
    setState(() {
      _currentRungIndex++;
      _lockedOptionIndex = null;
      _answerRevealed = false;
      _eliminatedOptions.clear();
      if (_playMode == MillionairePlayMode.dualPlayerLocal) {
        _activePlayerTurn = _activePlayerTurn == 1 ? 2 : 1;
      }
    });
    _startQuestionTimer();
  }

  void _walkAwayNow() {
    if (_matchFinished || _answerRevealed) return;
    _countdownTimer?.cancel();
    setState(() {
      _walkedAway = true;
    });
    _finalizeMatch();
  }

  Future<void> _finalizeMatch() async {
    if (_matchFinished) return;
    _countdownTimer?.cancel();

    final userProv = context.read<FirdawsUserProvider>();
    final famProv = context.read<FamilyChallengeProvider>();
    final jannatiProv = context.read<JannatiProvider>();
    HasanatProvider? hasanat;
    try {
      hasanat = context.read<HasanatProvider>();
    } catch (_) {}

    final userName = _p1NameCtrl.text.trim().isEmpty
        ? (userProv.displayName.trim().isEmpty
            ? 'أنت'
            : userProv.displayName.trim())
        : _p1NameCtrl.text.trim();

    if (_playMode == MillionairePlayMode.dualPlayerLocal) {
      final p2Name = _p2NameCtrl.text.trim().isEmpty
          ? 'اللاعب ٢'
          : _p2NameCtrl.text.trim();
      final outcome = famProv.recordDualPlayerMatch(
        player1Name: userName,
        player1Score: _p1Score,
        player2Name: p2Name,
        player2Score: _p2Score,
        modeTitle: 'من سيربح المليون (٢ لاعبين)',
      );
      await jannatiProv.recordArenaKnowledgeReward(
        'جولة ثنائية في من سيربح المليون ($userName ضد $p2Name)',
        math.max(_p1Score, _p2Score) ~/ 10 + 40,
      );
      if (hasanat != null) {
        try {
          await hasanat.earnHasanat(
            35 + (_p1CorrectCount * 5),
            reason: 'تحدي المليونير الثنائي',
            sourceTag: 'المليونير',
          );
          await hasanat.recordMetric(
            EventMissionMetric.dualPlayerMatches,
            delta: 1,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      if (_p1Score >= _p2Score) {
        ArenaSfxService.instance.playWin();
      } else {
        ArenaSfxService.instance.playLose();
      }
      setState(() {
        _matchFinished = true;
        _postMatchPhrase = outcome.winnerPhrase;
        _postMatchSecondPhrase = outcome.loserPhrase;
      });
      return;
    }

    final targetRivalId = _playMode == MillionairePlayMode.familyChallenge
        ? (_selectedFamilyRivalId ?? famProv.selectedRivalId)
        : famProv.selectedRivalId;

    final userStepScore = _currentEarnedAmount;
    final rivalCompareScore = _playMode == MillionairePlayMode.vsAiRivals
        ? _aiRivalScore
        : (_guaranteedAmount > 0 ? _guaranteedAmount : 2000);

    final bool won;
    if (_gameOverLost && _currentEarnedAmount == 0) {
      won = false;
    } else if (_currentRungIndex >= 14 && !_gameOverLost) {
      won = true;
    } else {
      won = userStepScore >= rivalCompareScore && !_gameOverLost;
    }

    if (won && !_gameOverLost) {
      ArenaSfxService.instance.playWin();
    } else {
      ArenaSfxService.instance.playLose();
    }

    final phrase = await famProv.recordChallengeMatchResult(
      userName: userName,
      rivalId: targetRivalId,
      modeTitle: _playMode == MillionairePlayMode.familyChallenge
          ? 'تحدي من سيربح المليون'
          : 'استوديو المليون (${_selectedAiRival.name})',
      userScore: (userStepScore ~/ 100) + (_currentRungIndex * 10),
      rivalScore:
          won ? (rivalCompareScore ~/ 200) : (rivalCompareScore ~/ 100) + 150,
      forceWonIfTie: won,
    );

    final rewardPts = 25 + (_currentRungIndex * 12) + (won ? 80 : 10);
    await jannatiProv.recordArenaKnowledgeReward(
      'مسابقة من سيربح المليون (المرحلة ${_currentRungIndex + 1})',
      rewardPts,
    );
    if (hasanat != null) {
      try {
        await hasanat.earnHasanat(
          won ? 55 : 20,
          reason: won ? 'فوز في استوديو المليونير 🏆' : 'ختام جولة المليونير',
          sourceTag: 'المليونير',
        );
        await hasanat.recordMetric(
          EventMissionMetric.arenaMatchesPlayed,
          delta: 1,
        );
        if (won) {
          await hasanat.recordMetric(
            EventMissionMetric.arenaMatchesWon,
            delta: 1,
          );
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _matchFinished = true;
      _postMatchPhrase = phrase;
    });
  }

  // ==================== وسائل المساعدة ====================

  void _use5050() {
    if (_used5050 || _answerRevealed || _matchFinished) return;
    HapticFeedback.selectionClick();
    ArenaSfxService.instance.playTap();
    final q = _questions[_currentRungIndex];
    final wrongIndices = [0, 1, 2, 3].where((i) => i != q.correctIndex).toList()
      ..shuffle();
    setState(() {
      _used5050 = true;
      _eliminatedOptions.addAll(wrongIndices.take(2));
    });
  }

  void _useSwapQuestion() {
    if (_usedSwapQuestion || _answerRevealed || _matchFinished) return;
    HapticFeedback.selectionClick();
    ArenaSfxService.instance.playTap();
    final cur = _questions[_currentRungIndex];
    final spare = _bundle.pickSpareFor(cur.difficulty);
    if (spare == null) return;
    setState(() {
      _usedSwapQuestion = true;
      _questions[_currentRungIndex] = spare;
      _eliminatedOptions.clear();
      _lockedOptionIndex = null;
    });
    _startQuestionTimer();
  }

  void _useCallScholar(ThemePalette palette) {
    if (_usedCallFriend || _answerRevealed || _matchFinished) return;
    HapticFeedback.selectionClick();
    ArenaSfxService.instance.playTap();
    setState(() => _usedCallFriend = true);

    final q = _questions[_currentRungIndex];
    final letters = ['أ', 'ب', 'ج', 'د'];
    final rng = math.Random(_currentRungIndex + 31);
    final confidence = q.difficulty == MillionaireDifficulty.easy
        ? 92
        : (q.difficulty == MillionaireDifficulty.medium ? 81 : 70);
    final suggestedIndex = rng.nextInt(100) < confidence
        ? q.correctIndex
        : ([0, 1, 2, 3].where((i) => !_eliminatedOptions.contains(i)).first);

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: firdaws3DSurfaceColor(palette),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
          title: const Row(
            children: [
              Text('📞 ', style: TextStyle(fontSize: FirdawsType.headline)),
              Flexible(
                child: Text(
                  'اتصال بالشيخ الحكيم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: FirdawsType.section),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '«السلام عليكم ورحمة الله! بعد تدقيق السؤال أرى بإذن الله أن الإجابة الأرجح هي:»',
                style: TextStyle(fontSize: FirdawsType.label, height: 1.5),
              ),
              const SizedBox(height: 12),
              Firdaws3DCard(
                palette: palette,
                glowColor: const Color(0xFF10B981),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخيار (${letters[suggestedIndex]}): ${q.options[suggestedIndex]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: FirdawsType.label,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'نسبة الثقة العلمية: $confidence٪',
                      style: TextStyle(
                        fontSize: FirdawsType.caption,
                        color: firdawsCrispSecondaryText(palette),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('شكراً جزيلاً'),
            ),
          ],
        ),
      ),
    );
  }

  void _useAudiencePoll(ThemePalette palette) {
    if (_usedAudiencePoll || _answerRevealed || _matchFinished) return;
    HapticFeedback.selectionClick();
    ArenaSfxService.instance.playTap();
    setState(() => _usedAudiencePoll = true);

    final q = _questions[_currentRungIndex];
    final rng = math.Random(_currentRungIndex * 17 + 9);
    final weights = List<int>.filled(4, 0);
    int correctShare = q.difficulty == MillionaireDifficulty.easy
        ? 68 + rng.nextInt(15)
        : (q.difficulty == MillionaireDifficulty.medium
            ? 52 + rng.nextInt(15)
            : 40 + rng.nextInt(16));

    int remaining = 100 - correctShare;
    final availableOthers = [0, 1, 2, 3]
        .where((i) => i != q.correctIndex && !_eliminatedOptions.contains(i))
        .toList();

    weights[q.correctIndex] = correctShare;
    for (int i = 0; i < availableOthers.length; i++) {
      final idx = availableOthers[i];
      if (i == availableOthers.length - 1) {
        weights[idx] = remaining;
      } else {
        final slice = rng.nextInt(remaining + 1);
        weights[idx] = slice;
        remaining -= slice;
      }
    }

    const letters = ['أ', 'ب', 'ج', 'د'];
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: firdaws3DSurfaceColor(palette),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
          ),
          title: const Text(
            '📊 تصويت الجمهور المباشر',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: FirdawsType.section),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 170,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(4, (i) {
                    final pct = weights[i];
                    final barH = (pct / 100.0) * 115.0 + 10.0;
                    final col = i == q.correctIndex
                        ? const Color(0xFF10B981)
                        : const Color(0xFF38BDF8);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$pct٪',
                          style: TextStyle(
                            fontSize: FirdawsType.caption,
                            fontWeight: FontWeight.w900,
                            color: col,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 36,
                          height: barH,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [col, col.withOpacity(0.45)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: col.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          letters[i],
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: FirdawsType.label,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('متابعة المسابقة'),
            ),
          ],
        ),
      ),
    );
  }

  void _openLadderSheet(ThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.sizeOf(context).height * .86,
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: palette.dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
              top: false,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                            color: palette.dividerColor,
                            borderRadius: BorderRadius.circular(6)))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ParadiseHero(
                      title: 'سُلّم الجوائز',
                      subtitle:
                          '١٥ محطة للتقدّم، مع محطات أمان تحفظ ما وصلت إليه.',
                      imageAsset: Theme.of(context)
                          .extension<FirdawsNatureLook>()
                          ?.sceneryAsset,
                      minHeight: 142,
                    )),
                const SizedBox(height: 10),
                Expanded(
                    child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  itemCount: MillionaireLadderConfig.rungs.length,
                  itemBuilder: (_, index) {
                    final rung = MillionaireLadderConfig.rungs[index];
                    final current = index == _currentRungIndex;
                    final passed = index < _currentRungIndex;
                    final rivalHere =
                        _playMode == MillionairePlayMode.vsAiRivals &&
                            _aiRivalStep == index + 1;
                    final tone = current
                        ? palette.accentColor
                        : (passed
                            ? const Color(0xFF16835D)
                            : palette.dividerColor);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: current
                            ? palette.elevatedCardColor
                            : palette.cardColor,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                            color: current
                                ? palette.accentColor
                                : palette.dividerColor,
                            width: current ? 1.6 : 1),
                      ),
                      child: Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tone.withOpacity(.12),
                              border: Border.all(color: tone.withOpacity(.55))),
                          child: Center(
                              child: Text('${rung.step}',
                                  style: TextStyle(
                                      color: tone,
                                      fontWeight: FontWeight.w900))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(rung.formattedAmount,
                                  softWrap: true,
                                  style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: FirdawsType.body)),
                              if (rung.isSafeHaven || rivalHere) ...[
                                const SizedBox(height: 5),
                                Wrap(spacing: 8, runSpacing: 4, children: [
                                  if (rung.isSafeHaven)
                                    _stageTag(
                                        'محطة أمان', const Color(0xFF16835D)),
                                  if (rivalHere)
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FirdawsPortraitAvatar(
                                              entityId: _selectedAiRival.id,
                                              displayName:
                                                  _selectedAiRival.name,
                                              size: 22),
                                          const SizedBox(width: 5),
                                          Text('المنافس',
                                              style: TextStyle(
                                                  color: palette.textSecondary,
                                                  fontSize:
                                                      FirdawsType.caption)),
                                        ]),
                                ]),
                              ],
                            ])),
                        if (current)
                          Icon(Icons.my_location_rounded,
                              color: palette.accentColor, size: 20)
                        else if (passed)
                          const Icon(Icons.check_circle_outline_rounded,
                              color: Color(0xFF16835D), size: 20),
                      ]),
                    );
                  },
                )),
              ])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final palette = settings.currentPalette;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.scaffoldColor,
        body: SafeArea(
          child: _inLobby
              ? _buildLobbyView(palette)
              : (_matchFinished
                  ? _buildPostMatchView(palette)
                  : _buildStageQuizView(palette)),
        ),
      ),
    );
  }

  Widget _buildLobbyView(ThemePalette palette) {
    final fam = context.watch<FamilyChallengeProvider>();
    final categories = MillionaireQuestionBank.categories;
    final secondary = firdawsCrispSecondaryText(palette);
    final scenery =
        Theme.of(context).extension<FirdawsNatureLook>()?.sceneryAsset;
    final ctaTextColor =
        ThemeData.estimateBrightnessForColor(palette.primaryColor) ==
                Brightness.dark
            ? Colors.white
            : const Color(0xFF102019);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 12, 4),
          child: Row(children: [
            IconButton(
              tooltip: 'العودة',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مسابقة المليون',
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: FirdawsType.title,
                        fontWeight: FontWeight.w900)),
                Text('اختر منافستك ثم ابدأ الجولة',
                    style: TextStyle(
                        color: secondary, fontSize: FirdawsType.caption)),
              ],
            )),
            Builder(builder: (ctx) {
              int balance = 0;
              try {
                balance = ctx.watch<HasanatProvider>().hasanatBalance;
              } catch (_) {}
              return Firdaws3DPill(
                label: '$balance حسنة',
                icon: Icons.toll_rounded,
                accentColor: const Color(0xFFD0A94A),
                palette: palette,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const HasanatStoreScreen())),
              );
            }),
          ]),
        ),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ParadiseHero(
                      title: 'من سيربح المليون؟',
                      subtitle:
                          'رحلة أسئلة من ١٥ محطة؛ تقدّم بثبات واختر الإجابة التي تثق بها.',
                      imageAsset: scenery,
                      minHeight: 244,
                      footer: const Wrap(spacing: 8, runSpacing: 8, children: [
                        ParadiseChip(
                            label: '١٥ محطة', icon: Icons.stairs_rounded),
                        ParadiseChip(
                            label: '٤ وسائل مساعدة',
                            icon: Icons.lightbulb_outline_rounded),
                        ParadiseChip(
                            label: 'ثلاثة أنماط', icon: Icons.groups_rounded),
                      ]),
                    ),
                    const SizedBox(height: 28),
                    ParadiseSection(
                      title: 'اختر طريقة المنافسة',
                      child: Column(children: [
                        _buildModeSelectorCard(
                            palette: palette,
                            mode: MillionairePlayMode.vsAiRivals,
                            title: 'منافس افتراضي',
                            subtitle: 'اختر متسابقًا وتابع تقدمه مع محطاتك.',
                            icon: '🤖',
                            color: const Color(0xFF4B8E7B)),
                        const SizedBox(height: 10),
                        _buildModeSelectorCard(
                            palette: palette,
                            mode: MillionairePlayMode.dualPlayerLocal,
                            title: 'لاعبان على جهاز واحد',
                            subtitle:
                                'تناوبا على الإجابة، واجمعا النقاط خلال الجولة.',
                            icon: '🤝',
                            color: const Color(0xFF4B8E7B)),
                        const SizedBox(height: 10),
                        _buildModeSelectorCard(
                            palette: palette,
                            mode: MillionairePlayMode.familyChallenge,
                            title: 'تحدي العائلة والصحبة',
                            subtitle:
                                'اختر منافسًا من قائمتك وسجّل نتيجة التحدي.',
                            icon: '🏆',
                            color: const Color(0xFF8A6A9D)),
                      ]),
                    ),
                    const SizedBox(height: 26),
                    if (_playMode == MillionairePlayMode.vsAiRivals)
                      ParadiseSection(
                        title: 'اختر منافسك',
                        child: LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth < 560
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: MillionaireLadderConfig.virtualRivals
                                .map((rival) {
                              final selected = rival.id == _selectedAiRival.id;
                              return SizedBox(
                                  width: width,
                                  child: Material(
                                    color: selected
                                        ? palette.elevatedCardColor
                                        : palette.cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                          color: selected
                                              ? palette.accentColor
                                              : palette.dividerColor),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () => setState(
                                          () => _selectedAiRival = rival),
                                      child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(children: [
                                            FirdawsPortraitAvatar(
                                                entityId: rival.id,
                                                displayName: rival.name,
                                                size: 44,
                                                ringColor: selected
                                                    ? palette.accentColor
                                                    : null,
                                                isHighlighted: selected),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(rival.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: palette
                                                              .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: FirdawsType
                                                              .body)),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                      'دقة ${(rival.accuracyRate * 100).round()}٪',
                                                      style: TextStyle(
                                                          color: secondary,
                                                          fontSize: FirdawsType
                                                              .caption)),
                                                ])),
                                            Icon(
                                                selected
                                                    ? Icons.check_circle_rounded
                                                    : Icons.circle_outlined,
                                                color: selected
                                                    ? palette.accentColor
                                                    : palette.textMuted),
                                          ])),
                                    ),
                                  ));
                            }).toList(),
                          );
                        }),
                      )
                    else if (_playMode == MillionairePlayMode.dualPlayerLocal)
                      ParadiseSection(
                          title: 'أسماء اللاعبين',
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final fields = [
                                TextField(
                                    controller: _p1NameCtrl,
                                    style:
                                        TextStyle(color: palette.textPrimary),
                                    decoration: InputDecoration(
                                        labelText: 'اللاعب الأول',
                                        filled: true,
                                        fillColor: palette.cardColor,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)))),
                                TextField(
                                    controller: _p2NameCtrl,
                                    style:
                                        TextStyle(color: palette.textPrimary),
                                    decoration: InputDecoration(
                                        labelText: 'اللاعب الثاني',
                                        filled: true,
                                        fillColor: palette.cardColor,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)))),
                              ];
                              if (constraints.maxWidth < 460) {
                                return Column(children: [
                                  fields[0],
                                  const SizedBox(height: 12),
                                  fields[1]
                                ]);
                              }
                              return Row(children: [
                                Expanded(child: fields[0]),
                                const SizedBox(width: 12),
                                Expanded(child: fields[1])
                              ]);
                            },
                          ))
                    else
                      ParadiseSection(
                        title: 'اختر منافسًا من العائلة أو الصحبة',
                        child: fam.members.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                    color: palette.cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: palette.dividerColor)),
                                child: Row(children: [
                                  Icon(Icons.people_outline_rounded,
                                      color: palette.accentColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(
                                          'لا توجد أسماء متاحة في القائمة بعد. يمكنك بدء الجولة، وسيُستخدم المنافس المحدد في إعدادات العائلة.',
                                          style: TextStyle(
                                              color: palette.textPrimary,
                                              height: 1.45))),
                                ]))
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: fam.members.map((member) {
                                  final selected = member.id ==
                                      (_selectedFamilyRivalId ??
                                          fam.selectedRivalId);
                                  return ParadiseChip(
                                    label: member.name,
                                    icon: selected
                                        ? Icons.check_circle_rounded
                                        : Icons.person_outline_rounded,
                                    selected: selected,
                                    onTap: () {
                                      setState(() =>
                                          _selectedFamilyRivalId = member.id);
                                      fam.selectRival(member.id);
                                    },
                                  );
                                }).toList()),
                      ),
                    const SizedBox(height: 26),
                    ParadiseSection(
                        title: 'حدّد مجال الأسئلة',
                        child: Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            ParadiseChip(
                                label:
                                    'شامل · ${MillionaireQuestionBank.totalCount} سؤال',
                                icon: Icons.auto_awesome_rounded,
                                selected: _selectedCategory == null,
                                onTap: () =>
                                    setState(() => _selectedCategory = null)),
                            ...categories.map((category) => ParadiseChip(
                                label: category,
                                selected: _selectedCategory == category,
                                onTap: () => setState(
                                    () => _selectedCategory = category))),
                          ],
                        )),
                    const SizedBox(height: 18),
                  ]),
            )),
          ],
        )),
        SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                  color: palette.cardColor,
                  border: Border(top: BorderSide(color: palette.dividerColor))),
              child: Center(
                  child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: SizedBox(
                    width: double.infinity,
                    child: Firdaws3DButton(
                      baseColor: palette.primaryColor,
                      onPressed: _startMatch,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 14),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: ctaTextColor, size: 25),
                            const SizedBox(width: 8),
                            Flexible(
                                child: Text('ابدأ جولة المليون',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                        color: ctaTextColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: FirdawsType.body))),
                          ]),
                    )),
              )),
            )),
      ],
    );
  }

  Widget _buildModeSelectorCard({
    required ThemePalette palette,
    required MillionairePlayMode mode,
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    final selected = _playMode == mode;
    final glyph = icon == '🤖'
        ? Icons.psychology_alt_rounded
        : (icon == '🤝' ? Icons.people_alt_rounded : Icons.diversity_3_rounded);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.elevatedCardColor : palette.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: selected ? color : palette.dividerColor,
              width: selected ? 1.6 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _playMode = mode),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: color.withOpacity(.12), shape: BoxShape.circle),
                    child: Icon(glyph, color: color, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          softWrap: true,
                          style: TextStyle(
                              color: selected ? color : palette.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: FirdawsType.body)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          softWrap: true,
                          style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: FirdawsType.caption,
                              height: 1.4)),
                    ])),
                const SizedBox(width: 8),
                Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected ? color : palette.textMuted),
              ])),
        ),
      ),
    );
  }

  Widget _buildStageQuizView(ThemePalette palette) {
    final q = _questions[_currentRungIndex];
    final rung = MillionaireLadderConfig.rungs[_currentRungIndex];
    final secondary = firdawsCrispSecondaryText(palette);
    final isUrgent = _secondsLeft <= 8;
    final scenery =
        Theme.of(context).extension<FirdawsNatureLook>()?.sceneryAsset;
    const letters = ['أ', 'ب', 'ج', 'د'];

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
        child: Row(children: [
          Firdaws3DPill(
              label: 'اترك الجولة',
              icon: Icons.logout_rounded,
              accentColor: palette.accentColor,
              palette: palette,
              onTap: _walkAwayNow),
          const Spacer(),
          Firdaws3DPill(
              label: 'سُلّم الجوائز',
              icon: Icons.stairs_rounded,
              accentColor: palette.accentColor,
              palette: palette,
              onTap: () => _openLadderSheet(palette)),
        ]),
      ),
      Expanded(child: LayoutBuilder(builder: (context, constraints) {
        return Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                ParadiseHero(
                  title: 'المحطة ${rung.step} من ١٥',
                  subtitle:
                      '${rung.formattedAmount} • ${rung.isSafeHaven ? 'محطة أمان' : 'تابع تقدّمك نحو المحطة التالية'}',
                  imageAsset: scenery,
                  minHeight: 174,
                  footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Icon(Icons.hourglass_bottom_rounded,
                              color: isUrgent
                                  ? const Color(0xFFFFB8B8)
                                  : const Color(0xFFE8D6A7),
                              size: 19),
                          const SizedBox(width: 7),
                          Text('الوقت المتبقي للإجابة',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.94),
                                  fontSize: FirdawsType.caption)),
                          const Spacer(),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: isUrgent
                                      ? const Color(0xFFB42332)
                                      : Colors.white.withOpacity(.16),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: isUrgent
                                          ? const Color(0xFFFFC1C1)
                                          : Colors.white.withOpacity(.35))),
                              child: Text('$_secondsLeft ث',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: FirdawsType.body))),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                                value: rung.step / 15,
                                minHeight: 5,
                                backgroundColor: Colors.white.withOpacity(.28),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFD8C28C)))),
                      ]),
                ),
                const SizedBox(height: 20),
                ParadiseSection(
                    title: 'المنافسة الآن',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _playMode == MillionairePlayMode.dualPlayerLocal
                          ? [
                              _DualScoreChip(
                                  name: _p1NameCtrl.text.isEmpty
                                      ? 'اللاعب ١'
                                      : _p1NameCtrl.text,
                                  score: _p1Score,
                                  active: _activePlayerTurn == 1,
                                  color: const Color(0xFF327C68),
                                  palette: palette),
                              _DualScoreChip(
                                  name: _p2NameCtrl.text.isEmpty
                                      ? 'اللاعب ٢'
                                      : _p2NameCtrl.text,
                                  score: _p2Score,
                                  active: _activePlayerTurn == 2,
                                  color: const Color(0xFF507A9B),
                                  palette: palette),
                            ]
                          : _buildCurrentRival(palette, secondary),
                    )),
                const SizedBox(height: 20),
                ParadiseSection(
                    title: 'وسائل المساعدة',
                    child: LayoutBuilder(builder: (context, box) {
                      final itemWidth = box.maxWidth < 540
                          ? (box.maxWidth - 8) / 2
                          : (box.maxWidth - 24) / 4;
                      Widget item(IconData icon, String label, bool used,
                              Color color, VoidCallback onTap) =>
                          SizedBox(
                              width: itemWidth,
                              child: _Lifeline3DChip(
                                  icon: icon,
                                  label: label,
                                  used: used,
                                  disabled: _answerRevealed ||
                                      _matchFinished ||
                                      _lockedOptionIndex != null,
                                  color: color,
                                  palette: palette,
                                  onTap: onTap));
                      return Wrap(spacing: 8, runSpacing: 8, children: [
                        item(Icons.content_cut_rounded, '٥٠:٥٠', _used5050,
                            palette.accentColor, _use5050),
                        item(
                            Icons.call_rounded,
                            'اتصال',
                            _usedCallFriend,
                            const Color(0xFF3E9273),
                            () => _useCallScholar(palette)),
                        item(
                            Icons.bar_chart_rounded,
                            'الجمهور',
                            _usedAudiencePoll,
                            const Color(0xFF796B9B),
                            () => _useAudiencePoll(palette)),
                        item(
                            Icons.swap_horiz_rounded,
                            'تبديل',
                            _usedSwapQuestion,
                            const Color(0xFF9B6D56),
                            _useSwapQuestion),
                      ]);
                    })),
                const SizedBox(height: 22),
                ParadiseSection(
                    title: 'نص السؤال',
                    child: Material(
                      color: palette.cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(color: palette.dividerColor)),
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    _stageTag(
                                        '${q.category} · ${q.difficulty.arabicLabel}',
                                        q.difficulty.color),
                                    if (_guaranteedAmount > 0)
                                      _stageTag(
                                          'المضمون: $_guaranteedAmount نقطة',
                                          const Color(0xFF16835D)),
                                  ]),
                              const SizedBox(height: 18),
                              Text(q.question,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                      color: palette.textPrimary,
                                      fontSize: FirdawsType.section,
                                      height: 1.6,
                                      fontWeight: FontWeight.w900)),
                            ],
                          )),
                    )),
                const SizedBox(height: 20),
                ParadiseSection(
                    title: 'اختر الإجابة',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('اختر أحد الخيارات الأربعة لتثبيت إجابتك.',
                            style: TextStyle(
                                color: secondary,
                                fontSize: FirdawsType.caption,
                                height: 1.4)),
                        const SizedBox(height: 10),
                        LayoutBuilder(builder: (context, box) {
                          final answerWidth = box.maxWidth >= 650
                              ? (box.maxWidth - 12) / 2
                              : box.maxWidth;
                          return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(4, (index) {
                                final eliminated =
                                    _eliminatedOptions.contains(index);
                                final locked = _lockedOptionIndex == index;
                                final correct = index == q.correctIndex;
                                final disabled = eliminated ||
                                    _answerRevealed ||
                                    _matchFinished ||
                                    _lockedOptionIndex != null;
                                final border = _answerRevealed && correct
                                    ? const Color(0xFF16835D)
                                    : (_answerRevealed && locked
                                        ? const Color(0xFFB42332)
                                        : (locked
                                            ? palette.accentColor
                                            : palette.dividerColor));
                                final feedback = _answerRevealed && correct
                                    ? '، الإجابة الصحيحة'
                                    : (_answerRevealed && locked
                                        ? '، إجابة غير صحيحة'
                                        : (eliminated ? '، مستبعد' : ''));
                                return SizedBox(
                                    width: answerWidth,
                                    child: Semantics(
                                      button: true,
                                      enabled: !disabled,
                                      selected: locked,
                                      liveRegion: _answerRevealed &&
                                          (correct || locked),
                                      label:
                                          'الخيار ${letters[index]}: ${q.options[index]}$feedback',
                                      excludeSemantics: true,
                                      child: Opacity(
                                        opacity: eliminated ? .48 : 1,
                                        child: Material(
                                          color: palette.cardColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              side: BorderSide(
                                                  color: border,
                                                  width: locked ||
                                                          (_answerRevealed &&
                                                              correct)
                                                      ? 1.8
                                                      : 1)),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: disabled
                                                ? null
                                                : () => _onSelectOption(index),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 16),
                                                child: Row(children: [
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: border
                                                            .withOpacity(.1),
                                                        border: Border.all(
                                                            color: border)),
                                                    child: Center(
                                                        child: Text(
                                                            letters[index],
                                                            style: TextStyle(
                                                                color: border,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900))),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                      child: Text(
                                                          q.options[index],
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              color: palette
                                                                  .textPrimary,
                                                              fontSize:
                                                                  FirdawsType
                                                                      .body,
                                                              height: 1.45,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700))),
                                                  if (_answerRevealed &&
                                                      correct)
                                                    const Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color:
                                                            Color(0xFF16835D))
                                                  else if (_answerRevealed &&
                                                      locked)
                                                    const Icon(
                                                        Icons.cancel_rounded,
                                                        color:
                                                            Color(0xFFB42332)),
                                                ])),
                                          ),
                                        ),
                                      ),
                                    ));
                              }));
                        }),
                      ],
                    )),
                if (_answerRevealed) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: palette.elevatedCardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: palette.dividerColor)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('توضيح الإجابة',
                              style: TextStyle(
                                  color: palette.accentColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: FirdawsType.label)),
                          const SizedBox(height: 7),
                          Text(q.explanation,
                              softWrap: true,
                              style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: FirdawsType.body,
                                  height: 1.55)),
                        ]),
                  ),
                ],
              ]),
        ));
      })),
    ]);
  }

  Widget _stageTag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(.45))),
        child: Text(label,
            softWrap: true,
            style: TextStyle(
                color: color,
                fontSize: FirdawsType.caption,
                fontWeight: FontWeight.w800)),
      );

  List<Widget> _buildCurrentRival(ThemePalette palette, Color secondary) {
    if (_playMode == MillionairePlayMode.familyChallenge) {
      final family = context.watch<FamilyChallengeProvider>();
      final id = _selectedFamilyRivalId ?? family.selectedRivalId;
      for (final member in family.members) {
        if (member.id == id) {
          return [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: palette.dividerColor)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  FirdawsPortraitAvatar(
                      entityId: member.id,
                      displayName: member.name,
                      customPhotoBase64: member.customPhotoBase64,
                      networkPhotoUrl: member.networkPhotoUrl,
                      size: 34),
                  const SizedBox(width: 9),
                  Flexible(
                      child: Text('منافس العائلة: ${member.name}',
                          softWrap: true,
                          style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w700))),
                ]))
          ];
        }
      }
      return [
        Text('تحدي العائلة · المنافس المحدد',
            style: TextStyle(color: secondary))
      ];
    }
    return [
      Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: palette.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.dividerColor)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            FirdawsPortraitAvatar(
                entityId: _selectedAiRival.id,
                displayName: _selectedAiRival.name,
                size: 34),
            const SizedBox(width: 9),
            Flexible(
                child: Text('${_selectedAiRival.name} · المحطة $_aiRivalStep',
                    softWrap: true,
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700))),
          ]))
    ];
  }

  Widget _buildPostMatchView(ThemePalette palette) {
    final secondary = firdawsCrispSecondaryText(palette);
    final ctaTextColor =
        ThemeData.estimateBrightnessForColor(palette.primaryColor) ==
                Brightness.dark
            ? Colors.white
            : const Color(0xFF102019);
    final wonMillion =
        _currentRungIndex >= 14 && !_gameOverLost && !_walkedAway;
    final dualMode = _playMode == MillionairePlayMode.dualPlayerLocal;
    final statusColor = _gameOverLost
        ? const Color(0xFFEF4444)
        : (wonMillion || !_walkedAway
            ? const Color(0xFF10B981)
            : const Color(0xFF38BDF8));
    final headline = dualMode
        ? 'نتيجة المواجهة الثنائية!'
        : (wonMillion
            ? 'مبروك! ربحت المليون في الاستوديو!'
            : (_gameOverLost
                ? 'انتهت الجولة — عوّضها في المحاولة القادمة!'
                : (_walkedAway
                    ? 'انسحاب حكيم برصيدك المحقق!'
                    : 'جولة رائعة وتعلّم قيّم!')));
    final metrics = dualMode
        ? <ParadiseMetric>[
            ParadiseMetric(
                value: '$_p1Score',
                label: '${_p1NameCtrl.text} · نقاط',
                icon: Icons.person_outline_rounded),
            ParadiseMetric(
                value: '$_p1CorrectCount',
                label: 'إجابات صحيحة',
                icon: Icons.check_circle_outline_rounded),
            ParadiseMetric(
                value: '$_p2Score',
                label: '${_p2NameCtrl.text} · نقاط',
                icon: Icons.person_outline_rounded),
            ParadiseMetric(
                value: '$_p2CorrectCount',
                label: 'إجابات صحيحة',
                icon: Icons.check_circle_outline_rounded),
          ]
        : <ParadiseMetric>[
            ParadiseMetric(
                value: '${_currentRungIndex + 1} / ١٥',
                label: 'محطات الجولة',
                icon: Icons.stairs_rounded),
            ParadiseMetric(
                value: '$_currentEarnedAmount',
                label: 'رصيد المسابقة',
                icon: Icons.account_balance_wallet_outlined),
            ParadiseMetric(
                value: '$_guaranteedAmount',
                label: 'الرصيد المضمون',
                icon: Icons.shield_outlined),
          ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ParadiseHero(
              title: headline,
              subtitle: dualMode
                  ? 'انتهت المواجهة؛ راجعوا النقاط وعدد الإجابات الصحيحة.'
                  : 'وصلت إلى السؤال ${_currentRungIndex + 1} من ١٥ · رصيد الجولة: $_currentEarnedAmount نقطة داخل اللعبة',
              imageAsset: Theme.of(context)
                  .extension<FirdawsNatureLook>()
                  ?.sceneryAsset,
              minHeight: 230,
              footer: Row(children: [
                Icon(
                    dualMode
                        ? Icons.people_alt_rounded
                        : Icons.emoji_events_rounded,
                    color: statusColor,
                    size: 22),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(dualMode ? 'ملخص المواجهة' : 'ملخص الجولة',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800))),
                if (!dualMode && _walkedAway && !_gameOverLost)
                  const Icon(Icons.logout_rounded,
                      color: Colors.white70, size: 20),
              ]),
            ),
            const SizedBox(height: 22),
            LayoutBuilder(builder: (context, constraints) {
              final tileWidth = constraints.maxWidth < 380
                  ? constraints.maxWidth
                  : (constraints.maxWidth < 520
                      ? (constraints.maxWidth - 10) / 2
                      : (constraints.maxWidth - (metrics.length - 1) * 12) /
                          metrics.length);
              return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: metrics
                      .map(
                          (metric) => SizedBox(width: tileWidth, child: metric))
                      .toList());
            }),
            if (_postMatchPhrase.isNotEmpty) ...[
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: palette.dividerColor)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رسالة التحدي',
                          style: TextStyle(
                              color: palette.accentColor,
                              fontSize: FirdawsType.label,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(_postMatchPhrase,
                          softWrap: true,
                          style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: FirdawsType.body,
                              height: 1.6,
                              fontWeight: FontWeight.w700)),
                      if (_postMatchSecondPhrase.isNotEmpty) ...[
                        Divider(height: 24, color: palette.dividerColor),
                        Text(_postMatchSecondPhrase,
                            softWrap: true,
                            style: TextStyle(
                                color: secondary,
                                fontSize: FirdawsType.body,
                                height: 1.55)),
                      ],
                    ]),
              ),
            ],
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final startAgain = Firdaws3DButton(
                baseColor: palette.primaryColor,
                onPressed: _startMatch,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                child: Text('جولة جديدة بالإعدادات نفسها',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                        color: ctaTextColor, fontWeight: FontWeight.w900)),
              );
              final changeSettings = Firdaws3DButton(
                baseColor: palette.elevatedCardColor,
                rimColor: palette.dividerColor,
                onPressed: () => setState(() => _inLobby = true),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                child: Text('تغيير النمط أو المجال',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900)),
              );
              if (constraints.maxWidth < 520) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      startAgain,
                      const SizedBox(height: 10),
                      changeSettings,
                    ]);
              }
              return Row(children: [
                Expanded(child: startAgain),
                const SizedBox(width: 12),
                Expanded(child: changeSettings)
              ]);
            }),
            const SizedBox(height: 10),
            TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('العودة إلى الصفحة السابقة')),
          ]),
        )),
      ],
    );
  }
}

class _DualScoreChip extends StatelessWidget {
  final String name;
  final int score;
  final bool active;
  final Color color;
  final ThemePalette palette;

  const _DualScoreChip({
    required this.name,
    required this.score,
    required this.active,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: active
            ? color.withOpacity(0.22)
            : palette.textPrimary.withOpacity(0.05),
        border: Border.all(
          color: active ? color : palette.dividerColor.withOpacity(0.2),
          width: active ? 1.6 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              active ? '▶ $name' : name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: FirdawsType.caption,
                fontWeight: FontWeight.w800,
                color: active ? color : palette.textPrimary,
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: FirdawsType.label,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Lifeline3DChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool used;
  final bool disabled;
  final Color color;
  final ThemePalette palette;
  final VoidCallback onTap;

  const _Lifeline3DChip({
    required this.icon,
    required this.label,
    required this.used,
    this.disabled = false,
    required this.color,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unavailable = used || disabled;
    return Semantics(
      button: true,
      enabled: !unavailable,
      label: '$label${used ? '، استُخدمت' : ''}',
      child: Opacity(
        opacity: unavailable ? 0.45 : 1.0,
        child: Firdaws3DCard(
          palette: palette,
          glowColor: unavailable ? null : color,
          onTap: unavailable ? null : onTap,
          depth: unavailable ? 1 : 4,
          borderRadius: FirdawsRadius.control,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: unavailable ? palette.textSecondary : color,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FirdawsType.caption,
                    fontWeight: FontWeight.w800,
                    decoration: used ? TextDecoration.lineThrough : null,
                    color: palette.textPrimary,
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
