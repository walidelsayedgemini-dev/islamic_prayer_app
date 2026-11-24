import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
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
                  const CalmIconBadge(Icons.mosque_rounded, size: 64),
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
