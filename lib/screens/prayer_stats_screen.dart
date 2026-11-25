import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/firdaws_user_provider.dart';
import '../widgets/calm_ui.dart';

/// إحصائيات سجل الصلاة: آخر 7 أيام وآخر 30 يومًا.
class PrayerStatsScreen extends StatelessWidget {
  const PrayerStatsScreen({super.key});

  static const Map<String, String> _names = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  @override
  Widget build(BuildContext context) {
    final user = context.watch<FirdawsUserProvider>();
    final today = DateTime.now();
    final days = List<DateTime>.generate(
      30,
      (i) => DateTime(today.year, today.month, today.day - i),
    );
    final week = days.take(7).toList();

    int completedFor(List<DateTime> range) => range.fold<int>(
        0, (sum, d) => sum + user.recordForDate(d).completedObligatoryCount);

    final weekDone = completedFor(week);
    final monthDone = completedFor(days);
    final weekRate = (weekDone / (week.length * 5) * 100).round();
    final monthRate = (monthDone / (days.length * 5) * 100).round();

    // نسبة الالتزام بكل صلاة خلال آخر 30 يومًا.
    final perPrayer = <String, int>{
      for (final key in FirdawsUserProvider.obligatoryPrayerKeys)
        key: days
            .where((d) => user.recordForDate(d).statusFor(key).isCompleted)
            .length,
    };

    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CalmPage(
        title: 'إحصائيات الصلاة',
        subtitle: 'متابعة التزامك خلال الأسبوع والشهر',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CalmStat(
                      value: '$weekRate٪', label: 'التزام آخر 7 أيام'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CalmStat(
                      value: '$monthRate٪', label: 'التزام آخر 30 يومًا'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CalmStat(
                      value: '${user.currentPrayerStreak}',
                      label: 'أيام متتالية حاليًا'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CalmStat(
                      value: '${user.bestPrayerStreak}',
                      label: 'أفضل سلسلة'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const CalmSectionTitle('آخر 7 أيام'),
            const SizedBox(height: 10),
            CalmCard(
              child: Column(
                children: [
                  for (final d in week.reversed)
                    _DayBar(
                      label: _dayLabel(d, today),
                      count: user.recordForDate(d).completedObligatoryCount,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const CalmSectionTitle('كل صلاة خلال 30 يومًا'),
            const SizedBox(height: 10),
            CalmCard(
              child: Column(
                children: [
                  for (final entry in _names.entries)
                    _PrayerRow(
                      name: entry.value,
                      done: perPrayer[entry.key] ?? 0,
                      total: days.length,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'تعتمد الأرقام على ما سجّلته في سجل الصلاة على هذا الجهاز.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  static String _dayLabel(DateTime d, DateTime today) {
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return 'اليوم';
    }
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekdays[d.weekday - 1];
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final int count;
  const _DayBar({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: count / 5,
                minHeight: 12,
                backgroundColor: scheme.primary.withOpacity(.12),
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 32, child: Text('$count/5')),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final int done;
  final int total;
  const _PrayerRow(
      {required this.name, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(name)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 12,
                backgroundColor: scheme.primary.withOpacity(.12),
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 48, child: Text('$done/$total')),
        ],
      ),
    );
  }
}
