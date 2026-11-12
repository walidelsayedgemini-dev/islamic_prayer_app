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

    final breath = math.sin(t * movement.breathSpeed) * movement.breathAmplitude;
    final headTilt =
        math.sin(t * 0.5 * movement.breathSpeed) * movement.headTiltAngle;
    final handWave =
        math.sin(t * movement.handWaveSpeed + 0.6) * movement.handWaveAngle +
            (speakingIntensity * 0.14 * math.sin(t * 3.0));
    final cloakSway =
        math.sin(t * 0.75) * movement.cloakRippleAmplitude;
    final haloPulse = 0.85 + 0.15 * math.sin(t * movement.haloPulseSpeed);

    // طبيعة رمش العين الواقعية السلسة كل دورة
    final blinkWave = math.pow((math.sin(t * 0.5)).abs(), 26).toDouble();
    final eyeOpen = (1.0 - blinkWave * 0.92).clamp(0.08, 1.0);

    // الألوان المختارة (دمج لطيف بين تفاصيل المستخدم والسكن المختار)
    final skinBase = HoorCatalog.skinTones[appearance.skinToneIndex % 6];
    final skinShadow = Color.lerp(skinBase, const Color(0xFF6D4C41), 0.18)!;
    final eyeColor = HoorCatalog.eyeColors[appearance.eyeColorIndex % 6];

    final robePrimary = Color.lerp(
      HoorCatalog.robePalette[appearance.robeColorIndex % 12],
      skin.primarySilk,
      0.45,
    )!;
    final robeSecondary = Color.lerp(robePrimary, skin.secondarySilk, 0.5)!;
    final trimColor = Color.lerp(
      HoorCatalog.trimPalette[appearance.trimColorIndex % 8],
      skin.trimGold,
      0.5,
    )!;
    final headColor = Color.lerp(skin.hijabOrKufiColor, robePrimary, 0.35)!;

    final isMale = appearance.gender == HoorGender.male;
    final isPoseGreeting = appearance.basePose == 1;
    final isPoseDua = appearance.basePose == 2;

    // 1. الهالة النورانية خلف الشخصية
    _paintAura(canvas, cx, h * 0.44 + breath, math.min(w, h) * 0.42 * haloPulse,
        skin.auraColor);

    canvas.save();
    canvas.translate(0, breath * 0.75);

    // 2. العباءة / الثوب والوشاح المتدفق بنعومة الحرير
    _paintRobeAndShoulders(
      canvas,
      w: w,
      h: h,
      cx: cx,
      robePrimary: robePrimary,
      robeSecondary: robeSecondary,
      trimColor: trimColor,
      cloakSway: cloakSway,
      isMale: isMale,
    );

    // 3. الرقبة والظل الدافئ أسفل الذقن
    final neckRect = Rect.fromCenter(
      center: Offset(cx, h * 0.415),
      width: w * 0.125,
      height: h * 0.11,
    );
    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skinShadow, skinBase],
      ).createShader(neckRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, Radius.circular(w * 0.05)),
      neckPaint,
    );

    // 4. الرأس + الملامح الدقيقة + الحجاب أو الكوفية/العمامة
    canvas.save();
    canvas.translate(cx, h * 0.31);
    canvas.rotate(headTilt);

    if (!isMale) {
      // طرحة خلفية منسدلة للمؤنث (حور)
      _paintHijabDrapeBack(canvas, w, h, headColor, trimColor, cloakSway);
    }

    // الوجه المتناسب طبيعياً
    _paintFace(
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
    );

    if (isMale) {
      _paintMaleHeadwear(canvas, w, h, headColor, trimColor);
    } else {
      _paintFemaleHijabFront(canvas, w, h, headColor, trimColor);
    }

    canvas.restore();

    // 5. الذراعان واليدان مع الحركة الانسيابية والأداة المحمولة (فانوس/مصحف/سبحة/لؤلؤة)
    _paintArmsAndHandheld(
      canvas,
      w: w,
      h: h,
      cx: cx,
      robePrimary: robePrimary,
      trimColor: trimColor,
      skinBase: skinBase,
      handWave: handWave,
      isPoseGreeting: isPoseGreeting,
      isPoseDua: isPoseDua,
      t: t,
    );

    canvas.restore();
  }

  void _paintAura(
      Canvas canvas, double cx, double cy, double radius, Color auraColor) {
    final style = appearance.auraStyle;
    final grad = RadialGradient(
      colors: [
        auraColor.withOpacity(0.42),
        auraColor.withOpacity(0.14),
        auraColor.withOpacity(0.0),
      ],
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius * 1.15,
      Paint()
        ..shader = grad.createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: radius * 1.15)),
    );

    if (style >= 1) {
      final ringPaint = Paint()
        ..color = auraColor.withOpacity(0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawCircle(Offset(cx, cy), radius * 0.86, ringPaint);
    }
    if (style >= 2) {
      // هلال ونجمة هندسية مضيئة حول الهالة
      final starPaint = Paint()..color = Colors.white.withOpacity(0.65);
      for (int k = 0; k < 6; k++) {
        final ang = (k * math.pi / 3) + animationValue * math.pi * 0.5;
        final sx = cx + math.cos(ang) * radius * 0.92;
        final sy = cy + math.sin(ang) * radius * 0.92;
        canvas.drawCircle(Offset(sx, sy), k.isEven ? 2.4 : 1.5, starPaint);
      }
    }
  }

  void _paintRobeAndShoulders(
    Canvas canvas, {
    required double w,
    required double h,
    required double cx,
    required Color robePrimary,
    required Color robeSecondary,
    required Color trimColor,
    required double cloakSway,
    required bool isMale,
  }) {
    final bodyTop = h * 0.44;
    final shoulderHalf = w * (isMale ? 0.275 : 0.245);
    final hemHalf = w * (isMale ? 0.34 : 0.38);

    final robePath = Path()
      ..moveTo(cx - shoulderHalf * 0.45, bodyTop)
      ..quadraticBezierTo(
          cx - shoulderHalf, bodyTop + h * 0.04, cx - shoulderHalf * 1.05, bodyTop + h * 0.14)
      ..quadraticBezierTo(
          cx - hemHalf + cloakSway * 0.4, h * 0.78, cx - hemHalf + cloakSway, h * 0.97)
      ..lineTo(cx + hemHalf + cloakSway * 0.6, h * 0.97)
      ..quadraticBezierTo(
          cx + hemHalf + cloakSway * 0.3, h * 0.78, cx + shoulderHalf * 1.05, bodyTop + h * 0.14)
      ..quadraticBezierTo(
          cx + shoulderHalf, bodyTop + h * 0.04, cx + shoulderHalf * 0.45, bodyTop)
      ..close();

    final bodyRect = Rect.fromLTRB(cx - hemHalf, bodyTop, cx + hemHalf, h * 0.98);
    canvas.drawPath(
      robePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [robeSecondary, robePrimary, Color.lerp(robePrimary, Colors.black, 0.28)!],
        ).createShader(bodyRect),
    );

    // حزام أو تطريز عمودي وسط الثوب
    final centerPanel = Path()
      ..moveTo(cx - w * 0.032, bodyTop + h * 0.03)
      ..lineTo(cx + w * 0.032, bodyTop + h * 0.03)
      ..lineTo(cx + w * 0.065 + cloakSway * 0.4, h * 0.96)
      ..lineTo(cx - w * 0.065 + cloakSway * 0.4, h * 0.96)
      ..close();
    canvas.drawPath(
      centerPanel,
      Paint()
        ..color = trimColor.withOpacity(0.24)
        ..style = PaintingStyle.fill,
    );

    // خطوط التطريز الذهبي/الفضي الحريري
    final trimPaint = Paint()
      ..color = trimColor.withOpacity(0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(cx - w * 0.032, bodyTop + h * 0.03),
      Offset(cx - w * 0.065 + cloakSway * 0.4, h * 0.95),
      trimPaint,
    );
    canvas.drawLine(
      Offset(cx + w * 0.032, bodyTop + h * 0.03),
      Offset(cx + w * 0.065 + cloakSway * 0.4, h * 0.95),
      trimPaint,
    );

    // حاشية الياقة المزخرفة
    final collarPath = Path()
      ..moveTo(cx - w * 0.09, bodyTop + h * 0.01)
      ..quadraticBezierTo(cx, bodyTop + h * 0.075, cx + w * 0.09, bodyTop + h * 0.01);
    canvas.drawPath(
      collarPath,
      Paint()
        ..color = trimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintHijabDrapeBack(Canvas canvas, double w, double h, Color headColor,
      Color trimColor, double cloakSway) {
    final drape = Path()
      ..moveTo(-w * 0.16, -h * 0.06)
      ..quadraticBezierTo(-w * 0.25, h * 0.08, -w * 0.23 + cloakSway * 0.5, h * 0.30)
      ..quadraticBezierTo(0, h * 0.36, w * 0.23 + cloakSway * 0.5, h * 0.30)
      ..quadraticBezierTo(w * 0.25, h * 0.08, w * 0.16, -h * 0.06)
      ..close();

    canvas.drawPath(
      drape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [headColor, Color.lerp(headColor, Colors.black, 0.25)!],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: w * 0.28)),
    );
  }

  void _paintFace(
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
  }) {
    final faceWidth = w * (isMale ? 0.24 : 0.22);
    final faceHeight = h * 0.205;
    final faceRect = Rect.fromCenter(
      center: Offset.zero,
      width: faceWidth,
      height: faceHeight,
    );

    // تدرج الوجه المتناظر بنعومة
    final facePath = Path()
      ..addRRect(RRect.fromRectAndRadius(faceRect, Radius.circular(faceWidth * 0.48)));

    canvas.drawPath(
      facePath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.25),
          radius: 0.9,
          colors: [skinBase, skinBase, skinShadow],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(faceRect),
    );

    // حمرة خفيفة دافئة للخدود
    final blushColor = const Color(0xFFE57373).withOpacity(isMale ? 0.12 : 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-faceWidth * 0.27, faceHeight * 0.14),
        width: faceWidth * 0.20,
        height: faceHeight * 0.10,
      ),
      Paint()..color = blushColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceWidth * 0.27, faceHeight * 0.14),
        width: faceWidth * 0.20,
        height: faceHeight * 0.10,
      ),
      Paint()..color = blushColor,
    );

    // العيون الدقيقة التعبيرية
    final eyeY = -faceHeight * 0.04;
    final eyeOffsetX = faceWidth * 0.21;
    final eyeR = faceWidth * (appearance.eyeStyle == 1 ? 0.088 : 0.078);

    for (final side in [-1.0, 1.0]) {
      final ex = side * eyeOffsetX;
      canvas.save();
      canvas.translate(ex, eyeY);
      canvas.scale(1.0, eyeOpen);

      // بياض العين الناصع
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: eyeR * 2.1, height: eyeR * 1.6),
        Paint()..color = Colors.white,
      );
      // القزحية الملونة
      canvas.drawCircle(Offset.zero, eyeR * 0.78, Paint()..color = eyeColor);
      // البؤبؤ + لمعة نورانية
      canvas.drawCircle(
          Offset.zero, eyeR * 0.38, Paint()..color = const Color(0xFF111111));
      canvas.drawCircle(
        Offset(-eyeR * 0.25, -eyeR * 0.25),
        eyeR * 0.24,
        Paint()..color = Colors.white.withOpacity(0.9),
      );
      canvas.restore();

      // الجفن والرموش العليا
      final lashPaint = Paint()
        ..color = const Color(0xFF2C1E16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMale ? 1.8 : 2.3
        ..strokeCap = StrokeCap.round;
      final lashArc = Path()
        ..moveTo(ex - eyeR * 1.15, eyeY + 1)
        ..quadraticBezierTo(ex, eyeY - eyeR * 1.15 * eyeOpen, ex + eyeR * 1.15, eyeY + 1);
      canvas.drawPath(lashArc, lashPaint);

      // الحاجب (3 أنماط)
      final browY = eyeY - eyeR * (appearance.browStyle == 1 ? 1.85 : 1.55);
      final browArch = appearance.browStyle == 2 ? eyeR * 0.65 : eyeR * 0.45;
      final browPath = Path()
        ..moveTo(ex - eyeR * 1.1, browY)
        ..quadraticBezierTo(ex, browY - browArch, ex + eyeR * 1.1, browY + 0.8);
      canvas.drawPath(
        browPath,
        Paint()
          ..color = const Color(0xFF3E2723)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isMale ? 2.5 : 1.9
          ..strokeCap = StrokeCap.round,
      );
    }

    // الأنف الناعم المتناسب
    final nosePath = Path()
      ..moveTo(0, faceHeight * 0.02)
      ..quadraticBezierTo(faceWidth * 0.03, faceHeight * 0.14, -faceWidth * 0.015, faceHeight * 0.17);
    canvas.drawPath(
      nosePath,
      Paint()
        ..color = skinShadow.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    // الفم والابتسامة الدافئة (مع حركة كلام لطيفة عند التفاعل)
    final mouthY = faceHeight * 0.285;
    final mouthW = faceWidth * (appearance.mouthStyle == 1 ? 0.22 : 0.18);
    final speakOpen = speakingIntensity > 0.05
        ? (0.3 + 0.7 * (math.sin(t * 6.0).abs())) * speakingIntensity * 4.5
        : 0.0;

    final smilePath = Path()
      ..moveTo(-mouthW, mouthY)
      ..quadraticBezierTo(0, mouthY + 6.0 + speakOpen, mouthW, mouthY);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = isMale ? const Color(0xFF8D4E4E) : const Color(0xFFC25B6B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    if (speakOpen > 1.2) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, mouthY + 2.5),
          width: mouthW * 1.1,
          height: speakOpen + 1.5,
        ),
        Paint()..color = const Color(0xFF880E4F).withOpacity(0.65),
      );
    }

    // لحية خفيفة أنيقة اختيارية للذكر عند تفضيل النمط الوقور
    if (isMale && appearance.headwearStyle >= 2) {
      final beardPath = Path()
        ..moveTo(-faceWidth * 0.38, faceHeight * 0.20)
        ..quadraticBezierTo(0, faceHeight * 0.62, faceWidth * 0.38, faceHeight * 0.20)
        ..quadraticBezierTo(0, faceHeight * 0.44, -faceWidth * 0.38, faceHeight * 0.20);
      canvas.drawPath(
        beardPath,
        Paint()..color = const Color(0xFF2D1E16).withOpacity(0.75),
      );
    }
  }

  void _paintFemaleHijabFront(
      Canvas canvas, double w, double h, Color headColor, Color trimColor) {
    final hw = w * 0.135;
    final hh = h * 0.125;

    final topCap = Path()
      ..moveTo(-hw * 1.05, 0)
      ..quadraticBezierTo(-hw * 1.1, -hh * 1.15, 0, -hh * 1.12)
      ..quadraticBezierTo(hw * 1.1, -hh * 1.15, hw * 1.05, 0)
      ..quadraticBezierTo(hw * 0.55, -hh * 0.85, 0, -hh * 0.72)
      ..quadraticBezierTo(-hw * 0.55, -hh * 0.85, -hw * 1.05, 0)
      ..close();

    canvas.drawPath(
      topCap,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(headColor, Colors.white, 0.18)!, headColor],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: hw * 1.2)),
    );

    // تاج أو شريط ذهبي خفيف في أعلى الحجاب (حسب headwearStyle)
    if (appearance.headwearStyle >= 1) {
      final band = Path()
        ..moveTo(-hw * 0.85, -hh * 0.45)
        ..quadraticBezierTo(0, -hh * 0.92, hw * 0.85, -hh * 0.45);
      canvas.drawPath(
        band,
        Paint()
          ..color = trimColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
    if (appearance.headwearStyle >= 3) {
      // جوهرة/لؤلؤة الجبين الملكية
      canvas.drawCircle(
        Offset(0, -hh * 0.72),
        4.2,
        Paint()..color = trimColor,
      );
    }
  }

  void _paintMaleHeadwear(
      Canvas canvas, double w, double h, Color headColor, Color trimColor) {
    final hw = w * 0.135;
    final hh = h * 0.12;

    if (appearance.headwearStyle == 0) {
      // شعر مهذب أنيق
      final hair = Path()
        ..moveTo(-hw * 0.95, -hh * 0.2)
        ..quadraticBezierTo(-hw * 0.9, -hh * 1.05, 0, -hh * 1.0)
        ..quadraticBezierTo(hw * 0.9, -hh * 1.05, hw * 0.95, -hh * 0.2)
        ..quadraticBezierTo(0, -hh * 0.72, -hw * 0.95, -hh * 0.2);
      canvas.drawPath(hair, Paint()..color = const Color(0xFF251A14));
    } else if (appearance.headwearStyle == 1) {
      // طاقية / كوفية مطرزة بالذهب
      final kufiRect = RRect.fromLTRBAndCorners(
        -hw * 0.94,
        -hh * 1.05,
        hw * 0.94,
        -hh * 0.46,
        topLeft: Radius.circular(hw * 0.6),
        topRight: Radius.circular(hw * 0.6),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(kufiRect, Paint()..color = headColor);
      canvas.drawLine(
        Offset(-hw * 0.88, -hh * 0.56),
        Offset(hw * 0.88, -hh * 0.56),
        Paint()
          ..color = trimColor
          ..strokeWidth = 2.5,
      );
    } else {
      // عمامة أو غترة وقورة
      final turban = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -hh * 0.82),
          width: hw * 2.2,
          height: hh * 0.72,
        ),
        Radius.circular(hh * 0.36),
      );
      canvas.drawRRect(turban, Paint()..color = Colors.white.withOpacity(0.95));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -hh * 0.82),
            width: hw * 1.85,
            height: hh * 0.22,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = trimColor,
      );
    }
  }

  void _paintArmsAndHandheld(
    Canvas canvas, {
    required double w,
    required double h,
    required double cx,
    required Color robePrimary,
    required Color trimColor,
    required Color skinBase,
    required double handWave,
    required bool isPoseGreeting,
    required bool isPoseDua,
    required double t,
  }) {
    final shoulderY = h * 0.49;

    // الذراع اليمنى (تتحرك بمرونة وترحيب)
    canvas.save();
    canvas.translate(cx + w * 0.21, shoulderY);
    final rightAngle = isPoseDua
        ? -0.45 + handWave
        : (isPoseGreeting ? -0.35 + handWave * 1.5 : -0.15 + handWave);
    canvas.rotate(rightAngle);

    final sleeveRight = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.04, 0, w * 0.09, h * 0.20),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(sleeveRight, Paint()..color = robePrimary);
    canvas.drawCircle(
      Offset(w * 0.005, h * 0.21),
      w * 0.038,
      Paint()..color = skinBase,
    );
    canvas.restore();

    // الذراع اليسرى (تحمل العنصر النوراني المختار)
    canvas.save();
    canvas.translate(cx - w * 0.21, shoulderY);
    final leftAngle = isPoseDua ? 0.45 - handWave : 0.16 - handWave * 0.7;
    canvas.rotate(leftAngle);

    final sleeveLeft = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.05, 0, w * 0.09, h * 0.20),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(sleeveLeft, Paint()..color = robePrimary);
    final handCenter = Offset(-w * 0.005, h * 0.21);
    canvas.drawCircle(handCenter, w * 0.038, Paint()..color = skinBase);

    // رسم الأداة اليدوية النورانية
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
      // فانوس نوراني رقيق
      canvas.drawLine(
        Offset.zero,
        Offset(0, w * 0.06),
        Paint()
          ..color = trimColor
          ..strokeWidth = 1.6,
      );
      final glowRect = Offset(0, w * 0.115);
      canvas.drawCircle(
        glowRect,
        w * 0.08,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF59D).withOpacity(0.75),
              trimColor.withOpacity(0.0),
            ],
          ).createShader(Rect.fromCircle(center: glowRect, radius: w * 0.08)),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: glowRect, width: w * 0.055, height: w * 0.075),
          const Radius.circular(6),
        ),
        Paint()..color = trimColor,
      );
      canvas.drawCircle(
        glowRect,
        w * 0.018,
        Paint()..color = const Color(0xFFFFFDE7),
      );
    } else if (item == 2) {
      // مصحف كريم مفتوح
      final bookRect = Rect.fromCenter(
          center: Offset(0, -w * 0.02), width: w * 0.10, height: w * 0.07);
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
          ..strokeWidth = 1.6,
      );
    } else if (item == 3) {
      // سبحة من لآلئ النور
      for (int k = 0; k < 9; k++) {
        final ang = (k / 9) * math.pi * 2;
        final bx = math.cos(ang) * w * 0.036;
        final by = w * 0.05 + math.sin(ang) * w * 0.042;
        canvas.drawCircle(
          Offset(bx, by),
          3.2,
          Paint()..color = k.isEven ? trimColor : Colors.white,
        );
      }
    } else {
      // لؤلؤة فردوسية مضيئة
      canvas.drawCircle(
        Offset(0, -w * 0.03),
        w * 0.035,
        Paint()
          ..shader = const RadialGradient(
            colors: [Colors.white, Color(0xFFE0F7FA), Color(0xFF80DEEA)],
          ).createShader(Rect.fromCircle(
              center: Offset(0, -w * 0.03), radius: w * 0.035)),
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
