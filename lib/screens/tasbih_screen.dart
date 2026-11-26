import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/events_missions_catalog.dart';
import '../models/tasbih_1000_catalog.dart';
import '../models/tasbih_challenge.dart';
import '../providers/comfort_provider.dart';
import '../providers/family_challenge_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/hoor_companion_provider.dart';
import '../providers/jannati_provider.dart';
import '../services/activity_stats_store.dart';
import '../widgets/calm_ui.dart';
import '../widgets/interactive_tasbih_beads.dart';
import '../widgets/paradise_ui.dart';
import 'main_navigation_screen.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _counter = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;
  int _totalLifetimeTasbih = 0;
  int _completedChallengesCount = 0;
  String? _activeChallengeId;
  TasbihChallenge? _customChallenge;
  bool _vibrationEnabled = true;
  bool _isLoadingState = true;
  bool _stateLoadFailed = false;
  String? _interactionFeedback;
  Timer? _feedbackTimer;
  final Map<String, int> _challengeProgress = {};

  List<TasbihDuaEntry> get _dhikrCatalog => Tasbih1000Catalog.all1000;

  TasbihDuaEntry get _currentDhikrEntry =>
      _dhikrCatalog[_selectedDhikrIndex.clamp(0, _dhikrCatalog.length - 1)];

  TasbihChallenge? get _activeChallenge {
    if (_activeChallengeId == null) return null;
    if (_activeChallengeId == 'custom_user') return _customChallenge;
    return TasbihChallengesCatalog.getById(_activeChallengeId!);
  }

  @override
  void initState() {
    super.initState();
    _loadTasbihState();
  }

  Future<void> _loadTasbihState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final savedProgressRaw = prefs.getString('tasbih_challenge_progress');
      final loadedProgress = <String, int>{};
      if (savedProgressRaw != null) {
        final decoded = jsonDecode(savedProgressRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          loadedProgress[entry.key] = (entry.value as num).toInt();
        }
      }

      final customRaw = prefs.getString('tasbih_custom_challenge');
      TasbihChallenge? loadedCustom;
      if (customRaw != null) {
        final challenge = jsonDecode(customRaw) as Map<String, dynamic>;
        loadedCustom = TasbihChallenge(
          id: 'custom_user',
          title: challenge['title'] ?? 'تحديي الخاص',
          dhikr: challenge['dhikr'] ?? 'سُبْحَانَ اللَّهِ',
          targetCount: (challenge['targetCount'] as num?)?.toInt() ?? 100,
          badge: 'تحدٍ خاص',
          rewardVirtue: 'ورد مخصص من اختيارك للثبات على الذكر.',
          icon: Icons.flag_rounded,
          color: const Color(0xFF176B5B),
          isCustom: true,
        );
      }

      setState(() {
        _counter = prefs.getInt('tasbih_counter') ?? 0;
        _target = (prefs.getInt('tasbih_target') ?? 33).clamp(1, 100000);
        _selectedDhikrIndex = (prefs.getInt('tasbih_dhikr_idx') ?? 0)
            .clamp(0, _dhikrCatalog.length - 1);
        _totalLifetimeTasbih = prefs.getInt('tasbih_lifetime') ?? 0;
        _completedChallengesCount = prefs.getInt('tasbih_completed_count') ?? 0;
        _activeChallengeId = prefs.getString('tasbih_active_challenge');
        _vibrationEnabled = prefs.getBool('tasbih_vibration_enabled') ?? true;
        _customChallenge = loadedCustom;
        _isLoadingState = false;
        _challengeProgress
          ..clear()
          ..addAll(loadedProgress);
      });
    } catch (error) {
      debugPrint('Tasbih state load error: $error');
      if (mounted) {
        setState(() {
          _isLoadingState = false;
          _stateLoadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveTasbihState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_counter', _counter);
      await prefs.setInt('tasbih_target', _target);
      await prefs.setInt('tasbih_dhikr_idx', _selectedDhikrIndex);
      await prefs.setInt('tasbih_lifetime', _totalLifetimeTasbih);
      await prefs.setInt('tasbih_completed_count', _completedChallengesCount);
      await prefs.setBool('tasbih_vibration_enabled', _vibrationEnabled);
      if (_activeChallengeId != null) {
        await prefs.setString('tasbih_active_challenge', _activeChallengeId!);
      } else {
        await prefs.remove('tasbih_active_challenge');
      }
      await prefs.setString(
        'tasbih_challenge_progress',
        jsonEncode(_challengeProgress),
      );
      if (_customChallenge != null) {
        await prefs.setString(
          'tasbih_custom_challenge',
          jsonEncode(_customChallenge!.toJson()),
        );
      }
    } catch (error) {
      debugPrint('Tasbih state save error: $error');
    }
  }

  void _onBeadPressed() {
    if (_isLoadingState) return;
    if (_vibrationEnabled) HapticFeedback.selectionClick();

    final challenge = _activeChallenge;
    final activeDhikrText = challenge?.dhikr ?? _currentDhikrEntry.text;
    var reachedMilestone = false;

    setState(() {
      _totalLifetimeTasbih++;
      if (challenge != null) {
        final next = (_challengeProgress[challenge.id] ?? 0) + 1;
        _challengeProgress[challenge.id] = next;
        _counter = next;
        if (next == challenge.targetCount) {
          _completedChallengesCount++;
          reachedMilestone = true;
        } else if (next > challenge.targetCount &&
            next % challenge.targetCount == 0) {
          reachedMilestone = true;
        }
      } else {
        _counter++;
        if (_target > 0 && _counter % _target == 0) {
          reachedMilestone = true;
        }
      }
      _interactionFeedback = reachedMilestone
          ? 'اكتمل الورد · $_counter'
          : 'تمّ العدّ · $_counter';
    });
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1350), () {
      if (mounted) setState(() => _interactionFeedback = null);
    });

    unawaited(TasbihDailyStore.increment());
    final user = Provider.of<FirdawsUserProvider>(context, listen: false);
    unawaited(user.recordDhikrByText(activeDhikrText));

    try {
      Provider.of<JannatiProvider>(context, listen: false)
          .recordTasbihForGarden(activeDhikrText, count: 1);
    } catch (_) {}
    try {
      Provider.of<HoorCompanionProvider>(context, listen: false)
          .onDhikrPerformed(
        dhikrType: activeDhikrText,
        count: 1,
        userName: user.displayName,
        isFemale: user.isFemale,
      );
    } catch (_) {}
    try {
      Provider.of<FamilyChallengeProvider>(context, listen: false)
          .recordUserTasbih(1);
    } catch (_) {}
    try {
      final hasanat = Provider.of<HasanatProvider>(context, listen: false);
      hasanat.earnHasanat(
        reachedMilestone ? 20 : 1,
        reason: reachedMilestone ? 'إتمام ورد السبحة' : 'تسبيحة في السبحة',
        sourceTag: 'السبحة',
      );
      hasanat.recordMetric(EventMissionMetric.tasbihCount, delta: 1);
    } catch (_) {}

    _saveTasbihState();
  }

  void _reset() {
    setState(() {
      final challenge = _activeChallenge;
      if (challenge != null) _challengeProgress[challenge.id] = 0;
      _counter = 0;
    });
    _saveTasbihState();
  }

  Future<void> _showTargetDialog() async {
    final controller = TextEditingController(text: _target.toString());
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تحديد الهدف'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            labelText: 'عدد التسبيحات',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 1) return;
              setState(() => _target = value.clamp(1, 100000));
              _saveTasbihState();
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _confirmReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة العدّ'),
        content: const Text('هل تريد تصفير العدد الحالي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
    if (shouldReset == true) _reset();
  }

  void _showOptionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إدارة السبحة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'إعداداتك ومؤشراتك واختصاراتك في مكان واحد.',
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 20),
                  ParadiseSection(
                    title: 'ملخص محفوظ',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tileWidth = (constraints.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SizedBox(
                              width: tileWidth,
                              child: ParadiseMetric(
                                value: '$_totalLifetimeTasbih',
                                label: 'مجموع التسبيحات',
                                icon: Icons.all_inclusive_rounded,
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: ParadiseMetric(
                                value: '$_completedChallengesCount',
                                label: 'أوراد مكتملة',
                                icon: Icons.task_alt_rounded,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  CalmCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: scheme.surface,
                    child: SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text('الاهتزاز عند الضغط'),
                      subtitle:
                          const Text('فعّل أو أوقف الاهتزاز مع كل تسبيحة.'),
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() => _vibrationEnabled = value);
                        setSheetState(() {});
                        _saveTasbihState();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ParadiseSection(
                    title: 'انتقال سريع',
                    child: CalmCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          CalmActionTile(
                            icon: Icons.menu_book_outlined,
                            title: 'مكتبة الأذكار',
                            subtitle: 'اختر نصاً أو تصفّح التصنيفات',
                            onTap: () {
                              Navigator.pop(sheetContext);
                              _showDhikrCatalogSheet();
                            },
                          ),
                          const CalmDivider(),
                          CalmActionTile(
                            icon: Icons.flag_outlined,
                            title: 'الأوراد والتحديات',
                            subtitle: 'تابع ورداً قائماً أو أنشئ تحدياً خاصاً',
                            onTap: () {
                              Navigator.pop(sheetContext);
                              _showChallengesSheet();
                            },
                          ),
                          const CalmDivider(),
                          CalmActionTile(
                            icon: Icons.history_rounded,
                            title: 'السجل',
                            subtitle: 'عرض سجلّك اليومي',
                            onTap: () {
                              Navigator.pop(sheetContext);
                              FirdawsNavBridge.jumpTo(1);
                            },
                          ),
                          const CalmDivider(),
                          CalmActionTile(
                            icon: Icons.spa_outlined,
                            title: 'جنتي',
                            subtitle: 'متابعة غراس الذكر',
                            onTap: () {
                              Navigator.pop(sheetContext);
                              FirdawsNavBridge.jumpTo(5, jannatiTab: 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChallengesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final challenges = [
              ...TasbihChallengesCatalog.builtIn,
              if (_customChallenge != null) _customChallenge!,
            ];
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.82,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'تحديات السبحة',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _showCreateCustomChallengeDialog();
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('تحدٍ خاص'),
                          ),
                        ],
                      ),
                    ),
                    if (_activeChallenge != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _activeChallengeId = null;
                              _counter = 0;
                            });
                            _saveTasbihState();
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(Icons.close_rounded),
                          label:
                              const Text('إنهاء التحدي والعودة للسبحة الحرة'),
                        ),
                      ),
                    Expanded(
                      child: challenges.isEmpty
                          ? const CalmEmptyState(
                              icon: Icons.flag_outlined,
                              title: 'لا توجد تحديات متاحة الآن',
                              subtitle:
                                  'يمكنك إنشاء ورد خاص والبدء به متى شئت.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: challenges.length,
                              itemBuilder: (context, index) {
                                final challenge = challenges[index];
                                final progress =
                                    _challengeProgress[challenge.id] ?? 0;
                                final ratio = (progress / challenge.targetCount)
                                    .clamp(0.0, 1.0);
                                final active =
                                    _activeChallengeId == challenge.id;
                                final complete =
                                    progress >= challenge.targetCount;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CalmCard(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 14),
                                    color:
                                        active ? scheme.primaryContainer : null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CalmIconBadge(challenge.icon,
                                                size: 46),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    challenge.title,
                                                    softWrap: true,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    active
                                                        ? 'هذا هو الورد النشط حالياً'
                                                        : (complete
                                                            ? 'اكتمل الهدف المحفوظ'
                                                            : 'هدف ثابت بخطوات قابلة للمتابعة'),
                                                    softWrap: true,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: scheme
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (complete)
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(
                                                  start: 8,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle_outline,
                                                  color: scheme.primary,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: scheme.surface,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: const Color(0xFFB99C64)
                                                  .withOpacity(.3),
                                            ),
                                          ),
                                          child: Text(
                                            challenge.dhikr,
                                            textAlign: TextAlign.start,
                                            softWrap: true,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(height: 1.8),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          alignment: WrapAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'الهدف ${challenge.targetCount}',
                                              softWrap: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            Text(
                                              '$progress من ${challenge.targetCount}',
                                              textAlign: TextAlign.end,
                                              softWrap: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 9),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: ratio,
                                            minHeight: 6,
                                            backgroundColor:
                                                scheme.surfaceContainerHighest,
                                          ),
                                        ),
                                        if (challenge
                                            .rewardVirtue.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            challenge.rewardVirtue,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: FilledButton.tonal(
                                            onPressed: () {
                                              setState(() {
                                                _activeChallengeId =
                                                    challenge.id;
                                                _counter = progress;
                                              });
                                              _saveTasbihState();
                                              Navigator.pop(sheetContext);
                                            },
                                            child: Text(
                                              active
                                                  ? 'التحدي الحالي'
                                                  : (complete
                                                      ? 'بدء من جديد'
                                                      : 'ابدأ التحدي'),
                                            ),
                                          ),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateCustomChallengeDialog() {
    final titleController = TextEditingController(text: 'ورد التسبيح الخاص');
    final dhikrController = TextEditingController(
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    );
    final targetController = TextEditingController(text: '100');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إنشاء تحدٍ خاص'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'اسم التحدي'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dhikrController,
                decoration: const InputDecoration(labelText: 'نص الذكر'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الهدف'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final count = int.tryParse(targetController.text.trim()) ?? 100;
              final target = count.clamp(1, 100000);
              final challenge = TasbihChallenge(
                id: 'custom_user',
                title: titleController.text.trim().isEmpty
                    ? 'تحديي الخاص'
                    : titleController.text.trim(),
                dhikr: dhikrController.text.trim().isEmpty
                    ? 'سُبْحَانَ اللَّهِ'
                    : dhikrController.text.trim(),
                targetCount: target,
                badge: 'تحدٍ خاص',
                rewardVirtue: 'ورد مخصص من اختيارك للثبات على الذكر.',
                icon: Icons.flag_rounded,
                color: Theme.of(context).colorScheme.primary,
                isCustom: true,
              );
              setState(() {
                _customChallenge = challenge;
                _activeChallengeId = challenge.id;
                _challengeProgress[challenge.id] = 0;
                _counter = 0;
              });
              _saveTasbihState();
              Navigator.pop(dialogContext);
            },
            child: const Text('بدء التحدي'),
          ),
        ],
      ),
    ).whenComplete(() {
      titleController.dispose();
      dhikrController.dispose();
      targetController.dispose();
    });
  }

  void _showDhikrCatalogSheet() {
    var selectedCategory = 'الكل';
    var searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = Tasbih1000Catalog.search(
            query: searchQuery,
            category: selectedCategory,
          );
          final categories = ['الكل', ...Tasbih1000Catalog.categories];
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.86,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مكتبة الأذكار',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          '${filtered.length} نتيجة',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (value) =>
                              setSheetState(() => searchQuery = value),
                          decoration: const InputDecoration(
                            hintText: 'ابحث في نصوص الأذكار والأدعية',
                            prefixIcon: Icon(Icons.search_rounded),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (_) => setSheetState(
                            () => selectedCategory = category,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const CalmEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'لم نعثر على نتيجة',
                            subtitle: 'جرّب كلمة أخرى أو اختر تصنيفاً مختلفاً.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final entry = filtered[index];
                              final isSelected =
                                  entry.number - 1 == _selectedDhikrIndex;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CalmCard(
                                  padding: EdgeInsets.zero,
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedDhikrIndex = entry.number - 1;
                                      _counter = 0;
                                      _activeChallengeId = null;
                                      if (entry.recommendedCount > 0) {
                                        _target = entry.recommendedCount;
                                      }
                                    });
                                    _saveTasbihState();
                                    Navigator.pop(sheetContext);
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 17,
                                      child: Text('${entry.number}'),
                                    ),
                                    title: Text(
                                      entry.text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(height: 1.6),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${entry.category}  •  الهدف المقترح: ${entry.recommendedCount}\n${entry.virtue}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(height: 1.45),
                                      ),
                                    ),
                                    trailing: Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDhikrPanel({
    required TasbihChallenge? activeChallenge,
    required String activeDhikr,
  }) {
    final theme = Theme.of(context);
    final entry = _currentDhikrEntry;
    return CalmCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalmIconBadge(
                activeChallenge == null
                    ? Icons.menu_book_rounded
                    : Icons.flag_rounded,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeChallenge == null
                          ? 'الذكر المختار'
                          : activeChallenge.title,
                      softWrap: true,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeChallenge == null
                          ? '${entry.category}  •  الهدف المقترح ${entry.recommendedCount}'
                          : 'ورد محدد · ${activeChallenge.targetCount} تسبيحة',
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeChallenge == null)
                IconButton(
                  tooltip: 'اختيار ذكر',
                  onPressed: _showDhikrCatalogSheet,
                  icon: const Icon(Icons.tune_rounded),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFB99C64).withOpacity(.35),
              ),
            ),
            child: Text(
              activeDhikr,
              textAlign: TextAlign.center,
              softWrap: true,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 26,
                height: 1.9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (activeChallenge == null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _showDhikrCatalogSheet,
                icon: const Icon(Icons.library_books_outlined, size: 19),
                label: const Text('تصفّح مكتبة الأذكار'),
              ),
            )
          else
            Text(
              'تقدّم في هذا الورد باستخدام زرّ العدّاد.',
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounterPanel({
    required int effectiveTarget,
    required int remaining,
    required double progress,
    required bool hasActiveChallenge,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final comfort = Provider.of<ComfortProvider?>(context);
    final reduceMotion =
        mediaQuery.disableAnimations || (comfort?.reduceMotion ?? false);
    final highContrast =
        mediaQuery.highContrast || (comfort?.highContrast ?? false);
    return CalmCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hasActiveChallenge ? 'عداد التحدّي' : 'عداد الورد',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasActiveChallenge ? 'تحدٍّ نشط' : 'عدّ حر',
                  softWrap: true,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: InteractiveTasbihBeads(
              count: _counter,
              target: effectiveTarget,
              progress: progress,
              reduceMotion: reduceMotion,
              highContrast: highContrast,
              onTap: _isLoadingState ? null : _onBeadPressed,
            ),
          ),
          const SizedBox(height: 7),
          Semantics(
            liveRegion: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 28),
              child: Center(
                child: Text(
                  _interactionFeedback ?? 'المس الخرز مرة واحدة للعدّ',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _interactionFeedback == null
                        ? scheme.onSurfaceVariant
                        : scheme.primary,
                    fontWeight: _interactionFeedback == null
                        ? FontWeight.normal
                        : FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: FilledButton.icon(
              onPressed: _isLoadingState ? null : _onBeadPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('تسبيح'),
              style: FilledButton.styleFrom(
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Text(
                'الهدف $effectiveTarget',
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'المتبقي $remaining',
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (!hasActiveChallenge)
                OutlinedButton.icon(
                  onPressed: _showTargetDialog,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('تغيير الهدف'),
                ),
              TextButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('إعادة العدّ'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadNotice() {
    final theme = Theme.of(context);
    final isError = _stateLoadFailed;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isError
              ? theme.colorScheme.error.withOpacity(.4)
              : const Color(0xFFB99C64).withOpacity(.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingState)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            )
          else
            Icon(Icons.info_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _isLoadingState
                  ? 'جارٍ استعادة آخر إعدادات العدّ المحفوظة.'
                  : 'تعذّرت قراءة بعض الإعدادات المحفوظة؛ يمكنك المتابعة بالعدد الظاهر.',
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeChallenge = _activeChallenge;
    final activeDhikr = activeChallenge?.dhikr ?? _currentDhikrEntry.text;
    final effectiveTarget = activeChallenge?.targetCount ?? _target;
    final completedInCycle =
        effectiveTarget > 0 ? _counter % effectiveTarget : 0;
    final progress = _counter > 0 && completedInCycle == 0
        ? 1.0
        : completedInCycle / effectiveTarget;
    final remaining = completedInCycle == 0 && _counter > 0
        ? 0
        : effectiveTarget - completedInCycle;

    return CalmPage(
      title: 'السبحة',
      subtitle: 'خذ لحظة للذكر',
      actions: [
        IconButton(
          tooltip: 'خيارات السبحة',
          onPressed: _isLoadingState ? null : _showOptionsSheet,
          icon: const Icon(Icons.more_horiz_rounded),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoadingState || _stateLoadFailed) _buildLoadNotice(),
          LayoutBuilder(
            builder: (context, constraints) {
              final dhikrPanel = _buildDhikrPanel(
                activeChallenge: activeChallenge,
                activeDhikr: activeDhikr,
              );
              final counterPanel = _buildCounterPanel(
                effectiveTarget: effectiveTarget,
                remaining: remaining,
                progress: progress,
                hasActiveChallenge: activeChallenge != null,
              );
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: dhikrPanel),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: counterPanel),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dhikrPanel,
                  const SizedBox(height: 14),
                  counterPanel,
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          ParadiseSection(
            title: 'حصادك في السبحة',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - 10) / 2;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: ParadiseMetric(
                        value: '$_totalLifetimeTasbih',
                        label: 'مجموع التسبيحات',
                        icon: Icons.all_inclusive_rounded,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: ParadiseMetric(
                        value: '$_completedChallengesCount',
                        label: 'أوراد مكتملة',
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          ParadiseSection(
            title: 'متابعة المسار',
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                ParadiseChip(
                  label: 'مكتبة الأذكار',
                  icon: Icons.menu_book_outlined,
                  onTap: _showDhikrCatalogSheet,
                ),
                ParadiseChip(
                  label: 'الأوراد والتحديات',
                  icon: Icons.flag_outlined,
                  onTap: _showChallengesSheet,
                ),
                ParadiseChip(
                  label: 'خيارات السبحة',
                  icon: Icons.tune_rounded,
                  onTap: _showOptionsSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
