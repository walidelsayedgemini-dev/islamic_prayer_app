import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

class UserProfileEditorSheet extends StatefulWidget {
  const UserProfileEditorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const UserProfileEditorSheet(),
    );
  }

  @override
  State<UserProfileEditorSheet> createState() => _UserProfileEditorSheetState();
}

class _UserProfileEditorSheetState extends State<UserProfileEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late String _gender;
  late List<String> _preferences;
  late int _dailyDhikrGoal;
  late bool _enableMotivations;
  late bool _enablePrayerTimeEffects;

  @override
  void initState() {
    super.initState();
    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    final p = userProv.profile;
    _nameController = TextEditingController(text: p.name);
    _ageController = TextEditingController(text: p.age.toString());
    _gender = p.gender;
    _preferences = List<String>.from(p.preferences);
    _dailyDhikrGoal = p.dailyDhikrGoal;
    _enableMotivations = p.enableMotivations;
    _enablePrayerTimeEffects = p.enablePrayerTimeEffects;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  bool _pickingAvatar = false;

  Future<void> _pickAvatarFromGallery(ThemePalette palette) async {
    if (_pickingAvatar) return;
    setState(() => _pickingAvatar = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 82,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
      await userProv.updateAvatarBase64(base64Encode(bytes));
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: palette.cardColor,
          behavior: SnackBarBehavior.floating,
          content: Text(
            '📸✨ تم حفظ صورتك الشخصية بنجاح!',
            style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: palette.cardColor,
          content: Text(
            'تعذر فتح معرض الصور حالياً: $e',
            style: TextStyle(color: palette.textPrimary),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  Future<void> _saveProfile(ThemePalette palette) async {
    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    final parsedAge = (int.tryParse(_ageController.text.trim()) ?? 24).clamp(5, 110);
    await userProv.updateProfile(
      name: _nameController.text.trim(),
      age: parsedAge,
      gender: _gender,
      preferences: _preferences,
      dailyDhikrGoal: _dailyDhikrGoal,
      enableMotivations: _enableMotivations,
      enablePrayerTimeEffects: _enablePrayerTimeEffects,
    );
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.of(context).pop();
    final greeting = userProv.getPersonalizedMotivation();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.accentColor, width: 1.5),
        ),
        content: Text(
          greeting,
          style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: settings.isNightEffective);
    final accent = palette.accentColor;
    final avatarBytes = userProv.avatarBytes;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: palette.scaffoldColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 46,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: palette.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickAvatarFromGallery(palette),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.18),
                            border: Border.all(color: accent, width: 1.8),
                          ),
                          child: ClipOval(
                            child: avatarBytes != null
                                ? Image.memory(avatarBytes, fit: BoxFit.cover)
                                : Image.asset(
                                    'assets/images/palace_jannah_logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Icon(Icons.person_rounded, color: accent, size: 22),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🌟 ملفي الشخصي وتفضيلاتي في الفردوس ${themeOption.primaryEmoji}',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.5,
                              ),
                            ),
                            Text(
                              '✨ يُخصَّص الاسم والصورة والنوع للـ 500 عبارة والألقاب الـ 200',
                              style: TextStyle(color: palette.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: palette.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(color: palette.dividerColor, height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                    children: [
                      // بطاقة الصورة الشخصية العصرية من المعرض
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent.withOpacity(0.14),
                              palette.cardColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent.withOpacity(0.45)),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: accent, width: 2.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.28),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: avatarBytes != null
                                        ? Image.memory(avatarBytes, fit: BoxFit.cover)
                                        : Image.asset(
                                            'assets/images/palace_jannah_logo.png',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person_rounded,
                                              color: accent,
                                              size: 36,
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () => _pickAvatarFromGallery(palette),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: accent,
                                        border: Border.all(
                                          color: palette.scaffoldColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 13,
                                        color: palette.onAccentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📸 صورتك الشخصية في الفردوس ✨',
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'ارفع صورة من معرض جهازك لتظهر في ملفك والقائمة الجانبية',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _pickingAvatar
                                            ? null
                                            : () => _pickAvatarFromGallery(palette),
                                        icon: const Icon(Icons.photo_library_rounded, size: 16),
                                        label: Text(
                                          _pickingAvatar
                                              ? 'جاري الفتح...'
                                              : '📷 اختيار من المعرض',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accent,
                                          foregroundColor: palette.onAccentColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      if (avatarBytes != null)
                                        OutlinedButton.icon(
                                          onPressed: () => userProv.updateAvatarBase64(null),
                                          icon: const Icon(Icons.delete_outline_rounded, size: 15),
                                          label: const Text(
                                            '🗑️ حذف',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.redAccent,
                                            side: const BorderSide(color: Colors.redAccent),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '🪪 الاسم (يظهر في التحيات والعبارات التشجيعية والألقاب)',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: palette.textPrimary, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'اكتب اسمك أو كنيتك (مثال: وليد، أحمد، فاطمة)',
                          hintStyle: TextStyle(color: palette.textMuted, fontSize: 13),
                          prefixIcon: Icon(Icons.badge_rounded, color: accent),
                          filled: true,
                          fillColor: palette.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: palette.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: palette.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العمر',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '24',
                                    prefixIcon: Icon(Icons.cake_rounded, color: accent),
                                    filled: true,
                                    fillColor: palette.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: palette.dividerColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: palette.dividerColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'النوع (لصياغة الألقاب والتشجيع)',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGenderChip(
                                        label: 'ذكر',
                                        icon: Icons.man_rounded,
                                        selected: _gender == 'male',
                                        palette: palette,
                                        onTap: () => setState(() => _gender = 'male'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildGenderChip(
                                        label: 'أنثى',
                                        icon: Icons.woman_rounded,
                                        selected: _gender == 'female',
                                        palette: palette,
                                        onTap: () => setState(() => _gender = 'female'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'هدف التسبيح والذكر اليومي',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [33, 100, 300, 500, 1000].map((goal) {
                          final isSel = _dailyDhikrGoal == goal;
                          return ChoiceChip(
                            label: Text(
                              '$goal ذكر يومياً',
                              style: TextStyle(
                                color: isSel
                                    ? palette.onAccentColor
                                    : palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: accent,
                            backgroundColor: palette.cardColor,
                            onSelected: (_) =>
                                setState(() => _dailyDhikrGoal = goal),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تفضيلاتي الإيمانية واهتماماتي',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: FirdawsUserProvider.availablePreferences.map((pref) {
                          final selected = _preferences.contains(pref);
                          return FilterChip(
                            label: Text(
                              pref,
                              style: TextStyle(
                                color: selected
                                    ? palette.onAccentColor
                                    : palette.textPrimary,
                                fontSize: 12,
                                fontWeight:
                                    selected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: selected,
                            selectedColor: accent,
                            checkmarkColor: palette.onAccentColor,
                            backgroundColor: palette.cardColor,
                            side: BorderSide(
                              color: selected ? accent : palette.dividerColor,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  if (!_preferences.contains(pref)) {
                                    _preferences.add(pref);
                                  }
                                } else {
                                  _preferences.remove(pref);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: palette.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.dividerColor),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                'عرض العبارات التشجيعية بالاسم (500 عبارة)',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _enableMotivations,
                              activeTrackColor: accent,
                              onChanged: (v) =>
                                  setState(() => _enableMotivations = v),
                            ),
                            Divider(color: palette.dividerColor, height: 1),
                            SwitchListTile(
                              title: Text(
                                'مؤثرات أوقات الصلاة الحيّة في الشاشة الرئيسية',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _enablePrayerTimeEffects,
                              activeTrackColor: accent,
                              onChanged: (v) =>
                                  setState(() => _enablePrayerTimeEffects = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _saveProfile(palette),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text(
                          'حفظ البيانات وتخصيص الفردوس باسمي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: palette.onAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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
  }

  Widget _buildGenderChip({
    required String label,
    required IconData icon,
    required bool selected,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final accent = palette.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? accent : palette.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : palette.dividerColor,
            width: selected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? palette.onAccentColor : palette.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? palette.onAccentColor : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
