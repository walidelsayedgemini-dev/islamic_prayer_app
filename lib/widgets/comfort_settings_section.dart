import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/comfort_provider.dart';

/// Self-contained comfort controls intended for embedding in the app settings screen.
class ComfortSettingsSection extends StatelessWidget {
  const ComfortSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final comfort = context.watch<ComfortProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaleLabel = '${comfort.additionalTextScale.toStringAsFixed(1)}×';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('سهولة القراءة والحركة',
                style: theme.textTheme.titleLarge, softWrap: true),
            const SizedBox(height: 5),
            Text(
              'تفضيلات مستقلة تُحفظ على هذا الجهاز، مع الإبقاء على النصوص الدينية وآليات اللعب كما هي.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 14),
            Semantics(
              container: true,
              label: 'معاينة حية للتكبير الإضافي، $scaleLabel',
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('معاينة حية',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onSurface,
                        )),
                    const SizedBox(height: 5),
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'تكبير النص الإضافي',
                    style: theme.textTheme.titleSmall,
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 8),
                Text(scaleLabel,
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            Slider(
              value: comfort.additionalTextScale,
              min: ComfortProvider.textScaleChoices.first,
              max: ComfortProvider.textScaleChoices.last,
              divisions: ComfortProvider.textScaleChoices.length - 1,
              label: scaleLabel,
              semanticFormatterCallback: (value) =>
                  'تكبير النص الإضافي ${value.toStringAsFixed(1)}',
              onChanged: comfort.setAdditionalTextScale,
            ),
            Text(
              'تُضاف الزيادة إلى تكبير الجهاز؛ ولا يُحدّ تكبير النظام أو إعدادات تسهيل الاستخدام.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('تباين أوضح للنصوص وعناصر التحكم'),
              subtitle: const Text(
                  'يحافظ على ألوان الطابع ويقوّي وضوح النص والحدود.'),
              value: comfort.highContrast,
              onChanged: comfort.setHighContrast,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('تقليل الحركة الزخرفية'),
              subtitle: Text(
                comfort.systemReduceMotion
                    ? 'مفعّل وفق تفضيل تقليل الحركة في الجهاز.'
                    : 'يقلّل الحركة الزخرفية؛ لا يغيّر المؤقتات أو قواعد اللعب.',
              ),
              value: comfort.reduceMotion,
              onChanged: comfort.systemReduceMotion
                  ? null
                  : comfort.setReduceMotionPreference,
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: comfort.resetComfortPreferences,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('إعادة تفضيلات الراحة فقط'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
