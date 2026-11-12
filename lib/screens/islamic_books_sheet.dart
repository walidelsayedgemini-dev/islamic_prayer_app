import 'package:flutter/material.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/islamic_books_catalog.dart';
import '../services/offline_content_download_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/sacred_reference_widgets.dart';

class IslamicBooksSheet extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;

  const IslamicBooksSheet({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
  });

  @override
  State<IslamicBooksSheet> createState() => _IslamicBooksSheetState();
}

class _IslamicBooksSheetState extends State<IslamicBooksSheet> {
  BookCategory _selectedCategory = BookCategory.all;
  String _searchQuery = '';
  int _selectedBookIndex = 0;
  bool _batchDownloading = false;

  final _downloads = OfflineContentDownloadService.instance;

  @override
  void initState() {
    super.initState();
    _downloads.init();
    _downloads.addListener(_onDownloadChange);
  }

  @override
  void dispose() {
    _downloads.removeListener(_onDownloadChange);
    super.dispose();
  }

  void _onDownloadChange() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleBookDownload(IslamicLibraryBook book) async {
    if (_downloads.isDownloaded(book.id)) {
      await _downloads.removeDownload(book.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إزالة «${book.title}» من التخزين المحلي لتوفير المساحة'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final ok = await _downloads.downloadContent(
        id: book.id,
        offlineBundleJson: book.toOfflineJson(),
        remoteVerificationUrl: book.sourceReferenceUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'تم تحميل «${book.title}» للعمل بدون إنترنت بنجاح ✅📥'
                : 'تعذر التحميل حالياً، يرجى المحاولة لاحقاً',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _downloadAllBooks() async {
    if (_batchDownloading) return;
    setState(() => _batchDownloading = true);
    try {
      for (final book in IslamicBooksCatalog.allBooks) {
        if (!_downloads.isDownloaded(book.id)) {
          await _downloads.downloadContent(
            id: book.id,
            offlineBundleJson: book.toOfflineJson(),
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحميل جميع كتب المكتبة المعتمدة للقراءة بدون إنترنت 📚✅'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _batchDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;

    final filteredBooks = IslamicBooksCatalog.filter(
      category: _selectedCategory,
      query: _searchQuery,
    );
    final safeIdx = filteredBooks.isEmpty
        ? 0
        : _selectedBookIndex.clamp(0, filteredBooks.length - 1);
    final activeBook = filteredBooks.isEmpty ? null : filteredBooks[safeIdx];
    final int downloadedBooksCount = IslamicBooksCatalog.allBooks
        .where((b) => _downloads.isDownloaded(b.id))
        .length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: palette.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: palette.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Firdaws4KCardShell(
              backdrop: Background500Catalog.forExtraSection(38),
              isDark: palette.isDark,
              borderRadius: 18,
              borderColor: accent.withOpacity(0.45),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              imageOpacity: 0.45,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent),
                    ),
                    child: Icon(Icons.auto_stories_rounded, color: accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "المكتبة الموثقة • الأزهر وكبار العلماء 🕌",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${IslamicBooksCatalog.allBooks.length} كتاباً معتمداً • محمّل بدون نت: $downloadedBooksCount 📥",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _batchDownloading ? null : _downloadAllBooks,
                    icon: _batchDownloading
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : Icon(Icons.download_for_offline_rounded, size: 17, color: accent),
                    label: Text(
                      'الكل',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: palette.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),

          // بحث في الكتب
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              style: TextStyle(color: palette.textPrimary, fontSize: 13),
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _selectedBookIndex = 0;
              }),
              decoration: InputDecoration(
                hintText: 'ابحث عن كتاب، تفسير، فقه، سيرة، أو مؤلف...',
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

          // تصنيفات الكتب
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                for (final cat in BookCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(
                        cat.label,
                        style: TextStyle(
                          color: _selectedCategory == cat
                              ? palette.onAccentColor
                              : palette.textPrimary,
                          fontWeight: _selectedCategory == cat
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 11.5,
                        ),
                      ),
                      selected: _selectedCategory == cat,
                      selectedColor: accent,
                      backgroundColor: palette.cardColor,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = cat;
                            _selectedBookIndex = 0;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // شريط الكتب المفلترة
          if (filteredBooks.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: filteredBooks.length,
                itemBuilder: (context, idx) {
                  final b = filteredBooks[idx];
                  final isSel = idx == safeIdx;
                  final isOff = _downloads.isDownloaded(b.id);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${b.emoji} ${b.title}${isOff ? " ✅" : ""}',
                        style: TextStyle(
                          color: isSel ? palette.onAccentColor : palette.textPrimary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: accent,
                      backgroundColor: palette.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: isSel ? accent : palette.dividerColor),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedBookIndex = idx);
                      },
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: activeBook == null
                ? Center(
                    child: Text(
                      'لا توجد نتائج مطابقة للبحث في المكتبة 📖',
                      style: TextStyle(color: palette.textMuted, fontSize: 13),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      // بطاقة تعريف الكتاب + زر التحميل للعمل بدون نت
                      Firdaws4KCardShell(
                        backdrop: Background500Catalog.forExtraSection(37),
                        isDark: palette.isDark,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        borderRadius: 18,
                        borderColor: accent.withOpacity(0.55),
                        imageOpacity: 0.42,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(activeBook.emoji, style: const TextStyle(fontSize: 26)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeBook.title,
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        activeBook.author,
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: accent.withOpacity(0.45)),
                              ),
                              child: Text(
                                '🛡️ ${activeBook.accreditation}',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activeBook.summary,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _downloads.isDownloading(activeBook.id)
                                        ? null
                                        : () => _toggleBookDownload(activeBook),
                                    icon: _downloads.isDownloading(activeBook.id)
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            _downloads.isDownloaded(activeBook.id)
                                                ? Icons.offline_pin_rounded
                                                : Icons.download_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      _downloads.isDownloaded(activeBook.id)
                                          ? 'محمّل بدون نت ✓ (${OfflineContentDownloadService.formatBytes(_downloads.downloadedSizeBytes(activeBook.id))}) • حذف'
                                          : 'تحميل للقراءة بدون نت 📥',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _downloads.isDownloaded(activeBook.id)
                                          ? const Color(0xFF059669)
                                          : accent,
                                      foregroundColor: _downloads.isDownloaded(activeBook.id)
                                          ? Colors.white
                                          : palette.onAccentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // الفصول والنصوص الموثقة مع ربط المصحف وصحيح البخاري
                      for (int idx = 0; idx < activeBook.chapters.length; idx++)
                        _buildChapterCard(
                          activeBook.chapters[idx],
                          idx,
                          palette,
                          accent,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(
    IslamicBookChapter ch,
    int idx,
    ThemePalette palette,
    Color accent,
  ) {
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(39 + (idx % 20)),
      isDark: palette.isDark,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      borderColor: accent.withOpacity(0.45),
      imageOpacity: palette.isDark ? 0.45 : 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.2),
                  border: Border.all(color: accent),
                ),
                child: Center(
                  child: Text(
                    "${ch.number}",
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ch.title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Firdaws4KCardShell(
            backdrop: Background500Catalog.forExtraSection(50 + (idx % 20)),
            isDark: palette.isDark,
            padding: const EdgeInsets.all(12),
            borderRadius: 12,
            borderColor: palette.dividerColor,
            imageOpacity: 0.30,
            child: Text(
              ch.contentArabic,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                height: 1.65,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "💡 الشرح والفوائد: ${ch.explanation}",
            style: TextStyle(
              color: palette.isDark ? const Color(0xFFE2E8F0) : palette.primaryColor,
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '📜 ${ch.narrator}',
            style: TextStyle(color: palette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (ch.quranSurah != null)
                QuranRefBadge(
                  surahNumber: ch.quranSurah!,
                  ayahNumber: ch.quranAyah ?? 1,
                  accentColor: accent,
                ),
              if (ch.hadithId != null)
                HadithRefBadge(
                  referenceText: ch.hadithId!,
                  accentColor: accent,
                  trackInJannati: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
