// فلتر تنعيم حركة إبرة القبلة لمنع الاهتزاز المفاجئ مع معالجة الدوران الدائري (0 - 360 درجة)
double smoothHeading(double currentHeading, double newHeading, [double alpha = 0.15]) {
  // حساب أقصر مسار زاوية بين الاتجاه الحالي والجديد
  double diff = (newHeading - currentHeading) % 360;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;

  // تطبيق معادلة التنعيم الأسية (Exponential Smoothing Filter)
  double smoothed = (currentHeading + alpha * diff) % 360;
  if (smoothed < 0) smoothed += 360;
  return smoothed;
}
