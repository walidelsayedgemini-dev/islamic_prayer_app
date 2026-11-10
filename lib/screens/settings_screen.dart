import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_pattern_painter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showTheme22Details(BuildContext context, ThemeOption theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: theme.accentColor.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.85),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.accentColor, width: 2),
                        ),
                        child: Icon(theme.icon, color: theme.accentColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor,
                              ),
                            ),
                            Text(
                              theme.badgeHonor,
                              style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    theme.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.accentColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      theme.historicalStory,
                      style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 10),
                  _buildThemeDetailRow(Icons.mosque_rounded, "المعلم والصرح التاريخي", theme.landmarkName, theme.accentColor),
                  _buildThemeDetailRow(Icons.fingerprint_rounded, "خامة خرزات السبحة", theme.beadMaterialName, theme.accentColor),
                  _buildThemeDetailRow(Icons.spa_rounded, "الزخرفة الإسلامية الحصرية", theme.motifName, theme.accentColor),
                  _buildThemeDetailRow(Icons.air_rounded, "أجواء الجسيمات الطافية بالسماء", theme.particleType.toString().split('.').last, theme.accentColor),
                  _buildThemeDetailRow(Icons.hearing_rounded, "نبرة الأذان والترتيل", theme.soundAmbienceName, theme.accentColor),
                  _buildThemeDetailRow(Icons.chat_bubble_outline_rounded, "رسالة الترحيب الروحية", theme.spiritualGreeting, theme.accentColor),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<SettingsProvider>(context, listen: false).setTheme(theme.key);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: theme.cardColor,
                          behavior: SnackBarBehavior.floating,
                          content: Text("تم تفعيل ثيم ${theme.name} بنجاح ✨"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("تفعيل هذا الثيم والعيش في أجوائه الآن", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeDetailRow(IconData icon, String label, String value, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: accentColor.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final accentColor = themeOption.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات والتخصيص"),
      ),
      body: AnimatedIslamicBackground(
        accentColor: accentColor,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 95),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. المظهر والألوان الإسلامية (12 ثيم إسلامي فاخر)
            _buildSectionHeader("المظهر والألوان الإسلامية (12 نمطاً)", accentColor),
            _buildCard([
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "اختر طابعك الروحي المفضل من العصور والمدن الإسلامية:",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ...IslamicTheme.allThemes.map((theme) {
                      final isSelected = settings.selectedTheme == theme.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => settings.setTheme(theme.key),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.accentColor.withOpacity(0.18)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? theme.accentColor : Colors.white12,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.accentColor, width: 2),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: theme.accentColor.withOpacity(0.4),
                                              blurRadius: 10,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Icon(theme.icon, color: theme.accentColor, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        theme.name,
                                        style: TextStyle(
                                          color: isSelected ? theme.accentColor : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        theme.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.info_outline_rounded, color: isSelected ? theme.accentColor : Colors.white38, size: 18),
                                  tooltip: "معاينة خصائص وأجواء الثيم الـ 22",
                                  onPressed: () => _showTheme22Details(context, theme),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: theme.accentColor, size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ]),

            // 2. تحديد الموقع الجغرافي
            _buildSectionHeader("الموقع الجغرافي والمدينة", accentColor),
            _buildCard([
              SwitchListTile(
                title: const Text("تحديد الموقع التلقائي (GPS)", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  settings.cityName,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                value: settings.isAutoLocation,
                activeTrackColor: accentColor,
                onChanged: (val) async {
                  if (val) {
                    await settings.refreshCurrentLocation();
                  } else {
                    final makkah = LocationService.presetCities[0];
                    settings.setManualLocation(makkah.latitude, makkah.longitude, makkah.name);
                  }
                },
              ),
              if (!settings.isAutoLocation) ...[
                const Divider(color: Colors.white12),
                ListTile(
                  title: const Text("اختر مدينة من القائمة", style: TextStyle(color: Colors.white, fontSize: 14)),
                  trailing: DropdownButton<CityPreset>(
                    dropdownColor: const Color(0xFF09231B),
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: accentColor),
                    hint: Text(
                      settings.cityName,
                      style: TextStyle(color: accentColor, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: LocationService.presetCities.map((city) {
                      return DropdownMenuItem<CityPreset>(
                        value: city,
                        child: Text(
                          city.name,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (CityPreset? selected) {
                      if (selected != null) {
                        settings.setManualLocation(selected.latitude, selected.longitude, selected.name);
                      }
                    },
                  ),
                ),
              ],
            ]),

            // 3. الحساب الفلكي والمذهب
            _buildSectionHeader("طريقة الحساب الفلكي والمذهب", accentColor),
            _buildCard([
              _buildDropdownTile<CalculationMethod>(
                title: "طريقة الحساب",
                value: settings.calculationMethod,
                accentColor: accentColor,
                items: const [
                  DropdownMenuItem(value: CalculationMethod.umm_al_qura, child: Text("أم القرى (مكة المكرمة)")),
                  DropdownMenuItem(value: CalculationMethod.egyptian, child: Text("الهيئة المصرية العامة للمساحة")),
                  DropdownMenuItem(value: CalculationMethod.muslim_world_league, child: Text("رابطة العالم الإسلامي")),
                  DropdownMenuItem(value: CalculationMethod.karachi, child: Text("جامعة العلوم بكراتشي")),
                  DropdownMenuItem(value: CalculationMethod.dubai, child: Text("دائرة الشؤون الإسلامية بدبي")),
                  DropdownMenuItem(value: CalculationMethod.qatar, child: Text("وزارة الأوقاف بقطر")),
                  DropdownMenuItem(value: CalculationMethod.kuwait, child: Text("وزارة الأوقاف بالكويت")),
                  DropdownMenuItem(value: CalculationMethod.north_america, child: Text("أمريكا الشمالية (ISNA)")),
                ],
                onChanged: (val) => val != null ? settings.setCalculationMethod(val) : null,
              ),
              const Divider(color: Colors.white12),
              _buildDropdownTile<Madhab>(
                title: "حساب وقت صلاة العصر",
                value: settings.madhab,
                accentColor: accentColor,
                items: const [
                  DropdownMenuItem(value: Madhab.shafi, child: Text("الجمهور (شافعي، مالكي، حنبلي)")),
                  DropdownMenuItem(value: Madhab.hanafi, child: Text("المذهب الحنفي (ظل المثلين)")),
                ],
                onChanged: (val) => val != null ? settings.setMadhab(val) : null,
              ),
            ]),

            // 4. صوت الأذان والتنبيه
            _buildSectionHeader("صوت الأذان والتنبيهات", accentColor),
            _buildCard([
              _buildDropdownTile<String>(
                title: "صوت المؤذن",
                value: settings.adhanVoice,
                accentColor: accentColor,
                items: const [
                  DropdownMenuItem(value: "madinah", child: Text("أذان الحرم النبوي المدني")),
                  DropdownMenuItem(value: "makkah", child: Text("أذان المسجد الحرام بمكة")),
                  DropdownMenuItem(value: "aqsa", child: Text("أذان المسجد الأقصى المبارك")),
                  DropdownMenuItem(value: "cairo", child: Text("أذان مساجد القاهرة")),
                ],
                onChanged: (val) => val != null ? settings.setAdhanVoice(val) : null,
              ),
              const Divider(color: Colors.white12),
              SwitchListTile(
                title: const Text("تنبيه ما قبل الأذان (15 دقيقة)", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text("للاستعداد وإسباغ الوضوء قبل دخول الوقت", style: TextStyle(color: Colors.white54, fontSize: 12)),
                value: settings.playPreAdhanReminder,
                activeTrackColor: accentColor,
                onChanged: (val) => settings.setPreAdhanReminder(val),
              ),
              const Divider(color: Colors.white12),
              SwitchListTile(
                title: const Text("الصامت التلقائي أثناء إقامة الصلاة", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text("كتم رنين الهاتف لمدة 30 دقيقة بعد كل أذان", style: TextStyle(color: Colors.white54, fontSize: 12)),
                value: settings.autoMuteDuringPrayer,
                activeTrackColor: accentColor,
                onChanged: (val) => settings.setAutoMute(val),
              ),
            ]),

            // 5. ضبط يدوي لمواقيت الصلاة بالدقائق
            _buildSectionHeader("ضبط يدوي لمواقيت الصلاة (بالدقائق)", accentColor),
            _buildCard([
              _buildOffsetSlider(settings, "الفجر", 'fajr', accentColor),
              _buildOffsetSlider(settings, "الظهر", 'dhuhr', accentColor),
              _buildOffsetSlider(settings, "العصر", 'asr', accentColor),
              _buildOffsetSlider(settings, "المغرب", 'maghrib', accentColor),
              _buildOffsetSlider(settings, "العشاء", 'isha', accentColor),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8, right: 6),
      child: Text(
        title,
        style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09231B).withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required T value,
    required Color accentColor,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: DropdownButton<T>(
              dropdownColor: const Color(0xFF09231B),
              value: value,
              isExpanded: false,
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down, color: accentColor),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetSlider(
    SettingsProvider settings,
    String prayerName,
    String key,
    Color accentColor,
  ) {
    final int currentOffset = settings.offsets[key] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              prayerName,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Slider(
              value: currentOffset.toDouble(),
              min: -15,
              max: 15,
              divisions: 30,
              activeColor: accentColor,
              inactiveColor: Colors.white12,
              onChanged: (val) {
                settings.updateOffset(key, val.round());
              },
            ),
          ),
          SizedBox(
            width: 48,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "${currentOffset > 0 ? '+' : ''}$currentOffset د",
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
