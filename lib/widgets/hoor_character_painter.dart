import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/hoor_companion_data.dart';

class HoorCharacterPainter extends CustomPainter {
  final HoorAppearanceConfig appearance;
  final HoorSkinSpec skin;
  final HoorMovementSpec movement;
  final double animationValue; // 0..1 continuous cycle
  final double speakingIntensity; // 0..1 when freshly speaking/reacting

  const HoorCharacterPainter({
    required this.appearance,
    required this.skin,
    required this.movement,
    required this.animationValue,
    this.speakingIntensity = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final t = animationValue * 2 * math.pi;

    final animeIdx = appearance.animeStyleIndex.clamp(0, 23);
    final isChibiCompact = animeIdx % 3 == 2;

    final breath = math.sin(t * movement.breathSpeed) * movement.breathAmplitude;
    final headTilt =
        math.sin(t * 0.5 * movement.breathSpeed) * (movement.headTiltAngle * 0.85);
    final handWave =
        math.sin(t * movement.handWaveSpeed + 0.6) * movement.handWaveAngle +
            (speakingIntensity * 0.14 * math.sin(t * 3.0));
    final cloakSway =
        math.sin(t * 0.75) * movement.cloakRippleAmplitude;
    final haloPulse = 0.88 + 0.12 * math.sin(t * movement.haloPulseSpeed);

    // رمش أنمي لطيف ومشرق
    final blinkWave = math.pow((math.sin(t * 0.5)).abs(), 28).toDouble();
    final eyeOpen = (1.0 - blinkWave * 0.90).clamp(0.12, 1.0);

    final skinBase = HoorCatalog.skinTones[appearance.skinToneIndex % 6];
    final skinShadow = Color.lerp(skinBase, const Color(0xFFE09F87), 0.22)!;
    final eyeColor = HoorCatalog.eyeColors[appearance.eyeColorIndex % 6];

    final robePrimary = Color.lerp(
      HoorCatalog.robePalette[appearance.robeColorIndex % 12],
      skin.primarySilk,
      0.42,
    )!;
    final robeSecondary = Color.lerp(robePrimary, skin.secondarySilk, 0.55)!;
    final trimColor = Color.lerp(
      HoorCatalog.trimPalette[appearance.trimColorIndex % 8],
      skin.trimGold,
      0.48,
    )!;
    final headColor = Color.lerp(skin.hijabOrKufiColor, robePrimary, 0.36)!;

    final isMale = appearance.gender == HoorGender.male;
    final isPoseGreeting = appearance.basePose == 1;
    final isPoseDua = appearance.basePose == 2;

    // 1. الهالة الحالمة + نجوم/بتلات متلألئة
    _paintCuteAnimeAura(
      canvas,
      cx,
      h * 0.44 + breath,
      math.min(w, h) * 0.44 * haloPulse,
      skin.auraColor,
      trimColor,
      animeIdx,
    );

    canvas.save();
    canvas.translate(0, breath * 0.7);

    // 2. الرداء الأنمي اللطيف بخطوط نظيفة ولمعان حريري
    _paintAnimeRobe(
      canvas,
      w: w,
      h: h,
      cx: cx,
      robePrimary: robePrimary,
      robeSecondary: robeSecondary,
      trimColor: trimColor,
      cloakSway: cloakSway,
      isMale: isMale,
      animeIdx: animeIdx,
      isChibiCompact: isChibiCompact,
    );

    // 3. الرقبة الصغيرة الأنمي
    final neckRect = Rect.fromCenter(
      center: Offset(cx, h * 0.435),
      width: w * 0.095,
      height: h * 0.085,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, Radius.circular(w * 0.04)),
      Paint()..color = skinShadow,
    );

    // 4. الرأس الأنمي اللطيف (نسبة تشيبي جذابة بعيون واسعة وملامح بريئة جميلة)
    canvas.save();
    canvas.translate(cx, h * (isChibiCompact ? 0.325 : 0.315));
    canvas.rotate(headTilt);

    if (!isMale) {
      _paintAnimeHijabDrapeBack(
        canvas,
        w,
        h,
        headColor,
        trimColor,
        cloakSway,
        animeIdx,
      );
    }

    _paintAnimeFace(
      canvas,
      w: w,
      h: h,
      skinBase: skinBase,
      skinShadow: skinShadow,
      eyeColor: eyeColor,
      eyeOpen: eyeOpen,
      isMale: isMale,
      speakingIntensity: speakingIntensity,
      t: t,
      animeIdx: animeIdx,
    );

    if (isMale) {
      _paintAnimeMaleHeadwear(
        canvas,
        w,
        h,
        headColor,
        trimColor,
        animeIdx,
      );
    } else {
      _paintAnimeFemaleHijabFront(
        canvas,
        w,
        h,
        headColor,
        trimColor,
        animeIdx,
      );
    }

    canvas.restore();

    // 5. الذراعان واليدان + العنصر النوراني
    _paintAnimeArmsAndHandheld(
      canvas,
      w: w,
      h: h,
      cx: cx,
      robePrimary: robePrimary,
      robeSecondary: robeSecondary,
      trimColor: trimColor,
      skinBase: skinBase,
      handWave: handWave,
      isPoseGreeting: isPoseGreeting,
      isPoseDua: isPoseDua,
      t: t,
    );

    canvas.restore();
  }

