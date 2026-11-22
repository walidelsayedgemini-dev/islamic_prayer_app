import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import '../models/prayer_model.dart';

enum PrayerWindowEffect {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  qiyam,
}

extension PrayerWindowEffectExt on PrayerWindowEffect {
  String get key => name;

  String get arabicTitle {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return 'تأثير الفجر الصادق';
      case PrayerWindowEffect.sunrise:
        return 'تأثير الشروق والضحى';
      case PrayerWindowEffect.dhuhr:
        return 'تأثير نور الظهر';
      case PrayerWindowEffect.asr:
        return 'تأثير أصيل العصر';
      case PrayerWindowEffect.maghrib:
        return 'تأثير شفق المغرب';
      case PrayerWindowEffect.isha:
        return 'تأثير سكون العشاء';
      case PrayerWindowEffect.qiyam:
        return 'تأثير ثلث الليل والقيام';
    }
  }

  String get shortLabel {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return 'الفجر';
      case PrayerWindowEffect.sunrise:
        return 'الشروق والضحى';
      case PrayerWindowEffect.dhuhr:
        return 'الظهر';
      case PrayerWindowEffect.asr:
        return 'العصر';
      case PrayerWindowEffect.maghrib:
        return 'المغرب';
      case PrayerWindowEffect.isha:
        return 'العشاء';
      case PrayerWindowEffect.qiyam:
        return 'القيام والسَّحَر';
    }
  }

  String get description {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return 'انبلاج الخيط الأبيض في الأفق مع نجمات الأسحار وذرات السكينة الصاعدة.';
      case PrayerWindowEffect.sunrise:
        return 'أشعة إشراق صباحية هادئة من الشرق مع ذرات نور ذهبية دافئة.';
      case PrayerWindowEffect.dhuhr:
        return 'أعمدة نور سماوية صافية تشبه أضواء مشربيات المساجد وقت الظهيرة.';
      case PrayerWindowEffect.asr:
        return 'حُزَم نور أصيل مائلة بلون العنبر والذهب الهادئ تسبق الغروب.';
      case PrayerWindowEffect.maghrib:
        return 'شفق غروبي متدرج من الأرجوان إلى الذهب مع نجمة المساء وهلال رفيع.';
      case PrayerWindowEffect.isha:
        return 'سماء ليلية مرصّعة بالنجوم المتلألئة وهالة قمرية هادئة تبعث الطمأنينة.';
      case PrayerWindowEffect.qiyam:
        return 'ستائر نورانية روحانية من السكينة وذرات دعاء صاعدة نحو السماء في السَّحَر.';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return Icons.wb_twilight_rounded;
      case PrayerWindowEffect.sunrise:
        return Icons.light_mode_rounded;
      case PrayerWindowEffect.dhuhr:
        return Icons.brightness_high_rounded;
      case PrayerWindowEffect.asr:
        return Icons.filter_drama_rounded;
      case PrayerWindowEffect.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerWindowEffect.isha:
        return Icons.bedtime_rounded;
      case PrayerWindowEffect.qiyam:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return const Color(0xFF7DD3FC);
      case PrayerWindowEffect.sunrise:
        return const Color(0xFFFDBA74);
      case PrayerWindowEffect.dhuhr:
        return const Color(0xFFFDE68A);
      case PrayerWindowEffect.asr:
        return const Color(0xFFF59E0B);
      case PrayerWindowEffect.maghrib:
        return const Color(0xFFFB7185);
      case PrayerWindowEffect.isha:
        return const Color(0xFF93C5FD);
      case PrayerWindowEffect.qiyam:
        return const Color(0xFF34D399);
    }
  }

  static PrayerWindowEffect resolveActiveWindow({
    required AdvancedPrayerTimes prayerData,
    String overrideKey = 'auto',
    DateTime? now,
  }) {
    if (overrideKey != 'auto') {
      for (final val in PrayerWindowEffect.values) {
        if (val.name == overrideKey) return val;
      }
    }

    final currentTime = now ?? DateTime.now();
    final current = prayerData.prayerTimes.currentPrayer();

    // التحقق من دخول ثلث الليل الأخير قبل الفجر
    if ((current == Prayer.isha || current == Prayer.none) &&
        currentTime.isAfter(prayerData.qiyamStart)) {
      return PrayerWindowEffect.qiyam;
    }

    switch (current) {
      case Prayer.fajr:
        return PrayerWindowEffect.fajr;
      case Prayer.sunrise:
        return PrayerWindowEffect.sunrise;
      case Prayer.dhuhr:
        return PrayerWindowEffect.dhuhr;
      case Prayer.asr:
        return PrayerWindowEffect.asr;
      case Prayer.maghrib:
        return PrayerWindowEffect.maghrib;
      case Prayer.isha:
        return PrayerWindowEffect.isha;
      case Prayer.none:
        final hour = currentTime.hour;
        if (hour >= 1 && hour < 5) return PrayerWindowEffect.qiyam;
        return PrayerWindowEffect.isha;
    }
  }
}

/// Prayer-window calculation remains available; decorative drawing is disabled.
class PrayerTimeEffectsCanvas extends StatelessWidget {
  final PrayerWindowEffect windowEffect;
  final bool isNightMode;
  const PrayerTimeEffectsCanvas(
      {super.key, required this.windowEffect, this.isNightMode = true});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
