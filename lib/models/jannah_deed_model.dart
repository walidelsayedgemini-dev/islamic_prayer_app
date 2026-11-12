import 'package:flutter/material.dart';

/// تصنيف أعمال غراس وبناء الجنة
enum JannahDeedType {
  palmTree, // غرس النخيل
  palace, // بناء القصور
  treasure, // كنوز الجنة
  seedling, // غراس الجنة الرباعي
  river, // أنهار الجنة
}

class JannahDeed {
  final JannahDeedType type;
  final String title;
  final String dhikr;
  final String hadith;
  final String reference;
  final int targetPerUnit; // كم مرة لتحقيق وحدة واحدة (مثلاً 10 مرات لبناء قصر، 1 مرة لنخلة)
  final String rewardName;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const JannahDeed({
    required this.type,
    required this.title,
    required this.dhikr,
    required this.hadith,
    required this.reference,
    required this.targetPerUnit,
    required this.rewardName,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static const List<JannahDeed> allDeeds = [
    JannahDeed(
      type: JannahDeedType.palmTree,
      title: 'غراس نخيل الفردوس',
      dhikr: 'سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ',
      hadith: '«مَنْ قَالَ: سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ، غُرِسَتْ لَهُ نَخْلَةٌ فِي الْجَنَّةِ»',
      reference: 'صحيح الترمذي (نخلة جذوعها من ذهب وثمارها أحلى من العسل)',
      targetPerUnit: 1,
      rewardName: 'نخلة ذهبية في جنتك',
      icon: Icons.forest_rounded,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFFBBF24),
    ),
    JannahDeed(
      type: JannahDeedType.palace,
      title: 'تشييد قصور الجنة',
      dhikr: 'قِرَاءَةُ سُورَةِ الإِخْلاصِ (10 مَرَّاتٍ)',
      hadith: '«مَنْ قَرَأَ {قُلْ هُوَ اللَّهُ أَحَدٌ} حَتَّى يَخْتِمَهَا عَشْرَ مَرَّاتٍ، بَنَى اللَّهُ لَهُ قَصْرًا فِي الْجَنَّةِ»',
      reference: 'السلسلة الصحيحة للألباني (قصور لبنة من ذهب ولبنة من فضة)',
      targetPerUnit: 10,
      rewardName: 'قصر من الذهب والمسك',
      icon: Icons.castle_rounded,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFFCD34D),
    ),
    JannahDeed(
      type: JannahDeedType.treasure,
      title: 'كنوز الجنة المخبوءة',
      dhikr: 'لا حَوْلَ وَلا قُوَّةَ إِلاَّ بِاللَّهِ',
      hadith: '«أَلا أَدُلُّكَ عَلَى كَلِمَةٍ مِنْ تَحْتِ الْعَرْشِ مِنْ كَنْزِ الْجَنَّةِ؟ تَقُولُ: لا حَوْلَ وَلا قُوَّةَ إِلاَّ بِاللَّهِ»',
      reference: 'متفق عليه عن أبي موسى الأشعري رضي الله عنه',
      targetPerUnit: 1,
      rewardName: 'كنز من الياقوت تحت العرش',
      icon: Icons.diamond_rounded,
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFFA78BFA),
    ),
    JannahDeed(
      type: JannahDeedType.seedling,
      title: 'غراس إبراهيم عليه السلام',
      dhikr: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلا إِلَهَ إِلاَّ اللَّهُ، وَاللَّهُ أَكْبَرُ',
      hadith: '«لَقِيتُ إِبْرَاهِيمَ لَيْلَةَ أُسْرِيَ بِي فَقَالَ: يَا مُحَمَّدُ أَقْرِئْ أُمَّتَكَ السَّلامَ وَأَخْبِرْهُمْ أَنَّ الْجَنَّةَ قِيعَانٌ وَأَنَّ غِرَاسَهَا: سُبْحَانَ اللَّهِ...»',
      reference: 'سنن الترمذي وحسنه الألباني',
      targetPerUnit: 4,
      rewardName: 'روضة خضراء تفوح مسكاً',
      icon: Icons.spa_rounded,
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF67E8F9),
    ),
    JannahDeed(
      type: JannahDeedType.river,
      title: 'أنهار الكوثر النبوية',
      dhikr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      hadith: '«الْكَوْثَرُ نَهَرٌ أَعْطَانِيهِ رَبِّي فِي الْجَنَّةِ، تُرَابُهُ مِسْكٌ، مَاؤُهُ أَشَدُّ بَيَاضًا مِنَ اللَّبَنِ وَأَحْلَى مِنَ الْعَسَلِ»',
      reference: 'صحيح مسلم وسنن الترمذي',
      targetPerUnit: 10,
      rewardName: 'عين وسلسبيل في الفردوس',
      icon: Icons.water_drop_rounded,
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF93C5FD),
    ),
  ];
}