  void _paintCuteAnimeAura(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    Color auraColor,
    Color trimColor,
    int animeIdx,
  ) {
    final grad = RadialGradient(
      colors: [
        auraColor.withOpacity(0.36),
        trimColor.withOpacity(0.14),
        auraColor.withOpacity(0.0),
      ],
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius * 1.16,
      Paint()
        ..shader = grad.createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius * 1.16),
        ),
    );

    if (appearance.auraStyle >= 1) {
      final ringPaint = Paint()
        ..color = trimColor.withOpacity(0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawCircle(Offset(cx, cy), radius * 0.88, ringPaint);
    }

    // نجوم ولمعات أنمي متلألئة around character
    final sparkleCount = appearance.auraStyle >= 2 ? 7 : 4;
    for (int k = 0; k < sparkleCount; k++) {
      final ang = (k * (math.pi * 2 / sparkleCount)) +
          animationValue * math.pi * 0.65 +
          (animeIdx * 0.25);
      final r = radius * (k.isEven ? 0.94 : 0.78);
      final sx = cx + math.cos(ang) * r;
      final sy = cy + math.sin(ang) * r;
      final sSize = k.isEven ? 4.2 : 3.0;
      _drawFourPointStar(
        canvas,
        Offset(sx, sy),
        sSize,
        k % 3 == 0 ? trimColor : Colors.white.withOpacity(0.92),
      );
    }
  }

  void _drawFourPointStar(
      Canvas canvas, Offset center, double r, Color color) {
    final p = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx + r * 0.2, center.dy - r * 0.2,
          center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx + r * 0.2, center.dy + r * 0.2, center.dx,
          center.dy + r)
      ..quadraticBezierTo(center.dx - r * 0.2, center.dy + r * 0.2,
          center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx - r * 0.2, center.dy - r * 0.2, center.dx,
          center.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  void _paintAnimeRobe(
    Canvas canvas, {
    required double w,
    required double h,
    required double cx,
    required Color robePrimary,
    required Color robeSecondary,
    required Color trimColor,
    required double cloakSway,
    required bool isMale,
    required int animeIdx,
    required bool isChibiCompact,
  }) {
    final bodyTop = h * 0.455;
    final shoulderHalf = w * (isMale ? 0.235 : 0.215);
    final hemHalf = w * (isChibiCompact ? 0.36 : 0.33);

    final robePath = Path()
      ..moveTo(cx - shoulderHalf * 0.48, bodyTop)
      ..quadraticBezierTo(cx - shoulderHalf, bodyTop + h * 0.04,
          cx - shoulderHalf * 1.02, bodyTop + h * 0.14)
      ..quadraticBezierTo(cx - hemHalf + cloakSway * 0.35, h * 0.78,
          cx - hemHalf + cloakSway, h * 0.96)
      ..quadraticBezierTo(cx + cloakSway * 0.5, h * 0.99,
          cx + hemHalf + cloakSway * 0.55, h * 0.96)
      ..quadraticBezierTo(cx + hemHalf + cloakSway * 0.25, h * 0.78,
          cx + shoulderHalf * 1.02, bodyTop + h * 0.14)
      ..quadraticBezierTo(cx + shoulderHalf, bodyTop + h * 0.04,
          cx + shoulderHalf * 0.48, bodyTop)
      ..close();

    final bodyRect =
        Rect.fromLTRB(cx - hemHalf, bodyTop, cx + hemHalf, h * 0.98);
    canvas.drawPath(
      robePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(robeSecondary, Colors.white, 0.15)!,
            robePrimary,
            Color.lerp(robePrimary, Colors.black, 0.18)!,
          ],
        ).createShader(bodyRect),
    );

    // كاب كتف أنمي ناعم (capelet / ribbon sash) يختلف حسب animeIdx
    if (animeIdx % 4 != 3) {
      final capPath = Path()
        ..moveTo(cx - shoulderHalf * 0.55, bodyTop)
        ..quadraticBezierTo(cx - shoulderHalf * 1.12, bodyTop + h * 0.08,
            cx - shoulderHalf * 0.92, bodyTop + h * 0.17)
        ..quadraticBezierTo(cx, bodyTop + h * 0.22, cx + shoulderHalf * 0.92,
            bodyTop + h * 0.17)
        ..quadraticBezierTo(cx + shoulderHalf * 1.12, bodyTop + h * 0.08,
            cx + shoulderHalf * 0.55, bodyTop)
        ..close();
      canvas.drawPath(
        capPath,
        Paint()..color = robeSecondary.withOpacity(0.85),
      );
      canvas.drawPath(
        capPath,
        Paint()
          ..color = trimColor.withOpacity(0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // فيونكة / وسام نجمي أنمي لطيف على الصدر
    final bowY = bodyTop + h * 0.085;
    final ribbonPaint = Paint()..color = trimColor;
    canvas.drawCircle(Offset(cx, bowY), w * 0.022, ribbonPaint);
    if (!isMale) {
      final leftBow = Path()
        ..moveTo(cx, bowY)
        ..lineTo(cx - w * 0.055, bowY - h * 0.022)
        ..lineTo(cx - w * 0.048, bowY + h * 0.022)
        ..close();
      final rightBow = Path()
        ..moveTo(cx, bowY)
        ..lineTo(cx + w * 0.055, bowY - h * 0.022)
        ..lineTo(cx + w * 0.048, bowY + h * 0.022)
        ..close();
      canvas.drawPath(leftBow, ribbonPaint);
      canvas.drawPath(rightBow, ribbonPaint);
    }

    // حاشية ناعمة أسفل الثوب
    canvas.drawLine(
      Offset(cx - hemHalf * 0.85 + cloakSway * 0.8, h * 0.92),
      Offset(cx + hemHalf * 0.85 + cloakSway * 0.5, h * 0.92),
      Paint()
        ..color = trimColor.withOpacity(0.55)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintAnimeHijabDrapeBack(
    Canvas canvas,
    double w,
    double h,
    Color headColor,
    Color trimColor,
    double cloakSway,
    int animeIdx,
  ) {
    final spread = animeIdx.isEven ? 0.25 : 0.22;
    final drape = Path()
      ..moveTo(-w * 0.17, -h * 0.07)
      ..quadraticBezierTo(-w * (spread + 0.04), h * 0.08,
          -w * spread + cloakSway * 0.55, h * 0.29)
      ..quadraticBezierTo(0, h * 0.35, w * spread + cloakSway * 0.55, h * 0.29)
      ..quadraticBezierTo(
          w * (spread + 0.04), h * 0.08, w * 0.17, -h * 0.07)
      ..close();

    canvas.drawPath(
      drape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(headColor, Colors.white, 0.12)!,
            headColor,
            Color.lerp(headColor, Colors.black, 0.16)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: w * 0.29)),
    );
  }

  void _paintAnimeFace(
    Canvas canvas, {
    required double w,
    required double h,
    required Color skinBase,
    required Color skinShadow,
    required Color eyeColor,
    required double eyeOpen,
    required bool isMale,
    required double speakingIntensity,
    required double t,
    required int animeIdx,
  }) {
    final faceWidth = w * 0.265;
    final faceHeight = h * 0.225;

    // شكل رأس أنمي تشيبي لطيف بخدين مستديرين وذقن رقيق ناعم
    final hw = faceWidth * 0.5;
    final hh = faceHeight * 0.5;
    final facePath = Path()
      ..moveTo(0, -hh)
      ..cubicTo(hw * 0.92, -hh, hw * 1.05, -hh * 0.15, hw * 0.96, hh * 0.35)
      ..quadraticBezierTo(hw * 0.72, hh * 0.94, 0, hh * 1.02)
      ..quadraticBezierTo(-hw * 0.72, hh * 0.94, -hw * 0.96, hh * 0.35)
      ..cubicTo(-hw * 1.05, -hh * 0.15, -hw * 0.92, -hh, 0, -hh)
      ..close();

    final faceRect =
        Rect.fromCenter(center: Offset.zero, width: faceWidth, height: faceHeight);
    canvas.drawPath(
      facePath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.15, -0.25),
          radius: 0.95,
          colors: [
            Color.lerp(skinBase, Colors.white, 0.16)!,
            skinBase,
            skinShadow,
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(faceRect),
    );
    // تحديد أنمي ناعم دافئ حول الوجه
    canvas.drawPath(
      facePath,
      Paint()
        ..color = skinShadow.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // حمرة خدود أنمي لطيفة جداً (وردية خفيفة + خطوط أنمي كيوت)
    final blushColor =
        const Color(0xFFFF8A9E).withOpacity(isMale ? 0.24 : 0.38);
    for (final side in [-1.0, 1.0]) {
      final bx = side * faceWidth * 0.29;
      final by = faceHeight * 0.18;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(bx, by),
          width: faceWidth * 0.19,
          height: faceHeight * 0.105,
        ),
        Paint()..color = blushColor,
      );
      if (!isMale) {
        final stripeP = Paint()
          ..color = const Color(0xFFF06292).withOpacity(0.45)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(bx - 3, by + 1), Offset(bx - 1, by - 2), stripeP);
        canvas.drawLine(
            Offset(bx + 1, by + 1), Offset(bx + 3, by - 2), stripeP);
      }
    }

    // العيون الأنمي الكبيرة اللامعة البرّاقة ✨
    final eyeY = faceHeight * 0.01;
    final eyeOffsetX = faceWidth * 0.22;
    final eyeScaleMod = (animeIdx % 3 == 0) ? 1.12 : 1.02;
    final eyeW = faceWidth * (isMale ? 0.19 : 0.215) * eyeScaleMod;
    final eyeH = eyeW * (isMale ? 1.05 : 1.18);

    final irisTop = Color.lerp(eyeColor, Colors.black, 0.35)!;
    final irisBottom = Color.lerp(eyeColor, Colors.white, 0.35)!;

    for (final side in [-1.0, 1.0]) {
      final ex = side * eyeOffsetX;
      canvas.save();
      canvas.translate(ex, eyeY);
      canvas.scale(1.0, eyeOpen);

      // بياض العين الناعم
      final eyeOuterRect =
          Rect.fromCenter(center: Offset.zero, width: eyeW, height: eyeH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(eyeOuterRect, Radius.circular(eyeW * 0.45)),
        Paint()..color = Colors.white,
      );

      // القزحية الأنمي الكبيرة المتدرجة
      final irisRect = Rect.fromCenter(
        center: Offset(0, eyeH * 0.03),
        width: eyeW * 0.80,
        height: eyeH * 0.86,
      );
      canvas.drawOval(
        irisRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [irisTop, eyeColor, irisBottom],
          ).createShader(irisRect),
      );

      // البؤبؤ الأنيق في المركز
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, eyeH * 0.02),
          width: eyeW * 0.36,
          height: eyeH * 0.40,
        ),
        Paint()..color = const Color(0xFF14111A),
      );

      // هلال مضيء أسفل القزحية (بريق أنمي دافئ)
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(0, eyeH * 0.16),
          width: eyeW * 0.56,
          height: eyeH * 0.36,
        ),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = Colors.white.withOpacity(0.62)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );

      // لمعتان أنمي ساطعتان (Sparkle Catchlights!)
      canvas.drawCircle(
        Offset(-eyeW * 0.19, -eyeH * 0.18),
        eyeW * 0.16,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(eyeW * 0.16, eyeH * 0.16),
        eyeW * 0.085,
        Paint()..color = Colors.white.withOpacity(0.92),
      );

      canvas.restore();

      // خط الرمش الأنمي العلوي المقوّس + رموش طرفية لطيفة
      final lashPaint = Paint()
        ..color = const Color(0xFF231829)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMale ? 2.1 : 2.6
        ..strokeCap = StrokeCap.round;
      final lashY = eyeY - (eyeH * 0.44 * eyeOpen);
      final lashPath = Path()
        ..moveTo(ex - eyeW * 0.54, lashY + eyeH * 0.18)
        ..quadraticBezierTo(ex, lashY - eyeH * 0.12, ex + eyeW * 0.54,
            lashY + eyeH * 0.18);
      canvas.drawPath(lashPath, lashPaint);

      if (!isMale) {
        final wingX = ex + side * eyeW * 0.52;
        final wingY = lashY + eyeH * 0.12;
        canvas.drawLine(
          Offset(wingX, wingY),
          Offset(wingX + side * eyeW * 0.15, wingY - eyeH * 0.12),
          Paint()
            ..color = const Color(0xFF231829)
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round,
        );
      }

      // الحاجب الهادئ المقوس above eye
      final browY = eyeY - eyeH * 0.68;
      final browPath = Path()
        ..moveTo(ex - eyeW * 0.38, browY + 1)
        ..quadraticBezierTo(ex, browY - 3.2, ex + eyeW * 0.38, browY + 1);
      canvas.drawPath(
        browPath,
        Paint()
          ..color = const Color(0xFF3E2723).withOpacity(0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // أنف أنمي صغير لطيف جداً (نقطة ظل صغيرة ناعمة)
    canvas.drawCircle(
      Offset(0, faceHeight * 0.16),
      1.1,
      Paint()..color = skinShadow.withOpacity(0.75),
    );

    // فم أنمي مبتسم لطيف (بدون أي تفاصيل مخيفة)
    final mouthY = faceHeight * 0.285;
    final mouthW = faceWidth * 0.135;
    final speakWave = speakingIntensity > 0.05
        ? (0.3 + 0.7 * math.sin(t * 6.0).abs()) * speakingIntensity
        : 0.0;

    if (speakWave > 0.18) {
      // فم مفتوح سعيد كيوت أثناء الحديث
      final openRect = Rect.fromCenter(
        center: Offset(0, mouthY + 2.5),
        width: mouthW * 1.45,
        height: 4.5 + speakWave * 5.0,
      );
      canvas.drawOval(openRect, Paint()..color = const Color(0xFFD84B6E));
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(0, mouthY + 4.5),
          width: mouthW * 0.9,
          height: 3.5,
        ),
        0,
        math.pi,
        true,
        Paint()..color = const Color(0xFFFF9DB0),
      );
    } else if (appearance.mouthStyle == 2) {
      // ابتسامة ":3" الأنمي الظريفة
      final catSmile = Path()
        ..moveTo(-mouthW, mouthY)
        ..quadraticBezierTo(-mouthW * 0.5, mouthY + 4.5, 0, mouthY)
        ..quadraticBezierTo(mouthW * 0.5, mouthY + 4.5, mouthW, mouthY);
      canvas.drawPath(
        catSmile,
        Paint()
          ..color = const Color(0xFFB84C65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    } else {
      final smilePath = Path()
        ..moveTo(-mouthW, mouthY)
        ..quadraticBezierTo(0, mouthY + 5.5, mouthW, mouthY);
      canvas.drawPath(
        smilePath,
        Paint()
          ..color = isMale ? const Color(0xFF9E5252) : const Color(0xFFC7526C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.1
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintAnimeFemaleHijabFront(
    Canvas canvas,
    double w,
    double h,
    Color headColor,
    Color trimColor,
    int animeIdx,
  ) {
    final hw = w * 0.148;
    final hh = h * 0.132;

    // غطاء أنمي حريري ناعم يحيط بالجبهة والجانبين بخصلات ناعمة
    final topCap = Path()
      ..moveTo(-hw * 1.06, hh * 0.08)
      ..quadraticBezierTo(-hw * 1.12, -hh * 1.16, 0, -hh * 1.14)
      ..quadraticBezierTo(hw * 1.12, -hh * 1.16, hw * 1.06, hh * 0.08)
      ..quadraticBezierTo(hw * 0.58, -hh * 0.80, 0, -hh * 0.64)
      ..quadraticBezierTo(-hw * 0.58, -hh * 0.80, -hw * 1.06, hh * 0.08)
      ..close();

    canvas.drawPath(
      topCap,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(headColor, Colors.white, 0.24)!, headColor],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: hw * 1.25)),
    );

    // زينة أنمي مختلفة باختلاف الـ 24 شكلاً (فيونكة، هلال، زهرة، تاج نجمي)
    final ornamentKind = (animeIdx + appearance.headwearStyle) % 4;
    if (ornamentKind == 0) {
      // فيونكة أنمي على الجانب
      final bx = hw * 0.72;
      final by = -hh * 0.52;
      final bowP = Paint()..color = trimColor;
      canvas.drawCircle(Offset(bx, by), 3.4, bowP);
      canvas.drawCircle(Offset(bx - 5, by - 2), 4.0, bowP);
      canvas.drawCircle(Offset(bx + 5, by + 2), 4.0, bowP);
    } else if (ornamentKind == 1) {
      // شريط + جوهرة هلال لطيفة
      final band = Path()
        ..moveTo(-hw * 0.88, -hh * 0.46)
        ..quadraticBezierTo(0, -hh * 0.94, hw * 0.88, -hh * 0.46);
      canvas.drawPath(
        band,
        Paint()
          ..color = trimColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
      canvas.drawCircle(Offset(0, -hh * 0.72), 4.2, Paint()..color = trimColor);
      canvas.drawCircle(
          Offset(0, -hh * 0.72), 2.0, Paint()..color = Colors.white);
    } else if (ornamentKind == 2) {
      // زهرة أنمي 5 بتلات على طرف الحجاب
      final fx = -hw * 0.72;
      final fy = -hh * 0.45;
      for (int p = 0; p < 5; p++) {
        final ang = p * (math.pi * 2 / 5);
        canvas.drawCircle(
          Offset(fx + math.cos(ang) * 4.5, fy + math.sin(ang) * 4.5),
          2.6,
          Paint()..color = trimColor.withOpacity(0.92),
        );
      }
      canvas.drawCircle(Offset(fx, fy), 2.3, Paint()..color = Colors.white);
    } else {
      // نجمة بريق فوق الجبين
      _drawFourPointStar(canvas, Offset(0, -hh * 0.78), 5.6, trimColor);
    }
  }

  void _paintAnimeMaleHeadwear(
    Canvas canvas,
    double w,
    double h,
    Color headColor,
    Color trimColor,
    int animeIdx,
  ) {
    final hw = w * 0.145;
    final hh = h * 0.125;

    // خصلات شعر أنمي خفيفة للأولاد
    final hairColor = animeIdx % 4 == 2
        ? const Color(0xFF3E2723)
        : const Color(0xFF1F1824);

    if (appearance.headwearStyle == 0) {
      final hair = Path()
        ..moveTo(-hw * 1.02, -hh * 0.12)
        ..quadraticBezierTo(-hw * 1.0, -hh * 1.15, 0, -hh * 1.12)
        ..quadraticBezierTo(hw * 1.0, -hh * 1.15, hw * 1.02, -hh * 0.12)
        ..lineTo(hw * 0.7, -hh * 0.56)
        ..lineTo(hw * 0.35, -hh * 0.36)
        ..lineTo(0, -hh * 0.64)
        ..lineTo(-hw * 0.38, -hh * 0.36)
        ..lineTo(-hw * 0.72, -hh * 0.56)
        ..close();
      canvas.drawPath(hair, Paint()..color = hairColor);
    } else if (appearance.headwearStyle == 1) {
      final kufiRect = RRect.fromLTRBAndCorners(
        -hw * 0.96,
        -hh * 1.08,
        hw * 0.96,
        -hh * 0.45,
        topLeft: Radius.circular(hw * 0.65),
        topRight: Radius.circular(hw * 0.65),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      );
      canvas.drawRRect(kufiRect, Paint()..color = headColor);
      canvas.drawLine(
        Offset(-hw * 0.88, -hh * 0.54),
        Offset(hw * 0.88, -hh * 0.54),
        Paint()
          ..color = trimColor
          ..strokeWidth = 2.6,
      );
      _drawFourPointStar(canvas, Offset(0, -hh * 0.76), 4.0, trimColor);
    } else {
      final turban = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -hh * 0.84),
          width: hw * 2.15,
          height: hh * 0.74,
        ),
        Radius.circular(hh * 0.38),
      );
      canvas.drawRRect(
          turban, Paint()..color = Colors.white.withOpacity(0.96));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -hh * 0.84),
            width: hw * 1.82,
            height: hh * 0.22,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = trimColor,
      );
    }
  }

  void _paintAnimeArmsAndHandheld(
    Canvas canvas, {
    required double w,
    required double h,
    required double cx,
    required Color robePrimary,
    required Color robeSecondary,
    required Color trimColor,
    required Color skinBase,
    required double handWave,
    required bool isPoseGreeting,
    required bool isPoseDua,
    required double t,
  }) {
    final shoulderY = h * 0.495;

    // الذراع اليمنى الكيوت
    canvas.save();
    canvas.translate(cx + w * 0.195, shoulderY);
    final rightAngle = isPoseDua
        ? -0.42 + handWave
        : (isPoseGreeting ? -0.36 + handWave * 1.45 : -0.16 + handWave);
    canvas.rotate(rightAngle);

    final sleeveRight = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.04, 0, w * 0.088, h * 0.185),
      Radius.circular(w * 0.044),
    );
    canvas.drawRRect(sleeveRight, Paint()..color = robePrimary);
    canvas.drawCircle(
      Offset(w * 0.004, h * 0.195),
      w * 0.036,
      Paint()..color = skinBase,
    );
    canvas.restore();

    // الذراع اليسرى
    canvas.save();
    canvas.translate(cx - w * 0.195, shoulderY);
    final leftAngle = isPoseDua ? 0.42 - handWave : 0.15 - handWave * 0.7;
    canvas.rotate(leftAngle);

    final sleeveLeft = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.048, 0, w * 0.088, h * 0.185),
      Radius.circular(w * 0.044),
    );
    canvas.drawRRect(sleeveLeft, Paint()..color = robePrimary);
    final handCenter = Offset(-w * 0.004, h * 0.195);
    canvas.drawCircle(handCenter, w * 0.036, Paint()..color = skinBase);

    _paintHandheld(canvas, handCenter, w, trimColor, t);
    canvas.restore();
  }

  void _paintHandheld(
      Canvas canvas, Offset handCenter, double w, Color trimColor, double t) {
    final item = appearance.handheldItem;
    if (item == 0) return;

    final sway = math.sin(t * 1.2) * movement.lanternSwayAmplitude;
    canvas.save();
    canvas.translate(handCenter.dx, handCenter.dy);
    canvas.rotate(sway);

    if (item == 1) {
      canvas.drawLine(
        Offset.zero,
        Offset(0, w * 0.055),
        Paint()
          ..color = trimColor
          ..strokeWidth = 1.6,
      );
      final glowRect = Offset(0, w * 0.11);
      canvas.drawCircle(
        glowRect,
        w * 0.075,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF59D).withOpacity(0.78),
              trimColor.withOpacity(0.0),
            ],
          ).createShader(Rect.fromCircle(center: glowRect, radius: w * 0.075)),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: glowRect, width: w * 0.052, height: w * 0.072),
          const Radius.circular(6),
        ),
        Paint()..color = trimColor,
      );
      canvas.drawCircle(
        glowRect,
        w * 0.017,
        Paint()..color = const Color(0xFFFFFDE7),
      );
    } else if (item == 2) {
      final bookRect = Rect.fromCenter(
          center: Offset(0, -w * 0.02), width: w * 0.095, height: w * 0.065);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bookRect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF0B5345),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bookRect.deflate(3), const Radius.circular(2)),
        Paint()..color = const Color(0xFFFFF8E1),
      );
      canvas.drawLine(
        Offset(0, bookRect.top + 3),
        Offset(0, bookRect.bottom - 3),
        Paint()
          ..color = trimColor
          ..strokeWidth = 1.5,
      );
    } else if (item == 3) {
      for (int k = 0; k < 9; k++) {
        final ang = (k / 9) * math.pi * 2;
        final bx = math.cos(ang) * w * 0.034;
        final by = w * 0.048 + math.sin(ang) * w * 0.04;
        canvas.drawCircle(
          Offset(bx, by),
          3.0,
          Paint()..color = k.isEven ? trimColor : Colors.white,
        );
      }
    } else {
      canvas.drawCircle(
        Offset(0, -w * 0.028),
        w * 0.034,
        Paint()
          ..shader = const RadialGradient(
            colors: [Colors.white, Color(0xFFE0F7FA), Color(0xFF80DEEA)],
          ).createShader(Rect.fromCircle(
              center: Offset(0, -w * 0.028), radius: w * 0.034)),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HoorCharacterPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.speakingIntensity != speakingIntensity ||
        oldDelegate.skin.index != skin.index ||
        oldDelegate.movement.index != movement.index ||
        oldDelegate.appearance != appearance;
  }
}
