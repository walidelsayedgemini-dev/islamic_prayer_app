import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/compass_utils.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
import 'settings_screen.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _filteredHeading = 0;
  double _manualHeading = 0;
  bool _isAligned = false;
  bool _useManualSimulation = kIsWeb;

  void _openLocationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final qiblaDirection =
        Qibla(Coordinates(settings.latitude, settings.longitude)).direction;

    final Widget compassContent;
    if (_useManualSimulation) {
      compassContent = _buildCompassView(
        heading: _manualHeading,
        qiblaDirection: qiblaDirection,
        isSimulated: true,
      );
    } else {
      compassContent = StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final rawHeading = snapshot.data?.heading;
          if (rawHeading == null) {
            final notice = snapshot.hasError
                ? 'تعذر الوصول إلى مستشعر البوصلة'
                : snapshot.connectionState == ConnectionState.waiting
                    ? 'جارٍ التحقق من مستشعر البوصلة'
                    : 'مستشعر البوصلة غير متاح على هذا الجهاز';
            return _buildCompassView(
              heading: _manualHeading,
              qiblaDirection: qiblaDirection,
              isSimulated: true,
              sensorNotice: notice,
            );
          }

          _filteredHeading = smoothHeading(_filteredHeading, rawHeading, 0.22);
          return _buildCompassView(
            heading: _filteredHeading,
            qiblaDirection: qiblaDirection,
            isSimulated: false,
          );
        },
      );
    }

    return CalmPage(
      title: 'القبلة',
      subtitle: 'اتجاه مكة المكرمة محسوب من موقعك',
      actions: [
        IconButton(
          tooltip: 'إعدادات الموقع',
          onPressed: _openLocationSettings,
          icon: const Icon(Icons.location_on_outlined),
        ),
      ],
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalmCard(
                padding: EdgeInsets.zero,
                child: CalmActionTile(
                  icon: Icons.my_location_rounded,
                  title: settings.cityName,
                  subtitle: 'الموقع · ${settings.lastLocationStatus}',
                  trailing: Icon(
                    Icons.chevron_left_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: _openLocationSettings,
                ),
              ),
              const SizedBox(height: 18),
              compassContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompassView({
    required double heading,
    required double qiblaDirection,
    required bool isSimulated,
    String? sensorNotice,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final signedDifference = ((qiblaDirection - heading + 540) % 360) - 180;
    final difference = signedDifference.abs();
    final isFacingQibla = difference <= 3.5;

    if (isFacingQibla && !_isAligned) {
      _isAligned = true;
      HapticFeedback.heavyImpact();
    } else if (!isFacingQibla) {
      _isAligned = false;
    }

    final statusColor = isFacingQibla ? scheme.primary : scheme.onSurface;
    final sensorLabel = isSimulated ? 'محاكاة يدوية' : 'مستشعر البوصلة نشط';
    final instruction = isSimulated
        ? 'حرّك المنزلق لمحاكاة اتجاه الهاتف؛ لا تمثل هذه قراءة حية.'
        : 'أدر الهاتف ببطء واتبع السهم حتى يستقر اتجاه القبلة.';
    final instrument = _buildCompassInstrument(
      heading: heading,
      qiblaDirection: qiblaDirection,
      sensorNotice: sensorNotice,
      sensorLabel: sensorLabel,
      instruction: instruction,
    );
    final readout = _buildDirectionReadout(
      qiblaDirection: qiblaDirection,
      difference: difference,
    );
    final alignment = _buildAlignmentStatus(
      isFacingQibla: isFacingQibla,
      isSimulated: isSimulated,
      turnRight: signedDifference > 0,
      degrees: difference.round(),
      color: statusColor,
    );
    final adjustment = isSimulated
        ? _buildManualControl(heading: heading, sensorNotice: sensorNotice)
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _useManualSimulation = true),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('استخدام المحاكاة اليدوية'),
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 780) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: instrument),
              const SizedBox(width: 22),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    readout,
                    const SizedBox(height: 16),
                    alignment,
                    const SizedBox(height: 12),
                    adjustment,
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            instrument,
            const SizedBox(height: 18),
            readout,
            const SizedBox(height: 12),
            alignment,
            const SizedBox(height: 8),
            adjustment,
          ],
        );
      },
    );
  }

  Widget _buildCompassInstrument({
    required double heading,
    required double qiblaDirection,
    required String? sensorNotice,
    required String sensorLabel,
    required String instruction,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSimulated = _useManualSimulation || sensorNotice != null;

    return CalmCard(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'مؤشر الاتجاه',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              _StatusPill(
                icon: isSimulated ? Icons.tune_rounded : Icons.explore_outlined,
                label: sensorNotice ?? sensorLabel,
                color: isSimulated ? scheme.onSurfaceVariant : scheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            instruction,
            textAlign: TextAlign.start,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final diameter = math.min(constraints.maxWidth, 366.0);
              final dialDiameter = math.max(0.0, diameter - 18);
              final dialAngle = -heading * math.pi / 180;
              final qiblaRelativeAngle =
                  (qiblaDirection - heading) * math.pi / 180;

              return Center(
                child: SizedBox.square(
                  dimension: diameter,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          scheme.primary.withOpacity(.12),
                          scheme.surface,
                          const Color(0xFFD8C28C).withOpacity(.19),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFB99C64).withOpacity(.64),
                        width: 1.5,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.surface,
                        border: Border.all(
                          color: scheme.outlineVariant.withOpacity(.8),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: dialAngle,
                            child: CustomPaint(
                              size: Size.square(dialDiameter),
                              painter: _CompassDialPainter(
                                faceColor: scheme.surface,
                                ringColor: scheme.outlineVariant,
                                tickColor: scheme.onSurfaceVariant,
                                labelColor: scheme.onSurface,
                                accentColor: scheme.primary,
                                fontFamily: theme.textTheme.bodyMedium
                                        ?.fontFamily ??
                                    'Cairo',
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: qiblaRelativeAngle,
                            child: CustomPaint(
                              size: Size.square(dialDiameter),
                              painter: _QiblaNeedlePainter(
                                color: scheme.primary,
                                hubColor: scheme.surface,
                                outlineColor: scheme.outlineVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 8,
            children: [
              _CompassLegend(
                color: scheme.primary,
                label: 'سهم القبلة',
              ),
              _CompassLegend(
                color: scheme.onSurfaceVariant,
                label: 'قرص الاتجاهات',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionReadout({
    required double qiblaDirection,
    required double difference,
  }) {
    return ParadiseSection(
      title: 'قراءة الاتجاه',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final first = ParadiseMetric(
            value: '${qiblaDirection.toStringAsFixed(1)}°',
            label: 'زاوية القبلة من الشمال',
            icon: Icons.explore_rounded,
          );
          final second = ParadiseMetric(
            value: '${difference.round()}°',
            label: 'المتبقي للوصول للاتجاه',
            icon: Icons.turn_right_rounded,
          );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                first,
                const SizedBox(height: 10),
                second,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlignmentStatus({
    required bool isFacingQibla,
    required bool isSimulated,
    required bool turnRight,
    required int degrees,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isFacingQibla
                  ? Icons.check_circle_outline_rounded
                  : Icons.rotate_right_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _alignmentMessage(
                isFacingQibla: isFacingQibla,
                isSimulated: isSimulated,
                turnRight: turnRight,
                degrees: degrees,
              ),
              softWrap: true,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _alignmentMessage({
    required bool isFacingQibla,
    required bool isSimulated,
    required bool turnRight,
    required int degrees,
  }) {
    if (isFacingQibla) {
      return isSimulated
          ? 'المحاكاة الآن على اتجاه القبلة'
          : 'أنت الآن على اتجاه القبلة';
    }
    if (isSimulated) {
      return 'حرّك المنزلق ${turnRight ? 'يمينًا' : 'يسارًا'} بمقدار $degrees°';
    }
    return 'أدر الهاتف ${turnRight ? 'يمينًا' : 'يسارًا'} بمقدار $degrees°';
  }

  Widget _buildManualControl({
    required double heading,
    required String? sensorNotice,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final description = kIsWeb && sensorNotice == null
        ? 'المتصفح لا يوفّر قراءة حية لاتجاه الهاتف.'
        : sensorNotice == null
            ? 'هذه محاكاة يدوية وليست قراءة من مستشعر الهاتف.'
            : '$sensorNotice. يمكنك متابعة التوجيه بالمحاكاة اليدوية.';

    return CalmCard(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CalmIconBadge(Icons.screen_rotation_alt_rounded,
                      size: 42),
                  const SizedBox(width: 11),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 190),
                    child: Text(
                      'محاكاة اتجاه الهاتف',
                      softWrap: true,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB99C64).withOpacity(.4),
                  ),
                ),
                child: Text(
                  '${heading.round()}°',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            softWrap: true,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.north_rounded, size: 18),
              Expanded(
                child: Slider(
                  value: _manualHeading.clamp(0.0, 359.9),
                  min: 0,
                  max: 359.9,
                  divisions: 360,
                  label: '${_manualHeading.round()}°',
                  onChanged: (value) => setState(() => _manualHeading = value),
                ),
              ),
              const Icon(Icons.explore_outlined, size: 18),
            ],
          ),
          if (!kIsWeb && sensorNotice == null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _useManualSimulation = false),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('العودة إلى مستشعر الهاتف'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompassLegend extends StatelessWidget {
  const _CompassLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          softWrap: true,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color == scheme.onSurfaceVariant
                        ? color
                        : scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  const _CompassDialPainter({
    required this.faceColor,
    required this.ringColor,
    required this.tickColor,
    required this.labelColor,
    required this.accentColor,
    required this.fontFamily,
  });

  final Color faceColor;
  final Color ringColor;
  final Color tickColor;
  final Color labelColor;
  final Color accentColor;
  final String fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius - 2, Paint()..color = faceColor);
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      radius * 0.69,
      Paint()
        ..color = ringColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (var degree = 0; degree < 360; degree += 5) {
      final isMajor = degree % 30 == 0;
      final isMedium = degree % 15 == 0;
      final tickLength = isMajor ? 13.0 : (isMedium ? 8.0 : 4.0);
      final angle = degree * math.pi / 180;
      final start = Offset(
        center.dx + (radius - 8) * math.sin(angle),
        center.dy - (radius - 8) * math.cos(angle),
      );
      final end = Offset(
        center.dx + (radius - 8 - tickLength) * math.sin(angle),
        center.dy - (radius - 8 - tickLength) * math.cos(angle),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = degree == 0 ? accentColor : tickColor
          ..strokeWidth = isMajor ? 1.8 : 1
          ..strokeCap = StrokeCap.round,
      );
    }

    _paintDirectionLabel(canvas, 'شمال',
        Offset(center.dx, center.dy - radius * 0.79), labelColor);
    _paintDirectionLabel(canvas, 'شرق',
        Offset(center.dx + radius * 0.79, center.dy), labelColor);
    _paintDirectionLabel(canvas, 'جنوب',
        Offset(center.dx, center.dy + radius * 0.79), labelColor);
    _paintDirectionLabel(canvas, 'غرب',
        Offset(center.dx - radius * 0.79, center.dy), labelColor);
  }

  void _paintDirectionLabel(
      Canvas canvas, String text, Offset center, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.faceColor != faceColor ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.tickColor != tickColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.fontFamily != fontFamily;
}

class _QiblaNeedlePainter extends CustomPainter {
  const _QiblaNeedlePainter({
    required this.color,
    required this.hubColor,
    required this.outlineColor,
  });

  final Color color;
  final Color hubColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final tip = Offset(center.dx, center.dy - radius * 0.64);
    final leftShoulder =
        Offset(center.dx - radius * 0.075, center.dy - radius * 0.39);
    final notch = Offset(center.dx, center.dy - radius * 0.46);
    final rightShoulder =
        Offset(center.dx + radius * 0.075, center.dy - radius * 0.39);
    final needle = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftShoulder.dx, leftShoulder.dy)
      ..lineTo(notch.dx, notch.dy)
      ..lineTo(rightShoulder.dx, rightShoulder.dy)
      ..close();

    canvas.drawPath(needle, Paint()..color = color);
    canvas.drawCircle(center, radius * 0.065, Paint()..color = hubColor);
    canvas.drawCircle(
      center,
      radius * 0.065,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(center, radius * 0.026, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.hubColor != hubColor ||
      oldDelegate.outlineColor != outlineColor;
}
