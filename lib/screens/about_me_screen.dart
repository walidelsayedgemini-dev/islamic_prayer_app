import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../services/suggestions_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/calm_ui.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';

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
              content: Text('تم تحديث الصورة الشخصية.'),
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
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * .92,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: accent.withOpacity(.42)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const CalmIconBadge(Icons.edit_note_rounded, size: 46),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'بيانات صاحب الرسالة',
                                softWrap: true,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: FirdawsType.title,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'حدّث التعريف، واترك وسيلة التواصل اختيارية.',
                                softWrap: true,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: FirdawsType.caption,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _field(nameCtrl, 'الاسم أو الكنية', palette, accent),
                    const SizedBox(height: 12),
                    _field(titleCtrl, 'الصفة أو الرسالة', palette, accent),
                    const SizedBox(height: 12),
                    _field(bioCtrl, 'نبذة عن المشروع', palette, accent, lines: 4),
                    const SizedBox(height: 12),
                    _field(
                      duaCtrl,
                      'طلب الدعاء',
                      palette,
                      accent,
                      lines: 4,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      contactCtrl,
                      'ملاحظة أو وسيلة تواصل اختيارية',
                      palette,
                      accent,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
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
                          'حفظ التغييرات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: palette.onAccentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
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

  Widget _field(
    TextEditingController ctrl,
    String label,
    ThemePalette palette,
    Color accent, {
    int lines = 1,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: palette.dividerColor),
    );
    return TextField(
      controller: ctrl,
      maxLines: lines,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: FirdawsType.body,
        height: 1.45,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: palette.textSecondary, fontSize: FirdawsType.label),
        filled: true,
        fillColor: palette.cardColor,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.5),
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
    final scene = FirdawsParadiseRegistry.imageFor(settings.selectedTheme);

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          const Positioned.fill(child: BotanicalBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) {
                final compact = viewport.maxWidth < 440;
                final horizontal = compact ? 14.0 : 24.0;
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _pageHeader(context, userProv, palette),
                          const SizedBox(height: 18),
                          if (!userProv.isInitialized) ...[
                            _loadingNotice(palette),
                            const SizedBox(height: 14),
                          ],
                          ParadiseHero(
                            title: 'عنّي وأثر المشروع',
                            subtitle:
                                'تعريف بصاحب الرسالة، ومساحة لإدارة البيانات وإرسال المقترحات.',
                            imageAsset: scene,
                            minHeight: compact ? 224 : 260,
                            footer: ParadiseChip(
                              label: 'تعديل بيانات التعريف',
                              icon: Icons.edit_note_rounded,
                              onTap: () => _openEditAboutSheet(
                                context,
                                userProv,
                                palette,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ParadiseSection(
                            title: 'هوية المشروع',
                            child: _identityCard(
                              userProv,
                              palette,
                              accent,
                              avatarBytes,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ParadiseSection(
                            title: 'رسالة الدعاء والاقتراحات',
                            child: _duaAndFeedbackCard(
                              context,
                              userProv,
                              palette,
                              accent,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ParadiseSection(
                            title: 'أثر الاستخدام',
                            child: _activityMetrics(userProv, palette, accent),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageHeader(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'رجوع',
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: palette.cardColor,
            foregroundColor: palette.textPrimary,
            side: BorderSide(color: palette.dividerColor),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عنّي',
                softWrap: true,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: FirdawsType.title,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              Text(
                'الملف الشخصي',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: FirdawsType.caption,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _openEditAboutSheet(context, userProv, palette),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('تعديل'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.accentColor,
            side: BorderSide(color: palette.accentColor.withOpacity(.45)),
            minimumSize: const Size(44, 46),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingNotice(ThemePalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: palette.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'جارٍ تحميل بيانات الملف المحفوظة…',
              softWrap: true,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: FirdawsType.label,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identityCard(
    FirdawsUserProvider userProv,
    ThemePalette palette,
    Color accent,
    Uint8List? avatarBytes,
  ) {
    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 590;
          final portrait = _portraitControl(userProv, palette, accent, avatarBytes);
          final details = _identityDetails(userProv, palette, accent);
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                portrait,
                const SizedBox(height: 22),
                details,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              const SizedBox(width: 28),
              portrait,
            ],
          );
        },
      ),
    );
  }

  Widget _portraitControl(
    FirdawsUserProvider userProv,
    ThemePalette palette,
    Color accent,
    Uint8List? avatarBytes,
  ) {
    final portrait = avatarBytes == null
        ? FirdawsBrandLogo(
            size: 126,
            borderColor: accent,
            borderWidth: 0,
            userAvatarBytes: null,
            fallbackIcon: Icons.person_outline_rounded,
          )
        : Image.memory(
            avatarBytes,
            width: 126,
            height: 126,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 126,
              height: 126,
              color: palette.elevatedCardColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                size: 38,
                color: palette.textSecondary,
              ),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(.42 + _pulse.value * .14),
                  palette.dividerColor,
                  accent.withOpacity(.66),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.10 + _pulse.value * .08),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(width: 126, height: 126, child: child),
            ),
          ),
          child: portrait,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pickingPhoto
                  ? null
                  : () => _pickPhotoFromGallery(userProv),
              icon: _pickingPhoto
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    )
                  : Icon(
                      avatarBytes == null
                          ? Icons.add_a_photo_outlined
                          : Icons.photo_camera_back_outlined,
                      size: 18,
                    ),
              label: Text(
                _pickingPhoto
                    ? 'جارٍ تجهيز الصورة'
                    : avatarBytes == null
                        ? 'اختيار صورة'
                        : 'تغيير الصورة',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                minimumSize: const Size(44, 46),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                side: BorderSide(color: accent.withOpacity(.45)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            if (avatarBytes != null)
              IconButton(
                tooltip: 'إزالة الصورة والعودة إلى الشعار',
                onPressed: () => userProv.updateAvatarBase64(null),
                style: IconButton.styleFrom(
                  minimumSize: const Size(46, 46),
                  foregroundColor: palette.textSecondary,
                  backgroundColor: palette.elevatedCardColor,
                ),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
      ],
    );
  }

  Widget _identityDetails(
    FirdawsUserProvider userProv,
    ThemePalette palette,
    Color accent,
  ) {
    final name = userProv.aboutCreatorName.trim();
    final title = userProv.aboutCreatorTitle.trim();
    final bio = userProv.aboutBio.trim();
    final contact = userProv.aboutContactInfo.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(11, 7, 11, 7),
          decoration: BoxDecoration(
            color: palette.elevatedCardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'تعريف المشروع',
            style: TextStyle(
              color: accent,
              fontSize: FirdawsType.caption,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name.isEmpty ? 'اسم صاحب الرسالة' : name,
          softWrap: true,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: FirdawsType.headline,
            height: 1.28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title.isEmpty ? 'لم تُضف صفة تعريفية بعد.' : title,
          softWrap: true,
          style: TextStyle(
            color: accent,
            fontSize: FirdawsType.body,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Container(height: 1, color: palette.dividerColor),
        const SizedBox(height: 14),
        Text(
          bio.isEmpty
              ? 'لا توجد نبذة مضافة. يمكنك كتابة تعريف بالمشروع من خيار «تعديل».'
              : bio,
          softWrap: true,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: FirdawsType.body,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 16),
        if (contact.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.dividerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mail_outline_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    contact,
                    softWrap: true,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: FirdawsType.label,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _emptyNote(
            palette,
            'معلومة اختيارية',
            'لم تُضف وسيلة تواصل أو ملاحظة.',
          ),
      ],
    );
  }

  Widget _duaAndFeedbackCard(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
    Color accent,
  ) {
    final request = userProv.aboutDuaRequest.trim();
    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CalmIconBadge(Icons.volunteer_activism_outlined, size: 48),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب الدعاء',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: FirdawsType.section,
                        height: 1.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رسالة صاحب المشروع للزائر',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: FirdawsType.caption,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(8),
                topEnd: Radius.circular(18),
                bottomEnd: Radius.circular(18),
                bottomStart: Radius.circular(18),
              ),
              border: BorderDirectional(
                start: BorderSide(color: accent.withOpacity(.62), width: 3),
              ),
            ),
            child: Text(
              request.isEmpty
                  ? 'لم تُضف رسالة بعد. يمكنك إدخالها من خيار «تعديل بيانات التعريف».'
                  : userProv.aboutDuaRequest,
              softWrap: true,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: FirdawsType.body,
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),
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
              icon: const Icon(Icons.volunteer_activism_outlined, size: 20),
              label: Text(
                'دعاء بظهر الغيب · ${userProv.creatorDuasCount}',
                softWrap: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: FirdawsType.label,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: palette.onAccentColor,
                minimumSize: const Size.fromHeight(52),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => SuggestionsService.showComposerSheet(
                context,
                palette,
              ),
              icon: Icon(Icons.mark_email_unread_outlined, color: accent),
              label: Text(
                'إرسال اقتراح خاص',
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontSize: FirdawsType.label,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                side: BorderSide(color: accent.withOpacity(.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityMetrics(
    FirdawsUserProvider userProv,
    ThemePalette palette,
    Color accent,
  ) {
    final values = [
      ('الصلوات المسجّلة', '${userProv.totalPrayersLogged}', Icons.event_available_outlined),
      ('الأذكار', '${userProv.totalDhikr}', Icons.auto_awesome_outlined),
      ('الدعوات', '${userProv.creatorDuasCount}', Icons.volunteer_activism_outlined),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 2;
        const gap = 12.0;
        final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in values)
              SizedBox(
                width: itemWidth,
                child: CalmCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalmIconBadge(item.$3, size: 42),
                      const SizedBox(height: 12),
                      _statItem(item.$1, item.$2, palette, accent),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _emptyNote(ThemePalette palette, String title, String detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.caption,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.caption,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, ThemePalette palette, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: accent,
            fontSize: FirdawsType.section,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          softWrap: true,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: FirdawsType.caption,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
