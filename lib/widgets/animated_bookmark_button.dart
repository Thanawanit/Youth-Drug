import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class _HeartParticle {
  final double angle;
  final double speed;
  final double size;
  _HeartParticle({required this.angle, required this.speed, required this.size});
}

class AnimatedBookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onTap;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String activeLabel;
  final String inactiveLabel;
  final Color activeColor;
  final Color inactiveColor;
  final bool isIconButtonOnly; // If true, matches layout of the bottom row in random_fact_page (vertical stack of icon + label). If false, matches inline action row (horizontal text button).

  const AnimatedBookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onTap,
    this.activeIcon = Icons.favorite_rounded,
    this.inactiveIcon = Icons.favorite_border_rounded,
    required this.activeLabel,
    required this.inactiveLabel,
    this.activeColor = Colors.redAccent,
    this.inactiveColor = AppColors.textGrey,
    this.isIconButtonOnly = false,
  });

  @override
  State<AnimatedBookmarkButton> createState() => _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<AnimatedBookmarkButton> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _particlesController;
  List<_HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.7), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _particlesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedBookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If it was toggled from unbookmarked to bookmarked, run the particle effect
    if (widget.isBookmarked && !oldWidget.isBookmarked) {
      _scaleController.forward(from: 0.0);
      _spawnParticles();
      _particlesController.forward(from: 0.0);
    } else if (!widget.isBookmarked && oldWidget.isBookmarked) {
      // Small scale pop on untoggle
      _scaleController.forward(from: 0.0);
    }
  }

  void _spawnParticles() {
    final random = Random();
    _particles = List.generate(6, (index) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 25.0 + random.nextDouble() * 25.0;
      return _HeartParticle(
        angle: angle,
        speed: speed,
        size: 8.0 + random.nextDouble() * 8.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = widget.isBookmarked;
    final iconColor = isBookmarked ? widget.activeColor : widget.inactiveColor;
    final currentIcon = isBookmarked ? widget.activeIcon : widget.inactiveIcon;
    final currentLabel = isBookmarked ? widget.activeLabel : widget.inactiveLabel;

    Widget buttonContent;

    if (widget.isIconButtonOnly) {
      buttonContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(currentIcon, color: iconColor, size: 28),
            onPressed: widget.onTap,
          ),
          Text(
            currentLabel,
            style: TextStyle(
              fontSize: 11,
              color: iconColor,
              fontWeight: FontWeight.w700,
              fontFamily: 'Prompt',
            ),
          ),
        ],
      );
    } else {
      buttonContent = TextButton.icon(
        onPressed: widget.onTap,
        icon: Icon(currentIcon, size: 16, color: iconColor),
        label: Text(
          currentLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: iconColor,
            fontFamily: 'Prompt',
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: buttonContent,
        ),
        if (_particlesController.isAnimating)
          ..._particles.map((p) {
            final double progress = _particlesController.value;
            final double distance = p.speed * progress;
            final double x = cos(p.angle) * distance;
            final double y = sin(p.angle) * distance;
            final double opacity = (1.0 - progress).clamp(0.0, 1.0);

            // Shift particle center slightly depending on button style
            final double offsetX = widget.isIconButtonOnly ? 0.0 : -32.0;
            final double offsetY = widget.isIconButtonOnly ? -12.0 : 0.0;

            return Positioned(
              left: widget.isIconButtonOnly ? x : (x + offsetX),
              top: widget.isIconButtonOnly ? (y + offsetY) : y,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                  size: p.size,
                ),
              ),
            );
          }),
      ],
    );
  }
}
