import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/events_missions_catalog.dart';
import '../models/tasbih_3d_phrases_200.dart';
import '../models/tasbih_challenge.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/jannati_provider.dart';
import 'hasanat_store_screen.dart';
import '../providers/family_challenge_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/tasbih_goal_effects.dart';
import 'main_navigation_screen.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  int _counter = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;

  // إحصائيات التحديات والأثر التراكمي
  int _totalLifetimeTasbih = 0;
  int _completedChallengesCount = 0;
  String? _activeChallengeId;
  TasbihChallenge? _customChallenge;
  final Map<String, int> _challengeProgress = {};

  // تأثيرات الوصول للهدف الـ 20 + اللافتة التحفيزية الثلاثية الأبعاد (200 عبارة 3D)
  int _selectedEffectIndex = 0; // 0..19
  int _activePlayingEffectIndex = 0;
  bool _autoCycleEffects = true;
  int _phraseNumber3d = 1; // 1..200
  bool _show3dBanner = false;

  late AnimationController _beadScaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _waterRippleController;
  late Animation<double> _waterRippleAnimation;

  late AnimationController _goalEffectController;

  final List<String> _dhikrList = [
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
    "سُبْحَانَ اللَّهِ الْعَظِيمِ",
    "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
    "اللَّهُ أَكْبَرُ كَبِيرًا",
    "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
    "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
    "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ",
  ];

  @override
  void initState() {
    super.initState();
    _beadScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _beadScaleController, curve: Curves.easeInOut),
    );

    _waterRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _waterRippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waterRippleController, curve: Curves.easeOutQuart),
    );

    _goalEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _loadTasbihState();
  }

  Future<void> _loadTasbihState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final savedProgressRaw = prefs.getString('tasbih_challenge_progress');
      final Map<String, int> loadedMap = {};
      if (savedProgressRaw != null) {
        final decoded = jsonDecode(savedProgressRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          loadedMap[entry.key] = (entry.value as num).toInt();
        }
      }
      final customRaw = prefs.getString('tasbih_custom_challenge');
      TasbihChallenge? loadedCustom;
      if (customRaw != null) {
        final cMap = jsonDecode(customRaw) as Map<String, dynamic>;
        loadedCustom = TasbihChallenge(
          id: 'custom_user',
          title: cMap['title'] ?? 'تحديي الخاص',
          dhikr: cMap['dhikr'] ?? 'سُبْحَانَ اللَّهِ',
          targetCount: (cMap['targetCount'] as num?)?.toInt() ?? 100,
          badge: 'إنجاز خاص 🌟',
          rewardVirtue: 'تحدٍ مخصص من اختيارك للثبات على الذكر يومياً.',
          icon: Icons.star_rounded,
          color: const Color(0xFFD4AF37),
          isCustom: true,
        );
      }

      setState(() {
        _counter = prefs.getInt('tasbih_counter') ?? 0;
        _target = prefs.getInt('tasbih_target') ?? 33;
        _selectedDhikrIndex =
            (prefs.getInt('tasbih_dhikr_idx') ?? 0).clamp(0, _dhikrList.length - 1);
        _totalLifetimeTasbih = prefs.getInt('tasbih_lifetime') ?? 0;
        _completedChallengesCount = prefs.getInt('tasbih_completed_count') ?? 0;
        _activeChallengeId = prefs.getString('tasbih_active_challenge');
        _selectedEffectIndex = (prefs.getInt('tasbih_effect_idx') ?? 0).clamp(0, 19);
        _activePlayingEffectIndex = _selectedEffectIndex;
        _autoCycleEffects = prefs.getBool('tasbih_effect_autocycle') ?? true;
        _phraseNumber3d = (prefs.getInt('tasbih_3d_phrase_num') ?? 1).clamp(1, 200);
        _customChallenge = loadedCustom;
        _challengeProgress
          ..clear()
          ..addAll(loadedMap);
      });
    } catch (e) {
      debugPrint('Tasbih state load error: $e');
    }
  }

  Future<void> _saveTasbihState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_counter', _counter);
      await prefs.setInt('tasbih_target', _target);
      await prefs.setInt('tasbih_dhikr_idx', _selectedDhikrIndex);
      await prefs.setInt('tasbih_lifetime', _totalLifetimeTasbih);
      await prefs.setInt('tasbih_completed_count', _completedChallengesCount);
      if (_activeChallengeId != null) {
        await prefs.setString('tasbih_active_challenge', _activeChallengeId!);
      } else {
        await prefs.remove('tasbih_active_challenge');
      }
      await prefs.setInt('tasbih_effect_idx', _selectedEffectIndex);
      await prefs.setBool('tasbih_effect_autocycle', _autoCycleEffects);
      await prefs.setInt('tasbih_3d_phrase_num', _phraseNumber3d);
      await prefs.setString('tasbih_challenge_progress', jsonEncode(_challengeProgress));
      if (_customChallenge != null) {
        await prefs.setString('tasbih_custom_challenge', jsonEncode(_customChallenge!.toJson()));
      }
    } catch (e) {
      debugPrint('Tasbih state save error: $e');
    }
  }

  TasbihChallenge? get _activeChallenge {
    if (_activeChallengeId == null) return null;
    if (_activeChallengeId == 'custom_user') return _customChallenge;
    return TasbihChallengesCatalog.getById(_activeChallengeId!);
  }

  @override
  void dispose() {
    _beadScaleController.dispose();
    _waterRippleController.dispose();
    _goalEffectController.dispose();
    super.dispose();
  }

  void _open3dPhrasesCatalog() {
    showTasbih200PhrasesExplorerSheet(
      context,
      currentNumber: _phraseNumber3d,
      onSelectPhrase: (phrase) {
        setState(() {
          _phraseNumber3d = phrase.number;
          _show3dBanner = true;
        });
        _goalEffectController.forward(from: 0.0);
        _saveTasbihState();
      },
    );
  }

  void _triggerGoalEffect({int? overrideIndex, String? message}) {
    int effectIdx = overrideIndex ?? _selectedEffectIndex;
    if (overrideIndex == null && _autoCycleEffects) {
      effectIdx = _selectedEffectIndex;
      _selectedEffectIndex = (_selectedEffectIndex + 1) % 20;
    }
    setState(() {
      _activePlayingEffectIndex = effectIdx;
      _phraseNumber3d = (_phraseNumber3d % 200) + 1;
      _show3dBanner = true;
    });
    _goalEffectController.forward(from: 0.0);
    _saveTasbihState();

    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    final effectInfo = TasbihGoalEffectsCatalog.getByIndex(effectIdx);
    final phrase3d = Tasbih3DPhrasesCatalog.getByNumber(_phraseNumber3d);
    final personalizedPhrase =
        userProv.getPersonalizedMotivation(category: 'أنس الذكر والتسبيح');
    _showCelebrationBanner(
      message ??
          "هنيئاً يا ${userProv.displayName}! ${phrase3d.emoji} (${effectInfo.number}/20: ${effectInfo.name}) • $personalizedPhrase",
    );
  }

  void _onBeadPressed() {
    _beadScaleController.forward().then((_) {
      if (mounted) _beadScaleController.reverse();
    });
    _waterRippleController.forward(from: 0.0);
    HapticFeedback.lightImpact();

    final activeChallenge = _activeChallenge;
    final activeDhikrText = activeChallenge?.dhikr ?? _dhikrList[_selectedDhikrIndex];
    String? pendingEffectMessage;
    bool shouldTriggerEffect = false;

    setState(() {
      _totalLifetimeTasbih++;
      if (activeChallenge != null) {
        final prev = _challengeProgress[activeChallenge.id] ?? 0;
        final next = prev + 1;
        _challengeProgress[activeChallenge.id] = next;
        _counter = next;

        if (next == activeChallenge.targetCount) {
          _completedChallengesCount++;
          shouldTriggerEffect = true;
          pendingEffectMessage =
              "مبارك إتمام «${activeChallenge.title}» (${activeChallenge.targetCount}) • ${activeChallenge.badge}";
        } else if (next > activeChallenge.targetCount &&
            next % activeChallenge.targetCount == 0) {
          shouldTriggerEffect = true;
        }
      } else {
        _counter++;
        if (_target > 0 && _counter % _target == 0) {
          shouldTriggerEffect = true;
        }
      }
    });

    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    userProv.recordDhikrByText(activeDhikrText).then((unlocked) {
      if (unlocked.isNotEmpty && mounted) {
        final first = unlocked.first;
        _showCelebrationBanner(
          "مبارك يا ${userProv.displayName}! فُتح لقب #${first.number}: ${first.localizedTitle(isFemale: userProv.isFemale)} 🏆",
        );
      }
    });

    // تشجير بستان «جنتي» ثلاثي الأبعاد + تحديث تحدي العائلة «مين سبّح أكتر» مع كل تسبيحة!
    try {
      Provider.of<JannatiProvider>(context, listen: false)
          .recordTasbihForGarden(activeDhikrText, count: 1);
    } catch (_) {}
    try {
      Provider.of<FamilyChallengeProvider>(context, listen: false)
          .recordUserTasbih(1);
    } catch (_) {}
    try {
      final hasanat = Provider.of<HasanatProvider>(context, listen: false);
      hasanat.earnHasanat(
        shouldTriggerEffect ? 20 : 1,
        reason: shouldTriggerEffect ? 'إتمام ورد السبحة ✨' : 'تسبيحة في المسبحة',
        sourceTag: 'السبحة',
      );
      hasanat.recordMetric(EventMissionMetric.tasbihCount, delta: 1);
    } catch (_) {}

    if (shouldTriggerEffect) {
      HapticFeedback.heavyImpact();
      _triggerGoalEffect(
        message: pendingEffectMessage,
      );
    }
    _saveTasbihState();
  }

  void _showCelebrationBanner(String text) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final palette = IslamicTheme.resolvePalette(
      settings.selectedTheme,
      isNight: settings.isNightEffective,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.elevatedCardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.accentColor, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(Icons.stars_rounded, color: palette.accentColor, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      final challenge = _activeChallenge;
      if (challenge != null) {
        _challengeProgress[challenge.id] = 0;
      }
      _counter = 0;
    });
    _saveTasbihState();
  }

  void _showChallengesSheet(ThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final challenges = [
              ...TasbihChallengesCatalog.builtIn,
              if (_customChallenge != null) _customChallenge!,
            ];

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: palette.accentColor.withOpacity(0.45), width: 1.5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: palette.accentColor, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "تحديات السبحة الإيمانية",
                                style: TextStyle(
                                  color: palette.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "الإجمالي: $_totalLifetimeTasbih تسبيحة • التحديات المنجزة: $_completedChallengesCount",
                                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showCreateCustomChallengeDialog(palette);
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text("مخصص", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.accentColor,
                            foregroundColor: palette.onAccentColor,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_activeChallengeId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _activeChallengeId = null;
                            _counter = 0;
                          });
                          _saveTasbihState();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close_rounded, color: palette.accentColor, size: 16),
                        label: Text(
                          "إلغاء التحدي والعودة للسبحة الحرة",
                          style: TextStyle(color: palette.accentColor, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: palette.accentColor.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      itemCount: challenges.length,
                      itemBuilder: (context, idx) {
                        final ch = challenges[idx];
                        final prog = _challengeProgress[ch.id] ?? 0;
                        final ratio = (prog / ch.targetCount).clamp(0.0, 1.0);
                        final isDone = prog >= ch.targetCount;
                        final isActive = _activeChallengeId == ch.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isActive
                                ? palette.accentColor.withOpacity(0.14)
                                : palette.cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isActive
                                  ? palette.accentColor
                                  : (isDone ? const Color(0xFF10B981) : palette.dividerColor),
                              width: isActive ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ch.color.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(ch.icon, color: ch.color, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ch.title,
                                          style: TextStyle(
                                            color: palette.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "${ch.badge} • الهدف: ${ch.targetCount}",
                                          style: TextStyle(
                                            color: palette.accentColor,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isDone)
                                    const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 22),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ch.dhikr,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ch.rewardVirtue,
                                style: TextStyle(color: palette.textMuted, fontSize: 11, height: 1.3),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 7,
                                  backgroundColor: palette.dividerColor,
                                  color: isDone ? const Color(0xFF10B981) : palette.accentColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "التقدم: $prog / ${ch.targetCount}",
                                    style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                                  ),
                                  Row(
                                    children: [
                                      if (prog > 0)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _challengeProgress[ch.id] = 0;
                                              if (isActive) _counter = 0;
                                            });
                                            setModalState(() {});
                                            _saveTasbihState();
                                          },
                                          child: Text(
                                            "تصفير",
                                            style: TextStyle(color: palette.textMuted, fontSize: 11.5),
                                          ),
                                        ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _activeChallengeId = ch.id;
                                            _counter = _challengeProgress[ch.id] ?? 0;
                                          });
                                          _saveTasbihState();
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isActive ? const Color(0xFF10B981) : palette.accentColor,
                                          foregroundColor: palette.onAccentColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          isActive ? "التحدي النشط ✓" : (isDone ? "إعادة التحدي" : "ابدأ التحدي"),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateCustomChallengeDialog(ThemePalette palette) {
    final titleCtrl = TextEditingController(text: 'ورد التسبيح الخاص');
    final dhikrCtrl = TextEditingController(text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ');
    final countCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.accentColor.withOpacity(0.5)),
        ),
        title: Text(
          "إنشاء تحدي سبحة مخصص",
          style: TextStyle(color: palette.accentColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: palette.textPrimary),
                decoration: InputDecoration(
                  labelText: 'عنوان التحدي',
                  labelStyle: TextStyle(color: palette.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dhikrCtrl,
                style: TextStyle(color: palette.textPrimary),
                decoration: InputDecoration(
                  labelText: 'نص الذكر',
                  labelStyle: TextStyle(color: palette.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: palette.textPrimary),
                decoration: InputDecoration(
                  labelText: 'الهدف المطلوب (رقم)',
                  labelStyle: TextStyle(color: palette.textSecondary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(color: palette.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final targetVal = int.tryParse(countCtrl.text.trim()) ?? 100;
              final safeTarget = targetVal.clamp(1, 100000);
              final challenge = TasbihChallenge(
                id: 'custom_user',
                title: titleCtrl.text.trim().isEmpty ? 'تحديي الخاص' : titleCtrl.text.trim(),
                dhikr: dhikrCtrl.text.trim().isEmpty ? 'سُبْحَانَ اللَّهِ' : dhikrCtrl.text.trim(),
                targetCount: safeTarget,
                badge: 'إنجاز خاص 🌟',
                rewardVirtue: 'تحدٍ مخصص من اختيارك للثبات على الذكر.',
                icon: Icons.star_rounded,
                color: palette.accentColor,
                isCustom: true,
              );
              setState(() {
                _customChallenge = challenge;
                _activeChallengeId = challenge.id;
                _challengeProgress[challenge.id] = 0;
                _counter = 0;
              });
              _saveTasbihState();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.accentColor,
              foregroundColor: palette.onAccentColor,
            ),
            child: const Text("بدء التحدي"),
          ),
        ],
      ),
    );
  }

  void _showGoalEffectsSheet(ThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.84,
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: palette.accentColor.withOpacity(0.45), width: 1.5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: palette.accentColor, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "20 تأثيراً للوصول للهدف في التسبيح",
                                style: TextStyle(
                                  color: palette.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "اختر تأثيرك المفضل أو فعّل التغيير التلقائي عند كل هدف",
                                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "تغيير تلقائي بين الـ 20 تأثيراً عند كل هدف",
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      value: _autoCycleEffects,
                      activeTrackColor: palette.accentColor,
                      onChanged: (val) {
                        setState(() => _autoCycleEffects = val);
                        setModalState(() {});
                        _saveTasbihState();
                      },
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.08,
                      ),
                      itemCount: TasbihGoalEffectsCatalog.allEffects.length,
                      itemBuilder: (context, idx) {
                        final eff = TasbihGoalEffectsCatalog.allEffects[idx];
                        final isSel = _selectedEffectIndex == idx;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedEffectIndex = idx;
                              _autoCycleEffects = false;
                            });
                            _saveTasbihState();
                            Navigator.pop(context);
                            _triggerGoalEffect(
                              overrideIndex: idx,
                              message: "معاينة التأثير (${eff.number}/20): ${eff.name} ✨",
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? palette.accentColor.withOpacity(0.16)
                                  : palette.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel ? palette.accentColor : palette.dividerColor,
                                width: isSel ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: eff.primaryColor.withOpacity(0.20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(eff.icon, color: eff.primaryColor, size: 18),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: palette.accentColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "#${eff.number}",
                                        style: TextStyle(
                                          color: palette.accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  eff.name,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  eff.subtitle,
                                  style: TextStyle(
                                    color: palette.textMuted,
                                    fontSize: 10,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accentColor = palette.accentColor;

    final activeChallenge = _activeChallenge;
    final activeDhikrText = activeChallenge?.dhikr ?? _dhikrList[_selectedDhikrIndex];
    final effectiveTarget = activeChallenge?.targetCount ?? _target;
    final double progressRatio = effectiveTarget > 0
        ? ((_counter % effectiveTarget == 0 && _counter > 0)
            ? 1.0
            : (_counter % effectiveTarget) / effectiveTarget)
        : 0.0;

    final currentEffect = TasbihGoalEffectsCatalog.getByIndex(_selectedEffectIndex);

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: palette.cardColor.withOpacity(isNight ? 0.78 : 0.88),
        elevation: 0,
        titleSpacing: 10,
        title: Row(
          children: [
            Flexible(
              child: Text(
                "📿 مسبحة الفردوس ${themeOption.primaryEmoji}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) {
              int balance = 0;
              try {
                balance = ctx.watch<HasanatProvider>().hasanatBalance;
              } catch (_) {}
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Firdaws3DPill(
                    label: '$balance 🪙',
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
            tooltip: '200 عبارة 3D ✨',
            onPressed: _open3dPhrasesCatalog,
            icon: Icon(Icons.auto_stories_rounded, color: accentColor, size: 20),
          ),
          IconButton(
            tooltip: 'معاينة التأثير 🎆',
            onPressed: () => _triggerGoalEffect(
              message:
                  "معاينة التأثير #${TasbihGoalEffectsCatalog.getByIndex(_selectedEffectIndex).number}/20 ✨🎆",
            ),
            icon: Icon(Icons.auto_awesome_rounded, color: accentColor, size: 20),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          ),
          Positioned.fill(
            child: IslamicThemeEffectsCanvas(
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 95),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 101),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. شريط التحديات الـ +20 تأثير في الأعلى
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _showChallengesSheet(palette),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: activeChallenge != null
                                        ? accentColor.withOpacity(0.20)
                                        : palette.cardColor.withOpacity(isNight ? 0.84 : 0.90),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: activeChallenge != null
                                          ? accentColor
                                          : palette.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events_rounded,
                                        color: accentColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              activeChallenge?.title ?? "🏆 التحديات الإيمانية",
                                              style: TextStyle(
                                                color: palette.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              activeChallenge != null
                                                  ? "🎯 $_counter / ${activeChallenge.targetCount}"
                                                  : "✨ 12 تحدياً + تحدٍ مخصص",
                                              style: TextStyle(
                                                color: accentColor,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_left_rounded, color: palette.textMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showGoalEffectsSheet(palette),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: palette.cardColor.withOpacity(isNight ? 0.84 : 0.90),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: palette.dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(currentEffect.icon, color: accentColor, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "🎆 تأثيرات الهدف (20)",
                                              style: TextStyle(
                                                color: palette.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              _autoCycleEffects
                                                  ? "🔄 تلقائي: #${currentEffect.number} + 200 عبارة 3D"
                                                  : "#${currentEffect.number}: ${currentEffect.name}",
                                              style: TextStyle(
                                                color: accentColor,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_left_rounded, color: palette.textMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                          const SizedBox(height: 10),

                          // 2. قائمة اختيار الذكر الحر أو شريط تقدم التحدي
                          if (activeChallenge == null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: BoxDecoration(
                                color: palette.cardColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: accentColor.withOpacity(0.35)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedDhikrIndex,
                                  isExpanded: true,
                                  dropdownColor: palette.cardColor,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor),
                                  items: List.generate(_dhikrList.length, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(
                                        _dhikrList[index],
                                        style: TextStyle(fontSize: 14, color: palette.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedDhikrIndex = val;
                                        _counter = 0;
                                      });
                                      _saveTasbihState();
                                    }
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: palette.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accentColor.withOpacity(0.5)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          activeChallenge.badge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "المتبقي: ${(activeChallenge.targetCount - _counter).clamp(0, activeChallenge.targetCount)}",
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (_counter / activeChallenge.targetCount).clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: palette.dividerColor,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 8),

                          // شارة النمو الفوري لبستان جنتي 3D مع كل تسبيحة
                          Builder(
                            builder: (ctx) {
                              int trees = 0;
                              String treeName = 'نخلة التوحيد الذهبية';
                              try {
                                final jp = Provider.of<JannatiProvider>(ctx);
                                trees = jp.totalGardenTrees;
                                treeName = jp.lastTasbihTreeName;
                              } catch (_) {}
                              return Firdaws3DCard(
                                palette: palette,
                                glowColor: const Color(0xFF10B981),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                borderRadius: 16,
                                depth: 3.5,
                                onTap: () => FirdawsNavBridge.jumpTo(5, jannatiTab: 0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.20),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF34D399)),
                                      ),
                                      child: const Icon(Icons.forest_rounded,
                                          color: Color(0xFF34D399), size: 17),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'بستان جنتي 3D يزدان بكل تسبيحة: $trees شجرة 🌳',
                                            style: TextStyle(
                                              color: palette.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            treeName,
                                            style: const TextStyle(
                                              color: Color(0xFF34D399),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        'شاهد البستان ⬅️',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          // 3. نص الذكر الحالي
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                activeDhikrText,
                                key: ValueKey<String>(activeDhikrText),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 4. حاوية ثابتة الأبعاد لقرص المسبحة مع حلقة التقدم الدائرية
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedBuilder(
                                  animation: _waterRippleAnimation,
                                  builder: (context, _) {
                                    final double size = 230 + _waterRippleAnimation.value * 58;
                                    final double opacity =
                                        (1.0 - _waterRippleAnimation.value) * 0.45;
                                    return Container(
                                      width: size,
                                      height: size,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: accentColor.withOpacity(opacity),
                                          width: 2.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                if (effectiveTarget > 0)
                                  SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: CircularProgressIndicator(
                                      value: progressRatio,
                                      strokeWidth: 7,
                                      backgroundColor: palette.dividerColor.withOpacity(0.5),
                                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                    ),
                                  ),

                                GestureDetector(
                                  onTap: _onBeadPressed,
                                  behavior: HitTestBehavior.opaque,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      width: 224,
                                      height: 224,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          center: const Alignment(-0.25, -0.30),
                                          radius: 0.95,
                                          colors: isNight
                                              ? [
                                                  palette.primaryColor,
                                                  palette.cardColor,
                                                  Colors.black,
                                                ]
                                              : [
                                                  palette.cardColor,
                                                  palette.elevatedCardColor,
                                                  palette.primaryColor.withOpacity(0.18),
                                                ],
                                        ),
                                        border: Border.all(color: accentColor, width: 3.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentColor.withOpacity(isNight ? 0.35 : 0.22),
                                            blurRadius: 28,
                                            spreadRadius: 3,
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(isNight ? 0.7 : 0.16),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "$_counter",
                                              style: TextStyle(
                                                fontSize: 68,
                                                fontWeight: FontWeight.w900,
                                                color: palette.textPrimary,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            if (effectiveTarget > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: accentColor.withOpacity(0.18),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: accentColor.withOpacity(0.45),
                                                  ),
                                                ),
                                                child: Text(
                                                  "الهدف: $effectiveTarget",
                                                  style: TextStyle(
                                                    color: accentColor,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 5. شرائح الهدف (عند عدم وجود تحدٍ نشط)
                          if (activeChallenge == null)
                            Wrap(
                              spacing: 6,
                              alignment: WrapAlignment.center,
                              children: [33, 99, 100, 1000, 0].map((t) {
                                final isSelected = _target == t;
                                return ChoiceChip(
                                  label: Text(t == 0 ? "مفتوح" : "$t"),
                                  selected: isSelected,
                                  selectedColor: accentColor.withOpacity(0.24),
                                  backgroundColor: palette.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: isSelected ? accentColor : palette.dividerColor,
                                      width: 1.4,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected ? accentColor : palette.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  onSelected: (_) {
                                    setState(() => _target = t);
                                    _saveTasbihState();
                                  },
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 8),

                          // 6. شريط الإجماليات وزر إعادة التعيين
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  color: palette.textSecondary,
                                  size: 28,
                                ),
                                tooltip: "إعادة تعيين العداد",
                                onPressed: _reset,
                              ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: palette.cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: accentColor.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    effectiveTarget > 0
                                        ? "🌟 الدورة: ${_counter ~/ effectiveTarget} • 📿 الإجمالي: $_totalLifetimeTasbih ${themeOption.primaryEmoji}"
                                        : "📿 الإجمالي التراكمي: $_totalLifetimeTasbih ${themeOption.primaryEmoji}",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: _open3dPhrasesCatalog,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: accentColor.withOpacity(0.55)),
                                  ),
                                  child: Text(
                                    "✨ #$_phraseNumber3d/200",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),

          // لافتة التحفيز الثلاثية الأبعاد 3D فوق المسبحة
          if (_show3dBanner)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 6,
              left: 0,
              right: 0,
              child: Tasbih3DMotivationBanner(
                phrase: Tasbih3DPhrasesCatalog.getByNumber(_phraseNumber3d),
                achievedCount: _counter,
                onNextPhrase: () {
                  setState(() {
                    _phraseNumber3d = (_phraseNumber3d % 200) + 1;
                  });
                  _saveTasbihState();
                },
                onOpenCatalog: _open3dPhrasesCatalog,
                onDismiss: () => setState(() => _show3dBanner = false),
              ),
            ),

          // طبقة تأثيرات الوصول للهدف الـ 20
          Positioned.fill(
            child: TasbihGoalEffectOverlay(
              animation: _goalEffectController,
              effectType: TasbihGoalEffectsCatalog.getByIndex(_activePlayingEffectIndex).type,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
