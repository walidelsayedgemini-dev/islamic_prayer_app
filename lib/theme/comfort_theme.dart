import 'package:flutter/material.dart';

/// Applies optional foreground/edge contrast improvements while retaining each theme's surfaces and palette.
abstract final class ComfortTheme {
  static ThemeData apply(ThemeData base, {required bool highContrast}) {
    if (!highContrast) return base;

    final original = base.colorScheme;
    final onSurface = _bestBlackOrWhite(original.surface);
    final onPrimary = _bestBlackOrWhite(original.primary);
    final onSecondary = _bestBlackOrWhite(original.secondary);
    final onError = _bestBlackOrWhite(original.error);
    final onPrimaryContainer = _bestBlackOrWhite(original.primaryContainer);
    final onSecondaryContainer = _bestBlackOrWhite(original.secondaryContainer);
    final onTertiaryContainer = _bestBlackOrWhite(original.tertiaryContainer);
    final highContrastEdge = _bestBlackOrWhite(original.surface);

    // Keep the palette's actual backgrounds and accents. Strengthen foreground roles only.
    final scheme = original.copyWith(
      onSurface: onSurface,
      onSurfaceVariant: onSurface,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onError: onError,
      onPrimaryContainer: onPrimaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      outline: highContrastEdge,
      outlineVariant: highContrastEdge,
    );
    final text = _recolorTextTheme(base.textTheme, onSurface);
    final controls = WidgetStatePropertyAll<Color?>(onPrimary);
    final inputTheme = base.inputDecorationTheme.copyWith(
      hintStyle: base.textTheme.bodyMedium?.copyWith(color: onSurface),
      labelStyle: base.textTheme.bodyMedium?.copyWith(color: onSurface),
      enabledBorder: base.inputDecorationTheme.enabledBorder?.copyWith(
        borderSide: BorderSide(color: highContrastEdge, width: 1.5),
      ),
      focusedBorder: base.inputDecorationTheme.focusedBorder?.copyWith(
        borderSide: BorderSide(color: highContrastEdge, width: 2),
      ),
    );

    return base.copyWith(
      colorScheme: scheme,
      textTheme: text,
      dividerColor: highContrastEdge,
      iconTheme: base.iconTheme.copyWith(color: onSurface),
      listTileTheme: base.listTileTheme.copyWith(
        textColor: onSurface,
        iconColor: onSurface,
        subtitleTextStyle: base.listTileTheme.subtitleTextStyle?.copyWith(
          color: onSurface,
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        foregroundColor: onSurface,
        iconTheme: base.appBarTheme.iconTheme?.copyWith(color: onSurface),
      ),
      inputDecorationTheme: inputTheme,
      filledButtonTheme: FilledButtonThemeData(
        style:
            base.filledButtonTheme.style?.copyWith(foregroundColor: controls),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            base.elevatedButtonTheme.style?.copyWith(foregroundColor: controls),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: base.outlinedButtonTheme.style?.copyWith(
          foregroundColor: controls,
          side: WidgetStatePropertyAll<BorderSide?>(
            BorderSide(color: highContrastEdge, width: 1.5),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: base.textButtonTheme.style?.copyWith(foregroundColor: controls),
      ),
    );
  }

  static TextTheme _recolorTextTheme(TextTheme source, Color color) =>
      source.copyWith(
        displayLarge: source.displayLarge?.copyWith(color: color),
        displayMedium: source.displayMedium?.copyWith(color: color),
        displaySmall: source.displaySmall?.copyWith(color: color),
        headlineLarge: source.headlineLarge?.copyWith(color: color),
        headlineMedium: source.headlineMedium?.copyWith(color: color),
        headlineSmall: source.headlineSmall?.copyWith(color: color),
        titleLarge: source.titleLarge?.copyWith(color: color),
        titleMedium: source.titleMedium?.copyWith(color: color),
        titleSmall: source.titleSmall?.copyWith(color: color),
        bodyLarge: source.bodyLarge?.copyWith(color: color),
        bodyMedium: source.bodyMedium?.copyWith(color: color),
        bodySmall: source.bodySmall?.copyWith(color: color),
        labelLarge: source.labelLarge?.copyWith(color: color),
        labelMedium: source.labelMedium?.copyWith(color: color),
        labelSmall: source.labelSmall?.copyWith(color: color),
      );

  static Color _bestBlackOrWhite(Color background) {
    final blackContrast = _contrastRatio(Colors.black, background);
    final whiteContrast = _contrastRatio(Colors.white, background);
    return blackContrast >= whiteContrast ? Colors.black : Colors.white;
  }

  static double _contrastRatio(Color foreground, Color background) {
    final first = foreground.computeLuminance();
    final second = background.computeLuminance();
    final lighter = first >= second ? first : second;
    final darker = first >= second ? second : first;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

/// Scales the device's (possibly nonlinear) text output by an additional user multiplier.
class ComfortTextScaler extends TextScaler {
  const ComfortTextScaler(this.systemScaler, this.additionalScale);

  final TextScaler systemScaler;
  final double additionalScale;

  @override
  double scale(double fontSize) =>
      systemScaler.scale(fontSize) * additionalScale;

  @override
  double get textScaleFactor => systemScaler.textScaleFactor * additionalScale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComfortTextScaler &&
          other.systemScaler == systemScaler &&
          other.additionalScale == additionalScale;

  @override
  int get hashCode => Object.hash(systemScaler, additionalScale);
}
