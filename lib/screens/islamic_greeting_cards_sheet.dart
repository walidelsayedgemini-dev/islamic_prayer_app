import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/islamic_theme.dart';
import '../widgets/paradise_ui.dart';

class IslamicGreetingCard {
  final String id;
  final String occasion;
  final String title;
  final String message;
  final String hadithOrDua;
  final IconData icon;

  const IslamicGreetingCard({
    required this.id,
    required this.occasion,
    required this.title,
    required this.message,
    required this.hadithOrDua,
    required this.icon,
  });
}

class IslamicGreetingCardsSheet extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;

  const IslamicGreetingCardsSheet({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
  });

  @override
  State<IslamicGreetingCardsSheet> createState() =>
      _IslamicGreetingCardsSheetState();
}

class _IslamicGreetingCardsSheetState extends State<IslamicGreetingCardsSheet> {
  int _selectedCardIndex = 0;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<IslamicGreetingCard> cards = [
    IslamicGreetingCard(
      id: 'jumuah_mubarak',
      occasion: 'يوم الجمعة المبارك',
      title: 'طابت جمعتكم بنور سورة الكهف',
      message:
          'اللهم في يوم الجمعة، عطر قلوبنا بالإيمان، واشرح صدورنا بالقرآن، وارزقنا شفاعة نبيك العدنان ﷺ.',
      hadithOrDua:
          '«من قرأ سورة الكهف في يوم الجمعة أضاء له من النور ما بين الجمعتين» (رواه الحاكم).',
      icon: Icons.mosque_rounded,
    ),
    IslamicGreetingCard(
      id: 'ramadan_kareem',
      occasion: 'شهر رمضان المبارك',
      title: 'مبارك عليكم الشهر الفضيل',
      message:
          'أعاده الله علينا وعليكم باليمن والإيمان والسلامة والإسلام، وتقبل منا ومنكم صالح الصيام والقيام.',
      hadithOrDua: '«من صام رمضان إيماناً واحتساباً غُفر له ما تقدم من ذنبه» (متفق عليه).',
      icon: Icons.nightlight_round,
    ),
    IslamicGreetingCard(
      id: 'eid_fitr',
      occasion: 'عيد الفطر السعيد',
      title: 'تقبل الله طاعتكم وعيدكم مبارك',
      message:
          'جعل الله عيدكم فرحاً وسروراً، وغفراناً لكل ذنب، وجمعنا وإياكم في جنات النعيم.',
      hadithOrDua: '«تقبل الله منا ومنكم صالح الأعمال والطاعات».',
      icon: Icons.celebration_rounded,
    ),
    IslamicGreetingCard(
      id: 'eid_adha',
      occasion: 'عيد الأضحى ويوم عرفة',
      title: 'لبيك اللهم لبيك • عيد أضحى مبارك',
      message:
          'رزقكم الله حج بيته الحرام، وغفر لكم يوم عرفة، وبارك في أضاحيكم ودعواتكم.',
      hadithOrDua:
          '«خير الدعاء دعاء يوم عرفة، وخير ما قلت أنا والنبيون من قبلي: لا إله إلا الله وحده لا شريك له».',
      icon: Icons.landscape_rounded,
    ),
    IslamicGreetingCard(
      id: 'morning_blessing',
      occasion: 'صباح الخير والبركة',
      title: 'صباح يشرق بنور الإيمان',
      message:
          'أصبحنا وأصبح الملك لله والحمد لله، ربي أسألك خير هذا اليوم وخير ما بعده وأعوذ بك من شره.',
      hadithOrDua: '«اللهم بك أصبحنا، وبك أمسينا، وبك نحيا، وبك نموت، وإليك النشور».',
      icon: Icons.wb_sunny_rounded,
    ),
    IslamicGreetingCard(
      id: 'dua_healing',
      occasion: 'دعاء الشفاء وعيادة المريض',
      title: 'شفاك الله وعافاك طهور إن شاء الله',
      message:
          'أسأل الله العظيم رب العرش العظيم أن يشفيك شفاءً لا يغادر سقماً، ويلبسك ثوب الصحة والعافية.',
      hadithOrDua: '«أذهب الباس رب الناس، واشف أنت الشافي، لا شفاء إلا شفاؤك» (متفق عليه).',
      icon: Icons.healing_rounded,
    ),
  ];

