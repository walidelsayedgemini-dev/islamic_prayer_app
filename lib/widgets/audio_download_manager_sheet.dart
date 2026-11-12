import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/islamic_audio_data.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_resilient_image.dart';

void showAudioDownloadManagerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _AudioDownloadManagerSheet(),
  );
}

class _AudioDownloadManagerSheet extends StatefulWidget {
  const _AudioDownloadManagerSheet();

  @override
  State<_AudioDownloadManagerSheet> createState() =>
      _AudioDownloadManagerSheetState();
}

class _AudioDownloadManagerSheetState extends State<_AudioDownloadManagerSheet> {
  String _tab = 'quran'; // quran, ruqyah, ibtihalat
  String _search = '';
  int _cacheBytes = 0;

  @override
  void initState() {
    super.initState();
    _refreshSize();
  }

  Future<void> _refreshSize() async {
    final player = Provider.of<AudioPlayerProvider>(context, listen: false);
    final bytes = await player.getOfflineCacheBytes();
    if (mounted) {
      setState(() => _cacheBytes = bytes);
    }
  }

  String _formatMb(int bytes) {
    if (bytes <= 0) return '0.0 MB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final player = Provider.of<AudioPlayerProvider>(context);
    final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOpt.resolve(isNight: settings.isNightEffective);
    final accent = palette.accentColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: palette.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: accent, width: 1.8)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: palette.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(themeOpt.primaryEmoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مركز التحميل بدون إنترنت ⬇️',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'حمّل فقط السور والمقاطع التي تريدها لحفظ مساحة جهازك (${_formatMb(_cacheBytes)}) ✨',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          if (!player.supportsOfflineDownload)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(3),
                isDark: palette.isDark,
                borderColor: accent.withOpacity(0.45),
                borderRadius: 16,
                borderWidth: 1.0,
                padding: const EdgeInsets.all(14),
                imageOpacity: 0.36,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'ميزة تنزيل السور على الهاتف متاحة داخل تطبيق الأندرويد؛ وعلى الويب يتم البث المباشر الفوري.',
                    style: TextStyle(color: palette.textPrimary, fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else ...[
            // شريط التحميل الجماعي النشط
            if (player.isBatchDownloading)
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(4),
                isDark: palette.isDark,
                borderColor: accent,
                borderRadius: 16,
                borderWidth: 1.2,
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                padding: const EdgeInsets.all(12),
                imageOpacity: 0.38,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'جاري تنزيل سورة #${player.batchCurrentSurah ?? ""} (${player.batchCompleted}/${player.batchTotal})...',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: player.cancelBatchDownload,
                          child: const Text(
                            'إيقاف',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: player.batchTotal > 0
                          ? (player.batchCompleted / player.batchTotal)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      color: accent,
                      backgroundColor: palette.dividerColor,
                    ),
                  ],
                ),
              ),

