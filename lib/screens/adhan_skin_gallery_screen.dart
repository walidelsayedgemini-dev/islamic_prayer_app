import 'package:flutter/material.dart';

import '../models/adhan_skin_catalog.dart';

class AdhanSkinGalleryScreen extends StatefulWidget {
  const AdhanSkinGalleryScreen({
    super.key,
    required this.selectedSkinId,
  });

  final String selectedSkinId;

  @override
  State<AdhanSkinGalleryScreen> createState() => _AdhanSkinGalleryScreenState();
}

class _AdhanSkinGalleryScreenState extends State<AdhanSkinGalleryScreen> {
  Future<void> _previewSkin(AdhanSkin skin) async {
    final selectedId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final isSelected = skin.id == widget.selectedSkinId;
        final imageHeight = (MediaQuery.sizeOf(dialogContext).height * 0.38)
            .clamp(190.0, 340.0)
            .toDouble();
        final scheme = Theme.of(dialogContext).colorScheme;

        return Dialog(
          backgroundColor: scheme.surface,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'معاينة الخلفية',
                            style: Theme.of(dialogContext)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق المعاينة',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: _skinImage(skin),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      skin.name,
                      style: Theme.of(dialogContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      skin.subtitle,
                      style: Theme.of(dialogContext)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withOpacity(.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volume_off_rounded,
                            color: scheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'هذه معاينة صامتة؛ لن يبدأ صوت الأذان.',
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(skin.id),
                      icon: Icon(isSelected
                          ? Icons.check_circle_outline_rounded
                          : Icons.wallpaper_rounded),
                      label: Text(isSelected
                          ? 'الخلفية المحددة'
                          : 'اختيار هذه الخلفية'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: skin.accentColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || selectedId == null) return;
    Navigator.of(context).pop(selectedId);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedSkin = AdhanSkinCatalog.byId(widget.selectedSkinId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: const Text('خلفيات الأذان'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 900
                  ? 4
                  : width >= 620
                      ? 3
                      : 2;
              final imageHeight = width >= 620 ? 205.0 : 174.0;
              final tileHeight = width >= 900
                  ? 328.0
                  : width >= 620
                      ? 302.0
                      : 274.0;

              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIntroduction(context, selectedSkin),
                        const SizedBox(height: 18),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: AdhanSkinCatalog.all.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: tileHeight,
                          ),
                          itemBuilder: (context, index) {
                            final skin = AdhanSkinCatalog.all[index];
                            return _buildSkinCard(
                              context,
                              skin,
                              imageHeight: imageHeight,
                              selected: skin.id == selectedSkin.id,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction(BuildContext context, AdhanSkin currentSkin) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر المشهد الذي يرافق منبه الأذان',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'خمسة عشر مشهداً هادئاً، ويمكنك معاينة كل خلفية قبل اعتمادها.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 96,
                    child: _skinImage(currentSkin),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخلفية الحالية',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSkin.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSkin.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded,
                    color: currentSkin.accentColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.volume_off_rounded,
                  size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'المعاينات صامتة ولا تشغّل صوت الأذان.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkinCard(
    BuildContext context,
    AdhanSkin skin, {
    required double imageHeight,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(18);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: radius,
        border: Border.all(
          color: selected ? skin.accentColor : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _previewSkin(skin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _skinImage(skin),
                      PositionedDirectional(
                        top: 9,
                        start: 9,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.48),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            selected
                                ? Icons.check_rounded
                                : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (selected)
                        PositionedDirectional(
                          bottom: 9,
                          start: 9,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: skin.accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'محددة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(11, 9, 11, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          skin.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skin.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _skinImage(AdhanSkin skin) {
    final assetKey = skin.imageAsset.startsWith('/')
        ? skin.imageAsset.substring(1)
        : skin.imageAsset;
    final scheme = Theme.of(context).colorScheme;

    return Image.asset(
      assetKey,
      fit: BoxFit.cover,
      cacheWidth: 640,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.landscape_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
