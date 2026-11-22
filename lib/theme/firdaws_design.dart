import 'package:flutter/material.dart';

/// Shared rhythm for the Arabic RTL interface. Illustrations and reading views
/// retain their own scale; application chrome uses these semantic sizes.
abstract final class FirdawsSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pageGutter = lg;
  static const double navigationClearance = 32;
  static const cardPadding = EdgeInsets.all(lg);
  static const controlPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
}

abstract final class FirdawsType {
  static const double micro = 10;
  static const double caption = 12;
  static const double label = 14;
  static const double body = 16;
  static const double section = 18;
  static const double title = 20;
  static const double headline = 24;
  static const double display = 32;
  static const double readingHeight = 1.6;
  static const double compactHeight = 1.35;
}

abstract final class FirdawsRadius {
  static const double small = 12;
  static const double control = 16;
  static const double card = 20;
  static const double sheet = 24;
}
