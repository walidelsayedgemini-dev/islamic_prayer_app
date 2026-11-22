part of 'islamic_theme.dart';

/// A visual identity for one stable Firdaws paradise theme key.
class ParadiseThemeSpec {
  const ParadiseThemeSpec._({
    required this.key,
    required this.title,
    required this.caption,
    required this.imageAsset,
    required this.accent,
    required double hue,
  }) : _hue = hue;

  final String key;
  final String title;
  final String caption;
  final String imageAsset;
  final Color accent;
  final double _hue;
}

/// Full identity registry for the historical 56-option Firdaws theme catalog.
abstract final class FirdawsParadiseRegistry {
  static double _hueForIndex(int index) => (149.0 + index * 137.507764) % 360.0;

  static Color _tone(double hue, double saturation, double lightness) =>
      HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();

  static List<ParadiseThemeSpec> get all => _all;

  static final List<ParadiseThemeSpec> _all = List.unmodifiable([
    ParadiseThemeSpec._(
      key: "emerald_gold",
      title: "واحة الفردوس الزمردية",
      caption: "ممرات من الرخام العاجي تعبر حدائق النخيل ومياه الذهب الهادئة.",
      imageAsset: "assets/images/paradise/emerald_gold.jpg",
      accent: _tone(_hueForIndex(0), 0.75, 0.24),
      hue: _hueForIndex(0),
    ),
    ParadiseThemeSpec._(
      key: "kaaba_black_gold",
      title: "حديقة الليل الأسود والذهب",
      caption: "أحواض ياسمين مضاءة حول جناح هندسي أسود بخيوط ذهبية رفيعة.",
      imageAsset:
          "/manus-storage/async-images/FXMy2cz87aIxvQKO408mey/image-1.webp",
      accent: _tone(_hueForIndex(1), 0.75, 0.24),
      hue: _hueForIndex(1),
    ),
    ParadiseThemeSpec._(
      key: "andalusian",
      title: "أروقة الرخام الملكي",
      caption: "أعمدة حجرية فاتحة تفتح على بستان ماء وأشجار حمضية.",
      imageAsset:
          "/manus-storage/async-images/FXMy2cz87aIxvQKO408mey/image-2.webp",
      accent: _tone(_hueForIndex(2), 0.75, 0.24),
      hue: _hueForIndex(2),
    ),
    ParadiseThemeSpec._(
      key: "makkah_rose",
      title: "حديقة الورد عند الشروق",
      caption: "مدرجات وردية على سفح جبلي تلمع فوقها قطرات الندى.",
      imageAsset:
          "/manus-storage/async-images/FXMy2cz87aIxvQKO408mey/image-3.webp",
      accent: _tone(_hueForIndex(3), 0.75, 0.24),
      hue: _hueForIndex(3),
    ),
    ParadiseThemeSpec._(
      key: "blue_mosque",
      title: "فسيفساء الفيروز الهادئ",
      caption: "قناطر خزفية زرقاء تحيط بحديقة توليب ونوافير صافية.",
      imageAsset: "assets/images/themes/blue_mosque.jpg",
      accent: _tone(_hueForIndex(4), 0.75, 0.24),
      hue: _hueForIndex(4),
    ),
    ParadiseThemeSpec._(
      key: "desert_night",
      title: "مرصد البادية الساكن",
      caption: "كثبان حريرية تتخللها واحة صغيرة تحت سماء مرصعة بالنجوم.",
      imageAsset:
          "/manus-storage/async-images/FXMy2cz87aIxvQKO408mey/image-5.webp",
      accent: _tone(_hueForIndex(5), 0.75, 0.24),
      hue: _hueForIndex(5),
    ),
    ParadiseThemeSpec._(
      key: "dome_of_rock",
      title: "حديقة القبة البنفسجية",
      caption: "أقواس بنفسجية وزيتون فضي تلتف حول بركة عاكسة.",
      imageAsset:
          "/manus-storage/async-images/w5TISu6WgRaEA8pC01fIvJ/image-1.webp",
      accent: _tone(_hueForIndex(6), 0.75, 0.24),
      hue: _hueForIndex(6),
    ),
    ParadiseThemeSpec._(
      key: "damascus_bronze",
      title: "بستان النحاس الدمشقي",
      caption: "عريشة نحاسية معتّقة تتساقط حولها أوراق الدلب والخريف.",
      imageAsset:
          "/manus-storage/async-images/w5TISu6WgRaEA8pC01fIvJ/image-2.webp",
      accent: _tone(_hueForIndex(7), 0.75, 0.24),
      hue: _hueForIndex(7),
    ),
    ParadiseThemeSpec._(
      key: "baghdad_amber",
      title: "حديقة المخطوطات الكهرمانية",
      caption: "أروقة طينية ذهبية تطل على بستان نخيل ومجرى ماء.",
      imageAsset:
          "/manus-storage/async-images/w5TISu6WgRaEA8pC01fIvJ/image-3.webp",
      accent: _tone(_hueForIndex(8), 0.75, 0.24),
      hue: _hueForIndex(8),
    ),
    ParadiseThemeSpec._(
      key: "madinah_sands",
      title: "واحة الرمال الهادئة",
      caption: "نخيل طيبة الخيالي يرسم ظلالًا طويلة فوق رمال عاجية.",
      imageAsset:
          "/manus-storage/async-images/w5TISu6WgRaEA8pC01fIvJ/image-4.webp",
      accent: _tone(_hueForIndex(9), 0.75, 0.24),
      hue: _hueForIndex(9),
    ),
    ParadiseThemeSpec._(
      key: "arabian_pearl",
      title: "حديقة اللؤلؤ البحري",
      caption: "ممرات صدفية على شاطئ هادئ بين اللآلئ والأعشاب الساحلية.",
      imageAsset:
          "/manus-storage/async-images/w5TISu6WgRaEA8pC01fIvJ/image-5.webp",
      accent: _tone(_hueForIndex(10), 0.75, 0.24),
      hue: _hueForIndex(10),
    ),
    ParadiseThemeSpec._(
      key: "celestial_rayyan",
      title: "بوابة الريان الخضراء",
      caption: "بوابة زمردية خيالية تفتح على بستان ينابيع وسدر.",
      imageAsset:
          "/manus-storage/async-images/VDfSVUn8iWZkz29XPU8zvj/image-1.webp",
      accent: _tone(_hueForIndex(11), 0.75, 0.24),
      hue: _hueForIndex(11),
    ),
    ParadiseThemeSpec._(
      key: "arafat_mercy",
      title: "حديقة جبل الرحمة",
      caption: "مصاطب حجرية هادئة ونبع صغير عند سفح جبل يكتنفه الضباب.",
      imageAsset:
          "/manus-storage/async-images/VDfSVUn8iWZkz29XPU8zvj/image-2.webp",
      accent: _tone(_hueForIndex(12), 0.75, 0.24),
      hue: _hueForIndex(12),
    ),
    ParadiseThemeSpec._(
      key: "mina_tents",
      title: "حدائق الخيام البيضاء",
      caption: "أجنحة قماشية بيضاء تتوزع بين أشجار السنط وممرات الماء.",
      imageAsset:
          "/manus-storage/async-images/VDfSVUn8iWZkz29XPU8zvj/image-3.webp",
      accent: _tone(_hueForIndex(13), 0.75, 0.24),
      hue: _hueForIndex(13),
    ),
    ParadiseThemeSpec._(
      key: "hira_light",
      title: "ممر النور الجبلي",
      caption: "حديقة صخرية صغيرة تنفتح على وادٍ يضيئه فجر شفيف.",
      imageAsset:
          "/manus-storage/async-images/VDfSVUn8iWZkz29XPU8zvj/image-4.webp",
      accent: _tone(_hueForIndex(14), 0.75, 0.24),
      hue: _hueForIndex(14),
    ),
    ParadiseThemeSpec._(
      key: "uhud_dawn",
      title: "شفق الجبل الأحمر",
      caption: "قمم وردية يعلوها ضباب خفيف وحدائق صخرية خضراء.",
      imageAsset:
          "/manus-storage/async-images/VDfSVUn8iWZkz29XPU8zvj/image-5.webp",
      accent: _tone(_hueForIndex(15), 0.75, 0.24),
      hue: _hueForIndex(15),
    ),
    ParadiseThemeSpec._(
      key: "zamzam_spring",
      title: "نبع الماء الصافي",
      caption: "عين فيروزية تنبع بين السوسن وأحجار فاتحة مصقولة.",
      imageAsset:
          "/manus-storage/async-images/cipXjNChciOGk6XD9dtZ1E/image-1.webp",
      accent: _tone(_hueForIndex(16), 0.75, 0.24),
      hue: _hueForIndex(16),
    ),
    ParadiseThemeSpec._(
      key: "baqi_serenity",
      title: "حديقة السكينة والظل",
      caption: "ممرات هادئة تحت ظلال السرو والزيتون مع رذاذ خفيف.",
      imageAsset:
          "/manus-storage/async-images/cipXjNChciOGk6XD9dtZ1E/image-2.webp",
      accent: _tone(_hueForIndex(17), 0.75, 0.24),
      hue: _hueForIndex(17),
    ),
    ParadiseThemeSpec._(
      key: "al_azhar_cairo",
      title: "حديقة العلم في القاهرة",
      caption: "أروقة حجرية ومشربيات خشبية تطل على ساحة مزروعة بالريحان.",
      imageAsset:
          "/manus-storage/async-images/cipXjNChciOGk6XD9dtZ1E/image-3.webp",
      accent: _tone(_hueForIndex(18), 0.75, 0.24),
      hue: _hueForIndex(18),
    ),
    ParadiseThemeSpec._(
      key: "cordoba_arches",
      title: "أقواس قرطبة المائية",
      caption: "أقواس متتابعة باللون العاجي بين النارنج وبرك الماء.",
      imageAsset:
          "/manus-storage/async-images/cipXjNChciOGk6XD9dtZ1E/image-4.webp",
      accent: _tone(_hueForIndex(19), 0.75, 0.24),
      hue: _hueForIndex(19),
    ),
    ParadiseThemeSpec._(
      key: "alhambra_granada",
      title: "بهو الحمراء والحدائق",
      caption: "باحة جصية منحوتة تنساب فيها قنوات الماء بين الياسمين.",
      imageAsset:
          "/manus-storage/async-images/cipXjNChciOGk6XD9dtZ1E/image-5.webp",
      accent: _tone(_hueForIndex(20), 0.75, 0.24),
      hue: _hueForIndex(20),
    ),
    ParadiseThemeSpec._(
      key: "qairawan_tunis",
      title: "حديقة المئذنة الصحراوية",
      caption: "مئذنة مربعة بعيدة تبرز بين أشجار الزيتون والآس.",
      imageAsset: "assets/images/themes/qairawan_tunis.jpg",
      accent: _tone(_hueForIndex(21), 0.75, 0.24),
      hue: _hueForIndex(21),
    ),
    ParadiseThemeSpec._(
      key: "hassan_casablanca",
      title: "حديقة الأطلسي البيضاء",
      caption: "شرفات حجرية بيضاء تلامسها أمواج البحر وأزهار زرقاء.",
      imageAsset:
          "/manus-storage/async-images/amOrFddSRnPtugyaVw1z58/image-2.webp",
      accent: _tone(_hueForIndex(22), 0.75, 0.24),
      hue: _hueForIndex(22),
    ),
    ParadiseThemeSpec._(
      key: "koutoubia_marrakech",
      title: "حديقة النخيل الحمراء",
      caption: "ممرات طينية حمراء بين النخيل والنافورات وأزهار الجهنمية.",
      imageAsset:
          "/manus-storage/async-images/XNSlb2HdFwyEJG9SQ8JZZQ/image-1.webp",
      accent: _tone(_hueForIndex(23), 0.75, 0.24),
      hue: _hueForIndex(23),
    ),
    ParadiseThemeSpec._(
      key: "suleymaniye_istanbul",
      title: "حديقة البوسفور العثمانية",
      caption: "قباب على الأفق الأزرق وبينها أشجار سرو وزهور توليب.",
      imageAsset:
          "/manus-storage/async-images/amOrFddSRnPtugyaVw1z58/image-4.webp",
      accent: _tone(_hueForIndex(24), 0.75, 0.24),
      hue: _hueForIndex(24),
    ),
    ParadiseThemeSpec._(
      key: "sheikh_zayed_abudhabi",
      title: "حديقة اللؤلؤة البيضاء",
      caption: "رخام أبيض لامع وحدائق متناظرة وقنوات فيروزية.",
      imageAsset: "assets/images/themes/sheikh_zayed_abudhabi.jpg",
      accent: _tone(_hueForIndex(25), 0.75, 0.24),
      hue: _hueForIndex(25),
    ),
    ParadiseThemeSpec._(
      key: "sultan_qaboos_muscat",
      title: "حديقة الثريا العمانية",
      caption: "أقواس من الحجر العماني وحديقة بخور تنساب فيها نافورة رقيقة.",
      imageAsset:
          "/manus-storage/async-images/SQfv6OsQOhiOBj0JTkphxw/image-1.webp",
      accent: _tone(_hueForIndex(26), 0.75, 0.24),
      hue: _hueForIndex(26),
    ),
    ParadiseThemeSpec._(
      key: "samarkand_registan",
      title: "حديقة لازورد سمرقند",
      caption: "بوابة خزفية عميقة الزرقة تفتح على حديقة رمان ونوافير.",
      imageAsset:
          "/manus-storage/async-images/SQfv6OsQOhiOBj0JTkphxw/image-2.webp",
      accent: _tone(_hueForIndex(27), 0.75, 0.24),
      hue: _hueForIndex(27),
    ),
    ParadiseThemeSpec._(
      key: "bukhara_turquoise",
      title: "حديقة المئذنة الفيروزية",
      caption: "برج خزفي رفيع بين أشجار التوت وقنوات الماء.",
      imageAsset:
          "/manus-storage/async-images/SQfv6OsQOhiOBj0JTkphxw/image-3.webp",
      accent: _tone(_hueForIndex(28), 0.75, 0.24),
      hue: _hueForIndex(28),
    ),
    ParadiseThemeSpec._(
      key: "lahore_badshahi",
      title: "حديقة الرخام والورد",
      caption: "شرفات رخامية وردية حول بستان كثيف وزهور موسمية.",
      imageAsset:
          "/manus-storage/async-images/SQfv6OsQOhiOBj0JTkphxw/image-4.webp",
      accent: _tone(_hueForIndex(29), 0.75, 0.24),
      hue: _hueForIndex(29),
    ),
    ParadiseThemeSpec._(
      key: "ibn_tulun_cairo",
      title: "حديقة اللولب الحجري",
      caption: "درج حجري حلزوني يطل على حديقة صحراوية فيها بركة ضيقة.",
      imageAsset:
          "/manus-storage/async-images/SQfv6OsQOhiOBj0JTkphxw/image-5.webp",
      accent: _tone(_hueForIndex(30), 0.75, 0.24),
      hue: _hueForIndex(30),
    ),
    ParadiseThemeSpec._(
      key: "aleppo_umayyad",
      title: "حديقة الحجر العتيق",
      caption: "جدران حجرية كريمية تتخللها كروم العنب وأشجار الزيتون.",
      imageAsset:
          "/manus-storage/async-images/O9wfK1CEsSihtv9jJ7Acfe/image-1.webp",
      accent: _tone(_hueForIndex(31), 0.75, 0.24),
      hue: _hueForIndex(31),
    ),
    ParadiseThemeSpec._(
      key: "amr_ibn_as",
      title: "حديقة الفسطاط الأولى",
      caption: "فناء بسيط واسع تحيط به أشجار النخيل والريحان ومجرى ماء.",
      imageAsset:
          "/manus-storage/async-images/O9wfK1CEsSihtv9jJ7Acfe/image-2.webp",
      accent: _tone(_hueForIndex(32), 0.75, 0.24),
      hue: _hueForIndex(32),
    ),
    ParadiseThemeSpec._(
      key: "salahuddin_citadel",
      title: "حديقة القلعة المرتفعة",
      caption: "شرفات صخرية تعلو المدينة وتطل على مدرجات السرو والينابيع.",
      imageAsset:
          "/manus-storage/async-images/O9wfK1CEsSihtv9jJ7Acfe/image-3.webp",
      accent: _tone(_hueForIndex(33), 0.75, 0.24),
      hue: _hueForIndex(33),
    ),
    ParadiseThemeSpec._(
      key: "fajr_sapphire",
      title: "حديقة الفجر الياقوتي",
      caption: "بحيرة زرقاء تحت سماء ما قبل الشروق تتخللها زهور بيضاء.",
      imageAsset:
          "/manus-storage/async-images/O9wfK1CEsSihtv9jJ7Acfe/image-4.webp",
      accent: _tone(_hueForIndex(34), 0.75, 0.24),
      hue: _hueForIndex(34),
    ),
    ParadiseThemeSpec._(
      key: "duha_sunlight",
      title: "حديقة ضياء الضحى",
      caption: "أزهار صفراء تتفتح حول نوافير صغيرة في شمس الصباح.",
      imageAsset:
          "/manus-storage/async-images/O9wfK1CEsSihtv9jJ7Acfe/image-5.webp",
      accent: _tone(_hueForIndex(35), 0.75, 0.24),
      hue: _hueForIndex(35),
    ),
    ParadiseThemeSpec._(
      key: "asr_gold",
      title: "حديقة العصر الذهبية",
      caption: "ظلال النخيل تمتد على كثبان عسلية وأحواض خضراء.",
      imageAsset: "assets/images/themes/asr_gold.jpg",
      accent: _tone(_hueForIndex(36), 0.75, 0.24),
      hue: _hueForIndex(36),
    ),
    ParadiseThemeSpec._(
      key: "maghrib_crimson",
      title: "حديقة الشفق القرمزي",
      caption: "بحيرة هادئة تعكس سماء حمراء بين أزهار الرمان.",
      imageAsset: "assets/images/themes/maghrib_crimson.jpg",
      accent: _tone(_hueForIndex(37), 0.75, 0.24),
      hue: _hueForIndex(37),
    ),
    ParadiseThemeSpec._(
      key: "isha_indigo",
      title: "حديقة العشاء النيلية",
      caption: "نافورة فضية وسط سرو داكن تحت سماء عميقة وهادئة.",
      imageAsset: "assets/images/themes/isha_indigo.jpg",
      accent: _tone(_hueForIndex(38), 0.75, 0.24),
      hue: _hueForIndex(38),
    ),
    ParadiseThemeSpec._(
      key: "qiyam_aurora",
      title: "حديقة السحر المتلألئة",
      caption: "أشرطة ضوء قطبي تنعكس على جدول بين أشجار السرو.",
      imageAsset: "assets/images/themes/qiyam_aurora.jpg",
      accent: _tone(_hueForIndex(39), 0.75, 0.24),
      hue: _hueForIndex(39),
    ),
    ParadiseThemeSpec._(
      key: "ramadan_hilal",
      title: "حديقة الفوانيس الرمضانية",
      caption: "فوانيس دافئة تتدلى بين النخيل حول قنوات ماء عاكسة.",
      imageAsset: "assets/images/themes/ramadan_hilal.jpg",
      accent: _tone(_hueForIndex(40), 0.75, 0.24),
      hue: _hueForIndex(40),
    ),
    ParadiseThemeSpec._(
      key: "laylat_qadr",
      title: "حديقة السحر البنفسجي",
      caption: "ممر من زهور بيضاء يقود إلى بركة تحت سماء بنفسجية.",
      imageAsset:
          "/manus-storage/async-images/me8xSBIj8EBa8e1CHPRTYu/image-1.webp",
      accent: _tone(_hueForIndex(41), 0.75, 0.24),
      hue: _hueForIndex(41),
    ),
    ParadiseThemeSpec._(
      key: "firdaws_waterfall",
      title: "شلالات الحديقة العليا",
      caption: "شلالات متعددة الطبقات بين السرخس والزهور البرية.",
      imageAsset: "assets/images/themes/firdaws_waterfall.jpg",
      accent: _tone(_hueForIndex(42), 0.75, 0.24),
      hue: _hueForIndex(42),
    ),
    ParadiseThemeSpec._(
      key: "kawthar_silver",
      title: "نهر الفضة الهادئ",
      caption: "نهر واسع فضي يلتف بين أشجار بيضاء وأعشاب ناعمة.",
      imageAsset: "assets/images/themes/kawthar_silver.jpg",
      accent: _tone(_hueForIndex(43), 0.75, 0.24),
      hue: _hueForIndex(43),
    ),
    ParadiseThemeSpec._(
      key: "salsabil_spring",
      title: "عين سلسبيل الخضراء",
      caption: "ينبوع متدرج بين أوراق السرخس والفل والياسمين.",
      imageAsset: "assets/images/themes/salsabil_spring.jpg",
      accent: _tone(_hueForIndex(44), 0.75, 0.24),
      hue: _hueForIndex(44),
    ),
    ParadiseThemeSpec._(
      key: "sidrat_muntaha",
      title: "ظلال السدرة المضيئة",
      caption: "شجرة سدر عظيمة تخيم على جدول ومرج من الزهور البيضاء.",
      imageAsset: "assets/images/themes/sidrat_muntaha.jpg",
      accent: _tone(_hueForIndex(45), 0.75, 0.24),
      hue: _hueForIndex(45),
    ),
    ParadiseThemeSpec._(
      key: "musk_obsidian",
      title: "حديقة المسك والأوبسيديان",
      caption: "أحواض حجرية سوداء لامعة تفوح حولها أزهار ليلية فاتحة.",
      imageAsset: "assets/images/themes/musk_obsidian.jpg",
      accent: _tone(_hueForIndex(46), 0.75, 0.24),
      hue: _hueForIndex(46),
    ),
    ParadiseThemeSpec._(
      key: "oud_royal_mahogany",
      title: "حديقة العود الملكي",
      caption: "أروقة خشب الماهوغاني والعنبر تحيط بأشجار العود والبخور.",
      imageAsset: "assets/images/themes/oud_royal_mahogany.jpg",
      accent: _tone(_hueForIndex(47), 0.75, 0.24),
      hue: _hueForIndex(47),
    ),
    ParadiseThemeSpec._(
      key: "saffron_imperial",
      title: "حديقة الزعفران والمخطوطات",
      caption: "أزهار زعفران بنفسجية حول أروقة بلون الرق والذهب.",
      imageAsset: "assets/images/themes/saffron_imperial.jpg",
      accent: _tone(_hueForIndex(48), 0.75, 0.24),
      hue: _hueForIndex(48),
    ),
    ParadiseThemeSpec._(
      key: "olive_palestine",
      title: "بستان الزيتون المبارك",
      caption: "أشجار زيتون معمرة بين مصاطب حجرية وينابيع صغيرة.",
      imageAsset: "assets/images/themes/olive_palestine.jpg",
      accent: _tone(_hueForIndex(49), 0.75, 0.24),
      hue: _hueForIndex(49),
    ),
    ParadiseThemeSpec._(
      key: "yemen_aqeeq",
      title: "حديقة العقيق الصنعانية",
      caption: "مدرجات عقيقية وأبراج طينية بين الرمان والكروم.",
      imageAsset: "assets/images/themes/yemen_aqeeq.jpg",
      accent: _tone(_hueForIndex(50), 0.75, 0.24),
      hue: _hueForIndex(50),
    ),
    ParadiseThemeSpec._(
      key: "andalus_orange_blossom",
      title: "حديقة زهر النارنج",
      caption: "أشجار نارنج بيضاء الزهر تحيط بفناء أندلسي وماء جارٍ.",
      imageAsset: "assets/images/themes/andalus_orange_blossom.jpg",
      accent: _tone(_hueForIndex(51), 0.75, 0.24),
      hue: _hueForIndex(51),
    ),
    ParadiseThemeSpec._(
      key: "royal_emerald_marble",
      title: "حديقة الرخام الزمردي",
      caption: "ألواح رخام خضراء مصقولة بين حدائق متناظرة ونوافير ذهبية.",
      imageAsset: "assets/images/marble/marble_emerald_dark.jpg",
      accent: _tone(_hueForIndex(52), 0.75, 0.24),
      hue: _hueForIndex(52),
    ),
    ParadiseThemeSpec._(
      key: "pearl_blush_marble",
      title: "حديقة الرخام الوردي",
      caption: "رخام وردي لؤلؤي يحيط ببركة وردية وأشجار كرز مزهرة.",
      imageAsset: "assets/images/marble/marble_pearl_gold_light.jpg",
      accent: _tone(_hueForIndex(53), 0.75, 0.24),
      hue: _hueForIndex(53),
    ),
    ParadiseThemeSpec._(
      key: "alabaster_veined_marble",
      title: "حديقة المرمر الأبيض",
      caption: "أعمدة مرمرية بعروق رقيقة بين شجر الليمون وأحواض صافية.",
      imageAsset: "assets/images/marble/marble_white_veined_light.jpg",
      accent: _tone(_hueForIndex(54), 0.75, 0.24),
      hue: _hueForIndex(54),
    ),
    ParadiseThemeSpec._(
      key: "snow_hermon_dawn",
      title: "حديقة الفجر الثلجي",
      caption: "قمم بيضاء تحيط بحديقة صنوبر ونبع يذوب عند أول الضوء.",
      imageAsset: "assets/images/themes/snow_hermon_dawn.jpg",
      accent: _tone(_hueForIndex(55), 0.75, 0.24),
      hue: _hueForIndex(55),
    ),
  ]);