            // أزرار التنزيل السريع وإدارة المساحة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: player.isBatchDownloading
                          ? null
                          : () async {
                              await player.downloadJuz30();
                              await _refreshSize();
                            },
                      icon: const Icon(Icons.download_for_offline_rounded, size: 17),
                      label: const Text(
                        'تحميل جزء عم (٣٧ سورة) ⬇️',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: palette.onAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _cacheBytes <= 0
                        ? null
                        : () async {
                            await player.clearAllOfflineCache();
                            await _refreshSize();
                          },
                    icon: const Icon(Icons.delete_sweep_rounded, size: 17),
                    label: Text(
                      'مسح الكل',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: palette.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // التبويبات: قرآن / رقية / ابتهالات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _buildTabChip('quran', 'القرآن (١١٤) 📖', palette, accent),
                  const SizedBox(width: 6),
                  _buildTabChip('ruqyah', 'الرقية (٦) 🛡️', palette, accent),
                  const SizedBox(width: 6),
                  _buildTabChip('ibtihalat', 'الابتهالات (٦) 🕌', palette, accent),
                ],
              ),
            ),

            if (_tab == 'quran') ...[
              // شريط القارئ والبحث
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: IslamicAudioLibrary.reciters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, idx) {
                    final rec = IslamicAudioLibrary.reciters[idx];
                    final sel = player.selectedReciter.id == rec.id;
                    return ChoiceChip(
                      label: Text(
                        rec.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? palette.onAccentColor : palette.textPrimary,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: sel,
                      selectedColor: accent,
                      backgroundColor: palette.cardColor,
                      onSelected: (_) => player.selectReciter(rec),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  onChanged: (v) => setState(() => _search = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم السورة للتحميل السريع...',
                    hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded, color: accent),
                    isDense: true,
                    filled: true,
                    fillColor: palette.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: palette.dividerColor),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Expanded(
              child: _buildList(player, palette, accent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabChip(
    String key,
    String label,
    ThemePalette palette,
    Color accent,
  ) {
    final sel = _tab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? accent : palette.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? accent : palette.dividerColor,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sel ? palette.onAccentColor : palette.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    AudioPlayerProvider player,
    ThemePalette palette,
    Color accent,
  ) {
    if (_tab == 'quran') {
      final surahs = IslamicAudioLibrary.allSurahs
          .where((s) => _search.isEmpty || s.nameArabic.contains(_search))
          .toList();
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
        itemCount: surahs.length,
        itemBuilder: (_, idx) {
          final s = surahs[idx];
          final recId = player.selectedReciter.id;
          final key = IslamicAudioLibrary.surahCacheKey(recId, s.number);
          final isBundled = IslamicAudioLibrary.getBundledSurahAsset(recId, s.number) != null;
          final isDownloaded = player.isTrackDownloaded(key);
          final progress = player.downloadProgressFor(key);

          return Firdaws4KCardShell(
            backdrop: Background500Catalog.forExtraSection(s.number),
            isDark: palette.isDark,
            borderColor: (isBundled || isDownloaded)
                ? accent.withOpacity(0.55)
                : palette.dividerColor,
            borderRadius: 14,
            borderWidth: 1.0,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            imageOpacity: (isBundled || isDownloaded) ? 0.36 : 0.25,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: accent.withOpacity(0.16),
                  child: Text(
                    '${s.number}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سورة ${s.nameArabic}',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isBundled
                            ? 'مدمجة أوفلاين ✅ • ${s.defaultDuration}'
                            : isDownloaded
                                ? 'محمّلة على الجهاز ✅ • ${s.defaultDuration}'
                                : '${s.versesCount} آية • بث مباشر أو تحميل • ${s.defaultDuration}',
                        style: TextStyle(
                          color: (isBundled || isDownloaded)
                              ? accent
                              : palette.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow_rounded, color: accent),
                  onPressed: () => player.playSurah(s),
                ),
                if (!isBundled)
                  if (progress != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2.4,
                          color: accent,
                        ),
                      ),
                    )
                  else if (isDownloaded)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      tooltip: 'حذف لتوفير مساحة',
                      onPressed: () async {
                        await player.deleteCachedTrack(key);
                        await _refreshSize();
                      },
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        await player.downloadTrackForOffline(
                          key,
                          IslamicAudioLibrary.getSurahUrl(recId, s.number),
                        );
                        await _refreshSize();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent.withOpacity(0.16),
                        foregroundColor: accent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'تحميل ⬇️',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
              ],
            ),
          );
        },
      );
    }

    if (_tab == 'ruqyah') {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
        itemCount: IslamicAudioLibrary.allRuqyah.length,
        itemBuilder: (_, idx) {
          final r = IslamicAudioLibrary.allRuqyah[idx];
          return _buildMiscDownloadCard(
            id: r.id,
            title: r.title,
            subtitle: '${r.reciter} • ${r.duration}',
            url: r.streamUrl,
            onPlay: () => player.playRuqyah(r),
            player: player,
            palette: palette,
            accent: accent,
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
      itemCount: IslamicAudioLibrary.allIbtihalat.length,
      itemBuilder: (_, idx) {
        final ib = IslamicAudioLibrary.allIbtihalat[idx];
        return _buildMiscDownloadCard(
          id: ib.id,
          title: ib.title,
          subtitle: '${ib.reciter} • ${ib.duration}',
          url: ib.streamUrl,
          onPlay: () => player.playIbtihal(ib),
          player: player,
          palette: palette,
          accent: accent,
        );
      },
    );
  }

  Widget _buildMiscDownloadCard({
    required String id,
    required String title,
    required String subtitle,
    required String url,
    required VoidCallback onPlay,
    required AudioPlayerProvider player,
    required ThemePalette palette,
    required Color accent,
  }) {
    final downloaded = player.isTrackDownloaded(id);
    final progress = player.downloadProgressFor(id);

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(
        10 + (id.hashCode.abs() % 30),
      ),
      isDark: palette.isDark,
      borderColor: downloaded ? accent.withOpacity(0.55) : palette.dividerColor,
      borderRadius: 16,
      borderWidth: 1.0,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      imageOpacity: downloaded ? 0.38 : 0.28,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.play_circle_fill_rounded, color: accent, size: 30),
            onPressed: onPlay,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  downloaded ? 'محمّلة بدون إنترنت ✅ • $subtitle' : subtitle,
                  style: TextStyle(
                    color: downloaded ? accent : palette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (progress != null)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.4,
                color: accent,
              ),
            )
          else if (downloaded)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () async {
                await player.deleteCachedTrack(id);
                await _refreshSize();
              },
            )
          else
            ElevatedButton(
              onPressed: () async {
                await player.downloadTrackForOffline(id, url);
                await _refreshSize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent.withOpacity(0.16),
                foregroundColor: accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'تحميل ⬇️',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
