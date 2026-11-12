import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../providers/audio_player_provider.dart';
import '../screens/quran_reader_screen.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_resilient_image.dart';

class PersistentAudioPlayerBar extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;
  final VoidCallback onOpenDrawer;

  const PersistentAudioPlayerBar({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
    required this.onOpenDrawer,
  });

  @override
  State<PersistentAudioPlayerBar> createState() => _PersistentAudioPlayerBarState();
}

class _PersistentAudioPlayerBarState extends State<PersistentAudioPlayerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<AudioPlayerProvider>(context);
    if (player.currentAudioId == null) {
      return const SizedBox.shrink();
    }

    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;

    final backdrop = Background500Catalog.forExtraSection(
      (player.currentSurahNumber ?? 6) + 2,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (palette.isDark ? Colors.black : palette.primaryColor)
                .withOpacity(palette.isDark ? 0.65 : 0.20),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: palette.isDark ? 0.34 : 0.22,
                child: FirdawsResilientImage.entry(backdrop),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      palette.cardColor.withOpacity(palette.isDark ? 0.86 : 0.88),
                      palette.scaffoldColor.withOpacity(palette.isDark ? 0.78 : 0.84),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
          if (player.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.45)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      player.errorMessage!,
                      style: TextStyle(color: palette.textPrimary, fontSize: 10.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => player.togglePlay(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        "إعادة",
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: player.clearError,
                    child: Icon(Icons.close_rounded, color: palette.textSecondary, size: 15),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: widget.onOpenDrawer,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(0.6)),
                  ),
                  child: Center(
                    child: _buildEqualizer(player.isPlaying, accent),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOpenDrawer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        player.currentTitle,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        player.currentSubTitle,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        player.isLoading
                            ? "جاري تحميل الصوت..."
                            : (player.isOfflineSource
                                ? "متاح بدون إنترنت ✓"
                                : "بث مباشر عبر الإنترنت"),
                        style: TextStyle(
                          color: player.isOfflineSource
                              ? (palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                              : accent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (player.currentSurahNumber != null)
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: Icon(Icons.auto_stories_rounded, color: accent, size: 20),
                  tooltip: "قراءة السورة",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuranReaderScreen(
                          initialSurahNumber: player.currentSurahNumber,
                        ),
                      ),
                    );
                  },
                ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: Icon(
                  Icons.repeat_rounded,
                  color: player.isLooping ? accent : palette.textMuted,
                  size: 20,
                ),
                tooltip: "تكرار التشغيل",
                onPressed: () => player.toggleLoop(),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: Icon(Icons.close_rounded, color: palette.textSecondary, size: 20),
                tooltip: "إيقاف وإغلاق",
                onPressed: () => player.closePlayer(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                player.formatDuration(player.position),
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: accent,
                    inactiveTrackColor: palette.dividerColor,
                    thumbColor: accent,
                  ),
                  child: Slider(
                    value: player.progressRatio,
                    onChanged: (ratio) => player.seekTo(ratio),
                  ),
                ),
              ),
              Text(
                player.formatDuration(player.duration),
                style: TextStyle(color: palette.textMuted, fontSize: 11),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.replay_10_rounded, color: palette.textSecondary, size: 24),
                tooltip: "رجوع 10 ثوانٍ",
                onPressed: () => player.seekRewind10(),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => player.togglePlay(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.55),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: player.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: palette.onAccentColor,
                            ),
                          )
                        : Icon(
                            player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: palette.onAccentColor,
                            size: 26,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                icon: Icon(Icons.forward_10_rounded, color: palette.textSecondary, size: 24),
                tooltip: "تقديم 10 ثوانٍ",
                onPressed: () => player.seekForward10(),
              ),
            ],
          ),
        ],
      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualizer(bool isPlaying, Color color) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            final phase = index * (math.pi / 2);
            final height = isPlaying
                ? 6.0 + 10.0 * ((math.sin(_waveController.value * math.pi * 2 + phase) + 1.0) / 2.0)
                : 5.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.2),
              width: 3.0,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
