import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../models/adhan_skin_catalog.dart';
import '../models/font_catalog.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/reminder_preferences_provider.dart';
import '../widgets/reminder_settings_section.dart';
import '../services/firdaws_native_service.dart';
import '../services/notification_capabilities.dart';
import '../services/notification_service.dart';
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
  String? _diagnosticsError;

  NotificationPlatformCapabilities get _notificationCapabilities =>
      widget.notificationCapabilities ??
      NotificationPlatformCapabilities.forTarget(
        isWeb: kIsWeb,
        targetPlatform: defaultTargetPlatform,
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
          final wide = constraints.maxWidth >= 850;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThemeStudio(context, settings, currentFont),
              const SizedBox(height: 28),
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
              const SizedBox(height: 26),
              _buildNotificationSection(context, settings),
              const SizedBox(height: 26),
              if (context.watch<ReminderPreferencesProvider?>() != null) ...[
                ReminderSettingsSection(onNavigate: widget.onNavigate),
                const SizedBox(height: 26),
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
              const SizedBox(height: 26),
              const ComfortSettingsSection(),
            ],
          );
        },
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
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
              child: Text(
                'المصدر: ${settings.locationSourceLabel} · '
                '${settings.hasConfirmedLocation ? 'موقع محفوظ أو محدد' : 'الموقع الحالي غير مؤكد'}',
                softWrap: true,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
            if (settings.lastLocationError != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withOpacity(.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  settings.lastLocationError!,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                    height: 1.4,
                  ),
                ),
              ),
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
              items: const [
                DropdownMenuItem(
                  value: CalculationMethod.umm_al_qura,
                  child: Text('أم القرى'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.egyptian,
                  child: Text('الهيئة المصرية العامة للمساحة'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.muslim_world_league,
                  child: Text('رابطة العالم الإسلامي'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.karachi,
                  child: Text('جامعة العلوم بكراتشي'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.dubai,
                  child: Text('دائرة الشؤون الإسلامية بدبي'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.qatar,
                  child: Text('وزارة الأوقاف بقطر'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.kuwait,
                  child: Text('وزارة الأوقاف بالكويت'),
                ),
                DropdownMenuItem(
                  value: CalculationMethod.north_america,
                  child: Text('أمريكا الشمالية (ISNA)'),
                ),
              ],
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
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              leading: const CalmIconBadge(Icons.tune_rounded, size: 40),
              title: const Text('ضبط يدوي للمواقيت'),
              subtitle: const Text('تعديل كل صلاة بالدقائق'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'يمكن تقديم الوقت أو تأخيره حتى ١٥ دقيقة.',
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
                                'اضغط لاستكشاف الخلفيات ومعاينتها',
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
                    ? 'قبل دخول الوقت بـ ١٥ دقيقة'
                    : 'غير متاح في نسخة الويب؛ لا يعمل حتى مع بقاء الصفحة مفتوحة',
              ),
              value: settings.playPreAdhanReminder,
              onChanged: capabilities.supportsLocalNotifications
                  ? settings.setPreAdhanReminder
                  : null,
            ),
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
                            ? 'يمكنك إعادة فحص إعدادات الجهاز'
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_diagnosticsError != null) ...[
                        Text(
                          _diagnosticsError!,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: _loadDiagnostics,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('فحص حالة التنبيهات'),
                        ),
                      ),
                    ],
                  )
                else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _diagPill(
                        'إشعارات النظام',
                        _adhanDiag['notificationsEnabled'] == true,
                      ),
                      if (_adhanDiag['canScheduleExactAlarms'] is bool)
                        _diagPill(
                          'المنبه الدقيق',
                          _adhanDiag['canScheduleExactAlarms'] == true,
                        ),
                      if (_adhanDiag['ignoringBatteryOptimizations'] is bool)
                        _diagPill(
                          'استثناء البطارية',
                          _adhanDiag['ignoringBatteryOptimizations'] == true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child:
                Text(prayerName, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: offset.toDouble().clamp(-15, 15),
              min: -15,
              max: 15,
              divisions: 30,
              onChanged: (value) => settings.updateOffset(key, value.round()),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              '${offset > 0 ? '+' : ''}$offset د',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _diagPill(String label, bool enabled) {
    final scheme = Theme.of(context).colorScheme;
    final color = enabled ? scheme.primary : scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle_outline_rounded : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