  static final Map<String, ParadiseThemeSpec> _byKey = {
    for (final spec in _all) spec.key: spec,
  };

  static String _normalizeKey(String key) =>
      key == 'emerald' ? 'emerald_gold' : key;

  static ParadiseThemeSpec forKey(String key) =>
      _byKey[_normalizeKey(key)] ?? _all.first;

  static String imageFor(String key) => forKey(key).imageAsset;

  static ThemePalette paletteFor(String key, bool isNight) {
    final spec = forKey(key);
    final hue = spec._hue;
    if (isNight) {
      final scaffold = _tone(hue, 0.28, 0.09);
      final card = _tone(hue, 0.24, 0.145);
      final elevated = _tone(hue, 0.28, 0.205);
      final accent = _tone(hue, 0.62, 0.76);
      return ThemePalette(
        isDark: true,
        primaryColor: _tone(hue, 0.50, 0.63),
        accentColor: accent,
        scaffoldColor: scaffold,
        cardColor: card,
        elevatedCardColor: elevated,
        textPrimary: _tone(hue, 0.16, 0.95),
        textSecondary: _tone(hue, 0.20, 0.80),
        textMuted: _tone(hue, 0.18, 0.72),
        dividerColor: _tone(hue, 0.22, 0.31),
        onAccentColor: _contrastingInk(accent),
        skyGradients: [
          _tone(hue, 0.35, 0.22),
          scaffold,
          _tone(hue, 0.08, 0.035)
        ],
      );
    }

    final scaffold = _tone(hue, 0.12, 0.975);
    final card = _tone(hue, 0.035, 0.998);
    final elevated = _tone(hue, 0.13, 0.94);
    final accent = spec.accent;
    return ThemePalette(
      isDark: false,
      primaryColor: _tone(hue, 0.68, 0.29),
      accentColor: accent,
      scaffoldColor: scaffold,
      cardColor: card,
      elevatedCardColor: elevated,
      textPrimary: _tone(hue, 0.14, 0.13),
      textSecondary: _tone(hue, 0.30, 0.28),
      textMuted: _tone(hue, 0.20, 0.32),
      dividerColor: _tone(hue, 0.20, 0.84),
      onAccentColor: _contrastingInk(accent),
      skyGradients: [_tone(hue, 0.22, 0.90), scaffold, card],
    );
  }

  static Color _contrastingInk(Color background) {
    const darkInk = Color(0xFF102019);
    final whiteContrast = _contrastRatio(Colors.white, background);
    final darkContrast = _contrastRatio(darkInk, background);
    return whiteContrast >= darkContrast ? Colors.white : darkInk;
  }

  static double _contrastRatio(Color foreground, Color background) {
    final first = foreground.computeLuminance();
    final second = background.computeLuminance();
    final lighter = first > second ? first : second;
    final darker = first > second ? second : first;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
