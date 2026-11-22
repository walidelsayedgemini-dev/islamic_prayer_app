import 'package:flutter/material.dart';

/// Animates the incoming tab without replacing its IndexedStack or saved state.
class CalmPageTransition extends StatefulWidget {
  const CalmPageTransition({
    super.key,
    required this.pageIndex,
    required this.child,
  });

  final int pageIndex;
  final Widget child;

  @override
  State<CalmPageTransition> createState() => _CalmPageTransitionState();
}

class _CalmPageTransitionState extends State<CalmPageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void didUpdateWidget(CalmPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve.drive(Tween<double>(begin: .85, end: 1)),
      child: SlideTransition(
        position: _curve.drive(Tween<Offset>(
          begin: const Offset(0, .012),
          end: Offset.zero,
        )),
        child: widget.child,
      ),
    );
  }
}

/// Applies the same understated transition to pushed library/game pages.
class CalmRouteTransitionsBuilder extends PageTransitionsBuilder {
  const CalmRouteTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curve = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: curve.drive(Tween<Offset>(
          begin: const Offset(.025, 0),
          end: Offset.zero,
        )),
        child: child,
      ),
    );
  }
}