  List<int> get _visibleCardIndices {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return List<int>.generate(cards.length, (index) => index);
    return List<int>.generate(cards.length, (index) => index).where((index) {
      final card = cards[index];
      return card.occasion.toLowerCase().contains(query) ||
          card.title.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCard(int index) {
    setState(() => _selectedCardIndex = index);
  }

  void _copySelectedCard(ThemePalette palette) {
    final selectedCard = cards[_selectedCardIndex];
    final textToCopy =
        '${selectedCard.title}\n\n${selectedCard.message}\n\n${selectedCard.hadithOrDua}';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ كرت ${selectedCard.occasion} بنجاح!',
          style: TextStyle(color: palette.textPrimary),
        ),
        backgroundColor: palette.cardColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;
    final selectedCard = cards[_selectedCardIndex];
    final media = MediaQuery.of(context);
    final sheetHeight = (media.size.height - media.viewInsets.bottom) * .92;
    final scene = FirdawsParadiseRegistry.imageFor(widget.themeOption.key);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1120,
          maxHeight: sheetHeight,
        ),
        child: SizedBox(
          width: double.infinity,
          height: sheetHeight,
          child: Material(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            clipBehavior: Clip.antiAlias,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.dividerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 4, 12, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: palette.elevatedCardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: accent.withOpacity(.34),
                              ),
                            ),
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              color: accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'بطاقات التهنئة',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'اختر مناسبة، راجع النص، ثم انسخه للمشاركة.',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'إغلاق بطاقات التهنئة',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(
                              foregroundColor: palette.textPrimary,
                              backgroundColor: palette.elevatedCardColor,
                              minimumSize: const Size(44, 44),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 14),
                      child: ParadiseHero(
                        title: 'كلمة طيبة في وقتها',
                        subtitle:
                            'تصفّح الرسائل الجاهزة، واختر ما يناسب مناسبتك.',
                        imageAsset: scene,
                        minHeight: 184,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 720) {
                            final selectorWidth =
                                (constraints.maxWidth * .32).clamp(280.0, 340.0);
                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 4, 20, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: selectorWidth,
                                    child: _buildWideSelector(palette, accent),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildPreview(
                                      selectedCard,
                                      palette,
                                      accent,
                                      showSectionTitle: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SingleChildScrollView(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                18, 4, 18, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildCompactSelector(palette, accent),
                                const SizedBox(height: 20),
                                _buildPreview(
                                  selectedCard,
                                  palette,
                                  accent,
                                  showSectionTitle: true,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 14),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _copySelectedCard(palette),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: palette.onAccentColor,
                            minimumSize: const Size.fromHeight(58),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.copy_rounded, size: 20),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'انسخ نص البطاقة للمشاركة',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.25,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemePalette palette) {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      onChanged: (value) => setState(() => _query = value),
      style: TextStyle(color: palette.textPrimary, height: 1.35),
      decoration: InputDecoration(
        hintText: 'ابحث عن مناسبة أو عنوان',
        hintStyle: TextStyle(color: palette.textMuted),
        prefixIcon: Icon(Icons.search_rounded, color: palette.textSecondary),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'مسح البحث',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: Icon(Icons.close_rounded, color: palette.textSecondary),
              ),
        filled: true,
        fillColor: palette.cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.accentColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCompactSelector(ThemePalette palette, Color accent) {
    final visible = _visibleCardIndices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ParadiseSection(
          title: 'اختر المناسبة',
          action: _countBadge(palette, visible.length),
          child: _buildSearchField(palette),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          _buildEmptySearch(palette)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final index in visible)
                ParadiseChip(
                  label: cards[index].occasion,
                  icon: cards[index].icon,
                  selected: index == _selectedCardIndex,
                  onTap: () => _selectCard(index),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildWideSelector(ThemePalette palette, Color accent) {
    final visible = _visibleCardIndices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ParadiseSection(
          title: 'اختر المناسبة',
          action: _countBadge(palette, visible.length),
          child: _buildSearchField(palette),
        ),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          Expanded(child: Center(child: _buildEmptySearch(palette)))
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.only(bottom: 8),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, position) {
                final index = visible[position];
                final card = cards[index];
                final selected = index == _selectedCardIndex;
                return Material(
                  color: selected
                      ? palette.elevatedCardColor
                      : palette.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => _selectCard(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? accent : palette.dividerColor,
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: selected
                                  ? palette.cardColor
                                  : palette.elevatedCardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(card.icon, color: accent, size: 21),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              card.occasion,
                              softWrap: true,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 7),
                            Icon(Icons.check_circle_rounded,
                                color: accent, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _countBadge(ThemePalette palette, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$count من ${cards.length}',
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptySearch(ThemePalette palette) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: palette.textSecondary, size: 27),
          const SizedBox(height: 8),
          Text(
            'لا توجد مناسبة بهذا الاسم. جرّب كلمة أخرى.',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
            },
            child: const Text('عرض كل المناسبات'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
    IslamicGreetingCard card,
    ThemePalette palette,
    Color accent, {
    required bool showSectionTitle,
  }) {
    final cardIndex = cards.indexOf(card) + 1;
    final preview = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .12 : .045),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withOpacity(.3)),
                ),
                child: Icon(card.icon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.occasion,
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'معاينة البطاقة',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cardIndex / ${cards.length}',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            card.title,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 23,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              card.message,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
                height: 1.75,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.scaffoldColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'الدعاء أو النص المرفق',
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.hadithOrDua,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!showSectionTitle) return preview;
    return ParadiseSection(
      title: 'رسالتك المختارة',
      child: preview,
    );
  }
}
