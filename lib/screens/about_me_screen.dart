import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _pickPhotoFromGallery(FirdawsUserProvider userProv) async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 82,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        await userProv.updateAvatarBase64(base64Encode(bytes));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع صورتك الشخصية من المعرض بنجاح ✨📸'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح المعرض: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  void _openEditAboutSheet(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final nameCtrl = TextEditingController(text: userProv.aboutCreatorName);
    final titleCtrl = TextEditingController(text: userProv.aboutCreatorTitle);
    final bioCtrl = TextEditingController(text: userProv.aboutBio);
    final duaCtrl = TextEditingController(text: userProv.aboutDuaRequest);
    final contactCtrl = TextEditingController(text: userProv.aboutContactInfo);
    final accent = palette.accentColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: accent, width: 1.8)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تعديل بيانات قسم «عنّي والدعاء» ✏️💛',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _field(nameCtrl, 'الاسم أو الكنية ✨', palette, accent),
                const SizedBox(height: 8),
                _field(titleCtrl, 'الصفة أو الرسالة 🌟', palette, accent),
                const SizedBox(height: 8),
                _field(bioCtrl, 'نبذة عني وعن التطبيق 📖', palette, accent, lines: 3),
                const SizedBox(height: 8),
                _field(duaCtrl, 'رجاء الدعاء لمن ينتفع بالتطبيق 🤲', palette, accent, lines: 3),
                const SizedBox(height: 8),
                _field(contactCtrl, 'ملاحظة أو وسيلة تواصل اختيارية 💌', palette, accent),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () async {
                    await userProv.updateAboutInfo(
                      creatorName: nameCtrl.text,
                      creatorTitle: titleCtrl.text,
                      bio: bioCtrl.text,
                      duaRequest: duaCtrl.text,
                      contactInfo: contactCtrl.text,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'حفظ البيانات ✅',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: palette.onAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    ThemePalette palette,
    Color accent, {
    int lines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      style: TextStyle(color: palette.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accent, fontSize: 12),
        filled: true,
        fillColor: palette.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.dividerColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOpt.resolve(isNight: isNight);
    final accent = palette.accentColor;
    final avatarBytes = userProv.avatarBytes;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: Prayer.isha,
              themeOption: themeOpt,
              isNightMode: isNight,
            ),
          ),
          Positioned.fill(
            child: IslamicThemeEffectsCanvas(
              themeOption: themeOpt,
              isNightMode: isNight,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // الشريط العلوي
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.cardColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: Icon(Icons.arrow_back_rounded, color: accent),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 6),
                      const Text('💛', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'عنّي وبياناتي والدعاء 🤲 ${themeOpt.primaryEmoji}',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_note_rounded, color: accent),
                        tooltip: 'تعديل بياناتي',
                        onPressed: () =>
                            _openEditAboutSheet(context, userProv, palette),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // بطاقة الهوية والصورة الشخصية من المعرض
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: palette.cardColor.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: accent.withOpacity(0.65), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulse,
                                    builder: (_, child) => Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            accent,
                                            palette.primaryColor,
                                            accent,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(0.28 + _pulse.value * 0.25),
                                            blurRadius: 18,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    ),
                                    child: CircleAvatar(
                                      radius: 52,
                                      backgroundColor: palette.elevatedCardColor,
                                      backgroundImage: avatarBytes != null
                                          ? MemoryImage(avatarBytes)
                                          : const AssetImage(
                                              'assets/images/palace_jannah_logo.png',
                                            ) as ImageProvider,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _pickPhotoFromGallery(userProv),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: palette.scaffoldColor,
                                          width: 2.2,
                                        ),
                                      ),
                                      child: _pickingPhoto
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: palette.onAccentColor,
                                              ),
                                            )
                                          : Icon(
                                              Icons.photo_camera_rounded,
                                              color: palette.onAccentColor,
                                              size: 18,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userProv.aboutCreatorName,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${userProv.aboutCreatorTitle} ${themeOpt.emojiStrip}',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _pickPhotoFromGallery(userProv),
                                    icon: Icon(Icons.photo_library_rounded, color: accent, size: 17),
                                    label: Text(
                                      avatarBytes == null
                                          ? 'رفع صورتي من المعرض 📸'
                                          : 'تغيير الصورة 📸',
                                      style: TextStyle(color: accent, fontSize: 11.5),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: accent.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  if (avatarBytes != null) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'إرجاع شعار قصر الفردوس',
                                      onPressed: () => userProv.updateAvatarBase64(null),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userProv.aboutBio,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 13.5,
                                  height: 1.65,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (userProv.aboutContactInfo.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.elevatedCardColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '💌 ${userProv.aboutContactInfo}',
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // بطاقة طلب الدعاء الصادق بظهر الغيب
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                accent.withOpacity(palette.isDark ? 0.24 : 0.14),
                                palette.cardColor.withOpacity(0.95),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: accent, width: 1.6),
                          ),
                          child: Column(
                            children: [
                              const Text('🤲💛🌙', style: TextStyle(fontSize: 28)),
                              const SizedBox(height: 8),
                              Text(
                                'أتمنى دعواتكم بظهر الغيب 🤲',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userProv.aboutDuaRequest,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 14.5,
                                  height: 1.75,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await userProv.incrementCreatorDua();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: palette.cardColor,
                                        content: Text(
                                          'آمـيـن! ولك بالمثل وأكثر يا ${userProv.displayName}، جزاك الله الفردوس الأعلى 🤲🌸',
                                          style: TextStyle(color: palette.textPrimary),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Text('🤲', style: TextStyle(fontSize: 20)),
                                  label: Text(
                                    'دعوتُ لك بالخير بظهر الغيب (${userProv.creatorDuasCount}) 💛',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // إحصائية ملف المستخدم الشخصي في التطبيق
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: palette.cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: palette.dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('🕌 الصلوات', '${userProv.totalPrayersLogged}', palette, accent),
                              _statItem('📿 الأذكار', '${userProv.totalDhikr}', palette, accent),
                              _statItem('🤲 الدعوات', '${userProv.creatorDuasCount}', palette, accent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, ThemePalette palette, Color accent) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: accent,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
        ),
      ],
    );
  }
}
