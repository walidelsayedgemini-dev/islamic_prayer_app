import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../models/adhan_skin_catalog.dart';
import '../models/font_catalog.dart';
import '../models/prayer_alarm_preference.dart';
import '../models/prayer_model.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/reminder_preferences_provider.dart';
import '../widgets/reminder_settings_section.dart';
import '../services/firdaws_native_service.dart';
import '../services/notification_capabilities.dart';
import '../services/notification_service.dart';
import '../services/prayer_reliability_labels.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/calm_ui.dart';
import '../widgets/comfort_settings_section.dart';
import '../widgets/manual_city_picker.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/unified_theme_hub.dart';
import '../widgets/user_profile_editor_sheet.dart';
import 'adhan_alarm_screen.dart';
import 'adhan_skin_gallery_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(
      {super.key, this.notificationCapabilities, this.onNavigate});

  final void Function(int pageIndex)? onNavigate;

  final NotificationPlatformCapabilities? notificationCapabilities;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _adhanDiag = const {};
  bool _isLoadingDiagnostics = true;
  bool _testAlarmScheduled = false;
  String? _diagnosticsError;

  NotificationPlatformCapabilities get _notificationCapabilities =>
      widget.notificationCapabilities ??
      NotificationPlatformCapabilities.forTarget(
        isWeb: kIsWeb,
        targetPlatform: defaultTargetPlatform,
      );

  String _arabicDigits(int value) => value.toString().replaceAllMapped(
        RegExp(r'\d'),
        (match) => '٠١٢٣٤٥٦٧٨٩'[int.parse(match.group(0)!)],
      );

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    if (mounted && !_isLoadingDiagnostics) {
      setState(() {
        _isLoadingDiagnostics = true;
        _diagnosticsError = null;
      });
    }
    try {
      final capabilities = _notificationCapabilities;
      late final Map<String, dynamic> diag;
      if (!capabilities.canCheckNotificationPermission) {
        diag = const {'supported': false};
      } else if (capabilities.supportsExactAlarms) {
        diag = {
          'supported': true,
          ...await FirdawsNativeService().getAdhanDiagnostics(),
        };
      } else {
        final plugin = NotificationService().flutterLocalNotificationsPlugin;
        final ios = plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final permissions = await ios?.checkPermissions();
        final pending = await plugin.pendingNotificationRequests();
        diag = {
          'supported': true,
          'notificationsEnabled': permissions?.isEnabled == true,
          'scheduledCount': pending.length,
          // Exact alarms and battery exemptions are Android-only diagnostics.
          'canScheduleExactAlarms': null,
          'ignoringBatteryOptimizations': null,
        };
      }
      if (mounted) {
        setState(() {
          _adhanDiag = diag;
          _isLoadingDiagnostics = false;
          _diagnosticsError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _adhanDiag = const {};
          _isLoadingDiagnostics = false;
          _diagnosticsError = 'تعذر قراءة حالة التنبيهات من هذا الجهاز.';
        });
      }
    }
  }

  Future<void> _scheduleTestAdhan(SettingsProvider settings) async {
    final now = DateTime.now();
    final times = AdvancedPrayerTimes.calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    ).prayerTimes;
    final upcoming = <DateTime>[
      times.fajr,
      times.dhuhr,
      times.asr,
      times.maghrib,
      times.isha,
    ].where((time) => time.isAfter(now));
    if (upcoming
        .any((time) => time.difference(now) < const Duration(minutes: 5))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'قرب موعد الصلاة؛ أرجّل الاختبار حتى لا يتداخل مع الأذان الحقيقي.'),
        ),
      );
      return;
    }
    final scheduled = await FirdawsNativeService().scheduleTestAdhan(
      voiceId: settings.adhanVoice,
      prayerName: 'اختبار الأذان',
      mode: PrayerAlarmMode.adhan.name,
      volumePercent: 100,
    );
    if (!mounted) return;
    setState(() => _testAlarmScheduled = scheduled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          scheduled
              ? 'تمت جدولة اختبار أذان بعد دقيقة. قد يتأخر إذا منع الجهاز المنبه الدقيق.'
              : 'تعذر جدولة الاختبار؛ راجع صلاحية المنبه الدقيق وحالة التنبيهات.',
        ),
      ),
    );
  }

  Future<void> _cancelTestAdhan() async {
    final cancelled = await FirdawsNativeService().cancelTestAdhan();
    if (!mounted) return;
    setState(() => _testAlarmScheduled = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            cancelled ? 'تم إلغاء اختبار الأذان.' : 'تعذر إلغاء الاختبار.'),
      ),
    );
  }

  Future<void> _refreshLocation(SettingsProvider settings) async {
    final result = await settings.refreshCurrentLocation();
    if (!mounted) return;

    final message = result.succeeded
        ? 'تم تحديث الموقع: ${result.displayName} (${result.sourceLabel})'
        : result.errorMessage ??
            'تعذر تحديد الموقع الآن. يمكنك اختيار المدينة يدوياً.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setAutomaticLocation(
    SettingsProvider settings,
    bool enabled,
  ) async {
    settings.setAutomaticLocationEnabled(enabled);
    if (enabled) {
      await _refreshLocation(settings);
    }
  }

  Future<void> _showCityPicker(SettingsProvider settings) async {
    final city = await ManualCityPicker.show(
      context,
      selectedCityName: settings.cityName,
    );
    if (!mounted || city == null) return;
    settings.setManualLocation(city.latitude, city.longitude, city.name);
  }

  Future<void> _showAdhanSkinGallery(SettingsProvider settings) async {
    final skinId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => AdhanSkinGalleryScreen(
          selectedSkinId: settings.adhanSkinId,
        ),
      ),
    );
    if (!mounted || skinId == null) return;
    settings.setAdhanSkin(skinId);
  }

  void _showFontPicker(SettingsProvider settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text('خط واجهة التطبيق',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: FontCatalog.allFonts.length,
                  separatorBuilder: (_, __) => const CalmDivider(),
                  itemBuilder: (context, index) {
                    final font = FontCatalog.allFonts[index];
                    final selected = settings.selectedFont == font.family;
                    return RadioListTile<String>(
                      value: font.family,
                      groupValue: settings.selectedFont,
                      title: Text(
                        font.arabicName,
                        style: TextStyle(fontFamily: font.family),
                      ),
                      subtitle: Text(font.description),
                      secondary: selected
                          ? const Icon(Icons.check_circle_outline_rounded)
                          : null,
                      onChanged: (value) {
                        if (value == null) return;
                        settings.setFont(value);
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final user = Provider.of<FirdawsUserProvider>(context);
    final currentFont = FontCatalog.getByFamily(settings.selectedFont);

    return CalmPage(
      title: 'إعدادات تجربتك',
      subtitle: 'اختر مظهرك، واضبط الموقع والتنبيهات بما يلائم يومك.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final wide = constraints.maxWidth >= 850 && textScale <= 1.2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThemeStudio(context, settings, currentFont),
              _buildSectionDivider(context),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLocationSection(context, settings)),
                    const SizedBox(width: 22),
                    Expanded(child: _buildPrayerSection(context, settings)),
                  ],
                )
              else ...[
                _buildLocationSection(context, settings),
                const SizedBox(height: 26),
                _buildPrayerSection(context, settings),
              ],
              _buildSectionDivider(context),
              _buildNotificationSection(context, settings),
              _buildSectionDivider(context),
              if (context.watch<ReminderPreferencesProvider?>() != null) ...[
                ReminderSettingsSection(onNavigate: widget.onNavigate),
                _buildSectionDivider(context),
              ],
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAccountSection(context, user)),
                    const SizedBox(width: 22),
                    Expanded(child: _buildAdvancedSection(context, settings)),
                  ],
                )
              else ...[
                _buildAccountSection(context, user),
                const SizedBox(height: 26),
                _buildAdvancedSection(context, settings),
              ],
              _buildSectionDivider(context),
              const ComfortSettingsSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionDivider(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
                color: scheme.outlineVariant.withOpacity(.72),
              ),
            ),
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFB99C64),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Divider(
                height: 1,
                color: scheme.outlineVariant.withOpacity(.72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeStudio(
    BuildContext context,
    SettingsProvider settings,
    AppFontOption currentFont,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final specs = FirdawsParadiseRegistry.all;
    final currentSpec = FirdawsParadiseRegistry.forKey(settings.selectedTheme);

    final modeOptions = <({String value, String label, IconData icon})>[
      (value: 'day', label: 'نهاري', icon: Icons.wb_sunny_outlined),
      (value: 'night', label: 'ليلي', icon: Icons.nights_stay_outlined),
      (value: 'auto', label: 'تلقائي', icon: Icons.brightness_auto_rounded),
      (value: 'system', label: 'حسب الجهاز', icon: Icons.settings_brightness),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ParadiseSection(
          title: 'هوية التطبيق',
          child: CalmCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 2.25,
                    child: _themeImage(currentSpec.imageAsset),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSpec.title,
                            softWrap: true,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            currentSpec.caption,
                            softWrap: true,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: currentSpec.accent.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: currentSpec.accent.withOpacity(.34),
                        ),
                      ),
                      child:
                          Icon(Icons.check_rounded, color: currentSpec.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('إضاءة الواجهة', style: theme.textTheme.titleSmall),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: modeOptions.map((option) {
                    return ParadiseChip(
                      label: option.label,
                      icon: option.icon,
                      selected: settings.brightnessMode == option.value,
                      onTap: () => settings.setBrightnessMode(option.value),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '«تلقائي» يتبدل وفق مواقيت الصلاة، و«حسب الجهاز» يتبع الوضع الداكن في إعدادات هاتفك.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const CalmDivider(),
                CalmActionTile(
                  icon: Icons.text_fields_rounded,
                  title: 'خط واجهة التطبيق',
                  subtitle: '${currentFont.arabicName} · ${currentFont.family}',
                  onTap: () => _showFontPicker(settings),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: currentFont.family,
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        ParadiseSection(
          title: 'معرض الثيمات',
          action: ParadiseChip(
            label: '${specs.length} طابعاً',
            icon: Icons.grid_view_rounded,
            selected: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تصفّح ${specs.length} مشهداً بطابع مستقل. افتح المعرض للبحث والاختيار ومشاهدة لوحتي النهار والليل.',
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => ThemeHubSheet.show(context),
                icon: const Icon(Icons.collections_outlined),
                label: const Text('استكشف معرض الثيمات'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _themeImage(String path) {
    final scheme = Theme.of(context).colorScheme;
    Widget fallback() => ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Center(
            child: Icon(Icons.landscape_rounded,
                size: 34, color: scheme.onSurfaceVariant),
          ),
        );

    if (path.startsWith('/manus-storage/')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        cacheWidth: 720,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          final total = progress.expectedTotalBytes;
          return ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: total == null
                      ? null
                      : progress.cumulativeBytesLoaded / total,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      cacheWidth: 720,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ParadiseSection(
      title: 'الموقع',
      child: CalmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CalmActionTile(
              icon: Icons.location_on_outlined,
              title: settings.cityName,
              subtitle: settings.lastLocationStatus,
              onTap: () => _showCityPicker(settings),
            ),
            _buildLocationStatus(context, settings),
            if (settings.lastLocationError != null) ...[
              const SizedBox(height: 4),
              _buildLocationError(context, settings),
            ],
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('تحديد الموقع تلقائياً'),
              subtitle: const Text('استخدام GPS أو الشبكة عند التحديث'),
              value: settings.isAutoLocation,
              onChanged: settings.isDetectingLocation
                  ? null
                  : (value) => _setAutomaticLocation(settings, value),
            ),
            if (settings.isDetectingLocation) ...[
              const SizedBox(height: 2),
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              Text('جارٍ تحديد موقعك…',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                OutlinedButton.icon(
                  onPressed: settings.isDetectingLocation
                      ? null
                      : () => _refreshLocation(settings),
                  icon: const Icon(Icons.my_location_outlined),
                  label: const Text('تحديث الموقع'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showCityPicker(settings),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('اختيار مدينة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confirmed = settings.hasConfirmedLocation;
    final accent = confirmed ? scheme.primary : scheme.tertiary;
    final background =
        confirmed ? scheme.primaryContainer : scheme.tertiaryContainer;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background.withOpacity(.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            confirmed
                ? Icons.verified_outlined
                : Icons.location_searching_rounded,
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  confirmed ? 'الموقع مؤكّد' : 'الموقع غير مؤكّد',
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المصدر: ${settings.locationSourceLabel}',
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (!confirmed) ...[
                  const SizedBox(height: 4),
                  Text(
                    'حدّث الموقع أو اختر مدينة يدوياً لضبط المواقيت على موقعك.',
                    softWrap: true,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationError(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.error.withOpacity(.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, color: scheme.error, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعذر تحديث الموقع',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      settings.lastLocationError!,
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: settings.isDetectingLocation
                  ? null
                  : () => _refreshLocation(settings),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSection(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    return ParadiseSection(
      title: 'حساب مواقيت الصلاة',
      child: CalmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownField<CalculationMethod>(
              context: context,
              title: 'طريقة الحساب',
              value: settings.calculationMethod,
              items: CalculationMethod.values
                  .map(
                    (method) => DropdownMenuItem<CalculationMethod>(
                      value: method,
                      child: Text(PrayerReliabilityLabels.method(method)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) settings.setCalculationMethod(value);
              },
            ),
            const SizedBox(height: 14),
            _buildDropdownField<Madhab>(
              context: context,
              title: 'حساب وقت صلاة العصر',
              value: settings.madhab,
              items: const [
                DropdownMenuItem(
                  value: Madhab.shafi,
                  child: Text('الجمهور (شافعي، مالكي، حنبلي)'),
                ),
                DropdownMenuItem(
                  value: Madhab.hanafi,
                  child: Text('المذهب الحنفي'),
                ),
              ],
              onChanged: (value) {
                if (value != null) settings.setMadhab(value);
              },
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 2),
              child: Text(
                'طريقة الحساب تحدد زوايا الفجر والعشاء حسب الجهة المختارة؛ أما ${PrayerReliabilityLabels.madhab(settings.madhab)} فيؤثر على وقت العصر فقط. راجع جدول مسجدك المحلي عند الحاجة.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              leading: const CalmIconBadge(Icons.tune_rounded, size: 40),
              title: const Text('ضبط يدوي للمواقيت'),
              subtitle: const Text('تصحيح لكل موقع محفوظ على هذا الجهاز'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'يمكن تقديم الوقت أو تأخيره حتى ١٥ دقيقة. يُحفظ التصحيح لهذا الموقع ولا ينتقل تلقائيًا إلى مدينة أخرى؛ هذه معايرة شخصية وليست فتوى أو جدولًا رسميًا.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                _buildOffsetSlider(settings, 'الفجر', 'fajr', context),
                _buildOffsetSlider(settings, 'الظهر', 'dhuhr', context),
                _buildOffsetSlider(settings, 'العصر', 'asr', context),
                _buildOffsetSlider(settings, 'المغرب', 'maghrib', context),
                _buildOffsetSlider(settings, 'العشاء', 'isha', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerAlarmControls(
    BuildContext context,
    SettingsProvider settings,
  ) {
    const prayers = <({String key, String name})>[
      (key: 'fajr', name: 'الفجر'),
      (key: 'dhuhr', name: 'الظهر'),
      (key: 'asr', name: 'العصر'),
      (key: 'maghrib', name: 'المغرب'),
      (key: 'isha', name: 'العشاء'),
    ];
    const voiceItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'madinah', child: Text('أذان المدينة المنورة')),
      DropdownMenuItem(value: 'makkah', child: Text('أذان مكة المكرمة')),
      DropdownMenuItem(value: 'aqsa', child: Text('أذان المسجد الأقصى')),
      DropdownMenuItem(value: 'cairo', child: Text('أذان مساجد القاهرة')),
      DropdownMenuItem(value: 'afasy', child: Text('مشاري العفاسي')),
    ];
    const modeItems = <DropdownMenuItem<PrayerAlarmMode>>[
      DropdownMenuItem(
        value: PrayerAlarmMode.adhan,
        child: Text('أذان صوتي'),
      ),
      DropdownMenuItem(
        value: PrayerAlarmMode.vibrationOnly,
        child: Text('اهتزاز فقط'),
      ),
      DropdownMenuItem(
        value: PrayerAlarmMode.off,
        child: Text('إيقاف أذان هذه الصلاة'),
      ),
    ];

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      leading: const CalmIconBadge(Icons.tune_rounded, size: 40),
      title: const Text('تخصيص كل صلاة'),
      subtitle: const Text('صوت مستقل أو اهتزاز فقط أو إيقاف'),
      children: [
        for (final prayer in prayers) ...[
          Builder(
            builder: (context) {
              final preference = settings.prayerAlarmPreference(prayer.key);
              final usesGlobalVoice = preference.voiceId == null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(top: 8, bottom: 6),
                    child: Text(
                      'صلاة ${prayer.name}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  _buildDropdownField<PrayerAlarmMode>(
                    context: context,
                    title: 'طريقة التنبيه',
                    value: preference.mode,
                    items: modeItems,
                    onChanged: (mode) {
                      if (mode != null) {
                        settings.setPrayerAlarmPreference(
                          prayer.key,
                          preference.copyWith(mode: mode),
                        );
                      }
                    },
                  ),
                  if (preference.mode == PrayerAlarmMode.adhan) ...[
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('استخدام صوت الأذان العام'),
                      subtitle: Text(
                        usesGlobalVoice
                            ? 'الحالي: ${settings.adhanVoice}'
                            : 'أوقفه لاختيار مؤذن لهذه الصلاة',
                      ),
                      value: usesGlobalVoice,
                      onChanged: (useGlobal) {
                        settings.setPrayerAlarmPreference(
                          prayer.key,
                          preference.copyWith(
                            voiceId: settings.adhanVoice,
                            clearVoiceId: useGlobal,
                          ),
                        );
                      },
                    ),
                    if (!usesGlobalVoice)
                      _buildDropdownField<String>(
                        context: context,
                        title: 'صوت صلاة ${prayer.name}',
                        value: preference.voiceId!,
                        items: voiceItems,
                        onChanged: (voice) {
                          if (voice != null) {
                            settings.setPrayerAlarmPreference(
                              prayer.key,
                              preference.copyWith(voiceId: voice),
                            );
                          }
                        },
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(child: Text('مستوى صوت الأذان')),
                        Text('${preference.volumePercent}%'),
                      ],
                    ),
                    Slider(
                      value: preference.volumePercent.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${preference.volumePercent}%',
                      onChanged: (value) => settings.setPrayerAlarmPreference(
                        prayer.key,
                        preference.copyWith(volumePercent: value.round()),
                      ),
                    ),
                  ] else if (preference.mode ==
                      PrayerAlarmMode.vibrationOnly) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'يهتز الهاتف بنبضات قصيرة، دون تشغيل ملف صوتي. يعمل هذا الخيار على Android؛ قد تختلف استجابة الأجهزة الأخرى.',
                      ),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'لن يصدر الأذان لهذه الصلاة. تذكير ما قبل الصلاة يظل خاضعًا لمفتاحه العام أعلاه.',
                      ),
                    ),
                  ],
                  const CalmDivider(),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final capabilities = _notificationCapabilities;
    final adhanSkin = AdhanSkinCatalog.byId(settings.adhanSkinId);
    return ParadiseSection(
      title: 'الأذان والتنبيهات',
      child: CalmCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showAdhanSkinGallery(settings),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 72,
                            height: 96,
                            child: Image.asset(
                              adhanSkin.imageAsset.startsWith('/')
                                  ? adhanSkin.imageAsset.substring(1)
                                  : adhanSkin.imageAsset,
                              fit: BoxFit.cover,
                              cacheWidth: 320,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: scheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.landscape_rounded,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خلفية منبه الأذان',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                adhanSkin.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '15 خلفية مضمّنة وتعمل دون إنترنت · اضغط للاستكشاف',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: adhanSkin.accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildDropdownField<String>(
              context: context,
              title: 'صوت الأذان',
              value: const ['madinah', 'makkah', 'aqsa', 'cairo', 'afasy']
                      .contains(settings.adhanVoice)
                  ? settings.adhanVoice
                  : 'madinah',
              items: const [
                DropdownMenuItem(
                    value: 'madinah', child: Text('أذان المدينة المنورة')),
                DropdownMenuItem(
                    value: 'makkah', child: Text('أذان مكة المكرمة')),
                DropdownMenuItem(
                    value: 'aqsa', child: Text('أذان المسجد الأقصى')),
                DropdownMenuItem(
                    value: 'cairo', child: Text('أذان مساجد القاهرة')),
                DropdownMenuItem(value: 'afasy', child: Text('مشاري العفاسي')),
              ],
              onChanged: (value) {
                if (value != null) settings.setAdhanVoice(value);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdhanAlarmScreen(
                      prayerName: 'الفجر (معاينة)',
                      voiceId: settings.adhanVoice,
                      useNativeService: FirdawsNativeService().isAndroid,
                      skinId: settings.adhanSkinId,
                      onSkinSelected: settings.setAdhanSkin,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.volume_up_outlined),
              label: const Text('تشغيل معاينة صوت الأذان'),
            ),
            if (FirdawsNativeService().isAndroid) ...[
              OutlinedButton.icon(
                onPressed: _testAlarmScheduled
                    ? null
                    : () => _scheduleTestAdhan(settings),
                icon: const Icon(Icons.alarm_add_rounded),
                label: const Text('اختبار منبه بعد دقيقة'),
              ),
              if (_testAlarmScheduled)
                TextButton.icon(
                  onPressed: _cancelTestAdhan,
                  icon: const Icon(Icons.alarm_off_rounded),
                  label: const Text('إلغاء اختبار المنبه'),
                ),
              Text(
                'يستخدم صوت الأذان العام مرة واحدة؛ لا تختبره قرب وقت الصلاة.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const CalmDivider(),
            _buildPrayerAlarmControls(context, settings),
            const SizedBox(height: 8),
            Text(
              capabilities.userNotice,
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const CalmDivider(),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('تذكير قبل الأذان'),
              subtitle: Text(
                capabilities.supportsLocalNotifications
                    ? 'قبل دخول الوقت بـ ${_arabicDigits(settings.preAdhanReminderMinutes)} دقيقة'
                    : 'غير متاح في نسخة الويب؛ لا يعمل حتى مع بقاء الصفحة مفتوحة',
              ),
              value: settings.playPreAdhanReminder,
              onChanged: capabilities.supportsLocalNotifications
                  ? settings.setPreAdhanReminder
                  : null,
            ),
            if (settings.playPreAdhanReminder &&
                capabilities.supportsLocalNotifications) ...[
              Row(
                children: [
                  const Expanded(child: Text('مدة التذكير قبل الصلاة')),
                  Text(
                      '${_arabicDigits(settings.preAdhanReminderMinutes)} دقيقة'),
                ],
              ),
              Slider(
                value: settings.preAdhanReminderMinutes.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label:
                    '${_arabicDigits(settings.preAdhanReminderMinutes)} دقيقة',
                onChanged: (value) =>
                    settings.setPreAdhanReminderMinutes(value.round()),
              ),
            ],
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('الصامت التلقائي أثناء الصلاة'),
              subtitle: const Text('كتم رنين الهاتف لمدة ٣٠ دقيقة بعد الأذان'),
              value: settings.autoMuteDuringPrayer,
              onChanged: settings.setAutoMute,
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              leading: const CalmIconBadge(
                Icons.notifications_active_outlined,
                size: 40,
              ),
              title: const Text('حالة التنبيهات'),
              subtitle: Text(
                _isLoadingDiagnostics
                    ? 'جارٍ التحقق من إعدادات الجهاز'
                    : _adhanDiag['supported'] == false
                        ? 'الفحص غير مدعوم على ${capabilities.platformLabel}'
                        : _adhanDiag.isEmpty
                            ? _diagnosticsError != null
                                ? 'تعذّر الفحص · اضغط لإعادة المحاولة'
                                : 'لم تُفحص الحالة بعد'
                            : '${_adhanDiag['scheduledCount'] ?? 0} إشعارات مجدولة',
              ),
              children: [
                if (_isLoadingDiagnostics)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Text('جارٍ فحص حالة التنبيهات…')),
                      ],
                    ),
                  )
                else if (_adhanDiag['supported'] == false)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 10),
                    child: Text(
                      capabilities.userNotice,
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  )
                else if (_adhanDiag.isEmpty)
                  _buildDiagnosticUnavailable(context)
                else ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 12),
                    child: Text(
                      'توضح العلامات حالة صلاحيات الجهاز. إذا ظهرت حالة تحتاج إجراءً، استخدم الزر المناسب أدناه ثم أعد فحصها.',
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _diagPill(
                        'إشعارات النظام',
                        _adhanDiag['notificationsEnabled'] == true,
                        enabledLabel: 'مسموح بها',
                        disabledLabel: 'تحتاج إذناً',
                      ),
                      if (_adhanDiag['canDrawOverlays'] is bool)
                        _diagPill(
                          'الظهور فوق التطبيقات',
                          _adhanDiag['canDrawOverlays'] == true,
                          enabledLabel: 'مسموح',
                          disabledLabel: 'يحتاج إذناً',
                        ),
                      if (_adhanDiag['canScheduleExactAlarms'] is bool)
                        _diagPill(
                          'المنبه الدقيق',
                          _adhanDiag['canScheduleExactAlarms'] == true,
                          enabledLabel: 'مسموح',
                          disabledLabel: 'يحتاج إذناً',
                        ),
                      if (_adhanDiag['ignoringBatteryOptimizations'] is bool)
                        _diagPill(
                          'استثناء البطارية',
                          _adhanDiag['ignoringBatteryOptimizations'] == true,
                          enabledLabel: 'مفعّل',
                          disabledLabel: 'غير مفعّل',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (_adhanDiag['notificationsEnabled'] == false)
                        OutlinedButton(
                          onPressed: () async {
                            await NotificationService()
                                .requestReminderPermissions();
                            settings.syncAllNotifications();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 600),
                            );
                            await _loadDiagnostics();
                          },
                          child: const Text('طلب صلاحية الإشعارات والمنبه'),
                        ),
                      if (capabilities.supportsExactAlarms &&
                          _adhanDiag['canScheduleExactAlarms'] == false)
                        OutlinedButton(
                          onPressed: () async {
                            await FirdawsNativeService()
                                .requestExactAlarmPermission();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 600),
                            );
                            await _loadDiagnostics();
                          },
                          child: const Text('تفعيل المنبه الدقيق'),
                        ),
                      if (capabilities.supportsBatteryOptimizationDiagnostics &&
                          _adhanDiag['ignoringBatteryOptimizations'] == false)
                        OutlinedButton(
                          onPressed: () async {
                            await FirdawsNativeService()
                                .requestBatteryOptimizationExemption();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 600),
                            );
                            await _loadDiagnostics();
                          },
                          child: const Text('استثناء البطارية'),
                        ),
                      if (capabilities.supportsLocalNotifications)
                        TextButton.icon(
                          onPressed: () async {
                            settings.syncAllNotifications();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 350),
                            );
                            await _loadDiagnostics();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة جدولة التنبيهات'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticUnavailable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = _diagnosticsError != null;
    final accent = hasError ? scheme.error : scheme.primary;
    final foreground = hasError ? scheme.onErrorContainer : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasError ? scheme.errorContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? accent.withOpacity(.3) : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasError ? Icons.error_outline_rounded : Icons.info_outline,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasError ? 'تعذّر فحص الحالة' : 'لم يكتمل الفحص',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _diagnosticsError ??
                          'أعد الفحص للتأكد من صلاحيات الجهاز وجدولة التنبيهات.',
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: _loadDiagnostics,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة الفحص'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    FirdawsUserProvider user,
  ) {
    return ParadiseSection(
      title: 'الحساب والمحتوى',
      child: CalmCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CalmActionTile(
              icon: Icons.person_outline_rounded,
              title: 'الملف الشخصي',
              subtitle: user.profile.hasCustomName
                  ? user.profile.displayName
                  : 'اختياري — لا يلزم إدخال بيانات',
              onTap: () => UserProfileEditorSheet.show(context),
            ),
            const CalmDivider(),
            CalmActionTile(
              icon: Icons.download_outlined,
              title: 'التنزيلات والمحتوى الصوتي',
              subtitle: 'إدارة الملفات المتاحة دون اتصال',
              onTap: () => showAudioDownloadManagerSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return ParadiseSection(
      title: 'تخصيصات إضافية',
      child: CalmCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('المؤثرات الصوتية للألعاب'),
              subtitle: const Text('أصوات النقاط والنتائج داخل المسابقات'),
              value: settings.gameSfxEnabled,
              onChanged: settings.setGameSfxEnabled,
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              leading: const CalmIconBadge(Icons.tune_rounded, size: 40),
              title: const Text('تفضيلات المؤثرات'),
              subtitle: const Text('تحكم بتأثيرات اللمس والخلفية'),
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تأثيرات اللمس'),
                  value: settings.touchEffectsEnabled,
                  onChanged: settings.setTouchEffectsEnabled,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تبديل تأثير اللمس تلقائياً'),
                  value: settings.touchEffectsAutoCycle,
                  onChanged: settings.setTouchEffectsAutoCycle,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('لمعان الخلفية'),
                  value: settings.ambientSparklesEnabled,
                  onChanged: settings.setAmbientSparklesEnabled,
                ),
              ],
            ),
            if (FirdawsNativeService().isAndroid) ...[
              const CalmDivider(),
              CalmActionTile(
                icon: Icons.widgets_outlined,
                title: 'ويدجت مواقيت الصلاة',
                subtitle: 'إظهار الصلاة القادمة على الشاشة الرئيسية',
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('إضافة ويدجت الفردوس'),
                    content: const Text(
                      'اضغط مطولًا على مساحة فارغة في الشاشة الرئيسية، ثم اختر «الأدوات» واسحب «الفردوس — مواقيت الصلاة». تتحدث بياناتها عند تغيير المدينة أو طريقة الحساب، ويمكن الضغط عليها لفتح التطبيق.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('حسنًا'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required BuildContext context,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildOffsetSlider(
    SettingsProvider settings,
    String prayerName,
    String key,
    BuildContext context,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final offset = settings.offsets[key] ?? 0;
    final offsetLabel =
        '${offset > 0 ? '+' : ''}${_arabicDigits(offset)} دقيقة';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                prayerName,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                offsetLabel,
                textAlign: TextAlign.end,
                softWrap: true,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                    ),
              ),
            ],
          ),
          Slider(
            value: offset.toDouble().clamp(-15, 15),
            min: -15,
            max: 15,
            divisions: 30,
            label: offsetLabel,
            semanticFormatterCallback: (value) {
              final minutes = value.round();
              final adjustment = minutes > 0
                  ? 'تقديم ${_arabicDigits(minutes)} دقائق'
                  : minutes < 0
                      ? 'تأخير ${_arabicDigits(minutes.abs())} دقائق'
                      : 'دون تعديل';
              return 'موعد صلاة $prayerName: $adjustment';
            },
            onChanged: (value) => settings.updateOffset(key, value.round()),
          ),
        ],
      ),
    );
  }

  Widget _diagPill(
    String label,
    bool enabled, {
    String enabledLabel = 'مفعّل',
    String disabledLabel = 'يحتاج تفعيل',
  }) {
    final scheme = Theme.of(context).colorScheme;
    final color = enabled ? scheme.primary : scheme.error;
    final status = enabled ? enabledLabel : disabledLabel;
    return Semantics(
      label: '$label: $status',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$label · $status',
                  softWrap: true,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
