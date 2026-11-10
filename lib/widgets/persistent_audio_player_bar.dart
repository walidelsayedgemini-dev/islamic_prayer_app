import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/islamic_theme.dart';

class PersistentAudioPlayerBar extends StatefulWidget {
  final ThemeOption themeOption;
  final VoidCallback onOpenDrawer;

  const PersistentAudioPlayerBar({
    super.key,
    required this.themeOption,
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

    final accent = widget.themeOption.accentColor;
    final cardBg = widget.themeOption.cardColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.65),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. رأس المشغل: معلومات التلاوة والقارئ مع أيقونة الراديو والزر X
          Row(
            children: [
              // زر فتح القائمة الجانبية للتلاوات
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

              // اسم السورة أو الرقية واسم الشيخ
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOpenDrawer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        player.currentTitle,
                        style: const TextStyle(
                          fontFamily: 'Aref Ruqaa',
                          color: Colors.white,
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
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // زر التكرار Loop
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: Icon(
                  Icons.repeat_rounded,
                  color: player.isLooping ? accent : Colors.white38,
                  size: 20,
                ),
                tooltip: "تكرار التشغيل",
                onPressed: () => player.toggleLoop(),
              ),

              // زر الإغلاق
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                tooltip: "إيقاف وإغلاق",
                onPressed: () => player.closePlayer(),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. سلايدر الوقت التفاعلي مع الوقت الحالي والإجمالي (مطابق للصورة 2 و 3)
          Row(
            children: [
              Text(
                player.formatDuration(player.position),
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: accent,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: player.progressRatio,
                    onChanged: (ratio) => player.seekTo(ratio),
                  ),
                ),
              ),
              Text(
                player.formatDuration(player.duration),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),

          // 3. أزرار التحكم (رجوع 10ث، تشغيل/إيقاف، تقديم 10ث)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 24),
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
                  child: Icon(
                    player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black87,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 24),
                tooltip: "تقديم 10 ثوانٍ",
                onPressed: () => player.seekForward10(),
              ),
            ],
          ),
        ],
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
