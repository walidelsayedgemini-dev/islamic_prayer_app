import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/firdaws_user_provider.dart';
import '../theme/islamic_theme.dart';

/// خدمة صندوق الاقتراحات والتواصل المباشر مع المطوّر دون إظهار أي بيانات رقمية
class SuggestionsService {
  static String get _channelEndpoint => String.fromCharCodes([
        50, 48, 49, 48, 50, 50, 52, 49, 50, 50, 52, 51,
      ]);

  static Uri buildSuggestionUri({
    required String message,
    String category = 'اقتراح عام',
    String? senderName,
  }) {
    final cleanMsg = message.trim();
    final sender =
        (senderName != null && senderName.trim().isNotEmpty)
            ? senderName.trim()
            : 'مستخدم تطبيق الفردوس';
    final composed =
        'السلام عليكم ورحمة الله وبركاته 🌿\n'
        'رسالة من صندوق الاقتراحات في تطبيق الفردوس:\n'
        '• القسم: $category\n'
        '• المرسل: $sender\n'
        '• النص:\n$cleanMsg';
    final encodedText = Uri.encodeComponent(composed);
    return Uri.parse('https://wa.me/$_channelEndpoint?text=$encodedText');
  }

  static Future<bool> sendSuggestion({
    required String message,
    String category = 'اقتراح عام',
    String? senderName,
  }) async {
    final uri = buildSuggestionUri(
      message: message,
      category: category,
      senderName: senderName,
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static void showComposerSheet(BuildContext context, ThemePalette palette) {
    final controller = TextEditingController();
    String selectedCat = 'اقتراح ميزة جديدة 💡';
    bool sending = false;
    const categories = [
      'اقتراح ميزة جديدة 💡',
      'إضافة ثيم أو خلفية 🎨',
      'تحسين قسم حُور أو الأسئلة 👑',
      'الإبلاغ عن خطأ بسيط 🛠️',
      'كلمة شكر ودعاء 🤲',
    ];

    String? senderName;
    try {
      senderName = Provider.of<FirdawsUserProvider>(context, listen: false)
          .displayName;
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final accent = palette.accentColor;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                decoration: BoxDecoration(
                  color: palette.scaffoldColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.dividerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.16),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mark_email_unread_rounded,
                              color: accent, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'صندوق الاقتراحات 💌',
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'شاركنا فكرتك أو دعاءك أو أي ملاحظة تصل فوراً لفريق التطوير بخصوصية تامة',
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: categories.map((c) {
                        final isSel = selectedCat == c;
                        return ChoiceChip(
                          label: Text(
                            c,
                            style: TextStyle(
                              color: isSel
                                  ? palette.onAccentColor
                                  : palette.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: accent,
                          backgroundColor: palette.cardColor,
                          onSelected: (_) =>
                              setModalState(() => selectedCat = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 3,
                      textInputAction: TextInputAction.newline,
                      style:
                          TextStyle(color: palette.textPrimary, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText:
                            'اكتب اقتراحك أو ملاحظتك هنا بكل محبة... 🌿',
                        hintStyle:
                            TextStyle(color: palette.textMuted, fontSize: 12.5),
                        filled: true,
                        fillColor: palette.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: palette.dividerColor.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: sending
                          ? null
                          : () async {
                              if (controller.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: palette.cardColor,
                                    content: Text(
                                      'من فضلك اكتب اقتراحك أولاً قبل الإرسال 💛',
                                      style:
                                          TextStyle(color: palette.textPrimary),
                                    ),
                                  ),
                                );
                                return;
                              }
                              setModalState(() => sending = true);
                              final ok = await sendSuggestion(
                                message: controller.text,
                                category: selectedCat,
                                senderName: senderName,
                              );
                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: palette.cardColor,
                                    content: Text(
                                      ok
                                          ? 'جزاك الله خيراً! يتم فتح نافذة الإرسال المباشر الآن 💌✨'
                                          : 'تعذّر فتح تطبيق المراسلة على هذا الجهاز حالياً، نشكرك على اهتمامك 🤍',
                                      style:
                                          TextStyle(color: palette.textPrimary),
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        sending ? 'جاري التحويل...' : 'إرسال الاقتراح بسرية 💌',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: palette.onAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
