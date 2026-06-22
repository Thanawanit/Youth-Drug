import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PhoneSimulator extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const PhoneSimulator({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isWide = screenWidth > 480.0;
        final bool showSidebar = screenWidth > 900.0;

        if (!isWide) {
          // Native mobile screen, just render the app directly
          return child;
        }

        // Desktop/Tablet simulator screen
        final double appWidth = 430.0; // Standard modern phone width
        final double appHeight = constraints.maxHeight;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A), // Slate 900 base background
          body: Stack(
            children: [
              // Decorative background grid/dots
              Positioned.fill(
                child: CustomPaint(
                  painter: SimulatorGridPainter(
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
              ),
              // Subtle background ambient glows
              Positioned(
                top: -150,
                left: -150,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -200,
                right: -200,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Main Layout: Sidebar (if wide) + Centered Simulator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showSidebar) ...[
                    Expanded(
                      flex: 4,
                      child: _buildSidebar(context),
                    ),
                    // Divider line
                    Container(
                      width: 1,
                      height: double.infinity,
                      color: Colors.white10,
                    ),
                  ],
                  // Phone Simulator Container
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Container(
                        width: appWidth,
                        height: appHeight,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          border: Border.all(
                            color: const Color(0xFF1E293B), // Metallic bezel color
                            width: 10,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 36,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              Positioned.fill(child: child),

                              // Simulated Camera Notch / Dynamic Island
                              Positioned(
                                top: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 110,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Lens reflection
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F172A),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white24,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 72,
                width: 72,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YouthShield',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'ภูมิคุ้มกันสารเสพติดสำหรับเยาวชน',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36),
          const Text(
            'เรียนรู้เพื่อป้องกัน\nเข้าใจเพื่อเลือกทางที่ถูกต้อง',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'แพลตฟอร์มการเรียนรู้และเสริมสร้างภูมิคุ้มกันยาเสพติดเชิงรุกสำหรับวัยรุ่น เพื่อให้เข้าใจถึงผลกระทบต่อร่างกาย จิตใจ สังคม และเข้าใจข้อกฎหมายของสารเสพติดแต่ละประเภทอย่างถูกต้อง',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'แอปพลิเคชันนี้ได้รับการปรับปรุงสำหรับการแสดงผลบนมือถือ ระบบจึงจำลองสัดส่วนโทรศัพท์จริงเพื่อให้คุณได้รับประสบการณ์การใช้งานที่ดีที่สุด',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SimulatorGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  SimulatorGridPainter({required this.color, this.spacing = 30.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
