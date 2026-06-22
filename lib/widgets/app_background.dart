import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../main.dart';

class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  DotGridPainter({
    required this.color,
    this.spacing = 24.0,
    this.radius = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool showDots;
  final Gradient? customGradient;
  final List<Color>? customBlobColors;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.showDots = true,
    this.customGradient,
    this.customBlobColors,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, childWidget) {
        final isDark = state.isDarkMode;

        // Base gradient colors
        final bgGradient = customGradient ?? (isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

        // Blob colors
        final blobColor1 = customBlobColors != null && customBlobColors!.isNotEmpty
            ? customBlobColors![0]
            : (isDark
                ? AppColors.success.withOpacity(0.04)
                : AppColors.primary.withOpacity(0.04));
        final blobColor2 = customBlobColors != null && customBlobColors!.length > 1
            ? customBlobColors![1]
            : (isDark
                ? Colors.teal.withOpacity(0.03)
                : AppColors.success.withOpacity(0.04));

        // Dot color
        final dotColor = isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.025);

        return Stack(
          children: [
            // 1. Base Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: bgGradient,
              ),
            ),

            // 2. Blurred/Glowing Blobs
            // Top Right Blob
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: blobColor1,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Bottom Left Blob
            Positioned(
              bottom: -120,
              left: -120,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: blobColor2,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 3. Dot Grid Overlay
            if (showDots)
              Positioned.fill(
                child: CustomPaint(
                  painter: DotGridPainter(color: dotColor),
                ),
              ),

            // 4. Main Content Screen
            Positioned.fill(
              child: childWidget!,
            ),
          ],
        );
      },
      child: child,
    );
  }
}
