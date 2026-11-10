import 'package:flutter/material.dart';

class Tasbih3DPhrase {
  final int number; // 1..200
  final String text;
  final String badgeTitle;
  final String emoji;
  final List<Color> gradientColors;
  final Color glowColor;

  const Tasbih3DPhrase({
    required this.number,
    required this.text,
    required this.badgeTitle,
    required this.emoji,
    required this.gradientColors,
    required this.glowColor,
  });
}

/// كتالوج يضم 200 جملة تحفيزية مخصصة للعروض ثلاثية الأبعاد (3D) في السبحة وعند إتمام الأهداف
class Tasbih3DPhrasesCatalog {
  static const List<String> _openings = [
    'أبشر بغرس نخلةٍ باسقةٍ لك في بساتين الفردوس الأعلى',
    'تبارك لسانُك الرطبُ بذكر الله يا زائر بيت الرحمن',
    'ما شاء الله! ثَقُل ميزان حسناتك بهذه الكلمات الطيبات',
    'أشرقت صحائفُك بنورِ التسبيح والتحميد والتهليل',
    'طوبى لقلبٍ أنِسَ بمناجاة مولاه في هذه اللحظة المباركة',
    'ارتقَتْ درجاتك في عليين بفضل مثابرتك وإخلاصك',
    'هنيئاً لك هذا الذكرُ الخالص الذي يمحو الخطايا ويجلو الصدور',
    'بُنيَ لك في الجنةِ أثرٌ خالدٌ بهذا الورد اليومي الميمون',
    'استمطرْتَ رحماتِ السماءِ بتكرار اسم الله الأعظم خشوعاً',
    'جزاك الله خيراً! ذكرك اليوم تاجُ نورٍ يزين طريقك إلى الجنة',
    'كُتب اسمك اليوم في سجل الذاكرين الله كثيراً والذاكرات',
    'أطفأتَ بهذه التسبيحاتِ وهجَ الهمومِ وفتحتَ أبوابَ السكينة',
    'نورٌ على نورٍ يضيء وجهك وقلبك كلما لهجَ لسانُك بالذكر',
    'بارك الله في همّتك! إنَّ قليلَ الذكرِ الدائمِ يبني قصورَ الخلد',
    'حلّتِ الطمأنينةُ في روحك لأنك لُذتَ بحصنِ الذاكرين المكين',
    'هذه اللحظةُ التي ذكرتَ فيها ربَّك هي أغلى ما في يومِك كلِّه',
    'تضاعفت أجورك أضعافاً مضاعفةً بكرم الكريم المنان',
    'سلّمت عليك الملائكةُ واستبشرت بمداومتك على رياض الذكر',
    'كلُّ حبةٍ سبّحتَ بها صارت شاهداً لك بالبرِّ يومَ العرض العظيم',
    'بشرى لك يا صاحب الهِمَّةِ العالية! ما أجمل ثباتك في طاعة ربك',
  ];

  static const List<String> _endings = [
    '— واصلِ السير نحو القمة الإيمانية!',
    '— زادك الله نوراً ورفعةً في الدارين.',
    '— هكذا تُعمر الجنان وتُزهر القلوب!',
    '— اللهم تقبلْ واجعلْه ذخراً ليومٍ لا ينفعُ فيه مالٌ ولا بنون.',
    '— أنت على ثغرٍ عظيمٍ من ثغورِ السكينةِ والقُرب.',
    '— طبتَ وطابَ ممشاكَ وبوّئتَ من الجنةِ منزلاً.',
    '— إنَّ الله يباهي بعباده الذاكرين ملائكتَه المقربين!',
    '— أدام الله لك هذا التوفيق والانشراح والبركة.',
    '— خطوةٌ مباركةٌ تلو خطوةٍ تصنع مجدَ الآخرة.',
    '— دمْتَ في حفظ الله ومعيّته ورعايته في كل حين.',
  ];

  static const List<String> _badgeTitles = [
    'وسام الذكر النوراني',
    'نخلة الفردوس المضيئة',
    'تاج التسبيح الملكي',
    'درع الطمأنينة الإلهية',
    'جوهرة الكنوز السماوية',
    'منارة الذاكرين بخشوع',
    'عطر الباقيات الصالحات',
    'مفتاح أبواب البركات',
  ];

  static const List<String> _emojis = [
    '🌴', '✨', '👑', '💎', '🕌', '📿', '🌟', '🌿', '🕋', '💫',
    '🪷', '🌸', '🏆', '☀️', '🌙', '💧', '🕊️', '💠', '🕯️', '💛',
  ];

  static const List<List<Color>> _gradients = [
    [Color(0xFF065F46), Color(0xFF10B981), Color(0xFFFBBF24)],
    [Color(0xFF78350F), Color(0xFFD97706), Color(0xFFFEF08A)],
    [Color(0xFF1E3A8A), Color(0xFF0EA5E9), Color(0xFF67E8F9)],
    [Color(0xFF4C1D95), Color(0xFF8B5CF6), Color(0xFFF472B6)],
    [Color(0xFF831843), Color(0xFFEC4899), Color(0xFFFDE68A)],
    [Color(0xFF134E4A), Color(0xFF14B8A6), Color(0xFFA7F3D0)],
    [Color(0xFF312E81), Color(0xFF6366F1), Color(0xFF38BDF8)],
    [Color(0xFF3F6212), Color(0xFF65A30D), Color(0xFFFACC15)],
  ];

  static final List<Tasbih3DPhrase> allPhrases = _build200();

  static List<Tasbih3DPhrase> _build200() {
    final list = <Tasbih3DPhrase>[];
    int n = 1;
    for (int i = 0; i < _openings.length; i++) {
      for (int j = 0; j < _endings.length; j++) {
        final idx = n - 1;
        final grad = _gradients[idx % _gradients.length];
        list.add(
          Tasbih3DPhrase(
            number: n,
            text: '${_openings[i]} ${_endings[j]}',
            badgeTitle: '${_badgeTitles[idx % _badgeTitles.length]} #$n',
            emoji: _emojis[idx % _emojis.length],
            gradientColors: grad,
            glowColor: grad.last,
          ),
        );
        n++;
      }
    }
    return List<Tasbih3DPhrase>.unmodifiable(list);
  }

  static Tasbih3DPhrase getByNumber(int number) {
    final safeIdx = (number - 1).clamp(0, allPhrases.length - 1);
    return allPhrases[safeIdx];
  }

  static Tasbih3DPhrase pickForSeed(int seed) {
    return allPhrases[seed.abs() % allPhrases.length];
  }
}
