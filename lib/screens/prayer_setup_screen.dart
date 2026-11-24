import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prayer_alarm_preference.dart';
import '../models/prayer_model.dart';
import '../providers/settings_provider.dart';
import '../services/firdaws_native_service.dart';
import '../services/prayer_reliability_labels.dart';
import '../services/notification_capabilities.dart';
import '../services/notification_service.dart';
import '../widgets/calm_ui.dart';
import '../widgets/manual_city_picker.dart';
import '../widgets/paradise_ui.dart';

class PrayerSetupScreen extends StatefulWidget {
  const PrayerSetupScreen({super.key});

  @override
  State<PrayerSetupScreen> createState() => _PrayerSetupScreenState();
}

class _PrayerSetupScreenState extends State<PrayerSetupScreen> {
  bool _requestingNotifications = false;
  bool _testAlarmScheduled = false;
  bool _schedulingTestAlarm = false;

  Future<void> _chooseCity(SettingsProvider settings) async {
    final city = await ManualCityPicker.show(
      context,
      selectedCityName: settings.cityName,
    );
    if (!mounted || city == null) return;
    settings.setManualLocation(city.latitude, city.longitude, city.name);
  }

  Future<void> _requestLocation(SettingsProvider settings) async {
    final result = await settings.refreshCurrentLocation();
    if (!mounted) return;
    final message = result.succeeded
        ? 'تم تحديد موقعك: ${result.displayName}'
        : result.errorMessage ??
            'تعذر تحديد الموقع؛ يمكنك اختيار مدينة يدويًا.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _scheduleTestAdhan(SettingsProvider settings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('اختبار تنبيه الأذان'),
        content: const Text(
          'سيتم جدولة تنبيه تجريبي بعد دقيقة للتأكد من عمل الإشعارات والأذان. لن يبدأ الصوت الآن، ولن يُجدول الاختبار إلا بعد موافقتك الصريحة. يمكنك إلغاؤه من هنا قبل موعده.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ليس الآن'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('جدولة الاختبار'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final now = DateTime.now();
    final times = AdvancedPrayerTimes.calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    ).prayerTimes;
    final upcoming = [
      times.fajr,
      times.dhuhr,
      times.asr,
      times.maghrib,
      times.isha
    ].where((time) => time.isAfter(now));
    if (upcoming
        .any((time) => time.difference(now) < const Duration(minutes: 5))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'قرب موعد الصلاة؛ أرجّل الاختبار حتى لا يتداخل مع الأذان الحقيقي.')),
      );
      return;
    }

    setState(() => _schedulingTestAlarm = true);
    final scheduled = await FirdawsNativeService().scheduleTestAdhan(
      voiceId: settings.adhanVoice,
      prayerName: 'اختبار الأذان',
      mode: PrayerAlarmMode.adhan.name,
      volumePercent: 100,
    );
    if (!mounted) return;
    setState(() {
      _schedulingTestAlarm = false;
      _testAlarmScheduled = scheduled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(scheduled
              ? 'تمت جدولة اختبار الأذان بعد دقيقة. قد يتأخر إذا منع الجهاز المنبه الدقيق.'
              : 'تعذر جدولة الاختبار؛ راجع صلاحية المنبه الدقيق وحالة التنبيهات.')),
    );
  }

  Future<void> _cancelTestAdhan() async {
    final cancelled = await FirdawsNativeService().cancelTestAdhan();
    if (!mounted) return;
    setState(() => _testAlarmScheduled = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              cancelled ? 'تم إلغاء اختبار الأذان.' : 'تعذر إلغاء الاختبار.')),
    );
  }

  Future<void> _requestNotifications(SettingsProvider settings) async {
    setState(() => _requestingNotifications = true);
    final granted = await NotificationService().requestReminderPermissions();
    if (!mounted) return;
    settings.syncAllNotifications();
    setState(() => _requestingNotifications = false);
    final message = granted
        ? 'تم إرسال طلب صلاحية الإشعارات. راجع حالة المنبه الدقيق من إعدادات التنبيهات.'
        : 'قد تحتاج تفعيل الإشعارات والمنبه الدقيق من إعدادات الجهاز؛ يمكنك ضبطهما لاحقًا.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final capabilities = NotificationPlatformCapabilities.forTarget(
      isWeb: kIsWeb,
      targetPlatform: defaultTargetPlatform,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: CalmIconBadge(Icons.mosque_rounded, size: 64),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'لنهيّئ الفردوس ليومك',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'خطوتان اختياريتان لتحصل على مواقيت أقرب لمدينتك وتنبيهات مناسبة لك. يمكنك تخطيهما وتغيير كل شيء لاحقًا.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SetupStepChip(
                        number: '١',
                        label: 'الموقع والمواقيت',
                        icon: Icons.place_outlined,
                      ),
                      _SetupStepChip(
                        number: '٢',
                        label: 'التنبيهات',
                        icon: Icons.notifications_none_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ParadiseSection(
                    title: '١. موقع ومواقيت الصلاة',
                    child: CalmCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'يُستخدم الموقع لحساب مواقيت الصلاة وعرض المدينة فقط. لا نحتاجه لاختيار مدينة يدويًا.',
                          ),
                          const SizedBox(height: 10),
                          Text(
                            settings.hasConfirmedLocation
                                ? 'الموقع الحالي: ${settings.cityName}'
                                : 'لم يتم تأكيد المدينة بعد؛ ستظهر المواقيت مؤقتًا إلى أن تختار موقعًا.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: settings.isDetectingLocation
                                ? null
                                : () => _requestLocation(settings),
                            icon: settings.isDetectingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            label: Text(settings.isDetectingLocation
                                ? 'جارٍ تحديد الموقع…'
                                : 'استخدم موقعي الحالي'),
                          ),
                          TextButton.icon(
                            onPressed: () => _chooseCity(settings),
                            icon: const Icon(Icons.location_city_rounded),
                            label: const Text('اختيار مدينة يدويًا'),
                          ),
                          const Divider(height: 24),
                          Text('طريقة الحساب',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<CalculationMethod>(
                            value: settings.calculationMethod,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              helperMaxLines: 3,
                              helperText:
                                  'اختر الطريقة الأقرب لجدول مسجدك؛ يمكنك تغييرها لاحقًا من الإعدادات.',
                            ),
                            items: CalculationMethod.values
                                .map((method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(
                                          PrayerReliabilityLabels.method(
                                              method)),
                                    ))
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value != null) {
                                settings.setCalculationMethod(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ParadiseSection(
                    title: '٢. تنبيهات الأذان',
                    child: CalmCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            capabilities.userNotice,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.tonalIcon(
                            onPressed: _requestingNotifications ||
                                    !capabilities.canCheckNotificationPermission
                                ? null
                                : () => _requestNotifications(settings),
                            icon: _requestingNotifications
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.notifications_active_outlined),
                            label: const Text('تفعيل الإشعارات الآن'),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'إذا رفضت الإذن، يمكنك تفعيله لاحقًا من الإعدادات ← الأذان والتنبيهات. طريقة الحساب والمذهب وتصحيحات دقائق الصلاة متاحة أيضًا في الإعدادات.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                          if (FirdawsNativeService().isAndroid) ...[
                            const Divider(height: 24),
                            Text('اختبار الأذان على هذا الجهاز',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(
                              'اختبار اختياري للتأكد من وصول التنبيه وتشغيل الأذان لاحقًا. لا يبدأ الصوت تلقائيًا الآن؛ سيُجدول فقط بعد موافقتك.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant, height: 1.45),
                            ),
                            const SizedBox(height: 10),
                            if (_testAlarmScheduled)
                              Text(
                                  'الحالة: يوجد اختبار مجدول بعد دقيقة تقريبًا.',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: scheme.primary)),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed: _schedulingTestAlarm
                                        ? null
                                        : () => _scheduleTestAdhan(settings),
                                    icon: _schedulingTestAlarm
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : const Icon(
                                            Icons.notification_add_outlined),
                                    label: Text(_testAlarmScheduled
                                        ? 'إعادة جدولة الاختبار'
                                        : 'جدولة اختبار بعد دقيقة'),
                                  ),
                                ),
                                if (_testAlarmScheduled) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                      tooltip: 'إلغاء الاختبار',
                                      onPressed: _cancelTestAdhan,
                                      icon: const Icon(Icons.cancel_outlined)),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: settings.completeFirstRunSetup,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('ابدأ استخدام الفردوس'),
                  ),
                  TextButton(
                    onPressed: settings.completeFirstRunSetup,
                    child: const Text('المتابعة لاحقًا دون ضبط الآن'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupStepChip extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const _SetupStepChip({
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 14, 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              number,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 17, color: scheme.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
