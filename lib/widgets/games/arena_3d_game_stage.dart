import 'package:flutter/material.dart';
import '../../models/arena_game_models.dart';
import '../../theme/islamic_theme.dart';
import 'arena_3d_backdrop.dart';
import 'engine_memory_path_3d.dart';
import 'engine_runner_target_3d.dart';
import 'engine_strategy_rhythm_3d.dart';
import 'engine_word_astrolabe_3d.dart';
import 'gfx/arena_live_events_controller.dart';
import 'gfx/arena_stage_fx.dart';
import 'gfx/arena_ui_image_cache.dart';

/// الموجّه الموحد الذي يشغّل المحرك ثلاثي الأبعاد المناسب لكل واحدة من الـ 30 لعبة
/// مع طبقة الأحداث الحية وصناديق الجوائز وتدفئة خلفيات 4K والمؤثرات البصرية والصوتية (VFX & SFX).
class Arena3DGameStage extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const Arena3DGameStage({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<Arena3DGameStage> createState() => _Arena3DGameStageState();
}

class _Arena3DGameStageState extends State<Arena3DGameStage> {
  final ArenaStageFxController _fxController = ArenaStageFxController();

  @override
  void initState() {
    super.initState();
    ArenaUiImageCache.loadImage(
      widget.config.resolvedBackdropAsset,
      targetWidth: 1080,
    );
  }

  @override
  void dispose() {
    _fxController.dispose();
    super.dispose();
  }

  Widget _buildEngine() {
    switch (widget.config.game.engineType) {
      case ArenaEngineType.runner3D:
        return Runner3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.target3D:
        return Target3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.memory3D:
        return Memory3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.path3D:
        return Path3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.wordForge3D:
        return WordForge3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.astrolabe3D:
        return Astrolabe3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.strategyGrid3D:
        return StrategyGrid3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
      case ArenaEngineType.rhythmPulse3D:
        return RhythmPulse3DEngineWidget(
          config: widget.config,
          palette: widget.palette,
          onFinished: widget.onFinished,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArenaStageFxScope(
      controller: _fxController,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fxController,
              builder: (_, child) => Transform.translate(
                offset: _fxController.shakeOffset,
                child: child,
              ),
              child: RepaintBoundary(
                child: _buildEngine(),
              ),
            ),
          ),
          Positioned.fill(
            child: ArenaLiveEventsOverlay(
              config: widget.config,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ArenaStageFxOverlay(
                controller: _fxController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
