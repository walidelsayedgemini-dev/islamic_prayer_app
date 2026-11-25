import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/calm_ui.dart';

/// تصدير واستعادة كل بيانات التطبيق المحفوظة محليًا كنص JSON.
class BackupService {
  static const int version = 1;

  static Future<String> exportAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is bool) {
        data[key] = {'t': 'b', 'v': value};
      } else if (value is int) {
        data[key] = {'t': 'i', 'v': value};
      } else if (value is double) {
        data[key] = {'t': 'd', 'v': value};
      } else if (value is String) {
        data[key] = {'t': 's', 'v': value};
      } else if (value is List) {
        data[key] = {'t': 'l', 'v': value.map((e) => e.toString()).toList()};
      }
    }
    return jsonEncode({
      'app': 'firdaws',
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  /// يُرجع عدد العناصر المستعادة، أو يرمي FormatException عند نص غير صالح.
  static Future<int> importAll(String raw) async {
    final decoded = jsonDecode(raw.trim());
    if (decoded is! Map ||
        decoded['app'] != 'firdaws' ||
        decoded['data'] is! Map) {
      throw const FormatException('ليست نسخة احتياطية من الفردوس');
    }
    final prefs = await SharedPreferences.getInstance();
    var restored = 0;
    for (final entry in (decoded['data'] as Map).entries) {
      final item = entry.value;
      if (entry.key is! String || item is! Map) continue;
      final key = entry.key as String;
      final v = item['v'];
      switch (item['t']) {
        case 'b':
          if (v is bool) {
            await prefs.setBool(key, v);
            restored++;
          }
        case 'i':
          if (v is int) {
            await prefs.setInt(key, v);
            restored++;
          }
        case 'd':
          if (v is num) {
            await prefs.setDouble(key, v.toDouble());
            restored++;
          }
        case 's':
          if (v is String) {
            await prefs.setString(key, v);
            restored++;
          }
        case 'l':
          if (v is List) {
            await prefs.setStringList(key, v.map((e) => '$e').toList());
            restored++;
          }
      }
    }
    return restored;
  }
}

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await BackupService.exportAll();
      await Clipboard.setData(ClipboardData(text: json));
      _controller.text = json;
      _snack('تم نسخ النسخة الاحتياطية. الصقها في ملاحظة أو رسالة تحتفظ بها.');
    } catch (_) {
      _snack('تعذّر إنشاء النسخة الاحتياطية.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _controller.text = data!.text!);
    }
  }

  Future<void> _import() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      _snack('الصق نص النسخة الاحتياطية أولًا.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('استعادة البيانات'),
          content: const Text(
              'ستُستبدل البيانات الحالية بما في النسخة الاحتياطية. هل تريد المتابعة؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء')),
            FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('استعادة')),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      final count = await BackupService.importAll(raw);
      _snack('تمت استعادة $count عنصرًا. أعد فتح التطبيق لتظهر كل البيانات.');
    } on FormatException {
      _snack('النص غير صالح: تأكد من نسخ النسخة الاحتياطية كاملة.');
    } catch (_) {
      _snack('تعذّرت الاستعادة.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CalmPage(
        title: 'النسخ الاحتياطي',
        subtitle: 'احفظ بياناتك أو انقلها إلى جهاز آخر',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CalmCard(
              child: Text(
                'بياناتك (سجل الصلاة، التقدّم، الإعدادات، العلامات المرجعية) محفوظة على هذا الجهاز فقط. '
                'صدّرها كنص وخزّنها في مكان آمن، ثم الصقها هنا لاستعادتها في أي وقت أو على جهاز آخر.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.copy_all_rounded),
              label: const Text('تصدير ونسخ إلى الحافظة'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 8,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                hintText: 'الصق هنا نص النسخة الاحتياطية للاستعادة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _paste,
                    icon: const Icon(Icons.content_paste_rounded),
                    label: const Text('لصق من الحافظة'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _import,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('استعادة'),
                    style:
                        FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
