import 'package:flutter/material.dart';

import '../services/location_service.dart';
import 'calm_ui.dart';

/// Shared city chooser used when location permission is denied or detection fails.
class ManualCityPicker {
  const ManualCityPicker._();

  static Future<CityPreset?> show(
    BuildContext context, {
    String? selectedCityName,
  }) {
    var query = '';
    return showModalBottomSheet<CityPreset>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final cities = LocationService.presetCities.where((city) {
            return query.isEmpty || city.name.contains(query);
          }).toList(growable: false);
          final scheme = Theme.of(context).colorScheme;

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اختيار المدينة',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      autofocus: false,
                      textDirection: TextDirection.rtl,
                      onChanged: (value) =>
                          setSheetState(() => query = value.trim()),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'ابحث باسم المدينة أو البلد',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: cities.isEmpty
                          ? const CalmEmptyState(
                              icon: Icons.location_city_outlined,
                              title: 'لا توجد مدينة بهذا الاسم',
                              subtitle: 'جرّب كتابة اسم أقصر أو امسح البحث.',
                            )
                          : ListView.separated(
                              itemCount: cities.length,
                              separatorBuilder: (_, __) => const CalmDivider(),
                              itemBuilder: (context, index) {
                                final city = cities[index];
                                final selected = city.name == selectedCityName;
                                return ListTile(
                                  leading: const CalmIconBadge(
                                    Icons.location_city_rounded,
                                  ),
                                  title: Text(city.name),
                                  trailing: selected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: scheme.primary,
                                        )
                                      : Icon(
                                          Icons.chevron_left_rounded,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  onTap: () => Navigator.of(sheetContext)
                                      .pop<CityPreset>(city),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
