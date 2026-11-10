import 'package:flutter/material.dart';

enum EmotionalState {
  anger, // الغضب
  sadness, // الحزن والضيق
  envyEye, // الحسد والعين
  anxietyFear, // الخوف والقلق
  laziness, // الكسل والفتور
  joyGratitude, // الفرح والنعمة
}

class HelpStep {
  final String title;
  final String description;
  final IconData icon;

  const HelpStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class HelpMeCategory {
  final EmotionalState state;
  final String title;
  final String subtitle;
  final String quranAyah;
  final String hadithReference;
  final String mainDuha;
  final Color primaryColor;
  final Color accentColor;
  final IconData icon;
  final List<HelpStep> sunnahSteps;
  final bool hasBreathingGuide;

  const HelpMeCategory({
    required this.state,
    required this.title,
    required this.subtitle,
    required this.quranAyah,
    required this.hadithReference,
    required this.mainDuha,
    required this.primaryColor,
    required this.accentColor,
    required this.icon,
    required this.sunnahSteps,
    this.hasBreathingGuide = false,
  });

  static const List<HelpMeCategory> categories = [
    HelpMeCategory(
      state: EmotionalState.anger,
      title: 'عندما أغضب أو أنفعل',
      subtitle: 'هدي النبي ﷺ في إطفاء جمرة الغضب واستعادة السكينة',
      quranAyah: '﴿وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ﴾',
      hadithReference: '«إِنَّ الْغَضَبَ مِنَ الشَّيْطَانِ، وَإِنَّ الشَّيْطَانَ خُلِقَ مِنَ النَّارِ، وَإِنَّمَا تُطْفَأُ النَّارُ بِالْمَاءِ، فَإِذَا غَضِبَ أَحَدُكُمْ فَلْيَتَوَضَّأْ»',
      mainDuha: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ • رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي',
      primaryColor: Color(0xFFEF4444),
      accentColor: Color(0xFFFCA5A5),
      icon: Icons.flash_on_rounded,
      hasBreathingGuide: true,
      sunnahSteps: [
        HelpStep(
          title: 'التعوذ بالله فوراً',
          description: 'قل "أعوذ بالله من الشيطان الرجيم" بقلب حاضر ليذهب عنك وسواس الغضب.',
          icon: Icons.shield_rounded,
        ),
        HelpStep(
          title: 'الوضوء بالماء البارد',
          description: 'قم وتوضأ فالماء يطفئ حرارة الغضب ويهدئ نبضات القلب والجسد.',
          icon: Icons.water_drop_rounded,
        ),
        HelpStep(
          title: 'تغيير وضع الجسد',
          description: 'إن كنت قائماً فاجلس، وإن كنت جالساً فاضطجع كما أوصى الحبيب ﷺ.',
          icon: Icons.airline_seat_recline_normal_rounded,
        ),
        HelpStep(
          title: 'السكوت وعدم الرد',
          description: '«إذا غضب أحدكم فليسكت» حتى لا تتلفظ بكلمة تندم عليها.',
          icon: Icons.record_voice_over_outlined,
        ),
      ],
    ),
    HelpMeCategory(
      state: EmotionalState.sadness,
      title: 'عندما أحزن أو يضيق صدري',
      subtitle: 'بلسم القرآن وسلوى القلوب المكلومة بفرج الله القريب',
      quranAyah: '﴿أَلا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾ • ﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
      hadithReference: '«مَا أَصَابَ أَحَدًا قَطُّ هَمٌّ وَلا حَزَنٌ فَقَالَ: اللَّهُمَّ إِنِّي عَبْدُكَ... إِلاَّ أَذْهَبَ اللَّهُ هَمَّهُ وَأَبْدَلَهُ مَكَانَ حُزْنِهِ فَرَحًا»',
      mainDuha: 'لا إِلَهَ إِلاَّ أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ • اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      primaryColor: Color(0xFF3B82F6),
      accentColor: Color(0xFF93C5FD),
      icon: Icons.favorite_border_rounded,
      hasBreathingGuide: true,
      sunnahSteps: [
        HelpStep(
          title: 'دعاء يونس في بطن الحوت',
          description: 'كرر "لا إله إلا أنت سبحانك إني كنت من الظالمين" فما دعا بها مكروب إلا فرج الله عنه.',
          icon: Icons.auto_awesome_rounded,
        ),
        HelpStep(
          title: 'صلاة ركعتين خاشعتين',
          description: '«كان النبي ﷺ إذا حزبه أمرٌ فزع إلى الصلاة» فالوقوف بين يدي الله يشفي الصدر.',
          icon: Icons.mosque_rounded,
        ),
        HelpStep(
          title: 'قراءة سورة الضحى والشرح',
          description: 'تدبر قول الله تعالى: ﴿مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ﴾ و ﴿أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ﴾.',
          icon: Icons.menu_book_rounded,
        ),
        HelpStep(
          title: 'اليقين بزوال الغمة',
          description: 'تذكر أن دوام الحال من المحال، وأن النصر مع الصبر وأن مع العسر يسراً.',
          icon: Icons.wb_sunny_rounded,
        ),
      ],
    ),
    HelpMeCategory(
      state: EmotionalState.anxietyFear,
      title: 'عندما أقلق أو أخاف من المستقبل',
      subtitle: 'التوكل المطلق وتفويض الأمور للحي القيوم الذي لا يغفل',
      quranAyah: '﴿الَّذِينَ قَالَ لَهُمُ النَّاسُ إِنَّ النَّاسَ قَدْ جَمَعُوا لَكُمْ فَاخْشَوْهُمْ فَزَادَهُمْ إِيمَانًا وَقَالُوا حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ﴾',
      hadithReference: '«يَا غُلامُ، إِنِّي أُعَلِّمُكَ كَلِمَاتٍ: احْفَظِ اللَّهَ يَحْفَظْكَ... وَاعْلَمْ أَنَّ الأُمَّةَ لَوْ اجْتَمَعَتْ عَلَى أَنْ يَنْفَعُوكَ بِشَيْءٍ لَمْ يَنْفَعُوكَ إِلاَّ بِشَيْءٍ قَدْ كَتَبَهُ اللَّهُ لَكَ»',
      mainDuha: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ • اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْجُبْنِ وَالْبُخْلِ',
      primaryColor: Color(0xFF8B5CF6),
      accentColor: Color(0xFFC4B5FD),
      icon: Icons.security_rounded,
      hasBreathingGuide: true,
      sunnahSteps: [
        HelpStep(
          title: 'تفويض الأمر لله',
          description: 'ردد "حسبنا الله ونعم الوكيل" واستشعر أن أزمة الكون كلها بيد مدبر السموات والأرض.',
          icon: Icons.done_all_rounded,
        ),
        HelpStep(
          title: 'الاستغفار يفك الأقفال',
          description: '«من لزم الاستغفار جعل الله له من كل هم فرجاً ومن كل ضيق مخرجاً ورزقه من حيث لا يحتسب».',
          icon: Icons.refresh_rounded,
        ),
        HelpStep(
          title: 'تمرين التنفس وتسكين الروح',
          description: 'خذ أنفاساً عميقة بانتظام لتهدئة هرمونات التوتر وأنت تسبح وتستحضر عظمة الخالق.',
          icon: Icons.air_rounded,
        ),
      ],
    ),
    HelpMeCategory(
      state: EmotionalState.envyEye,
      title: 'عندما أخاف من الحسد أو أوسوس',
      subtitle: 'حصن المسلم المتين والتحصين بالمعوذات وسور النور',
      quranAyah: '﴿وَإِن يَكَادُ الَّذِينَ كَفَرُوا لَيُزْلِقُونَكَ بِأَبْصَارِهِمْ﴾ • ﴿قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ﴾',
      hadithReference: '«مَنْ قَرَأَ بِالآيَتَيْنِ مِنْ آخِرِ سُورَةِ الْبَقَرَةِ فِي لَيْلَةٍ كَفَتَاهُ»',
      mainDuha: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ • بِسْمِ اللَّهِ الَّذِي لا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلا فِي السَّمَاءِ',
      primaryColor: Color(0xFF10B981),
      accentColor: Color(0xFF6EE7B7),
      icon: Icons.visibility_off_rounded,
      sunnahSteps: [
        HelpStep(
          title: 'قراءة المعوذتين والإخلاص ثلاثاً',
          description: 'اقرأ سورة الإخلاص والفلق والناس صباحاً ومساءً وقبل النوم وانفث في يديك وامسح جسدك.',
          icon: Icons.menu_book_rounded,
        ),
        HelpStep(
          title: 'آية الكرسي حارس من الله',
          description: 'اقرأ آية الكرسي دبر كل صلاة وعند النوم؛ فإنه لا يزال عليك من الله حافظ ولا يقربك شيطان.',
          icon: Icons.star_rounded,
        ),
        HelpStep(
          title: 'الدعاء بالبركة (التباريك)',
          description: 'إذا رأيت ما يعجبك في نفسك أو غيرك فقل: "اللهم بارك له، ما شاء الله لا قوة إلا بالله".',
          icon: Icons.thumb_up_alt_rounded,
        ),
      ],
    ),
    HelpMeCategory(
      state: EmotionalState.laziness,
      title: 'عندما أتكاسل عن الطاعة والعبادة',
      subtitle: 'شحذ الهمة وتجديد العزم وسلوك سبل النشاط النبوي',
      quranAyah: '﴿وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا ۚ وَإِنَّ اللَّهَ لَمَعَ الْمُحْسِنِينَ﴾',
      hadithReference: '«أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»',
      mainDuha: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ • اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
      primaryColor: Color(0xFFF59E0B),
      accentColor: Color(0xFFFDE68A),
      icon: Icons.bolt_rounded,
      sunnahSteps: [
        HelpStep(
          title: 'البدء بأبسط خطوة فوراً',
          description: 'لا تسوف؛ قم وتوضأ فقط، أو صلِّ ركعتين خفيفتين؛ فإن الشيطان يثبطك بالكثرة.',
          icon: Icons.play_arrow_rounded,
        ),
        HelpStep(
          title: 'تذكر لذة الجزاء وقصر الدنيا',
          description: 'تذكر أن ركعة في جوف الليل أو تسبيحة في كتابك خير لك من الدنيا وما فيها.',
          icon: Icons.alarm_rounded,
        ),
        HelpStep(
          title: 'تغيير المكان والوضوء',
          description: 'غادر الفراش وبلل وجهك بالماء وتنشق الهواء النقي وسبح الله لتنحل عقد الكسل.',
          icon: Icons.directions_walk_rounded,
        ),
      ],
    ),
    HelpMeCategory(
      state: EmotionalState.joyGratitude,
      title: 'عندما أفرح بنعمة أو رزق جديد',
      subtitle: 'شكر المنعم جل وعلا وسجود الشكر وحفظ النعم بالتقييد',
      quranAyah: '﴿وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ﴾ • ﴿وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ﴾',
      hadithReference: '«كَانَ النَّبِيُّ ﷺ إِذَا أَتَاهُ أَمْرُ سُرُورٍ خَرَّ سَاجِدًا شُكْرًا لِلَّهِ تَبَارَكَ وَتَعَالَى»',
      mainDuha: 'الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ • رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ',
      primaryColor: Color(0xFFEC4899),
      accentColor: Color(0xFFFBCFE8),
      icon: Icons.sentiment_very_satisfied_rounded,
      sunnahSteps: [
        HelpStep(
          title: 'سجدة الشكر لله تعالى',
          description: 'اخرر ساجداً في مكانك لله شكراً واعترافاً بفضله ومنّته دون اشتراط طهارة أو قبلة عند الحاجة.',
          icon: Icons.accessibility_new_rounded,
        ),
        HelpStep(
          title: 'تقييد النعمة بالصدقة والإحسان',
          description: 'تصدق بشيء من مالك أو أطعم مسكيناً ليكون شكرك بالقول والعمل فتدوم النعمة وتزيد.',
          icon: Icons.volunteer_activism_rounded,
        ),
        HelpStep(
          title: 'نسب الفضل لله لا للنفس',
          description: 'قل "هذا من فضل ربي ليبلوني أأشكر أم أكفر" ولا تقل أوتيته على علم عندي.',
          icon: Icons.thumb_up_rounded,
        ),
      ],
    ),
  ];
}
