import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

class IslamicBookChapter {
  final int number;
  final String title;
  final String contentArabic;
  final String explanation;
  final String narrator;

  const IslamicBookChapter({
    required this.number,
    required this.title,
    required this.contentArabic,
    required this.explanation,
    required this.narrator,
  });
}

class IslamicBooksSheet extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;

  const IslamicBooksSheet({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
  });

  @override
  State<IslamicBooksSheet> createState() => _IslamicBooksSheetState();
}

class _IslamicBooksSheetState extends State<IslamicBooksSheet> {
  int _selectedBookIndex = 0;
  final List<String> _bookTitles = [
    "الأربعين النووية",
    "رياض الصالحين",
    "قصص الأنبياء",
    "تفسير جزء عم",
  ];

  static const List<IslamicBookChapter> nawawiChapters = [
    IslamicBookChapter(
      number: 1,
      title: "الحديث الأول: إنما الأعمال بالنيات",
      contentArabic:
          "«إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى، فمن كانت هجرته إلى الله ورسوله فهجرته إلى الله ورسوله، ومن كانت هجرته لدنيا يصيبها أو امرأة ينكحها فهجرته إلى ما هاجر إليه».",
      explanation:
          "هذا الحديث أصل عظيم من أصول الإسلام، وعليه مدار الدين؛ فالنية هي المعيار لصحة العمل وقبوله وتفاضل الأجور.",
      narrator: "رواه البخاري ومسلم عن أمير المؤمنين عمر بن الخطاب رضي الله عنه.",
    ),
    IslamicBookChapter(
      number: 2,
      title: "الحديث الثاني: مراتب الدين (إسلام، إيمان، إحسان)",
      contentArabic:
          "«بينما نحن جلوس عند رسول الله ﷺ إذ طلع علينا رجل شديد بياض الثياب، شديد سواد الشعر، لا يُرى عليه أثر السفر، ولا يعرفه منا أحد... فقال: يا محمد أخبرني عن الإسلام... فأخبرني عن الإيمان... فأخبرني عن الإحسان: قال أن تعبد الله كأنك تراه فإن لم تكن تراه فإنه يراك».",
      explanation:
          "حديث جبريل عليه السلام الشهير؛ جامع لجميع وظائف العبادات الظاهرة والباطنة وحقيقة مراقبة الله تعالى.",
      narrator: "رواه مسلم عن عمر بن الخطاب رضي الله عنه.",
    ),
    IslamicBookChapter(
      number: 3,
      title: "الحديث الثالث: بني الإسلام على خمس",
      contentArabic:
          "«بُني الإسلام على خمس: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وحج البيت، وصوم رمضان».",
      explanation:
          "قواعد الإسلام وأركانه العظمى التي يقوم عليها بنيانه كالأعمدة المتماسكة.",
      narrator: "رواه البخاري ومسلم عن عبد الله بن عمر رضي الله عنهما.",
    ),
    IslamicBookChapter(
      number: 4,
      title: "الحديث الخامس: النهي عن الابتداع",
      contentArabic:
          "«من أحدث في أمرنا هذا ما ليس منه فهو رد». وفي رواية لمسلم: «من عمل عملاً ليس عليه أمرنا فهو رد».",
      explanation:
          "ميزان الأعمال الظاهرة؛ فكما أن حديث النيات ميزان الباطن، فهذا الحديث ميزان مطابقة الشرع.",
      narrator: "رواه البخاري ومسلم عن أم المؤمنين عائشة رضي الله عنها.",
    ),
    IslamicBookChapter(
      number: 5,
      title: "الحديث السابع: الدين النصيحة",
      contentArabic:
          "«الدين النصيحة. قلنا: لمن؟ قال: لله، ولكتابه، ولرسوله، ولأئمة المسلمين، وعامتهم».",
      explanation:
          "النصيحة هي إرادة الخير للمنصوح له؛ والنصيحة لله بالإيمان به وتوحيده، ولرسوله باتباع سنته.",
      narrator: "رواه مسلم عن تميم الداري رضي الله عنه.",
    ),
  ];

  static const List<IslamicBookChapter> riyadChapters = [
    IslamicBookChapter(
      number: 1,
      title: "باب الصبر واحتساب الأجر",
      contentArabic:
          "«عجباً لأمر المؤمن إن أمره كله خير، وليس ذاك لأحد إلا للمؤمن: إن أصابته سراء شكر فكان خيراً له، وإن أصابته ضراء صبر فكان خيراً له».",
      explanation:
          "المؤمن يتقلب بين مقامي الشكر والصبر، وبذلك تفنى أحزانه ويعظم أجره عند ربه.",
      narrator: "رواه مسلم عن صهيب بن سنان رضي الله عنه.",
    ),
    IslamicBookChapter(
      number: 2,
      title: "باب فضل الذكر ومجالس العلم",
      contentArabic:
          "«كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن: سبحان الله وبحمده، سبحان الله العظيم».",
      explanation: "فضل كلمات التسبيح والتحميد العظيمة في ميزان العبد يوم القيامة.",
      narrator: "رواه البخاري ومسلم عن أبي هريرة رضي الله عنه.",
    ),
    IslamicBookChapter(
      number: 3,
      title: "باب التقوى والتوكل على الله",
      contentArabic:
          "«لو أنكم تتوكلون على الله حق توكله لرزقكم كما يرزق الطير، تغدو خماصاً وتروح بطاناً».",
      explanation:
          "حقيقة التوكل الجمع بين الاعتماد القلبي على الله تعالى وبذل الأسباب المشروعة في السعي.",
      narrator: "رواه الترمذي وقال حديث حسن صحيح عن عمر بن الخطاب رضي الله عنه.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;
    final chapters = _selectedBookIndex == 0 ? nawawiChapters : riyadChapters;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: palette.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: palette.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent),
                  ),
                  child: Icon(Icons.auto_stories_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "المكتبة الإسلامية والتفاسير الشريفة",
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _bookTitles.length,
              itemBuilder: (context, idx) {
                final isSel = idx == _selectedBookIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      _bookTitles[idx],
                      style: TextStyle(
                        color: isSel ? palette.onAccentColor : palette.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: accent,
                    backgroundColor: palette.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: isSel ? accent : palette.dividerColor),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedBookIndex = idx);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: chapters.length,
              itemBuilder: (context, idx) {
                final ch = chapters[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: (palette.isDark ? Colors.black : palette.primaryColor)
                            .withOpacity(palette.isDark ? 0.35 : 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.2),
                              border: Border.all(color: accent),
                            ),
                            child: Center(
                              child: Text(
                                "${ch.number}",
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ch.title,
                              style: TextStyle(
                                color: accent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.elevatedCardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.dividerColor),
                        ),
                        child: Text(
                          ch.contentArabic,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "الشرح والفوائد: ${ch.explanation}",
                        style: TextStyle(
                          color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                          fontSize: 12.5,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ch.narrator,
                        style: TextStyle(color: palette.textMuted, fontSize: 11),
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
  }
}
