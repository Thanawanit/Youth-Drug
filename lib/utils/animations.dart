import 'package:flutter/material.dart';

/// A custom PageRouteBuilder that creates a premium, high-performance
/// Fade + Scale entry transition. Keeps response times snappy (<250ms).
class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Apply easing curves for biological/organic feel
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuad,
            );
            
            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// A standard widget that wraps its child with a slide/fade entry animation
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.offset = const Offset(0, 0.1),
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
