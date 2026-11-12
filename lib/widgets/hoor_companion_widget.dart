import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hoor_companion_data.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hoor_companion_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_resilient_image.dart';
import 'hoor_character_painter.dart';

class HoorCompanionWidget extends StatefulWidget {
  final ThemePalette palette;
  final VoidCallback? onOpenParadiseSceneryPicker;

  const HoorCompanionWidget({
    super.key,
    required this.palette,
    this.onOpenParadiseSceneryPicker,
  });

  @override
  State<HoorCompanionWidget> createState() => _HoorCompanionWidgetState();
}

class _HoorCompanionWidgetState extends State<HoorCompanionWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _speakController;
  int _lastPulseTick = -1;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _speakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _speakController.dispose();
    super.dispose();
  }

  void _triggerSpeakPulse() {
    _speakController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final hoor = context.watch<HoorCompanionProvider>();
    final user = context.watch<FirdawsUserProvider>();
    final settings = context.watch<SettingsProvider>();
    final palette = widget.palette;

    if (hoor.kineticPulseTick != _lastPulseTick) {
      _lastPulseTick = hoor.kineticPulseTick;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerSpeakPulse();
      });
    }

    final skin = hoor.activeSkin;
    final backdrop = hoor.activeBackdrop;
    final movement = hoor.activeMovement;
    final isDark = palette.isDark;
    final glassFill = isDark
        ? Colors.black.withOpacity(0.42)
        : Colors.white.withOpacity(0.76);
    final bubbleFill = isDark
        ? const Color(0xFF0B241E).withOpacity(0.84)
        : Colors.white.withOpacity(0.92);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          // خلفية الجنة النقية المختارة (من ١٠٠٠ خلفية أو ٤K جنتي)
          Positioned.fill(
            child: FirdawsResilientImage(
              networkUrl: backdrop.remoteUrl,
              fallbackAsset: backdrop.localAsset,
              fit: BoxFit.cover,
            ),
          ),
          // تدرج ستيح ناعم يمزج الخلفية مع المحتوى دون إطارات متداخلة مزعجة
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backdrop.tintTop.withOpacity(isDark ? 0.56 : 0.25),
                    backdrop.tintBottom.withOpacity(isDark ? 0.78 : 0.42),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // شريط التعريف السريع + تبديل الجنس + زر تخصيص المظهر
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: glassFill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(skin.badgeEmoji,
                                style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                hoor.companionName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : palette.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              hoor.isMaleCompanion ? '• رفيقك' : '• رفيقتك',
                              maxLines: 1,
                              style: TextStyle(
                                color: palette.accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // زر سريع لتبديل رفيق ذكر / أنثى
                    InkWell(
                      onTap: () => hoor.switchGenderAndAutoName(
                        hoor.isMaleCompanion
                            ? HoorGender.female
                            : HoorGender.male,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: glassFill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hoor.isMaleCompanion ? 'لحور 🌸' : 'لولد 🌙',
                          maxLines: 1,
                          style: TextStyle(
                            color: isDark ? Colors.white : palette.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _openCustomizationSheet(context, hoor, palette),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: palette.accentColor.withOpacity(0.88),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: Colors.white, size: 17),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // المسرح التفاعلي للشخصية + فقاعة الكلام النصية (صفر صوت / نص فقط)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الشخصية المرسومة بانسيابية 60fps
                    GestureDetector(
                      onTap: () => hoor.triggerManualPraise(
                        category: HoorReplyCategory.tasbih,
                        userName: user.displayName,
                        isFemale: user.isFemale,
                      ),
                      child: SizedBox(
                        width: 126,
                        height: 190,
                        child: AnimatedBuilder(
                          animation: Listenable.merge(
                              [_idleController, _speakController]),
                          builder: (context, _) {
                            final speakVal = _speakController.isAnimating
                                ? (1.0 - _speakController.value)
                                : 0.0;
                            return CustomPaint(
                              painter: HoorCharacterPainter(
                                appearance: hoor.appearance,
                                skin: skin,
                                movement: movement,
                                animationValue: _idleController.value,
                                speakingIntensity: speakVal,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // فقاعة الكلام المصرية الفرفوشة + الحديث الموثق (عرض نصي فقط)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Container(
                          key: ValueKey<String>(hoor.activeBubbleText),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: bubbleFill,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(6),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.16),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hoor.activeBubbleText,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF102A22),
                                  fontSize: 13.2,
                                  height: 1.55,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: palette.accentColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  hoor.activeHadithCitation,
                                  style: TextStyle(
                                    color: isDark
                                        ? palette.accentColor
                                        : palette.accentColor,
                                    fontSize: 11.4,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // أزرار التفاعل الذكري الفرفوش السريع (سبح / استغفر / صل على النبي / فضفض)
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _quickPraiseButton(
                      label: 'سبحان الله 🌿',
                      color: const Color(0xFF0D7A5F),
                      onTap: () => hoor.onDhikrPerformed(
                        dhikrType: 'سبحان الله وبحمده',
                        userName: user.displayName,
                        isFemale: user.isFemale,
                      ),
                    ),
                    _quickPraiseButton(
                      label: 'أستغفر الله 💧',
                      color: const Color(0xFF1D629C),
                      onTap: () => hoor.onDhikrPerformed(
                        dhikrType: 'أستغفر الله العظيم',
                        userName: user.displayName,
                        isFemale: user.isFemale,
                      ),
                    ),
                    _quickPraiseButton(
                      label: 'اللهم صلِّ على محمد ﷺ',
                      color: const Color(0xFF8E5A14),
                      onTap: () => hoor.onDhikrPerformed(
                        dhikrType: 'اللهم صل على محمد',
                        userName: user.displayName,
                        isFemale: user.isFemale,
                      ),
                    ),
                    _quickPraiseButton(
                      label: 'فضفض لـ ${hoor.companionName} 🤍',
                      color: const Color(0xFF6B2D5C),
                      onTap: () => openHoorVentingSheet(context, palette),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // أزرار الـ ١٠٠٠ سكن / ١٠٠٠ خلفية / ١٠٠٠ حركة / ١٠٠ منظر 4K
                Row(
                  children: [
                    Expanded(
                      child: _catalogPill(
                        icon: Icons.checkroom_rounded,
                        title: 'سكنات',
                        countText: '${hoor.activeSkinIndex + 1}/١٠٠٠',
                        glassFill: glassFill,
                        isDark: isDark,
                        palette: palette,
                        onTap: () => _open1000Picker(
                          context,
                          title: 'اختر من ١٠٠٠ سكن وحُلّة حريرية ✨',
                          total: 1000,
                          currentIndex: hoor.activeSkinIndex,
                          labelBuilder: (i) {
                            final s = HoorCatalog.skinByIndex(i);
                            return '${s.badgeEmoji} ${s.title}';
                          },
                          onSelected: hoor.selectSkin,
                          palette: palette,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _catalogPill(
                        icon: Icons.landscape_rounded,
                        title: 'خلفيات الجنة',
                        countText: '${hoor.activeBackdropIndex + 1}/١٠٠٠',
                        glassFill: glassFill,
                        isDark: isDark,
                        palette: palette,
                        onTap: () => _open1000Picker(
                          context,
                          title: 'اختر من ١٠٠٠ خلفية نقية للجنة 🌴',
                          total: 1000,
                          currentIndex: hoor.activeBackdropIndex,
                          labelBuilder: (i) =>
                              HoorCatalog.backdropByIndex(i).title,
                          onSelected: hoor.selectBackdrop,
                          palette: palette,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _catalogPill(
                        icon: Icons.animation_rounded,
                        title: 'الحركات',
                        countText: '${hoor.activeMovementIndex + 1}/١٠٠٠',
                        glassFill: glassFill,
                        isDark: isDark,
                        palette: palette,
                        onTap: () => _open1000Picker(
                          context,
                          title: 'اختر من ١٠٠٠ حركة سلسة ومرنة 💫',
                          total: 1000,
                          currentIndex: hoor.activeMovementIndex,
                          labelBuilder: (i) =>
                              HoorCatalog.movementByIndex(i).title,
                          onSelected: hoor.selectMovement,
                          palette: palette,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // شريط مساعد الشاشة العام + منظر الفردوس 100
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: glassFill,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إظهار ${hoor.companionName} للمساعدة بكل الشاشات',
                          style: TextStyle(
                            color: isDark ? Colors.white : palette.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: hoor.floatingGuideEnabled,
                        activeColor: palette.accentColor,
                        onChanged: hoor.toggleFloatingGuide,
                      ),
                      if (widget.onOpenParadiseSceneryPicker != null)
                        TextButton.icon(
                          onPressed: widget.onOpenParadiseSceneryPicker,
                          icon: const Icon(Icons.photo_library_rounded,
                              size: 16),
                          label: Text(
                            'مشهد ${settings.selectedJannatiSceneryIndex + 1}/١٠٠',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickPraiseButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _catalogPill({
    required IconData icon,
    required String title,
    required String countText,
    required Color glassFill,
    required bool isDark,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: glassFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isDark ? palette.accentColor : palette.accentColor, size: 19),
            const SizedBox(height: 3),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : palette.textPrimary,
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              countText,
              style: TextStyle(
                color: palette.accentColor,
                fontSize: 10.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open1000Picker(
    BuildContext context, {
    required String title,
    required int total,
    required int currentIndex,
    required String Function(int index) labelBuilder,
    required Future<void> Function(int index) onSelected,
    required ThemePalette palette,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.scaffoldColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = List<int>.generate(total, (i) => i).where((i) {
              if (query.trim().isEmpty) return true;
              final q = query.trim().toLowerCase();
              return '${i + 1}'.contains(q) ||
                  labelBuilder(i).toLowerCase().contains(q);
            }).toList();

            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.72,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (v) => setModalState(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'ابحث برقم (١..١٠٠٠) أو باسم...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: palette.elevatedCardColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (c, idx) {
                        final itemIndex = filtered[idx];
                        final selected = itemIndex == currentIndex;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: selected
                                ? palette.accentColor
                                : palette.accentColor.withOpacity(0.18),
                            child: Text(
                              '${itemIndex + 1}',
                              style: TextStyle(
                                color: selected
                                    ? Colors.black
                                    : palette.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            labelBuilder(itemIndex),
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: selected
                              ? Icon(Icons.check_circle_rounded,
                                  color: palette.accentColor)
                              : null,
                          onTap: () async {
                            await onSelected(itemIndex);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
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

  void _openCustomizationSheet(
    BuildContext context,
    HoorCompanionProvider hoor,
    ThemePalette palette,
  ) {
    final nameController = TextEditingController(text: hoor.appearance.name);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.scaffoldColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Consumer<HoorCompanionProvider>(
          builder: (ctx, liveHoor, _) {
            final app = liveHoor.appearance;
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.82,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.textSecondary.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تخصيص أدق تفاصيل الشخصية 👑',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 150,
                      child: AnimatedBuilder(
                        animation: _idleController,
                        builder: (_, __) => CustomPaint(
                          painter: HoorCharacterPainter(
                            appearance: app,
                            skin: liveHoor.activeSkin,
                            movement: liveHoor.activeMovement,
                            animationValue: _idleController.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // الاسم المخصص
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم الرفيق / الرفيقة',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_rounded),
                        onPressed: () {
                          final next = nameController.text.trim();
                          if (next.isNotEmpty) {
                            liveHoor.updateAppearance(app.copyWith(name: next));
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        liveHoor
                            .updateAppearance(app.copyWith(name: val.trim()));
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  // النوع: حور (أنثى) / ولد (ذكر)
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('أنثى (حُور) 🌸'),
                          selected: app.gender == HoorGender.female,
                          onSelected: (_) =>
                              liveHoor.switchGenderAndAutoName(HoorGender.female),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('ذكر (ولد) 🌙'),
                          selected: app.gender == HoorGender.male,
                          onSelected: (_) =>
                              liveHoor.switchGenderAndAutoName(HoorGender.male),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _detailColorSelector(
                    label: 'لون البشرة',
                    colors: HoorCatalog.skinTones,
                    selected: app.skinToneIndex,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(skinToneIndex: i)),
                  ),
                  _detailColorSelector(
                    label: 'لون العينين',
                    colors: HoorCatalog.eyeColors,
                    selected: app.eyeColorIndex,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(eyeColorIndex: i)),
                  ),
                  _detailColorSelector(
                    label: 'لون الرداء / الثوب',
                    colors: HoorCatalog.robePalette,
                    selected: app.robeColorIndex,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(robeColorIndex: i)),
                  ),
                  _detailColorSelector(
                    label: 'لون التطريز الذهبي/الفضي',
                    colors: HoorCatalog.trimPalette,
                    selected: app.trimColorIndex,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(trimColorIndex: i)),
                  ),
                  _detailChoiceRow(
                    label: 'شكل الحجاب / العمامة والوقار',
                    options: app.gender == HoorGender.male
                        ? const ['شعر أنيق', 'طاقية مطرزة', 'عمامة وقورة', 'عمامة ملكية', 'وقار ذهبي']
                        : const ['طرحة حريرية', 'وشاح ذهبي', 'طرحة مطرزة', 'تاج اللؤلؤ', 'نور الفردوس'],
                    selected: app.headwearStyle,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(headwearStyle: i)),
                  ),
                  _detailChoiceRow(
                    label: 'ما يحمله باليد',
                    options: const ['بدون', 'فانوس نور 🏮', 'مصحف 📖', 'سبحة 📿', 'لؤلؤة 💎'],
                    selected: app.handheldItem,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(handheldItem: i)),
                  ),
                  _detailChoiceRow(
                    label: 'تفاصيل العيون والحواجب والابتسامة',
                    options: const ['هادئ', 'باسم دافئ', 'مشع بالبشر', 'خاشع'],
                    selected: app.mouthStyle,
                    onTap: (i) => liveHoor.updateAppearance(app.copyWith(
                      mouthStyle: i,
                      eyeStyle: i,
                      browStyle: i % 3,
                    )),
                  ),
                  _detailChoiceRow(
                    label: 'الهالة النورانية',
                    options: const ['خافتة', 'هالة نور', 'نجوم مضيئة', 'توهج كامل'],
                    selected: app.auraStyle,
                    onTap: (i) =>
                        liveHoor.updateAppearance(app.copyWith(auraStyle: i)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final next = nameController.text.trim();
                      if (next.isNotEmpty) {
                        liveHoor.updateAppearance(app.copyWith(name: next));
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('حفظ التخصيص ✨'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailColorSelector({
    required String label,
    required List<Color> colors,
    required int selected,
    required ValueChanged<int> onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(colors.length, (i) {
              final isSel = i == selected;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSel ? Colors.amber : Colors.white54,
                      width: isSel ? 3 : 1.2,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _detailChoiceRow({
    required String label,
    required List<String> options,
    required int selected,
    required ValueChanged<int> onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(options.length, (i) {
              return ChoiceChip(
                label: Text(options[i], style: const TextStyle(fontSize: 11.5)),
                selected: i == selected,
                onSelected: (_) => onTap(i),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// نافذة خانة الفضفضة والمؤانسة المباشرة (نصياً بالكامل بدون أي صوت منطوق)
Future<void> openHoorVentingSheet(
    BuildContext context, ThemePalette palette) async {
  final textCtrl = TextEditingController();
  final quickPrompts = [
    'حاسس بتعب وضيق ومحتاج كلام يطمني',
    'خايف على رزقي وشغلي الفترة دي',
    'حاسس بالتقصير ونفسي ربنا يغفر لي ويثبتني',
    'محتاج دعوة حلوة تفرّح قلبي النهارده',
  ];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.scaffoldColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Consumer2<HoorCompanionProvider, FirdawsUserProvider>(
          builder: (ctx, hoor, user, _) {
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.78,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          'خانة الفضفضة مع ${hoor.companionName} 🤍',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'بداية صفحة جديدة',
                          onPressed: hoor.clearVentHistory,
                          icon: Icon(Icons.refresh_rounded,
                              color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: quickPrompts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, idx) {
                        return ActionChip(
                          label: Text(quickPrompts[idx],
                              style: const TextStyle(fontSize: 11.5)),
                          onPressed: () => hoor.sendVentMessage(
                            text: quickPrompts[idx],
                            userName: user.displayName,
                            isFemale: user.isFemale,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      itemCount: hoor.ventingHistory.length,
                      itemBuilder: (_, i) {
                        final msg = hoor.ventingHistory[i];
                        return Align(
                          alignment: msg.isUser
                              ? AlignmentDirectional.centerEnd
                              : AlignmentDirectional.centerStart,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(ctx).size.width * 0.78,
                            ),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? palette.accentColor
                                  : palette.elevatedCardColor.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser
                                    ? Colors.white
                                    : palette.textPrimary,
                                fontSize: 13.2,
                                height: 1.55,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textCtrl,
                            maxLines: 2,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText:
                                  'اكتب اللي في قلبك لـ ${hoor.companionName}...',
                              filled: true,
                              fillColor:
                                  palette.elevatedCardColor.withOpacity(0.55),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          backgroundColor: palette.accentColor,
                          onPressed: () {
                            final txt = textCtrl.text.trim();
                            if (txt.isEmpty) return;
                            textCtrl.clear();
                            hoor.sendVentMessage(
                              text: txt,
                              userName: user.displayName,
                              isFemale: user.isFemale,
                            );
                          },
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
