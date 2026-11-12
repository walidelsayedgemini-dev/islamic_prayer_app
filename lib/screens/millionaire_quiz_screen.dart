import 'dart:async';
import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/backgrounds_500_catalog.dart';
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
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/real_mosque_background.dart';
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

class _MillionaireQuizScreenState extends State<MillionaireQuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _stageAnim;

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
    _stageAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

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
    _stageAnim.dispose();
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
    if (_answerRevealed ||
        _matchFinished ||
        _eliminatedOptions.contains(idx)) {
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
    final hitChance = (_selectedAiRival.accuracyRate - penalty).clamp(0.35, 0.94);
    if (rng.nextDouble() <= hitChance && _aiRivalStep == rungIndex) {
      _aiRivalStep++;
      _aiRivalScore = MillionaireLadderConfig.rungs[rungIndex].amount;
    }
  }

  void _advanceNextRung({required bool wasCorrect}) {
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
      final p2Name =
          _p2NameCtrl.text.trim().isEmpty ? 'اللاعب ٢' : _p2NameCtrl.text.trim();
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
      rivalScore: won ? (rivalCompareScore ~/ 200) : (rivalCompareScore ~/ 100) + 150,
      forceWonIfTie: won,
    );

    final rewardPts =
        25 + (_currentRungIndex * 12) + (won ? 80 : 10);
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
    final wrongIndices = [0, 1, 2, 3]
        .where((i) => i != q.correctIndex)
        .toList()
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
              Text('📞 ', style: TextStyle(fontSize: 22)),
              Flexible(
                child: Text(
                  'اتصال بالشيخ الحكيم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
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
                style: TextStyle(fontSize: 13.5, height: 1.5),
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
                        fontSize: 14,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'نسبة الثقة العلمية: $confidence٪',
                      style: TextStyle(
                        fontSize: 12,
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
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
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
                            fontSize: 12,
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
                            fontSize: 14,
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
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: firdaws3DSurfaceColor(palette),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFF38BDF8).withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🪜 سُلّم المليون (١٥ محطة ذهبية)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MillionaireLadderConfig.rungs.length,
                  itemBuilder: (_, idx) {
                    final rung = MillionaireLadderConfig.rungs[idx];
                    final isCurrent = idx == _currentRungIndex;
                    final passed = idx < _currentRungIndex;
                    final rivalHere = _playMode == MillionairePlayMode.vsAiRivals &&
                        _aiRivalStep == idx + 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isCurrent
                            ? const LinearGradient(
                                colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                              )
                            : null,
                        color: isCurrent
                            ? null
                            : passed
                                ? const Color(0xFF10B981).withOpacity(0.14)
                                : (rung.isSafeHaven
                                    ? const Color(0xFF38BDF8).withOpacity(0.10)
                                    : palette.textPrimary.withOpacity(0.04)),
                        border: Border.all(
                          color: isCurrent
                              ? Colors.white.withOpacity(0.8)
                              : (rung.isSafeHaven
                                  ? const Color(0xFF38BDF8).withOpacity(0.45)
                                  : palette.dividerColor.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: isCurrent
                                ? Colors.white.withOpacity(0.25)
                                : palette.textPrimary.withOpacity(0.08),
                            child: Text(
                              '${rung.step}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isCurrent
                                    ? Colors.white
                                    : palette.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rung.formattedAmount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isCurrent
                                    ? Colors.white
                                    : (passed
                                        ? const Color(0xFF10B981)
                                        : palette.textPrimary),
                              ),
                            ),
                          ),
                          if (rung.isSafeHaven)
                            const Text(
                              'محطة أمان',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          if (rivalHere) ...[
                            const SizedBox(width: 8),
                            FirdawsPortraitAvatar(
                              entityId: _selectedAiRival.id,
                              displayName: _selectedAiRival.name,
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'المنافس',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final palette = settings.currentPalette;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final isNight = settings.isNightEffective;
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
                      Background500Catalog.forMillionaireSection(0),
                    ),
            ),
            // خلفية استوديو 3D تفاعلية متحركة بأضواء المسرح فوق صورة 4K
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _stageAnim,
                builder: (_, __) => CustomPaint(
                  painter: _Millionaire3DStudioPainter(
                    phase: _stageAnim.value,
                    isDark: palette.isDark,
                    accent: firdawsModernAccent(palette),
                    tension:
                        _inLobby ? 0.2 : (1.0 - _secondsLeft / _maxSecondsPerQuestion),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: _inLobby
                  ? _buildLobbyView(palette)
                  : (_matchFinished
                      ? _buildPostMatchView(palette)
                      : _buildStageQuizView(palette)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyView(ThemePalette palette) {
    final fam = context.watch<FamilyChallengeProvider>();
    final categories = MillionaireQuestionBank.categories;
    final secondary = firdawsCrispSecondaryText(palette);
    final accent = firdawsModernAccent(palette);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Firdaws3DPill(
                label: 'رجوع',
                icon: Icons.arrow_back_ios_new_rounded,
                accentColor: const Color(0xFF38BDF8),
                palette: palette,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (ctx) {
                  int bal = 0;
                  try {
                    bal = ctx.watch<HasanatProvider>().hasanatBalance;
                  } catch (_) {}
                  return Firdaws3DPill(
                    label: '$bal 🪙',
                    accentColor: const Color(0xFFF59E0B),
                    palette: palette,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HasanatStoreScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Firdaws3DPill(
                    label: '${MillionaireQuestionBank.totalCount} سؤال حقيقي',
                    icon: Icons.auto_awesome_rounded,
                    palette: palette,
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بطاقة العنوان 4K
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forMillionaireSection(1),
                isDark: palette.isDark,
                borderColor: const Color(0xFF38BDF8).withOpacity(0.58),
                padding: const EdgeInsets.all(18),
                borderRadius: 22,
                imageOpacity: 0.52,
                child: Column(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 6),
                    Text(
                      'من سيربح المليون — الاستوديو',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'بنك عملاق من ١,٠٠٠ سؤال إسلامي وثقافي فريد بدون تكرار، عبر ١٥ محطة حتى المليون مع ٤ وسائل مساعدة، ومنافسين افتراضيين، ومشاركة ٢ لاعبين!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // اختيار نمط اللعب
              Text(
                '١) اختر نظام المنافسة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildModeSelectorCard(
                palette: palette,
                mode: MillionairePlayMode.vsAiRivals,
                title: 'منافسة المتسابقين الافتراضيين',
                subtitle: 'سابق متنافسين افتراضيين على سلم المليون لحظة بلحظة',
                icon: '🤖',
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 8),
              _buildModeSelectorCard(
                palette: palette,
                mode: MillionairePlayMode.dualPlayerLocal,
                title: 'مشاركة ٢ لاعبين في نفس اللعبة (٢ ضد ٢)',
                subtitle: 'تحدٍّ ثنائي متناوب على نفس الشاشة مع حصد النقاط وعبارات الفوز/الخسارة',
                icon: '🤝',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 8),
              _buildModeSelectorCard(
                palette: palette,
                mode: MillionairePlayMode.familyChallenge,
                title: 'تحدي العائلة والصحبة المباشر',
                subtitle: 'نتيجتك تُسجّل في سباق «مين بطل أكتر؟» وتفتح عبارة من الـ ٨٠٠ عبارة!',
                icon: '🏆',
                color: const Color(0xFFA855F7),
              ),
              const SizedBox(height: 14),

              // إعدادات خاصة بالنمط المختار
              if (_playMode == MillionairePlayMode.vsAiRivals) ...[
                Text(
                  '٢) اختر منافسك الافتراضي في الاستوديو',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MillionaireLadderConfig.virtualRivals
                      .asMap()
                      .entries
                      .map((entry) {
                    final rIdx = entry.key;
                    final rival = entry.value;
                    final sel = rival.id == _selectedAiRival.id;
                    return Firdaws4KCardShell(
                      backdrop: Background500Catalog.forMillionaireSection(
                          6 + (rIdx % 5)),
                      isDark: palette.isDark,
                      borderColor: sel
                          ? const Color(0xFF38BDF8).withOpacity(0.85)
                          : palette.dividerColor.withOpacity(0.45),
                      borderRadius: 16,
                      imageOpacity: sel ? 0.52 : 0.36,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      onTap: () => setState(() => _selectedAiRival = rival),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FirdawsPortraitAvatar(
                            entityId: rival.id,
                            displayName: rival.name,
                            size: 38,
                            ringColor: sel ? const Color(0xFF38BDF8) : null,
                            isHighlighted: sel,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rival.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                    color: sel
                                        ? const Color(0xFF38BDF8)
                                        : palette.textPrimary,
                                  ),
                                ),
                                Text(
                                  'دقة ${(rival.accuracyRate * 100).round()}٪',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 10.5, color: secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else if (_playMode == MillionairePlayMode.dualPlayerLocal) ...[
                Firdaws4KCardShell(
                  backdrop: Background500Catalog.forMillionaireSection(5),
                  isDark: palette.isDark,
                  borderColor: const Color(0xFF10B981).withOpacity(0.58),
                  borderRadius: 18,
                  imageOpacity: 0.46,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أسماء المتنافسَين (مشاركة ٢ في نفس اللعبة)',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _p1NameCtrl,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                labelText: 'اللاعب الأول',
                                labelStyle: TextStyle(color: secondary),
                                filled: true,
                                fillColor:
                                    palette.textPrimary.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _p2NameCtrl,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                labelText: 'اللاعب الثاني',
                                labelStyle: TextStyle(color: secondary),
                                filled: true,
                                fillColor:
                                    palette.textPrimary.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  '٢) اختر المنافس من العائلة والصحبة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: fam.members.map((m) {
                    final sel = m.id == (_selectedFamilyRivalId ?? fam.selectedRivalId);
                    return ChoiceChip(
                      label: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: math.max(
                              120.0, MediaQuery.of(context).size.width - 72.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FirdawsPortraitAvatar(
                              entityId: m.id,
                              displayName: m.name,
                              customPhotoBase64: m.customPhotoBase64,
                              networkPhotoUrl: m.networkPhotoUrl,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                m.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      selected: sel,
                      selectedColor: const Color(0xFFA855F7).withOpacity(0.28),
                      onSelected: (_) {
                        setState(() => _selectedFamilyRivalId = m.id);
                        fam.selectRival(m.id);
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 14),
              Text(
                '٣) اختر مجال الأسئلة (١,٠٠٠ سؤال فريد)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.max(
                            120.0, MediaQuery.of(context).size.width - 72.0),
                      ),
                      child: const Text(
                        '🌟 شامل (١,٠٠٠ سؤال)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    selected: _selectedCategory == null,
                    selectedColor: accent.withOpacity(0.28),
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  ...categories.map(
                    (cat) => ChoiceChip(
                      label: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: math.max(
                              120.0, MediaQuery.of(context).size.width - 72.0),
                        ),
                        child: Text(
                          cat,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      selected: _selectedCategory == cat,
                      selectedColor: accent.withOpacity(0.28),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Firdaws3DButton(
                baseColor: const Color(0xFF0EA5E9),
                onPressed: _startMatch,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 26),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'دخول كرسي الاستوديو وبدء المليون',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forMillionaireSection(2 + mode.index),
      isDark: palette.isDark,
      borderColor: selected
          ? color.withOpacity(0.85)
          : palette.dividerColor.withOpacity(0.42),
      borderRadius: 18,
      imageOpacity: selected ? 0.54 : 0.38,
      onTap: () => setState(() => _playMode = mode),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: selected ? color : palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: firdawsCrispSecondaryText(palette),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? color : palette.dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStageQuizView(ThemePalette palette) {
    final q = _questions[_currentRungIndex];
    final rung = MillionaireLadderConfig.rungs[_currentRungIndex];
    final secondary = firdawsCrispSecondaryText(palette);
    final isUrgent = _secondsLeft <= 8;
    const letters = ['أ', 'ب', 'ج', 'د'];

    return Column(
      children: [
        // الشريط العلوي
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Row(
            children: [
              Firdaws3DPill(
                label: 'انسحاب',
                icon: Icons.exit_to_app_rounded,
                palette: palette,
                accentColor: const Color(0xFF10B981),
                onTap: _walkAwayNow,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withOpacity(0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      'السؤال ${rung.step}/١٥ • ${rung.formattedAmount}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Firdaws3DPill(
                label: 'السلم',
                icon: Icons.stairs_rounded,
                palette: palette,
                accentColor: const Color(0xFF38BDF8),
                onTap: () => _openLadderSheet(palette),
              ),
            ],
          ),
        ),

        // لوحة المتنافسين الحية (الافتراضي أو لاعبين) + عداد الوقت
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              if (_playMode == MillionairePlayMode.dualPlayerLocal) ...[
                Expanded(
                  child: _DualScoreChip(
                    name: _p1NameCtrl.text.isEmpty ? 'اللاعب ١' : _p1NameCtrl.text,
                    score: _p1Score,
                    active: _activePlayerTurn == 1,
                    color: const Color(0xFF38BDF8),
                    palette: palette,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DualScoreChip(
                    name: _p2NameCtrl.text.isEmpty ? 'اللاعب ٢' : _p2NameCtrl.text,
                    score: _p2Score,
                    active: _activePlayerTurn == 2,
                    color: const Color(0xFF10B981),
                    palette: palette,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Row(
                    children: [
                      FirdawsPortraitAvatar(
                        entityId: _selectedAiRival.id,
                        displayName: _selectedAiRival.name,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${_selectedAiRival.name} في محطة $_aiRivalStep',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: (isUrgent
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF38BDF8))
                      .withOpacity(0.18),
                  border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF38BDF8),
                  ),
                ),
                child: Text(
                  '⏱ $_secondsLeft ث',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    color: isUrgent
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // أشرطة وسائل المساعدة الـ 4
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _Lifeline3DChip(
                  icon: '✂️',
                  label: '٥٠:٥٠',
                  used: _used5050,
                  color: const Color(0xFF38BDF8),
                  palette: palette,
                  onTap: _use5050,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Lifeline3DChip(
                  icon: '📞',
                  label: 'اتصال',
                  used: _usedCallFriend,
                  color: const Color(0xFF10B981),
                  palette: palette,
                  onTap: () => _useCallScholar(palette),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Lifeline3DChip(
                  icon: '📊',
                  label: 'الجمهور',
                  used: _usedAudiencePoll,
                  color: const Color(0xFF8B5CF6),
                  palette: palette,
                  onTap: () => _useAudiencePoll(palette),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Lifeline3DChip(
                  icon: '🔄',
                  label: 'تبديل',
                  used: _usedSwapQuestion,
                  color: const Color(0xFFF43F5E),
                  palette: palette,
                  onTap: _useSwapQuestion,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              // بطاقة السؤال 4K
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forMillionaireSection(
                    13 + (_currentRungIndex % 4)),
                isDark: palette.isDark,
                borderColor: q.difficulty.color.withOpacity(0.70),
                borderRadius: 22,
                imageOpacity: 0.52,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: q.difficulty.color.withOpacity(0.16),
                            ),
                            child: Text(
                              '${q.category} • ${q.difficulty.arabicLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: q.difficulty.color,
                              ),
                            ),
                          ),
                        ),
                        if (_guaranteedAmount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'الأمان: $_guaranteedAmount',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      q.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.5,
                        height: 1.55,
                        fontWeight: FontWeight.w900,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // خيارات الأجوبة الـ 4 بستايل أزرار 3D مجسّمة
              ...List.generate(4, (i) {
                final eliminated = _eliminatedOptions.contains(i);
                final isLocked = _lockedOptionIndex == i;
                final isCorrect = i == q.correctIndex;

                Color? cardGlow;
                Color? letterColor;
                if (_answerRevealed) {
                  if (isCorrect) {
                    cardGlow = const Color(0xFF10B981);
                    letterColor = const Color(0xFF10B981);
                  } else if (isLocked) {
                    cardGlow = const Color(0xFFEF4444);
                    letterColor = const Color(0xFFEF4444);
                  }
                } else if (isLocked) {
                  cardGlow = const Color(0xFF6366F1);
                  letterColor = const Color(0xFF6366F1);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Opacity(
                    opacity: eliminated ? 0.24 : 1.0,
                    child: Firdaws4KCardShell(
                      backdrop: Background500Catalog.forMillionaireSection(
                          17 + (i % 2)),
                      isDark: palette.isDark,
                      borderColor: (cardGlow ?? palette.dividerColor)
                          .withOpacity(cardGlow != null ? 0.85 : 0.45),
                      borderRadius: 16,
                      imageOpacity: cardGlow != null ? 0.52 : 0.34,
                      onTap: eliminated ? null : () => _onSelectOption(i),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (letterColor ?? const Color(0xFF38BDF8))
                                  .withOpacity(0.18),
                              border: Border.all(
                                color: letterColor ?? const Color(0xFF38BDF8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                letters[i],
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: letterColor ?? const Color(0xFF38BDF8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                          if (_answerRevealed && isCorrect)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981))
                          else if (_answerRevealed && isLocked && !isCorrect)
                            const Icon(Icons.cancel_rounded,
                                color: Color(0xFFEF4444)),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // شرح تعليمي مختصر فور الكشف
              if (_answerRevealed) ...[
                const SizedBox(height: 6),
                Firdaws4KCardShell(
                  backdrop: Background500Catalog.forMillionaireSection(19),
                  isDark: palette.isDark,
                  borderColor: const Color(0xFF10B981).withOpacity(0.65),
                  borderRadius: 16,
                  imageOpacity: 0.46,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '💡 الفائدة: ${q.explanation}',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostMatchView(ThemePalette palette) {
    final secondary = firdawsCrispSecondaryText(palette);
    final wonMillion = _currentRungIndex >= 14 && !_gameOverLost && !_walkedAway;
    final dualMode = _playMode == MillionairePlayMode.dualPlayerLocal;
    final statusColor = _gameOverLost
        ? const Color(0xFFEF4444)
        : (wonMillion || !_walkedAway
            ? const Color(0xFF10B981)
            : const Color(0xFF38BDF8));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forMillionaireSection(11),
          isDark: palette.isDark,
          borderColor: statusColor.withOpacity(0.75),
          borderRadius: 22,
          imageOpacity: 0.52,
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Text(
                wonMillion
                    ? '👑'
                    : (dualMode
                        ? '🤝'
                        : (_gameOverLost ? '💔' : '🏆')),
                style: const TextStyle(fontSize: 54),
              ),
              const SizedBox(height: 10),
              Text(
                dualMode
                    ? 'نتيجة المواجهة الثنائية!'
                    : (wonMillion
                        ? 'مبروك! ربحت المليون في الاستوديو!'
                        : (_gameOverLost
                            ? 'انتهت الجولة — عوّضها في المحاولة القادمة!'
                            : (_walkedAway
                                ? 'انسحاب حكيم برصيدك المحقق!'
                                : 'جولة رائعة وتعلّم قيّم!'))),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _gameOverLost ? const Color(0xFFFCA5A5) : palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (dualMode) ...[
                Text(
                  '${_p1NameCtrl.text}: $_p1Score نقطة ($_p1CorrectCount إجابات صحيحة)\n'
                  '${_p2NameCtrl.text}: $_p2Score نقطة ($_p2CorrectCount إجابات صحيحة)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    fontWeight: FontWeight.w800,
                    color: secondary,
                  ),
                ),
              ] else ...[
                Text(
                  'وصلت إلى السؤال ${_currentRungIndex + 1} من ١٥ • الرصيد: $_currentEarnedAmount نقطة',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_postMatchPhrase.isNotEmpty)
          Firdaws4KCardShell(
            backdrop: Background500Catalog.forMillionaireSection(12),
            isDark: palette.isDark,
            borderColor: const Color(0xFFA855F7).withOpacity(0.65),
            borderRadius: 18,
            imageOpacity: 0.48,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💬 عبارة التحدي التحفيزية (من الـ ٨٠٠ عبارة):',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _postMatchPhrase,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                if (_postMatchSecondPhrase.isNotEmpty) ...[
                  const Divider(height: 18),
                  Text(
                    _postMatchSecondPhrase,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Firdaws3DButton(
                baseColor: const Color(0xFF0EA5E9),
                onPressed: _startMatch,
                child: const Text(
                  'جولة جديدة بالاستوديو',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Firdaws3DButton(
                baseColor: const Color(0xFF6366F1),
                onPressed: () => setState(() => _inLobby = true),
                child: const Text(
                  'تغيير النمط والمجال',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('العودة إلى الرئيسية'),
          ),
        ),
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
        color: active ? color.withOpacity(0.22) : palette.textPrimary.withOpacity(0.05),
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
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: active ? color : palette.textPrimary,
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 12.5,
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
  final String icon;
  final String label;
  final bool used;
  final Color color;
  final ThemePalette palette;
  final VoidCallback onTap;

  const _Lifeline3DChip({
    required this.icon,
    required this.label,
    required this.used,
    required this.color,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: used ? 0.32 : 1.0,
      child: Firdaws3DCard(
        palette: palette,
        glowColor: used ? null : color,
        onTap: used ? null : onTap,
        depth: used ? 1 : 4,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  decoration: used ? TextDecoration.lineThrough : null,
                  color: palette.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// رسّام خلفية الاستوديو 3D مع أضواء مسرحية وشبكة أرضية منظورية
class _Millionaire3DStudioPainter extends CustomPainter {
  final double phase;
  final bool isDark;
  final Color accent;
  final double tension;

  const _Millionaire3DStudioPainter({
    required this.phase,
    required this.isDark,
    required this.accent,
    required this.tension,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgTop = (isDark ? const Color(0xFF060B18) : const Color(0xFFEEF6FF))
        .withOpacity(isDark ? 0.42 : 0.24);
    final bgMid = (isDark ? const Color(0xFF0C1732) : const Color(0xFFDCEBFF))
        .withOpacity(isDark ? 0.34 : 0.20);
    final bgBot = (isDark ? const Color(0xFF04070F) : const Color(0xFFCDE2FA))
        .withOpacity(isDark ? 0.58 : 0.36);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgTop, bgMid, bgBot],
        ).createShader(Offset.zero & size),
    );

    // حزم أضواء مسرحية 3D متحركة
    for (int i = 0; i < 4; i++) {
      final angle = math.sin(phase * math.pi * 2 + i * 1.4) * 0.32;
      final sx = size.width * (0.15 + i * 0.24);
      final beamPath = Path()
        ..moveTo(sx, 0)
        ..lineTo(sx + math.tan(angle - 0.14) * size.height, size.height)
        ..lineTo(sx + math.tan(angle + 0.14) * size.height, size.height)
        ..close();

      final beamColor = (i.isEven
              ? const Color(0xFF38BDF8)
              : const Color(0xFF8B5CF6))
          .withOpacity(isDark ? (0.07 + tension * 0.04) : 0.08);
      canvas.drawPath(
        beamPath,
        Paint()..color = beamColor,
      );
    }

    // أرضية استوديو منظورية 3D مع حلقات متحدة المركز
    final horizonY = size.height * 0.56;
    final vanish = Offset(size.width * 0.5, horizonY);
    final gridPaint = Paint()
      ..color = accent.withOpacity(isDark ? 0.15 : 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int k = 1; k <= 6; k++) {
      final t = k / 6.0;
      final rx = size.width * (0.16 + t * 0.55);
      final ry = rx * 0.28;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(vanish.dx, horizonY + size.height * 0.16 * t),
          width: rx * 2,
          height: ry * 2,
        ),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Millionaire3DStudioPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.isDark != isDark ||
      oldDelegate.tension != tension;
}
