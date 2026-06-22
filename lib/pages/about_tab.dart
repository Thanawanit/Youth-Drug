import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';

import '../widgets/app_background.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'เกี่ยวกับโครงการ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          body: BackgroundWrapper(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Objectives Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flag_rounded, color: AppColors.success, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'วัตถุประสงค์',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'YouthShield จัดทำขึ้นเพื่อเผยแพร่ความรู้ความเข้าใจที่ถูกต้องเกี่ยวกับภัยของยาเสพติด และสร้างความตระหนักรู้แก่เยาวชน นักเรียน นักศึกษา ตลอดจนประชาชนทั่วไป เพื่อให้เห็นผลกระทบและเข้าใจแนวทางการป้องกันและแง่มุมทางกฎหมายอย่างกระชับ เข้าใจง่าย และไม่มีการกดดัน',
                          style: TextStyle(
                            fontSize: 14,
                            color: subTextColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Sources Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: isDark ? AppColors.success : AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'แหล่งอ้างอิงข้อมูลข้อมูล',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSourceItem('สถาบันบำบัดรักษาและฟื้นฟูผู้ติดยาเสพติดแห่งชาติบรมราชชนนี (สบยช.)', subTextColor),
                        _buildSourceItem('กรมสุขภาพจิต กระทรวงสาธารณสุข', subTextColor),
                        _buildSourceItem('สำนักงานคณะกรรมการป้องกันและปราบปรามยาเสพติด (สำนักงาน ป.ป.ส.)', subTextColor),
                        _buildSourceItem('พระราชบัญญัติให้ใช้ประมวลกฎหมายยาเสพติด พ.ศ. 2564', subTextColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Credits & Version Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.people_alt_rounded, color: Colors.blueAccent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'คณะผู้จัดทำ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCreditRow('พัฒนาแอปพลิเคชัน', 'นายธนวนิฐ ศรีสำแดง', textColor, subTextColor),
                        const Divider(height: 24),
                        _buildCreditRow('การออกแบบ UI/UX', 'Modern Minimalist Design Guideline', textColor, subTextColor),
                        const Divider(height: 24),
                        _buildCreditRow('เวอร์ชันแอปพลิเคชัน', 'Version 1.1.0 (Offline-First)', textColor, subTextColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildSourceItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6.0),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditRow(String title, String value, Color titleColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
