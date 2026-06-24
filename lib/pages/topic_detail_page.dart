import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui' show ImageFilter;
import '../state/app_state.dart';
import '../main.dart';
import '../constants/app_colors.dart';
import '../widgets/app_background.dart';

enum TopicType {
  definition,
  classification,
  impact,
  prevention,
  law,
}

class TopicDetailPage extends StatefulWidget {
  final TopicType topicType;

  const TopicDetailPage({
    super.key,
    required this.topicType,
  });

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

        final info = _getTopicInfo(widget.topicType);
        final total = info.sections.length;

        return BackgroundWrapper(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                info.title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  fontSize: 18 * state.fontScale,
                  fontFamily: 'Prompt',
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 1. Top progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentPageIndex + 1) / total,
                        minHeight: 6,
                        backgroundColor: isDark ? const Color(0xFF334155) : AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(info.color),
                      ),
                    ),
                  ),

                  // 2. Swipable Custom Slides Area
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      itemCount: total,
                      itemBuilder: (context, index) {
                        final sec = info.sections[index];
                        final secColor = sec.iconColor ?? info.color;

                        return _buildCustomSlideLayout(
                          widget.topicType,
                          index,
                          sec,
                          secColor,
                          isDark,
                          state.fontScale,
                          textColor,
                          cardBg,
                          borderColor,
                          total,
                        );
                      },
                    ),
                  ),

                  // 3. Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(total, (idx) {
                      final isActive = idx == _currentPageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        height: 6,
                        width: isActive ? 16 : 6,
                        decoration: BoxDecoration(
                          color: isActive ? info.color : (isDark ? Colors.white24 : AppColors.border),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),

                  // 4. Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      children: [
                        // Back Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _currentPageIndex == 0
                                  ? null
                                  : () {
                                      _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text(
                                'ก่อนหน้า',
                                style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: info.color,
                                side: BorderSide(
                                  color: _currentPageIndex == 0
                                      ? Colors.transparent
                                      : info.color,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Next/Complete Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_currentPageIndex < total - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              icon: Icon(
                                _currentPageIndex < total - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_circle_rounded,
                              ),
                              label: Text(
                                _currentPageIndex < total - 1
                                    ? 'ถัดไป'
                                    : 'เสร็จสิ้น',
                                style: const TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColors.success
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== DISPATCH LAYOUT FOR EACH SLIDE ====================
  Widget _buildKnowledgeDatabaseCard({
    required List<String> bullets,
    required Color secColor,
    required double fontScale,
    required bool isDark,
    required Color textColor,
    required Color cardBg,
    required Color borderColor,
  }) {
    if (bullets.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books_rounded, color: secColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'สาระสำคัญ',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...bullets.map((bullet) {
            IconData icon = Icons.check_circle_outline_rounded;
            if (bullet.contains('สมอง') || bullet.contains('ประสาท') || bullet.contains('จิต') || bullet.contains('โดปามีน')) {
              icon = Icons.psychology_rounded;
            } else if (bullet.contains('ร่างกาย') || bullet.contains('สุขภาพ') || bullet.contains('โรค') || bullet.contains('หายใจ') || bullet.contains('หัวใจ') || bullet.contains('ตับ') || bullet.contains('ไต')) {
              icon = Icons.health_and_safety_rounded;
            } else if (bullet.contains('กฎหมาย') || bullet.contains('โทษ') || bullet.contains('ศาล') || bullet.contains('ความผิด') || bullet.contains('คดี')) {
              icon = Icons.gavel_rounded;
            } else if (bullet.contains('ป้องกัน') || bullet.contains('เกราะ') || bullet.contains('ทักษะ')) {
              icon = Icons.shield_rounded;
            } else if (bullet.contains('สาร') || bullet.contains('เคมี')) {
              icon = Icons.science_rounded;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2.0, right: 10.0),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: secColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: secColor, size: 12),
                  ),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        fontSize: 11.5 * fontScale,
                        color: textColor,
                        height: 1.45,
                        fontFamily: 'Prompt',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionDivider({
    required Color secColor,
    required double fontScale,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            'กิจกรรมจำลอง',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12.0 * fontScale,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white70 : AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: secColor.withOpacity(0.18),
              thickness: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSlideLayout(
    TopicType type,
    int index,
    TopicSection sec,
    Color secColor,
    bool isDark,
    double fontScale,
    Color textColor,
    Color cardBg,
    Color borderColor,
    int total,
  ) {


    // Tips footer template
    Widget buildTipsFooter(String tips) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: secColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: secColor.withOpacity(0.15), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: secColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  'รู้หรือไม่ / ข้อควรรู้',
                  style: TextStyle(
                    fontSize: 11 * fontScale,
                    fontWeight: FontWeight.w800,
                    color: secColor,
                    fontFamily: 'Prompt',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tips,
              style: TextStyle(
                fontSize: 11 * fontScale,
                color: isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.85),
                height: 1.4,
                fontFamily: 'Prompt',
              ),
            ),
          ],
        ),
      );
    }

    final Widget visualWidget;
    switch (type) {
      case TopicType.definition:
        if (index == 0) {
          visualWidget = IntroOverviewVisual(
            isDark: isDark,
            fontScale: fontScale,
          );
        } else if (index == 1) {
          visualWidget = ContrastBattleVisual(isDark: isDark, fontScale: fontScale);
        } else if (index == 2) {
          visualWidget = BrainDopamineVisual(isDark: isDark, fontScale: fontScale);
        } else {
          visualWidget = ArmorShieldVisual(isDark: isDark, fontScale: fontScale);
        }
        break;

      case TopicType.classification:
        if (index == 0) {
          visualWidget = StimulantRushVisual(isDark: isDark, fontScale: fontScale);
        } else if (index == 1) {
          visualWidget = DepressantSlowVisual(isDark: isDark, fontScale: fontScale);
        } else if (index == 2) {
          visualWidget = RealityDistorterVisual(isDark: isDark, fontScale: fontScale);
        } else {
          visualWidget = MixedStormVisual(isDark: isDark, fontScale: fontScale);
        }
        break;

      case TopicType.impact:
        if (index == 0) {
          visualWidget = MoodCrackedMirror(isDark: isDark, fontScale: fontScale);
        } else if (index == 1) {
          visualWidget = HumanBodyScanner(isDark: isDark, fontScale: fontScale);
        } else if (index == 2) {
          visualWidget = FuturePathGpaVisual(isDark: isDark, fontScale: fontScale);
        } else {
          visualWidget = BrokenFamilyNetwork(isDark: isDark, fontScale: fontScale);
        }
        break;

      case TopicType.prevention:
        if (index == 0) {
          visualWidget = RefusalChatSimulator(isDark: isDark);
        } else if (index == 1) {
          visualWidget = FriendFilterVisual(isDark: isDark, fontScale: fontScale);
        } else {
          visualWidget = StressBusterVisual(isDark: isDark, fontScale: fontScale);
        }
        break;

      case TopicType.law:
        if (index == 0) {
          visualWidget = LawDecisionPathways(isDark: isDark, fontScale: fontScale);
        } else if (index == 1) {
          visualWidget = ScalesOfJusticeVisual(isDark: isDark, fontScale: fontScale);
        } else {
          visualWidget = CareerPassportStamps(isDark: isDark, fontScale: fontScale);
        }
        break;
    }

    final bool showDatabaseCard = !(type == TopicType.definition && index == 0);

    return TopicSlideScrollWrapper(
      topicType: type,
      index: index,
      sec: sec,
      secColor: secColor,
      isDark: isDark,
      fontScale: fontScale,
      textColor: textColor,
      cardBg: cardBg,
      borderColor: borderColor,
      total: total,
      databaseCard: showDatabaseCard && sec.bullets.isNotEmpty
          ? _buildKnowledgeDatabaseCard(
              bullets: sec.bullets,
              secColor: secColor,
              fontScale: fontScale,
              isDark: isDark,
              textColor: textColor,
              cardBg: cardBg,
              borderColor: borderColor,
            )
          : const SizedBox.shrink(),
      sectionDivider: showDatabaseCard
          ? _buildSectionDivider(
              secColor: secColor,
              fontScale: fontScale,
              isDark: isDark,
            )
          : const SizedBox.shrink(),
      visualWidget: visualWidget,
      tipsFooter: sec.tips != null ? buildTipsFooter(sec.tips!) : const SizedBox.shrink(),
    );
  }

  TopicInfo _getTopicInfo(TopicType type) {
    switch (type) {
      case TopicType.definition:
        return TopicInfo(
          title: 'ยาเสพติดคืออะไร?',
          icon: Icons.help_outline_rounded,
          color: AppColors.primary,
          sections: [
            TopicSection(
              title: 'บทนำ: รู้จักยาเสพติด',
              summary: 'ทำความเข้าใจนิยามพื้นฐาน วิธีการเข้าสู่ร่างกาย และกลไกทำไมมนุษย์ถึงติดยาเสพติด',
              bullets: [
                'สารเสพติดคือ สารเคมีหรือสารธรรมชาติที่เข้าสู่ร่างกายแล้วทำให้สุขภาพทรุดโทรมและจิตใจเปลี่ยนแปลงอย่างรุนแรง',
                'สามารถเข้าสู่ร่างกายได้หลายวิธี ทั้งการกิน ดม สูบ หรือฉีด ซึ่งแต่ละวิธีทำอันตรายต่ออวัยวะภายในต่างกัน',
                'สารเคมีสังเคราะห์ในปัจจุบันถูกออกแบบมาให้แฮ็กระบบประสาทส่วนกลาง ทำให้สมองเสพติดได้ง่ายและรวดเร็วอย่างยิ่ง',
              ],
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blueAccent,
              tips: 'การเรียนรู้ลักษณะพื้นฐานของสารเสพติดเป็นก้าวแรกที่ช่วยให้เราแยกแยะสารอันตรายรอบตัวในสังคมได้',
            ),
            TopicSection(
              title: 'ความหมายของยาเสพติด',
              summary: 'สารเคมีแปลกปลอมที่เข้าสู่ร่างกายแล้วส่งผลกระทบรุนแรง',
              bullets: [
                'เป็นสารเคมีที่เข้าสู่ร่างกายแล้วส่งผลกระทบต่อระบบประสาทส่วนกลางและร่างกายอย่างรุนแรง',
                'ทำให้เกิดการเปลี่ยนแปลงทางชีวภาพ ส่งผลให้ร่างกายและจิตใจมีความต้องการสารนั้นเพิ่มขึ้นเรื่อยๆ',
                'ส่งผลเสียต่ออวัยวะและพฤติกรรมโดยตรง',
              ],
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.primary,
              tips: 'ยาเสพติดต่างจากยารักษาโรคทั่วไปเพราะไม่มีผลช่วยรักษาโรค',
            ),
            TopicSection(
              title: 'กลไกสมองติดยา',
              summary: 'สารเคมีเข้าไปรบกวนระบบสมองส่วนควบคุมความสุข',
              bullets: [
                'สารเสพติดจะกระตุ้นการหลั่งสารโดปามีนในสมองส่วนระบบการให้รางวัล (Reward Pathway) มากกว่าปกติ',
                'เมื่อสมองชินกับปริมาณสารเคมีที่สูง จะลดการตอบสนองตามธรรมชาติลง ส่งผลให้รู้สึกเฉื่อยชาและไม่มีความสุขในชีวิตประจำวัน',
                'นำไปสู่สภาวะสมองติดยา (Brain Disease of Addiction) ซึ่งทำให้ผู้ใช้มีความยากเกินต้านทานที่จะปฏิเสธสารเสพติด',
              ],
              icon: Icons.psychology_rounded,
              iconColor: Colors.purpleAccent,
              tips: 'สมองวัยรุ่นยังโตไม่เต็มที่ จึงเสี่ยงต่อการพึ่งพาสารเคมีง่ายกว่าผู้ใหญ่',
            ),
            TopicSection(
              title: 'ความสำคัญของการป้องกัน',
              summary: 'การป้องกันและตัดสินใจไม่ยุ่งเกี่ยวแต่แรกปลอดภัยที่สุด',
              bullets: [
                'การป้องกันตั้งแต่ต้นช่วยป้องกันความเสียหายถาวรของระบบสมองที่ยังพัฒนาไม่เต็มที่ในวัยรุ่น',
                'ลดโอกาสที่จะเกิดพฤติกรรมเสี่ยงอื่น ๆ เช่น การหลงผิด การกระทำผิดกฎหมาย หรือการประสบอุบัติเหตุ',
                'สร้างทักษะชีวิตและภูมิคุ้มกันทางจิตใจ',
              ],
              icon: Icons.shield_rounded,
              iconColor: AppColors.success,
              tips: 'การป้องกันตนเองและปฏิเสธแต่ต้น ง่ายกว่าการดูแลรักษายามสาย',
            ),
          ],
        );

      case TopicType.classification:
        return TopicInfo(
          title: 'ประเภทสารเสพติด',
          icon: Icons.category_rounded,
          color: Colors.amber,
          sections: [
            TopicSection(
              title: '1. ประเภทกระตุ้นประสาท',
              summary: 'เร่งระบบการทำงานของสมองและหัวใจให้เร็วขึ้น',
              bullets: [
                'เร่งระบบการทำงานของหัวใจและสมองส่วนกลาง ทำให้ร่างกายรู้สึกตื่นตัวและมีพลังงานชั่วคราว',
                'ทำให้เกิดอาการหัวใจเต้นเร็ว ความดันโลหิตสูง รูม่านตาขยาย นอนไม่หลับ และมีความก้าวร้าวเพิ่มขึ้น',
                'เมื่อหมดฤทธิ์ยาจะเกิดอาการสลึมสลือ ร่างกายเหนื่อยล้าสะสม และเกิดภาวะอารมณ์ดิ่งหรือซึมเศร้าอย่างรุนแรง',
              ],
              icon: Icons.bolt_rounded,
              iconColor: Colors.amber,
              tips: 'สารกระตุ้นประสาทมักทำให้ร่างกายเหนื่อยล้าหนักหลังหมดฤทธิ์',
            ),
            TopicSection(
              title: '2. ประเภทกดประสาท',
              summary: 'ชะลอการส่งสัญญาณสมองและลดการตอบสนองลง',
              bullets: [
                'ลดประสิทธิภาพและการส่งสัญญาณของสมอง ทำให้ร่างกายและระบบหายใจทำงานช้าลง',
                'ส่งผลให้เกิดอาการเซื่องซึม ง่วงนอน ร่างกายตอบสนองช้าลงอย่างเห็นได้ชัด และสติสัมปชัญญะลดลง',
                'หากได้รับปริมาณมากเกินไป อาจส่งผลให้หมดสติ หยุดหายใจ และเสียชีวิตได้อย่างเฉียบพลัน',
              ],
              icon: Icons.hotel_rounded,
              iconColor: Colors.blueAccent,
              tips: 'แอลกอฮอล์ก็จัดอยู่ในกลุ่มกดประสาทที่ลดสติสัมปชัญญะ',
            ),
            TopicSection(
              title: '3. ประเภทหลอนประสาท',
              summary: 'บิดเบือนการรับรู้ภาพ เสียง และประสาทสัมผัส',
              bullets: [
                'บิดเบือนการทำงานของสมองส่วนรับความรู้สึก ทำให้รับรู้ภาพ เสียง และประสาทสัมผัสผิดเพี้ยนไปจากความจริง',
                'ทำให้เกิดอาการหูแว่ว เห็นภาพหลอน วิตกกังวลอย่างรุนแรง ตื่นตระหนก และมีพฤติกรรมคลุ้มคลั่ง',
                'บ่อยครั้งทำให้ผู้ใช้ขาดความยับยั้งชั่งใจ จนทำร้ายร่างกายตนเองหรือผู้อื่นโดยไม่รู้ตัว',
              ],
              icon: Icons.bubble_chart_rounded,
              iconColor: Colors.deepPurpleAccent,
              tips: 'ไอระเหยจากสารเคมีบางชนิดสามารถทำลายเซลล์สมองระยะยาว',
            ),
            TopicSection(
              title: '4. ประเภทผสมผสาน',
              summary: 'ออกฤทธิ์หลายรูปแบบร่วมกัน ทั้งกระตุ้น กด หรือหลอน',
              bullets: [
                'ออกฤทธิ์ร่วมกันหลายรูปแบบในเวลาเดียวกัน โดยอาจทั้งกระตุ้น กด หรือหลอนประสาทตามปริมาณและชนิดของสาร',
                'ทำให้ผู้เสพมีอารมณ์แปรปรวนอย่างรุนแรง สับสนในเวลาและสถานที่ และเกิดความเครียดสะสมทางจิตใจ',
                'ส่งผลต่อระบบการตัดสินใจและการเรียนรู้ของเยาวชน ทำให้การพัฒนาสมองหยุดชะงัก',
              ],
              icon: Icons.sync_rounded,
              iconColor: AppColors.success,
              tips: 'กัญชาและกระท่อมมีสารเคมีที่ออกฤทธิ์ผสมผสานหลายด้าน',
            ),
          ],
        );

      case TopicType.impact:
        return TopicInfo(
          title: 'ผลกระทบ 4 ด้าน',
          icon: Icons.heart_broken_rounded,
          color: Colors.redAccent,
          sections: [
            TopicSection(
              title: 'ด้านจิตใจและอารมณ์',
              summary: 'ส่งผลกระทบต่ออารมณ์ความรู้สึกและสภาวะจิตใจ',
              bullets: [
                'รบกวนสมดุลของสารเคมีในสมองอย่างรุนแรง ทำให้ไม่สามารถควบคุมอารมณ์ของตนเองได้ในชีวิตประจำวัน',
                'เกิดภาวะหวาดระแวง อารมณ์ฉุนเฉียว และเสี่ยงต่อโรคซึมเศร้า',
                'ส่งผลระยะยาวทำให้ระบบความนึกคิดเสื่อมลง เกิดสภาวะทางจิตเวชเรื้อรังที่จำเป็นต้องรักษาทางการแพทย์',
              ],
              icon: Icons.psychology_rounded,
              iconColor: Colors.deepPurple,
              tips: 'ความรู้สึกแปรปรวนมักเกิดจากสารเคมีในสมองทำงานผิดปกติ',
            ),
            TopicSection(
              title: 'ด้านร่างกายและสุขภาพ',
              summary: 'ส่งผลเสียต่อการทำงานของอวัยวะภายในร่างกาย',
              bullets: [
                'ทำลายระบบภูมิคุ้มกันและส่งผลเสียต่อการทำงานของอวัยวะภายใน เช่น ตับ ไต ปอด และหัวใจ',
                'ทำให้ร่างกายทรุดโทรม น้ำหนักลดลงอย่างรวดเร็ว ผิวพรรณทรุดโทรมลงอย่างชัดเจน และดูแก่กว่าวัยจริงอย่างชัดเจน',
                'มีความเสี่ยงสูงที่จะติดโรคทางกระแสเลือดและเสียชีวิตเฉียบพลันจากปริมาณสารที่เกินขนาด',
              ],
              icon: Icons.favorite_rounded,
              iconColor: Colors.redAccent,
              tips: 'ร่างกายทรุดโทรมมักเป็นสัญญาณเตือนว่าอวัยวะภายในกำลังทำงานหนัก',
            ),
            TopicSection(
              title: 'ด้านการเรียนและอนาคต',
              summary: 'ส่งผลต่อสมาธิและโอกาสในการศึกษาเรียนรู้',
              bullets: [
                'ทำลายเซลล์สมองที่เกี่ยวข้องกับสมาธิ ความจำระยะสั้น และทักษะการเรียนรู้อย่างต่อเนื่อง',
                'ส่งผลให้ประสิทธิภาพในการเรียนตกลงอย่างรวดเร็ว ขาดเรียนบ่อยครั้ง และขาดความสนใจต่อเป้าหมายชีวิต',
                'เสียโอกาสในการศึกษาต่อ การสมัครทุนการศึกษา และการเข้าทำงานในสายอาชีพที่มั่นคง',
              ],
              icon: Icons.school_rounded,
              iconColor: Colors.blueAccent,
              tips: 'สมองที่แจ่มใสช่วยให้จดจำและเรียนรู้สิ่งใหม่ๆ ได้รวดเร็วกว่า',
            ),
            TopicSection(
              title: 'ด้านครอบครัวและสังคม',
              summary: 'กระทบต่อความอบอุ่นและมิตรภาพของคนรอบข้าง',
              bullets: [
                'สร้างความวิตกกังวลและความตึงเครียดภายในครอบครัว นำไปสู่ความขัดแย้งและการสูญเสียความอบอุ่น',
                'พฤติกรรมก้าวร้าวหรือเก็บตัวทำให้สูญเสียมิตรภาพและความไว้วางใจจากเพื่อนและคนรอบข้าง',
                'อาจถูกปฏิเสธโอกาสในการเข้าร่วมสังคมปกติ และเสี่ยงที่จะเข้าไปพัวพันกับกลุ่มอาชญากรรม',
              ],
              icon: Icons.groups_rounded,
              iconColor: Colors.teal,
              tips: 'ปัญหาที่เกิดขึ้นสามารถปรับความเข้าใจกันได้ด้วยการพูดคุย',
            ),
          ],
        );

      case TopicType.prevention:
        return TopicInfo(
          title: 'แนวทางและทักษะป้องกัน',
          icon: Icons.shield_rounded,
          color: AppColors.success,
          sections: [
            TopicSection(
              title: '1. ทักษะการปฏิเสธที่หนักแน่น',
              summary: 'พูดปฏิเสธอย่างมีชั้นเชิงและรักษาจุดยืนของตนเอง',
              bullets: [
                'เป็นทักษะสำคัญในการรักษาความปลอดภัยของตนเองเมื่อต้องเผชิญหน้ากับกลุ่มเพื่อนหรือแรงกดดันทางสังคม',
                'เน้นการสื่อสารด้วยน้ำเสียงที่มั่นคง สุภาพ และมีสายตาที่หนักแน่นเพื่อแสดงเจตจำนงที่แน่วแน่',
                'ใช้วิธีปฏิเสธควบคู่กับการบอกเหตุผลส่วนตัวสั้นๆ แล้วชักชวนไปทำกิจกรรมอื่นที่สร้างสรรค์แทนทันที',
              ],
              icon: Icons.cancel_outlined,
              iconColor: Colors.redAccent,
              tips: 'การปฏิเสธอย่างชัดเจนช่วยกรองเพื่อนที่เคารพความคิดเห็นของเราจริงๆ',
            ),
            TopicSection(
              title: '2. การคบเพื่อน',
              summary: 'พาตนเองไปอยู่ในกลุ่มเพื่อนที่มีทัศนคติเชิงบวก',
              bullets: [
                'การคบหากลุ่มเพื่อนที่มีทัศนคติเชิงบวกจะช่วยส่งเสริมสุขภาพ จิตใจ และกระตุ้นพฤติกรรมการเรียนรู้ที่ดี',
                'เพื่อนที่ดีจะยอมรับในตัวตน มีความเคารพในการตัดสินใจ และคอยเตือนสติเมื่อเกิดสิ่งผิดพลาด',
                'ร่วมมือกันทำกิจกรรมสร้างสรรค์ เช่น การเล่นกีฬา เล่นดนตรี หรือติวหนังสือเรียน ช่วยหันเหความสนใจจากสิ่งเสพติดและพฤติกรรมเสี่ยง',
              ],
              icon: Icons.people_rounded,
              iconColor: Colors.amber,
              tips: 'การเลือกคบเพื่อนส่งผลต่อความสุขและพฤติกรรมของเราเกือบทั้งหมด',
            ),
            TopicSection(
              title: '3. การจัดการความเครียดเชิงบวก',
              summary: 'ระบายความเครียดสะสมด้วยวิธีการที่ปลอดภัยต่อสุขภาพ',
              bullets: [
                'ความเครียดจากการเรียนและชีวิตส่วนตัวเป็นเรื่องปกติ การหาวิธีผ่อนคลายที่สร้างสรรค์เป็นเกราะป้องกันที่ดี',
                'เรียนรู้วิธีจัดการอารมณ์และจิตใจอย่างถูกต้อง เช่น การออกกำลังกาย นั่งสมาธิ หรือทำงานศิลปะ',
                'การระบายความเครียดกับคุณครูแนะแนว ครอบครัว หรือผู้ใหญ่ที่ไว้ใจ ช่วยให้ได้คำปรึกษาและทางแก้ไขที่ปลอดภัย',
              ],
              icon: Icons.spa_rounded,
              iconColor: Colors.teal,
              tips: 'สายด่วนสุขภาพจิต โทร 1323 พร้อมให้คำปรึกษาตลอด 24 ชั่วโมง',
            ),
          ],
        );

      case TopicType.law:
        return TopicInfo(
          title: 'เข้าใจข้อกฎหมายน่ารู้',
          icon: Icons.gavel_rounded,
          color: Colors.blueAccent,
          sections: [
            TopicSection(
              title: 'แนวทางบำบัดรักษาพยาบาล',
              summary: 'มุมมองทางกฎหมายที่ให้โอกาสฟื้นฟูช่วยเหลือเยาวชน',
              bullets: [
                'กฎหมายเน้นหลักการ "ผู้เสพคือผู้ป่วย" มุ่งเน้นการส่งตัวเข้าบำบัดฟื้นฟูทางการแพทย์แทนการส่งเข้าคุก',
                'ผู้ที่สมัครใจเข้ารับการบำบัดและรักษาตัวจนครบกำหนด จะไม่มีการบันทึกประวัติอาชญากรรมในระบบตำรวจ',
                'กระบวนการรักษามุ่งเน้นฟื้นฟูสภาพร่างกายและจิตใจอย่างปลอดภัย เพื่อให้กลับคืนสู่สังคมได้อย่างปกติสุข',
              ],
              icon: Icons.health_and_safety_rounded,
              iconColor: AppColors.success,
              tips: 'การส่งเสริมให้ผู้รับการฟื้นฟูกลับตัวช่วยสร้างโอกาสใหม่ในสังคม',
            ),
            TopicSection(
              title: 'บทลงโทษของผู้กระทำผิดร้ายแรง',
              summary: 'มาตรการเด็ดขาดเพื่อปราบปรามขบวนการค้ายาเสพติด',
              bullets: [
                'กฎหมายมีบทลงโทษสถานหนักต่อผู้ผลิต นำเข้า ส่งออก หรือครอบครองสารเสพติดเพื่อจัดจำหน่าย',
                'ผู้ที่มีส่วนเกี่ยวข้องกับการส่งพัสดุผิดกฎหมายหรือรับจ้างขนส่ง จะโดนโทษทางคดีอาญาและมาตรการยึดทรัพย์',
                'การมีส่วนร่วมในวงจรการค้าจะถูกตัดสิทธิ์การบำบัด และต้องได้รับโทษจำคุกในเรือนจำสถานเดียว',
              ],
              icon: Icons.gavel_rounded,
              iconColor: Colors.redAccent,
              tips: 'การหลีกเลี่ยงไม่ยุ่งเกี่ยวกับขบวนการค้าช่วยรักษาประวัติสะอาดร้อยเปอร์เซ็นต์',
            ),
            TopicSection(
              title: 'อนาคตและหน้าที่ในการป้องกัน',
              summary: 'รักษาความประพฤติที่ดีเพื่อเป้าหมายและอาชีพการงาน',
              bullets: [
                'ประวัติคดีอาญาที่เกี่ยวข้องกับสารเสพติดจะถูกบันทึกถาวร ส่งผลให้ขาดคุณสมบัติในการทำงานภาครัฐและเอกชน',
                'การมีประวัติคดีความอาจถูกปฏิเสธวีซ่าเดินทาง ศึกษาต่อต่างประเทศ หรือไม่ผ่านการตรวจสอบประวัติพื้นหลัง',
                'การดูแลประวัติตนเองให้สะอาดสะท้อนถึงวุฒิภาวะ เป็นการเปิดกว้างสำหรับทุกโอกาสสำคัญในชีวิตและการงาน',
              ],
              icon: Icons.card_membership_rounded,
              iconColor: Colors.amber,
              tips: 'ประวัติการเรียนและความประพฤติที่ดีคือหนังสือเดินทางสู่อนาคตที่สดใส',
            ),
          ],
        );
    }
  }
}

class TopicSlideScrollWrapper extends StatefulWidget {
  final TopicType topicType;
  final int index;
  final TopicSection sec;
  final Color secColor;
  final bool isDark;
  final double fontScale;
  final Color textColor;
  final Color cardBg;
  final Color borderColor;
  final int total;
  final Widget databaseCard;
  final Widget sectionDivider;
  final Widget visualWidget;
  final Widget tipsFooter;

  const TopicSlideScrollWrapper({
    super.key,
    required this.topicType,
    required this.index,
    required this.sec,
    required this.secColor,
    required this.isDark,
    required this.fontScale,
    required this.textColor,
    required this.cardBg,
    required this.borderColor,
    required this.total,
    required this.databaseCard,
    required this.sectionDivider,
    required this.visualWidget,
    required this.tipsFooter,
  });

  @override
  State<TopicSlideScrollWrapper> createState() => _TopicSlideScrollWrapperState();
}

class _TopicSlideScrollWrapperState extends State<TopicSlideScrollWrapper> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Trigger a rebuild after layout to evaluate maxScrollExtent accurately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSimulation = !(widget.topicType == TopicType.definition && widget.index == 0);
    
    // Shared header for custom layouts
    Widget slideHeader = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: widget.secColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'หัวข้อ ${widget.index + 1} จาก ${widget.total}',
            style: TextStyle(
              fontSize: 10 * widget.fontScale,
              fontWeight: FontWeight.w800,
              color: widget.secColor,
              fontFamily: 'Prompt',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(widget.sec.icon ?? Icons.bookmark_rounded, color: widget.secColor, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.sec.title,
                style: TextStyle(
                  fontSize: 16 * widget.fontScale,
                  fontWeight: FontWeight.w900,
                  color: widget.textColor,
                  fontFamily: 'Prompt',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.sec.summary,
          style: TextStyle(
            fontSize: 13 * widget.fontScale,
            fontWeight: FontWeight.w500,
            color: widget.isDark ? Colors.white70 : AppColors.textGrey,
            fontFamily: 'Prompt',
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );

    if (!hasSimulation) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            slideHeader,
            widget.visualWidget,
            widget.tipsFooter,
          ],
        ),
      );
    }

    final double maxScroll = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 200.0;
    final bool isScrollable = maxScroll > 50.0;
    
    // Active offset starts when user scrolls past 10px, up to 140px of scrolling
    final double activeOffset = (_scrollOffset - 10.0).clamp(0.0, 140.0);
    final double percent = isScrollable ? (activeOffset / 140.0) : 1.0;
    
    final double bottomOpacity = isScrollable ? (0.15 + 0.85 * percent) : 1.0;
    final double translateY = isScrollable ? (25.0 * (1.0 - percent)) : 0.0;
    final double blurSigma = isScrollable ? (4.5 * (1.0 - percent)) : 0.0;

    Widget bottomSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.sectionDivider,
        widget.visualWidget,
        widget.tipsFooter,
      ],
    );

    Widget animatedBottomSection = Opacity(
      opacity: bottomOpacity,
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: blurSigma > 0.1
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: bottomSection,
              )
            : bottomSection,
      ),
    );

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Top Section (Header + Database Card)
          slideHeader,
          widget.databaseCard,

          // 2. Standard spacing
          const SizedBox(height: 16),

          // 3. Bottom Section (Section Divider + Simulation + Tips)
          animatedBottomSection,
          
          if (isScrollable) const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class TopicInfo {
  final String title;
  final IconData icon;
  final Color color;
  final List<TopicSection> sections;

  TopicInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.sections,
  });
}

class TopicSection {
  final String title;
  final String summary;
  final List<String> bullets;
  final IconData? icon;
  final Color? iconColor;
  final String? tips;

  TopicSection({
    required this.title,
    required this.summary,
    required this.bullets,
    this.icon,
    this.iconColor,
    this.tips,
  });
}

// ============================================================================
// WIDGET 0.9: Intro5W1HVisual (Introductory What, Where, When, How Interactive Display)
// ============================================================================
// ============================================================================
// WIDGET 0.9: IntroOverviewVisual (Overview & Learning Roadmap Interactive Display)
// ============================================================================
class IntroOverviewVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const IntroOverviewVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<IntroOverviewVisual> createState() => _IntroOverviewVisualState();
}

class _IntroOverviewVisualState extends State<IntroOverviewVisual> {
  int _activeTab = 0; // 0: นิยามหลัก, 1: การรับสาร, 2: ทำไมถึงติด

  final List<Map<String, dynamic>> _tabsData = [
    {
      'title': 'นิยามหลัก',
      'label': 'ความหมาย',
      'icon': Icons.menu_book_rounded,
      'color': Colors.blueAccent,
      'content': 'ยาเสพติด คือ สารหรือวัตถุที่เมื่อเข้าสู่ร่างกายแล้วส่งผลต่อสมอง ระบบประสาท อารมณ์ หรือพฤติกรรม และอาจทำให้เกิดการพึ่งพาหรือการเสพติดได้ ทั้งนี้สารเหล่านี้จะเข้าไปปรับเปลี่ยนสมดุลของสมองในระยะยาว',
      'subinfo': 'ส่งผลกระทบต่ออวัยวะและพฤติกรรมโดยตรง',
    },
    {
      'title': 'การรับสาร',
      'label': 'ช่องทางรับยา',
      'icon': Icons.vaccines_rounded,
      'color': Colors.amber,
      'content': 'สารเคมีเข้าสู่ร่างกายได้หลายทาง เช่น การรับประทาน, การสูดดมหรือสูบ (ดูดซึมผ่านปอดรวดเร็ว), การฉีด (เข้ากระแสเลือดโดยตรง), และการดูดซึมผ่านเยื่อบุผิว ซึ่งทุกเส้นทางส่งพิษถึงสมองอย่างรวดเร็ว',
      'subinfo': 'การฉีดมีความเสี่ยงติดเชื้อในกระแสเลือดและอันตรายเฉียบพลันสูงสุด',
    },
    {
      'title': 'ทำไมถึงติด',
      'label': 'แฮ็กสมอง',
      'icon': Icons.psychology_rounded,
      'color': Colors.redAccent,
      'content': 'สารเคมีแฮ็กระบบรางวัลของสมองเหนี่ยวนำให้หลั่งโดปามีนปริมาณสูงเฉียบพลัน ทำให้สมองเรียนรู้พฤติกรรมนี้และเกิดการปรับตัวทางสรีรวิทยาจนนำไปสู่ความต้องการใช้ซ้ำเพื่อพยุงอารมณ์และลดความทรมาน',
      'subinfo': 'สมองที่ถูกปรับตัวจะสูญเสียการควบคุมตามธรรมชาติในที่สุด',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeColor = _tabsData[_activeTab]['color'] as Color;
    final cardColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final activeTabBg = activeColor.withValues(alpha: 0.12);
    final borderColor = widget.isDark ? const Color(0xFF334155) : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_rounded, color: widget.isDark ? const Color(0xFFC084FC) : AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'ข้อมูลเบื้องต้นเกี่ยวกับสารเสพติด:',
                style: TextStyle(
                  fontSize: 13.5 * widget.fontScale,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Prompt',
                  color: widget.isDark ? Colors.white70 : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tab bar selector
          Row(
            children: List.generate(3, (index) {
              final tab = _tabsData[index];
              final isActive = _activeTab == index;
              final Color tabColor = tab['color'] as Color;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? activeTabBg : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? tabColor : borderColor,
                        width: isActive ? 1.8 : 1.0,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: tabColor.withValues(alpha: widget.isDark ? 0.15 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          color: isActive ? tabColor : (widget.isDark ? Colors.white60 : AppColors.textGrey),
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tab['title'] as String,
                          style: TextStyle(
                            fontSize: 11 * widget.fontScale,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Prompt',
                            color: isActive ? tabColor : (widget.isDark ? Colors.white70 : AppColors.textDark),
                          ),
                        ),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 9.0 * widget.fontScale,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                            color: isActive ? tabColor : (widget.isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 14),
          
          // Info display area
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: activeColor.withValues(alpha: 0.25), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: widget.isDark ? 0.08 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(_tabsData[_activeTab]['icon'] as IconData, color: activeColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _tabsData[_activeTab]['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 13.5 * widget.fontScale,
                        fontWeight: FontWeight.w900,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _tabsData[_activeTab]['content'] as String,
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 12.0 * widget.fontScale,
                    color: widget.isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: activeColor, size: 13),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _tabsData[_activeTab]['subinfo'] as String,
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 10.0 * widget.fontScale,
                            color: activeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

// WIDGET 1.0: ContrastBattleVisual
// ============================================================================
class _SortItem {
  final String name;
  final String desc;
  final bool isMedicine;
  _SortItem(this.name, this.desc, this.isMedicine);
}

class _CrystalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0.0); // top point
    path.lineTo(size.width, size.height * 0.3); // upper right
    path.lineTo(size.width * 0.8, size.height * 0.9); // lower right
    path.lineTo(size.width * 0.5, size.height); // bottom point
    path.lineTo(size.width * 0.2, size.height * 0.9); // lower left
    path.lineTo(0.0, size.height * 0.3); // upper left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ContrastBattleVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const ContrastBattleVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<ContrastBattleVisual> createState() => _ContrastBattleVisualState();
}

class _ContrastBattleVisualState extends State<ContrastBattleVisual> {
  late List<_SortItem> _items;
  int _currentIndex = 0;
  int _score = 0;
  bool _gameCompleted = false;
  
  bool _isHoveringLeft = false;
  bool _isHoveringRight = false;
  
  String? _feedbackText;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _items = [
        _SortItem('พาราเซตามอล', 'ยาสามัญประจำบ้านสำหรับลดไข้และบรรเทาอาการปวดทั่วไป ปลอดภัยหากใช้ตามปริมาณที่กำหนด', true),
        _SortItem('ยาบ้า (เมทแอมเฟตามีน)', 'สารกระตุ้นประสาทรุนแรง ทำลายเซลล์สมอง ก่อให้เกิดอาการระแวง คุ้มคลั่ง และติดง่ายมาก', false),
        _SortItem('ยาปฏิชีวนะ (ยาฆ่าเชื้อ)', 'ใช้สำหรับยับยั้งและทำลายเชื้อแบคทีเรีย ต้องทานให้ครบตามคำแนะนำของแพทย์เพื่อป้องกันการดื้อยา', true),
        _SortItem('เฮโรอีน', 'สารเสพติดให้โทษประเภท 1 ออกฤทธิ์กดประสาทรุนแรง เสี่ยงต่อการหยุดหายใจเฉียบพลัน', false),
        _SortItem('วัคซีนป้องกันโรค', 'สารชีววัตถุที่ใช้กระตุ้นร่างกายให้สร้างภูมิคุ้มกันเพื่อรับมือโรคระบาดร้ายแรงในอนาคต', true),
        _SortItem('ยาไอซ์', 'เมทแอมเฟตามีนในรูปแบบผลึกคริสตัลบริสุทธิ์ ทำลายสุขภาพจิตอย่างรุนแรงและก่อให้เกิดโรคจิตประสาท', false),
      ]..shuffle();
      _currentIndex = 0;
      _score = 0;
      _gameCompleted = false;
      _feedbackText = null;
      _lastCorrect = null;
    });
  }

  void _handleSort(bool choice) {
    if (_gameCompleted) return;
    
    final currentItem = _items[_currentIndex];
    final isCorrect = currentItem.isMedicine == choice;
    
    setState(() {
      if (isCorrect) {
        _score++;
        _lastCorrect = true;
        _feedbackText = 'ถูกต้อง! "${currentItem.name}" คือ ${choice ? 'ยารักษาโรค' : 'ยาเสพติด'}';
      } else {
        _lastCorrect = false;
        _feedbackText = 'ไม่ถูกต้อง! "${currentItem.name}" คือ ${currentItem.isMedicine ? 'ยารักษาโรค' : 'ยาเสพติด'}';
      }
      
      _currentIndex++;
      if (_currentIndex >= _items.length) {
        _gameCompleted = true;
      }
    });
  }

  // --- SUBSTANCE SHAPE BUILDERS ---

  Widget _buildParacetamol(String name) {
    return Container(
      width: 155,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
          width: 2,
        ),
        gradient: LinearGradient(
          colors: widget.isDark
              ? [const Color(0xFFF1F5F9), const Color(0xFF94A3B8)]
              : [Colors.white, const Color(0xFFE2E8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              width: 1.5,
              height: 52,
              color: widget.isDark ? Colors.white30 : Colors.black12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYaba(String name) {
    return SizedBox(
      width: 155,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC2410C), width: 2),
              gradient: const RadialGradient(
                colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                radius: 0.65,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'WY',
              style: TextStyle(
                color: Color(0xFF7C2D12),
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 10.5 * widget.fontScale,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? Colors.redAccent : Colors.red.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAntibiotic(String name) {
    return Container(
      width: 155,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: widget.isDark ? Colors.white30 : Colors.grey.shade300,
          width: 1.8,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEF4444), Color(0xFFEF4444),
            Color(0xFFFBBF24), Color(0xFFFBBF24),
          ],
          stops: [0.0, 0.5, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          name,
          style: const TextStyle(
            fontFamily: 'Prompt',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(0, 1.5),
                blurRadius: 3,
              ),
            ],
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildHeroin(String name) {
    return SizedBox(
      width: 155,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 85,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.isDark ? Colors.white38 : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 10.5 * widget.fontScale,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? Colors.redAccent : Colors.red.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccine(String name) {
    return SizedBox(
      width: 155,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 14,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey.shade500, width: 1),
                    vertical: BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isDark ? Colors.white38 : Colors.grey.shade400,
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: widget.isDark
                        ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                        : [Colors.white, const Color(0xFFF1F5F9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withOpacity(0.65),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.vaccines_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 10.5 * widget.fontScale,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? Colors.lightBlueAccent : Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIce(String name) {
    return SizedBox(
      width: 155,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipPath(
            clipper: _CrystalClipper(),
            child: Container(
              width: 65,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.9),
                    Colors.white.withOpacity(0.95),
                    const Color(0xFFE0F2FE).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.diamond_rounded,
                  color: Colors.cyan,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 10.5 * widget.fontScale,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? Colors.cyanAccent : Colors.cyan.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePill(_SortItem item, {required bool isDragging, bool isPlaceholder = false}) {
    final name = item.name;
    
    Widget shape;
    if (name.contains('พารา')) {
      shape = _buildParacetamol(name);
    } else if (name.contains('ยาบ้า')) {
      shape = _buildYaba(name);
    } else if (name.contains('ปฏิชีวนะ')) {
      shape = _buildAntibiotic(name);
    } else if (name.contains('เฮโรอีน')) {
      shape = _buildHeroin(name);
    } else if (name.contains('วัคซีน')) {
      shape = _buildVaccine(name);
    } else if (name.contains('ยาไอซ์')) {
      shape = _buildIce(name);
    } else {
      shape = Container(
        width: 155,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(name, textAlign: TextAlign.center),
      );
    }

    if (isPlaceholder) {
      return Opacity(
        opacity: 0.25,
        child: shape,
      );
    }

    return AnimatedOpacity(
      opacity: isDragging ? 0.75 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: shape,
    );
  }

  Widget _buildBucket({
    required String label,
    required bool isMedicine,
    required bool isHovered,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? color.withOpacity(0.12)
                : (widget.isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHovered ? color : (widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
              width: isHovered ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11.5 * widget.fontScale,
                  fontWeight: FontWeight.w900,
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final bool perfectScore = _score == _items.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: perfectScore 
              ? AppColors.success.withOpacity(0.5) 
              : Colors.blueAccent.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            perfectScore ? Icons.stars_rounded : Icons.check_circle_outline_rounded,
            color: perfectScore ? Colors.amber : AppColors.success,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            perfectScore ? 'ยอดเยี่ยมที่สุด!' : 'แยกแยะได้ดีมาก!',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 16 * widget.fontScale,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'คุณจำแนกประเภท ยา vs ยาเสพติด ถูกต้อง\n$_score จาก ${_items.length} รายการ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12 * widget.fontScale,
              color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.replay_rounded),
            label: const Text(
              'เล่นใหม่อีกครั้ง',
              style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: perfectScore ? Colors.amber : AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameCompleted) {
      return _buildCompletionScreen();
    }
    
    final currentItem = _items[_currentIndex];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'จัดประเภทการ์ด: ${_currentIndex + 1}/${_items.length}',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.blueGrey.shade300 : Colors.grey.shade600,
                ),
              ),
              Text(
                'คะแนน: $_score/${_items.length}',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: widget.isDark ? Colors.blueGrey.shade400 : Colors.blueGrey.shade500,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'คำใบ้รายละเอียดสาร:',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 9.5 * widget.fontScale,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentItem.desc,
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 11 * widget.fontScale,
                          height: 1.45,
                          color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DragTarget<bool>(
                  onWillAcceptWithDetails: (details) {
                    setState(() => _isHoveringLeft = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => _isHoveringLeft = false);
                  },
                  onAcceptWithDetails: (details) {
                    setState(() => _isHoveringLeft = false);
                    _handleSort(true);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return _buildBucket(
                      label: 'ยารักษาโรค',
                      isMedicine: true,
                      isHovered: _isHoveringLeft,
                      color: const Color(0xFF10B981),
                      icon: Icons.healing_rounded,
                      onTap: () => _handleSort(true),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DragTarget<bool>(
                  onWillAcceptWithDetails: (details) {
                    setState(() => _isHoveringRight = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => _isHoveringRight = false);
                  },
                  onAcceptWithDetails: (details) {
                    setState(() => _isHoveringRight = false);
                    _handleSort(false);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return _buildBucket(
                      label: 'ยาเสพติด',
                      isMedicine: false,
                      isHovered: _isHoveringRight,
                      color: const Color(0xFFEF4444),
                      icon: Icons.coronavirus_rounded,
                      onTap: () => _handleSort(false),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ลากสารด้านล่างขึ้นไปยังกล่องจัดประเภท หรือแตะกล่องเป้าหมาย',
            style: TextStyle(
              fontSize: 10 * widget.fontScale,
              fontFamily: 'Prompt',
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 105,
            width: double.infinity,
            child: Center(
              child: Draggable<bool>(
                data: currentItem.isMedicine,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildDraggablePill(currentItem, isDragging: true),
                ),
                childWhenDragging: _buildDraggablePill(currentItem, isDragging: false, isPlaceholder: true),
                child: _buildDraggablePill(currentItem, isDragging: false),
              ),
            ),
          ),
          if (_feedbackText != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _lastCorrect == true
                    ? AppColors.success.withOpacity(0.08)
                    : Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _lastCorrect == true ? AppColors.success : Colors.redAccent,
                  width: 1,
                ),
              ),
              child: Text(
                _feedbackText!,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: _lastCorrect == true ? AppColors.success : Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// WIDGET 1.1: BrainDopamineVisual (Dopamine Control Center - Pop-up Modal)
// ============================================================================
class BrainDopamineVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const BrainDopamineVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<BrainDopamineVisual> createState() => _BrainDopamineVisualState();
}

class _BrainDopamineVisualState extends State<BrainDopamineVisual> {
  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isDark ? const Color(0xFFC084FC) : AppColors.primary;
    final cardBg = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = widget.isDark ? const Color(0xFF334155) : AppColors.border;

    return GestureDetector(
      onTap: () => _openSimulationSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: activeColor.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: widget.isDark ? 0.12 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // Header decoration
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.insights_rounded, color: activeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'กลไกสมองเสพติด (Dopamine Loop)',
                        style: TextStyle(
                          fontSize: 14.5 * widget.fontScale,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Prompt',
                          color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'เรียนรู้บทบาทของโดปามีนและการเปลี่ยนแปลงระบบรางวัล',
                        style: TextStyle(
                          fontSize: 10 * widget.fontScale,
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Visual Preview representation
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 20,
                    child: Icon(
                      Icons.settings_suggest_rounded,
                      size: 64,
                      color: activeColor.withValues(alpha: 0.10),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 80,
                      color: Colors.pinkAccent.withValues(alpha: 0.10),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: activeColor, size: 38),
                      const SizedBox(height: 6),
                      Text(
                        'แตะเพื่อเปิดเครื่องจำลอง (เต็มจอ)',
                        style: TextStyle(
                          fontSize: 11.5 * widget.fontScale,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Prompt',
                          color: activeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'แตะเพื่อขยายหน้าจอจำลองแบบโต้ตอบขนาดใหญ่ ช่วยให้เรียนรู้การทำงานของโดปามีนและการติดยาเสพติดได้อย่างละเอียดและชัดเจนที่สุด',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5 * widget.fontScale,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontFamily: 'Prompt',
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSimulationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DopamineSimulationSheet(isDark: widget.isDark, fontScale: widget.fontScale);
      },
    );
  }
}

class _DopamineSimulationSheet extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const _DopamineSimulationSheet({required this.isDark, required this.fontScale});

  @override
  State<_DopamineSimulationSheet> createState() => _DopamineSimulationSheetState();
}

class _DopamineSimulationSheetState extends State<_DopamineSimulationSheet> with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0 = Normal, 1 = Drug, 2 = Crash
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildStepTab(int stepIndex, String title, IconData icon, Color activeColor) {
    final bool isSelected = _currentStep == stepIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentStep = stepIndex;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: widget.isDark ? 0.15 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : (widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeColor : (widget.isDark ? Colors.white38 : Colors.black38),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10 * widget.fontScale,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (widget.isDark ? Colors.white : activeColor)
                      : (widget.isDark ? Colors.white38 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.85;
    
    Color stepColor = Colors.blue;
    String statusTitle = "ปกติ (ระบบสมดุล)";
    double dopamineLevel = 0.45;
    String description = "สมองทำงานปกติเหมือนเปิดก๊อกน้ำความสุข (โดปามีน) ไหลรินเบาๆ เมื่อส่งความรู้สึกเสร็จก็ระบายน้ำทิ้งได้สะดวกตามธรรมชาติ ทำให้เรารู้สึกสุขสงบและพร้อมเรียนรู้";
    String flowInfo = "หลั่งสมดุลเมื่อเรียน เล่นกีฬา หรือทานอาหาร";
    String effectInfo = "ตัวรับและท่อดูดกลับทำงานราบรื่น ไม่มีสารเคมีค้าง";

    if (_currentStep == 1) {
      stepColor = Colors.amber;
      statusTitle = "รับสารเสพติด (ล้นทะลัก!)";
      dopamineLevel = 1.0;
      description = "ยาเสพติดจะเข้าไปปิดช่องดูดซึมกลับ (ตัวรีไซเคิล) ทำให้สารโดปามีนติดค้างและเอ่อล้นทะลักเต็มระบบ สมองจึงถูกบังคับให้รับความสุขล้นพ้นชั่วครู่จนเริ่มบอบช้ำ";
      flowInfo = "โดปามีนโดนกักขังล้นระบบ ประสาทตื่นตัวสูงสุด";
      effectInfo = "สมองเริ่มเสียหาย และหาทางปิดช่องรับสัญญาณ";
    } else if (_currentStep == 2) {
      stepColor = Colors.red;
      statusTitle = "หมดฤทธิ์ยา (ขาดแคลน/ดื้อยา)";
      dopamineLevel = 0.08;
      description = "เมื่อฤทธิ์ยาหมดลง ก๊อกผลิตน้ำแห้งขอด (สมองอ่อนแอจนผลิตโดปามีนเองแทบไม่ได้) แถมตัวรับความสุขก็พังเสียหาย ทำให้สารความสุขตกต่ำรุนแรง รู้สึกซึมเศร้าทรมาน";
      flowInfo = "สารโดปามีนลดต่ำกว่าเกณฑ์ปกติมาก รู้สึกไร้สุข";
      effectInfo = "ดื้อยาและอยากยาเพิ่มขึ้นเพื่อเค้นความสุขเทียมกลับมา";
    }

    final sheetBg = widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final contentBg = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = widget.isDark ? const Color(0xFF334155) : AppColors.border;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sheet Header with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เครื่องจำลองกลไกสมองติดยา',
                    style: TextStyle(
                      fontSize: 16 * widget.fontScale,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Prompt',
                      color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'เครื่องมือศึกษาการทำงานของสารเคมีและสมองเสพติด',
                    style: TextStyle(
                      fontSize: 10 * widget.fontScale,
                      fontFamily: 'Prompt',
                      color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: widget.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Steps Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildStepTab(0, '1. ปกติ / สมดุล', Icons.spa_rounded, Colors.blue),
                const SizedBox(width: 4),
                _buildStepTab(1, '2. ใช้สาร / ล้นระบบ', Icons.bolt_rounded, Colors.amber),
                const SizedBox(width: 4),
                _buildStepTab(2, '3. หมดฤทธิ์ / ดื้อยา', Icons.mood_bad_rounded, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Concept Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (widget.isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "แนวคิดหลัก: ไม่ได้เกิดจากโดปามีนอย่างเดียว แต่เกิดจากสมองเรียนรู้และปรับตัว จนระบบรางวัลทำงานเปลี่ยนไป",
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 10 * widget.fontScale,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Expanded CustomPaint visual
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: contentBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: CustomPaint(
                  painter: SynapseDopaminePainter(
                    currentStep: _currentStep,
                    isDark: widget.isDark,
                    animValue: _animController.value,
                    repaint: _animController,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Dopamine gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ปริมาณสารโดปามีน (ความสุข):',
                style: TextStyle(
                  fontSize: 11 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Prompt',
                  color: widget.isDark ? Colors.white70 : AppColors.textDark,
                ),
              ),
              Text(
                '${(dopamineLevel * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: stepColor,
                  fontFamily: 'Prompt',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: dopamineLevel,
              minHeight: 6,
              backgroundColor: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(stepColor),
            ),
          ),
          const SizedBox(height: 14),

          // Unified description card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: stepColor.withValues(alpha: 0.15), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _currentStep == 0
                          ? Icons.check_circle_rounded
                          : (_currentStep == 1 ? Icons.warning_rounded : Icons.error_rounded),
                      color: stepColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 13 * widget.fontScale,
                        fontWeight: FontWeight.w800,
                        color: stepColor,
                        fontFamily: 'Prompt',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5 * widget.fontScale,
                    color: widget.isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                    fontFamily: 'Prompt',
                    height: 1.5,
                  ),
                ),
                const Divider(height: 16, thickness: 0.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚙️ สารโดปามีน: ', style: TextStyle(fontSize: 11 * widget.fontScale, fontWeight: FontWeight.bold, fontFamily: 'Prompt', color: widget.isDark ? Colors.white70 : Colors.black87)),
                    Expanded(
                      child: Text(flowInfo, style: TextStyle(fontSize: 11 * widget.fontScale, fontFamily: 'Prompt', color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚠️ ผลกระทบ: ', style: TextStyle(fontSize: 11 * widget.fontScale, fontWeight: FontWeight.bold, fontFamily: 'Prompt', color: widget.isDark ? Colors.white70 : Colors.black87)),
                    Expanded(
                      child: Text(effectInfo, style: TextStyle(fontSize: 11 * widget.fontScale, fontFamily: 'Prompt', color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class SynapseDopaminePainter extends CustomPainter {
  final int currentStep;
  final bool isDark;
  final double animValue;

  SynapseDopaminePainter({
    required this.currentStep,
    required this.isDark,
    required this.animValue,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // ----------------------------------------------------
    // 0. Base Colors Config
    // ----------------------------------------------------
    final Color strokeColor = isDark ? Colors.white30 : Colors.black26;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;

    // Step-based main colors: Normal = Blue, Stimulated = Yellow, Unbalanced = Red
    Color mainThemeColor;
    if (currentStep == 0) {
      mainThemeColor = const Color(0xFF3B82F6); // Blue
    } else if (currentStep == 1) {
      mainThemeColor = const Color(0xFFFBBF24); // Yellow/Amber
    } else {
      mainThemeColor = const Color(0xFFEF4444); // Red
    }

    final pipePaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final pipeOutlinePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Helper text painter
    void drawText(String text, Offset position, Color color, {double fontSize = 9.5, bool alignCenter = true, bool bold = true}) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontFamily: 'Prompt',
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final offset = alignCenter
          ? Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2)
          : position;
      textPainter.paint(canvas, offset);
    }

    // ----------------------------------------------------
    // 1. Draw Faucet and Knob (Left Side)
    // ----------------------------------------------------
    final double fx = size.width * 0.22;
    final double fy = size.height * 0.58;

    // Pipe feeding into faucet
    final faucetPath = Path()
      ..moveTo(0, size.height * 0.24)
      ..lineTo(fx, size.height * 0.24)
      ..lineTo(fx, size.height * 0.32);
    canvas.drawPath(faucetPath, pipePaint);
    canvas.drawPath(faucetPath, pipeOutlinePaint);

    // Spout body
    final spoutRect = Rect.fromLTWH(fx - 12, size.height * 0.32, 24, 8);
    final spoutPaint = Paint()
      ..color = isDark ? Colors.grey.shade600 : Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawRect(spoutRect, spoutPaint);
    canvas.drawRect(spoutRect, pipeOutlinePaint);

    // Rotating Knob / Valve Handle on top of Faucet
    final Offset knobCenter = Offset(fx, size.height * 0.20);
    double knobAngle = 0;
    if (currentStep == 0) {
      knobAngle = pi / 4; // Partially open
    } else if (currentStep == 1) {
      knobAngle = animValue * 2 * pi; // Spinning to show rush
    } else {
      knobAngle = 0; // Closed / stuck
    }

    canvas.save();
    canvas.translate(knobCenter.dx, knobCenter.dy);
    canvas.rotate(knobAngle);
    
    // Draw cross handle valve
    final valvePaint = Paint()
      ..color = (currentStep == 2) ? Colors.red.shade400 : (isDark ? Colors.blueGrey.shade300 : Colors.grey.shade700)
      ..style = PaintingStyle.fill;
    final valveOutline = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Horizontal bar
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 26, height: 6), const Radius.circular(3)), valvePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 26, height: 6), const Radius.circular(3)), valveOutline);
    // Vertical bar
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 6, height: 26), const Radius.circular(3)), valvePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 6, height: 26), const Radius.circular(3)), valveOutline);
    // Center cap
    canvas.drawCircle(Offset.zero, 4.5, Paint()..color = mainThemeColor);
    canvas.drawCircle(Offset.zero, 4.5, valveOutline);
    
    canvas.restore();

    // ----------------------------------------------------
    // 2. Draw Receptors & Funnel
    // ----------------------------------------------------
    final funnelPath = Path()
      ..moveTo(fx - 26, fy - 10)
      ..lineTo(fx + 26, fy - 10)
      ..lineTo(fx + 12, fy + 8)
      ..lineTo(fx - 12, fy + 8)
      ..close();

    final funnelPaint = Paint()
      ..color = mainThemeColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final funnelBorderPaint = Paint()
      ..color = mainThemeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(funnelPath, funnelPaint);
    canvas.drawPath(funnelPath, funnelBorderPaint);

    if (currentStep == 2) {
      // Draw cracks on funnel
      final crackPaint = Paint()
        ..color = isDark ? Colors.white60 : Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(fx - 14, fy - 10), Offset(fx - 6, fy), crackPaint);
      canvas.drawLine(Offset(fx + 14, fy - 10), Offset(fx + 4, fy + 2), crackPaint);
      canvas.drawLine(Offset(fx - 4, fy + 8), Offset(fx - 2, fy + 1), crackPaint);
    }

    // Receptors LEDs (representing desensitization & tolerance)
    // 4 LED lights positioned below the funnel
    final double ledY = fy + 18;
    final List<Offset> ledOffsets = [
      Offset(fx - 18, ledY),
      Offset(fx - 6, ledY),
      Offset(fx + 6, ledY),
      Offset(fx + 18, ledY),
    ];

    for (int i = 0; i < 4; i++) {
      Color ledColor;
      bool isGlow = false;

      if (currentStep == 0) {
        // Normal: 4 active Blue LEDs
        ledColor = const Color(0xFF3B82F6);
        isGlow = true;
      } else if (currentStep == 1) {
        // Stimulated: 4 active bright Yellow LEDs
        ledColor = const Color(0xFFFBBF24);
        isGlow = true;
      } else {
        // Unbalanced: Only 1 LED active (dim Red), other 3 are dark/grey
        if (i == 0) {
          ledColor = const Color(0xFFEF4444).withValues(alpha: 0.5); // Dim red
          isGlow = true;
        } else {
          ledColor = isDark ? Colors.white12 : Colors.grey.shade400; // Grey / off
          isGlow = false;
        }
      }

      final ledPaint = Paint()
        ..color = ledColor
        ..style = PaintingStyle.fill;
      final ledOutline = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // LED Glow effect
      if (isGlow) {
        canvas.drawCircle(
          ledOffsets[i],
          6.0,
          Paint()
            ..color = ledColor.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      canvas.drawCircle(ledOffsets[i], 3.5, ledPaint);
      canvas.drawCircle(ledOffsets[i], 3.5, ledOutline);
    }

    // ----------------------------------------------------
    // 3. Draw Dopamine Particles
    // ----------------------------------------------------
    final particlePaint = Paint()
      ..color = (currentStep == 0)
          ? const Color(0xFF3B82F6) // Blue
          : ((currentStep == 1) ? const Color(0xFFFBBF24) : const Color(0xFFEF4444).withValues(alpha: 0.4))
      ..style = PaintingStyle.fill;

    final double startY = size.height * 0.34;
    final double endY = fy - 12;

    if (currentStep == 0) {
      // Normal: moderate blue drops flowing
      for (int i = 0; i < 3; i++) {
        final double t = ((animValue + i / 3.0) % 1.0);
        final double y = startY + (endY - startY) * t;
        canvas.drawCircle(Offset(fx, y), 4.5, particlePaint);
      }
    } else if (currentStep == 1) {
      // Stimulated: massive yellow drops flowing fast
      for (int i = 0; i < 7; i++) {
        final double t = ((animValue * 1.6 + i / 7.0) % 1.0);
        final double y = startY + (endY - startY) * t;
        final double offset = 3 * sin(t * 4 * pi + i);
        canvas.drawCircle(Offset(fx + offset, y), 5.0, particlePaint);
      }
    } else {
      // Unbalanced: Red drops dripping very slowly, far apart
      for (int i = 0; i < 1; i++) {
        final double t = ((animValue * 0.4) % 1.0);
        final double y = startY + (endY - startY) * t;
        canvas.drawCircle(Offset(fx, y), 3.5, particlePaint);
      }
    }

    // ----------------------------------------------------
    // 4. Draw Brain Adaptation Gears ("การปรับตัวของสมอง")
    // ----------------------------------------------------
    final Offset gearCenter1 = Offset(size.width * 0.48, size.height * 0.28);
    final Offset gearCenter2 = Offset(size.width * 0.58, size.height * 0.34);

    double gearAngle1 = animValue * 2 * pi;
    double gearAngle2 = -animValue * 2 * pi * (22 / 14) + pi / 8;

    if (currentStep == 2) {
      // Jammed / stuck: vibrate back and forth instead of spinning
      gearAngle1 = sin(animValue * 10 * pi) * 0.05;
      gearAngle2 = -gearAngle1 * (22 / 14);
    }

    void drawSingleGear(Offset center, double radius, double angle, int numTeeth, Color color) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final gearPaint = Paint()
        ..color = color.withValues(alpha: isDark ? 0.25 : 0.15)
        ..style = PaintingStyle.fill;
      final gearBorder = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      // Base circle
      canvas.drawCircle(Offset.zero, radius, gearPaint);
      canvas.drawCircle(Offset.zero, radius, gearBorder);

      // Draw teeth
      for (int i = 0; i < numTeeth; i++) {
        final double a = i * (2 * pi / numTeeth);
        canvas.save();
        canvas.rotate(a);
        
        final toothPath = Path()
          ..moveTo(-3, -radius)
          ..lineTo(-2, -radius - 4)
          ..lineTo(2, -radius - 4)
          ..lineTo(3, -radius)
          ..close();
          
        canvas.drawPath(toothPath, gearPaint);
        canvas.drawPath(toothPath, gearBorder);
        canvas.restore();
      }

      // Center cap
      canvas.drawCircle(Offset.zero, radius * 0.3, Paint()..color = (isDark ? Colors.grey.shade800 : Colors.grey.shade200));
      canvas.drawCircle(Offset.zero, radius * 0.3, gearBorder);
      
      canvas.restore();
    }

    // Draw interlocking gears
    drawSingleGear(gearCenter1, 22, gearAngle1, 12, mainThemeColor);
    drawSingleGear(gearCenter2, 14, gearAngle2, 8, mainThemeColor.withValues(alpha: 0.8));

    // Label for Gears
    drawText('การปรับตัวของสมอง', Offset(size.width * 0.53, size.height * 0.18), textColor, fontSize: 8.5);

    // ----------------------------------------------------
    // 5. Draw Satisfaction Meter (Needle Speedometer Gauge)
    // ----------------------------------------------------
    final Offset gaugeCenter = Offset(size.width * 0.78, size.height * 0.28);
    final double gaugeRadius = 26.0;

    final gaugePaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // Draw speedometer arc (from 180 deg to 360 deg)
    canvas.drawArc(
      Rect.fromCircle(center: gaugeCenter, radius: gaugeRadius),
      pi,
      pi,
      false,
      gaugePaint,
    );

    // Draw colored sections on gauge arc
    final sectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Red zone (0% to 25%)
    sectionPaint.color = const Color(0xFFEF4444).withValues(alpha: 0.6);
    canvas.drawArc(Rect.fromCircle(center: gaugeCenter, radius: gaugeRadius), pi, pi * 0.25, false, sectionPaint);
    
    // Yellow zone (25% to 75%)
    sectionPaint.color = const Color(0xFFFBBF24).withValues(alpha: 0.6);
    canvas.drawArc(Rect.fromCircle(center: gaugeCenter, radius: gaugeRadius), pi + pi * 0.25, pi * 0.5, false, sectionPaint);

    // Blue/Green zone (75% to 100%)
    sectionPaint.color = const Color(0xFF3B82F6).withValues(alpha: 0.6);
    canvas.drawArc(Rect.fromCircle(center: gaugeCenter, radius: gaugeRadius), pi + pi * 0.75, pi * 0.25, false, sectionPaint);

    // Needle Angle based on satisfaction level
    // Step 0: 45% (Normal satisfaction), Step 1: 95% (Extreme pleasure), Step 2: 10% (Crash)
    double targetSatisfaction = 0.45;
    if (currentStep == 1) {
      targetSatisfaction = 0.95;
    } else if (currentStep == 2) {
      targetSatisfaction = 0.10;
    }

    final double needleAngle = pi + (targetSatisfaction * pi);
    final Offset needleTip = Offset(
      gaugeCenter.dx + (gaugeRadius - 2) * cos(needleAngle),
      gaugeCenter.dy + (gaugeRadius - 2) * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = (currentStep == 2) ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(gaugeCenter, needleTip, needlePaint);
    canvas.drawCircle(gaugeCenter, 3.5, Paint()..color = mainThemeColor);
    canvas.drawCircle(gaugeCenter, 3.5, Paint()..color = strokeColor..style = PaintingStyle.stroke);

    drawText('ระดับความพึงพอใจ', Offset(gaugeCenter.dx, gaugeCenter.dy + 12), textColor, fontSize: 8.5);

    // ----------------------------------------------------
    // 6. Draw Brain Character
    // ----------------------------------------------------
    final double cx = size.width * 0.78;
    final double cy = size.height * 0.58;

    Color brainColor = const Color(0xFFFDA4AF);
    if (currentStep == 1) {
      brainColor = const Color(0xFFF43F5E); // Bright excited pink
    } else if (currentStep == 2) {
      brainColor = const Color(0xFF94A3B8); // Slate grey / damaged
    }

    final brainPaint = Paint()
      ..color = brainColor
      ..style = PaintingStyle.fill;

    // Draw main lobes
    canvas.drawCircle(Offset(cx, cy), 22, brainPaint);
    canvas.drawCircle(Offset(cx - 16, cy), 17, brainPaint);
    canvas.drawCircle(Offset(cx + 16, cy), 17, brainPaint);
    canvas.drawCircle(Offset(cx - 8, cy - 14), 16, brainPaint);
    canvas.drawCircle(Offset(cx + 8, cy - 14), 16, brainPaint);
    canvas.drawCircle(Offset(cx - 10, cy + 11), 14, brainPaint);
    canvas.drawCircle(Offset(cx + 10, cy + 11), 14, brainPaint);

    final foldPaint = Paint()
      ..color = (currentStep == 2) ? Colors.black26 : Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: Offset(cx - 12, cy - 6), radius: 8), 0.5, 2.0, false, foldPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx + 12, cy - 6), radius: 8), 0.6, 2.0, false, foldPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy + 8), radius: 10), -1.0, 2.0, false, foldPaint);

    // Eyes and mouth
    final facePaint = Paint()
      ..color = (currentStep == 2) ? const Color(0xFF334155) : const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (currentStep == 0) {
      // Happy eyes ^ ^
      final leftEyePath = Path()
        ..moveTo(cx - 9, cy - 3)
        ..quadraticBezierTo(cx - 6, cy - 6, cx - 3, cy - 3);
      final rightEyePath = Path()
        ..moveTo(cx + 3, cy - 3)
        ..quadraticBezierTo(cx + 6, cy - 6, cx + 9, cy - 3);
      canvas.drawPath(leftEyePath, facePaint);
      canvas.drawPath(rightEyePath, facePaint);

      // Smiling mouth
      final mouthPath = Path()
        ..moveTo(cx - 3, cy + 4)
        ..quadraticBezierTo(cx, cy + 7, cx + 3, cy + 4);
      canvas.drawPath(mouthPath, facePaint);

      // Blushing cheeks
      final cheekPaint = Paint()..color = Colors.pinkAccent.withValues(alpha: 0.3)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 12, cy + 3), 3, cheekPaint);
      canvas.drawCircle(Offset(cx + 12, cy + 3), 3, cheekPaint);
    } else if (currentStep == 1) {
      // Excited eyes O O
      final eyeOutline = Paint()..color = Colors.white..style = PaintingStyle.fill;
      final pupilPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(cx - 6, cy - 3), 4.5, eyeOutline);
      canvas.drawCircle(Offset(cx - 6, cy - 3), 2.0, pupilPaint);

      canvas.drawCircle(Offset(cx + 6, cy - 3), 4.5, eyeOutline);
      canvas.drawCircle(Offset(cx + 6, cy - 3), 2.0, pupilPaint);

      // Excited open mouth
      final mouthPaint = Paint()..color = const Color(0xFFE11D48)..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 5), width: 6, height: 8), mouthPaint);

      drawText('✨', Offset(cx - 18, cy - 20), Colors.amber, fontSize: 12);
      drawText('✨', Offset(cx + 18, cy - 20), Colors.amber, fontSize: 12);
    } else {
      // Sad Crying Eyes \ /
      canvas.drawLine(Offset(cx - 8, cy - 5), Offset(cx - 4, cy - 2), facePaint);
      canvas.drawLine(Offset(cx + 8, cy - 5), Offset(cx + 4, cy - 2), facePaint);

      // Frowny mouth
      final mouthPath = Path()
        ..moveTo(cx - 4, cy + 6)
        ..quadraticBezierTo(cx, cy + 3, cx + 4, cy + 6);
      canvas.drawPath(mouthPath, facePaint);

      // Tears falling
      final tearPaint = Paint()..color = Colors.lightBlueAccent..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 7, cy + 3 + 4 * (animValue % 1.0)), 2.5, tearPaint);
      canvas.drawCircle(Offset(cx + 7, cy + 1 + 4 * ((animValue + 0.5) % 1.0)), 2.0, tearPaint);
    }

    drawText('สมองส่วนควบคุม', Offset(cx, cy - 25), textColor, fontSize: 8.5);

    // ----------------------------------------------------
    // 7. Draw Curved Feedback Loop (Center Bottom)
    // ----------------------------------------------------
    final double loopY = size.height * 0.82;
    final double loopStartX = size.width * 0.18;
    final double loopEndX = size.width * 0.82;
    
    // Draw horizontal dashed connection line representing feedback loop
    final loopLinePaint = Paint()
      ..color = mainThemeColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw dashed path
    final loopPath = Path();
    const double dashLen = 5.0;
    const double gapLen = 4.0;
    double currentX = loopStartX;
    while (currentX < loopEndX) {
      loopPath.moveTo(currentX, loopY);
      loopPath.lineTo(min(currentX + dashLen, loopEndX), loopY);
      currentX += dashLen + gapLen;
    }
    canvas.drawPath(loopPath, loopLinePaint);

    // Draw running flow dot along the line
    final double flowProgress = animValue;
    final double dotX = loopStartX + (loopEndX - loopStartX) * flowProgress;
    canvas.drawCircle(
      Offset(dotX, loopY),
      4.0,
      Paint()
        ..color = mainThemeColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(Offset(dotX, loopY), 2.5, Paint()..color = Colors.white);

    // Draw Loop Step Cards
    final double stepWidth = (loopEndX - loopStartX) / 4.0;
    final List<String> loopSteps = ['กระตุ้น', 'รู้สึกดี', 'เรียนรู้', 'อยากซ้ำ'];
    
    for (int i = 0; i < 4; i++) {
      final double sx = loopStartX + (i + 0.5) * stepWidth;
      final Offset cardOffset = Offset(sx, loopY + 12);
      
      // Draw background pill card
      final bool isCurrentStepHighlight = (flowProgress * 4).floor() == i;
      final Color pillBg = isCurrentStepHighlight
          ? mainThemeColor.withValues(alpha: isDark ? 0.3 : 0.15)
          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03));
      final Color pillBorder = isCurrentStepHighlight
          ? mainThemeColor
          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05));
      final Color pillText = isCurrentStepHighlight
          ? (isDark ? Colors.white : mainThemeColor)
          : (isDark ? Colors.white54 : Colors.black54);

      final Rect pillRect = Rect.fromCenter(center: cardOffset, width: 44, height: 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(8)),
        Paint()..color = pillBg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(8)),
        Paint()
          ..color = pillBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      drawText(
        loopSteps[i],
        cardOffset,
        pillText,
        fontSize: 8.0,
        alignCenter: true,
        bold: isCurrentStepHighlight,
      );
      
      // Draw arrow in between cards
      if (i < 3) {
        final double arrowX = loopStartX + (i + 1) * stepWidth;
        drawText('➔', Offset(arrowX, loopY), mainThemeColor, fontSize: 8.0);
      }
    }

    // ----------------------------------------------------
    // 8. General Labels
    // ----------------------------------------------------
    drawText('ก๊อกโดปามีน (แหล่งผลิต)', Offset(fx, size.height * 0.13), textColor, fontSize: 8.5);
    drawText('ตัวรับความสุข (ตัวรับสาร)', Offset(fx, fy + 30), textColor, fontSize: 8.5);
  }

  @override
  bool shouldRepaint(covariant SynapseDopaminePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep ||
        oldDelegate.isDark != isDark ||
        oldDelegate.animValue != animValue;
  }
}

// WIDGET 1.2: ArmorShieldVisual (Armor Up! Shield Game)
// ============================================================================
class ArmorShieldVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const ArmorShieldVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<ArmorShieldVisual> createState() => _ArmorShieldVisualState();
}

class _ArmorShieldVisualState extends State<ArmorShieldVisual> with TickerProviderStateMixin {
  bool _knowledge = false;
  bool _mindset = false;
  bool _refusal = false;

  late final AnimationController _knowledgeController;
  late final AnimationController _mindsetController;
  late final AnimationController _refusalController;
  late final AnimationController _threatController;

  @override
  void initState() {
    super.initState();
    _knowledgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _mindsetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _refusalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _threatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _knowledgeController.dispose();
    _mindsetController.dispose();
    _refusalController.dispose();
    _threatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allEquipped = _knowledge && _mindset && _refusal;
    String status = allEquipped ? '🛡 เกราะป้องกันสมบูรณ์ 100%' : '⚠ เลือกติดตั้งเกราะป้องกันให้ครบ';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _knowledgeController,
                _mindsetController,
                _refusalController,
                _threatController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: DefenseShieldPainter(
                    knowledgeProgress: _knowledgeController.value,
                    mindsetProgress: _mindsetController.value,
                    refusalProgress: _refusalController.value,
                    idleProgress: _threatController.value,
                    isDark: widget.isDark,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12 * widget.fontScale,
              color: allEquipped ? AppColors.success : Colors.grey,
              fontFamily: 'Prompt',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildShieldButton(
                Icons.shield_rounded,
                'ความรู้',
                _knowledge,
                () {
                  setState(() {
                    _knowledge = !_knowledge;
                    if (_knowledge) {
                      _knowledgeController.forward();
                    } else {
                      _knowledgeController.reverse();
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildShieldButton(
                Icons.psychology_rounded,
                'จิตใจ',
                _mindset,
                () {
                  setState(() {
                    _mindset = !_mindset;
                    if (_mindset) {
                      _mindsetController.forward();
                    } else {
                      _mindsetController.reverse();
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildShieldButton(
                Icons.record_voice_over_rounded,
                'ปฏิเสธ',
                _refusal,
                () {
                  setState(() {
                    _refusal = !_refusal;
                    if (_refusal) {
                      _refusalController.forward();
                    } else {
                      _refusalController.reverse();
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShieldButton(IconData icon, String name, bool active, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(name, style: const TextStyle(fontSize: 11, fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? AppColors.success : (widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]),
          foregroundColor: active ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black.withOpacity(0.85)),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}

class DefenseShieldPainter extends CustomPainter {
  final double knowledgeProgress;
  final double mindsetProgress;
  final double refusalProgress;
  final double idleProgress;
  final bool isDark;

  DefenseShieldPainter({
    required this.knowledgeProgress,
    required this.mindsetProgress,
    required this.refusalProgress,
    required this.idleProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    void drawEmoji(String emoji, Offset center, double emojiSize) {
      final tp = TextPainter(
        text: TextSpan(
          text: emoji,
          style: TextStyle(fontSize: emojiSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
    }

    final double totalProgress = (knowledgeProgress + mindsetProgress + refusalProgress) / 3.0;
    final bool allEquipped = knowledgeProgress > 0.95 && mindsetProgress > 0.95 && refusalProgress > 0.95;

    final corePaint = Paint()
      ..color = allEquipped ? Colors.amber : Colors.amber.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 16, corePaint);

    final babyEmoji = allEquipped ? '😊' : (totalProgress > 0.5 ? '😐' : '😟');
    drawEmoji(babyEmoji, Offset(cx, cy), 16);

    if (knowledgeProgress > 0.01) {
      final p = Paint()
        ..color = const Color(0xFF3B82F6).withOpacity(knowledgeProgress * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final radius = 16 + (25 - 16) * knowledgeProgress;
      canvas.drawCircle(Offset(cx, cy), radius, p);
    }

    if (mindsetProgress > 0.01) {
      final p = Paint()
        ..color = const Color(0xFFA855F7).withOpacity(mindsetProgress * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final radius = 16 + (35 - 16) * mindsetProgress;
      canvas.drawCircle(Offset(cx, cy), radius, p);
    }

    if (refusalProgress > 0.01) {
      final p = Paint()
        ..color = const Color(0xFF10B981).withOpacity(refusalProgress * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final radius = 16 + (45 - 16) * refusalProgress;
      canvas.drawCircle(Offset(cx, cy), radius, p);
    }

    if (allEquipped) {
      final safePaint = Paint()
        ..color = AppColors.success.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 45, safePaint);
    }

    final double easeK = Curves.easeOutBack.transform(knowledgeProgress);
    final double easeM = Curves.easeOutBack.transform(mindsetProgress);
    final double easeR = Curves.easeOutBack.transform(refusalProgress);

    double baseDist = 22.0;
    double pushDist = 14.0 * easeK + 14.0 * easeM + 16.0 * easeR;
    if (allEquipped) {
      pushDist += 12.0;
    }
    
    final double idleWave = sin(idleProgress * 2 * pi) * 2.5;
    final double finalDist = baseDist + pushDist + idleWave;

    final double angle1 = 5 * pi / 4;
    final Offset threatPos1 = Offset(cx + finalDist * cos(angle1), cy + finalDist * sin(angle1));
    drawEmoji('💀', threatPos1, 18);

    final double angle2 = pi / 4;
    final Offset threatPos2 = Offset(cx + finalDist * cos(angle2), cy + finalDist * sin(angle2));
    drawEmoji('🦠', threatPos2, 18);

    if (knowledgeProgress > 0.75) {
      drawEmoji('🛡️', Offset(cx - 30 * cos(pi/6), cy - 30 * sin(pi/6)), 9);
    }
    if (refusalProgress > 0.75) {
      drawEmoji('🚫', Offset(cx - 52 * cos(pi/6), cy - 52 * sin(pi/6)), 11);
      drawEmoji('🚫', Offset(cx + 52 * cos(pi/6), cy + 52 * sin(pi/6)), 11);
    }
  }

  @override
  bool shouldRepaint(covariant DefenseShieldPainter oldDelegate) {
    return oldDelegate.knowledgeProgress != knowledgeProgress ||
        oldDelegate.mindsetProgress != mindsetProgress ||
        oldDelegate.refusalProgress != refusalProgress ||
        oldDelegate.idleProgress != idleProgress ||
        oldDelegate.isDark != isDark;
  }
}

// WIDGET 2.0: StimulantRushVisual (Heart Rate Rush)
// ============================================================================
class StimulantRushVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const StimulantRushVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<StimulantRushVisual> createState() => _StimulantRushVisualState();
}

class _StimulantRushVisualState extends State<StimulantRushVisual> with SingleTickerProviderStateMixin {
  bool _isStimulated = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speed = _isStimulated ? 180 : 72;
    _animController.duration = Duration(milliseconds: _isStimulated ? 400 : 1200);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('อัตราการเต้นของหัวใจ:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
              Text('$speed BPM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _isStimulated ? Colors.redAccent : AppColors.success, fontFamily: 'Prompt')),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: DynamicEcgPainter(
                    phase: _animController.value,
                    isFast: _isStimulated,
                    color: _isStimulated ? Colors.redAccent : AppColors.success,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isStimulated = !_isStimulated;
              });
            },
            icon: Icon(_isStimulated ? Icons.stop_circle_rounded : Icons.bolt_rounded, size: 18),
            label: Text(
              _isStimulated ? 'หยุดการกระตุ้น' : 'จำลองฤทธิ์กระตุ้นประสาท',
              style: const TextStyle(fontFamily: 'Prompt', fontSize: 11, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStimulated ? Colors.redAccent : Colors.amber,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicEcgPainter extends CustomPainter {
  final double phase;
  final bool isFast;
  final Color color;

  DynamicEcgPainter({required this.phase, required this.isFast, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    double loops = isFast ? 4 : 2;
    for (double i = 0; i <= size.width; i++) {
      double relativeX = (i / size.width) * loops - phase;
      double cyclePosition = relativeX - relativeX.floor();

      double y = size.height * 0.5;
      if (cyclePosition > 0.3 && cyclePosition < 0.35) {
        y = size.height * 0.2; // QRS peak
      } else if (cyclePosition > 0.35 && cyclePosition < 0.4) {
        y = size.height * 0.85; // drop
      } else if (cyclePosition > 0.45 && cyclePosition < 0.55) {
        y = size.height * 0.4; // T wave
      }

      path.lineTo(i, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DynamicEcgPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.isFast != isFast || oldDelegate.color != color;
  }
}

// ============================================================================
// WIDGET 2.1: DepressantSlowVisual (Deep Slow Slumber)
// ============================================================================
class DepressantSlowVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const DepressantSlowVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<DepressantSlowVisual> createState() => _DepressantSlowVisualState();
}

class _DepressantSlowVisualState extends State<DepressantSlowVisual> {
  double _intake = 0.0; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    String stateText = 'การทำงานของสมอง: ปกติ';
    Color waveColor = Colors.blueAccent;
    if (_intake > 0.8) {
      stateText = 'อันตราย! ระบบหายใจอาจหยุดทำงาน!';
      waveColor = Colors.redAccent;
    } else if (_intake > 0.4) {
      stateText = 'ง่วงมาก สูญเสียการควบคุม ความจำเลือนราง';
      waveColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ปริมาณสารกดประสาท:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
              Text('${(_intake * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: waveColor, fontFamily: 'Prompt')),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: DepressWavePainter(intake: _intake, color: waveColor),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _intake,
            min: 0.0,
            max: 1.0,
            activeColor: waveColor,
            onChanged: (val) => setState(() => _intake = val),
          ),
          Text(
            stateText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5 * widget.fontScale, color: waveColor, fontFamily: 'Prompt'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DepressWavePainter extends CustomPainter {
  final double intake;
  final Color color;

  DepressWavePainter({required this.intake, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    double frequency = 1.0 + (1.0 - intake) * 4.0;
    double amplitude = (1.0 - intake) * 16.0;

    if (intake >= 0.95) {
      // flatline
      canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paint);
    } else {
      for (double i = 0; i <= size.width; i++) {
        final y = size.height * 0.5 + sin((i / size.width) * 2 * pi * frequency) * amplitude;
        path.lineTo(i, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DepressWavePainter oldDelegate) {
    return oldDelegate.intake != intake || oldDelegate.color != color;
  }
}

// ============================================================================
// WIDGET 2.2: RealityDistorterVisual (Reality Distorter Kaleidoscope)
// ============================================================================
class RealityDistorterVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const RealityDistorterVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<RealityDistorterVisual> createState() => _RealityDistorterVisualState();
}

class _RealityDistorterVisualState extends State<RealityDistorterVisual> with SingleTickerProviderStateMixin {
  bool _hallucinateMode = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _hallucinateMode ? Colors.purpleAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Selectors
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _hallucinateMode = false),
                  icon: const Icon(Icons.remove_red_eye_rounded, size: 14),
                  label: const Text('ความจริง', style: TextStyle(fontSize: 11, fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_hallucinateMode
                        ? AppColors.primary
                        : (widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]),
                    foregroundColor: !_hallucinateMode
                        ? Colors.white
                        : (widget.isDark ? Colors.white70 : AppColors.textDark),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _hallucinateMode = true),
                  icon: const Icon(Icons.blur_on_rounded, size: 14),
                  label: const Text('หลอนประสาท', style: TextStyle(fontSize: 11, fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hallucinateMode
                        ? Colors.purpleAccent
                        : (widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]),
                    foregroundColor: _hallucinateMode ? Colors.white : (widget.isDark ? Colors.white70 : AppColors.textDark),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Simulation Display Box
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: activeColor.withOpacity(0.25)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Animated background for hallucinogen mode
                  if (_hallucinateMode)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HallucinationWarpPainter(
                          animValue: _animController.value,
                          repaint: _animController,
                        ),
                      ),
                    ),
                  // Content Info
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Left Visual Graphic
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _hallucinateMode
                                ? Colors.purple.withOpacity(0.15)
                                : Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: _hallucinateMode
                                ? [
                                    BoxShadow(
                                      color: Colors.purpleAccent.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            _hallucinateMode ? Icons.hourglass_empty_rounded : Icons.access_time_filled_rounded,
                            color: _hallucinateMode ? Colors.purpleAccent : Colors.blueAccent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Right Descriptive Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _hallucinateMode ? 'การรับรู้บิดเบือน: เวลาดูเหมือนไม่จริง' : 'การรับรู้ปกติ: เวลาเดินตามปกติ',
                                style: TextStyle(
                                  fontSize: 13.5 * widget.fontScale,
                                  fontWeight: FontWeight.w800,
                                  color: _hallucinateMode ? Colors.purpleAccent : (widget.isDark ? Colors.white : AppColors.textDark),
                                  fontFamily: 'Prompt',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _hallucinateMode
                                    ? 'สารรบกวนการรับรู้เวลาและสถานที่ เวลาอาจยืดหรือหดสั้นตามประสาทหลอน ทำให้ตัดสินใจผิดพลาดในสถานการณ์อันตราย'
                                    : 'เวลาเดินตามปกติ รู้สึกตัวดี รับรู้สถานการณ์รอบข้างได้ชัดเจน สามารถตัดสินใจและวางแผนได้',
                                style: TextStyle(
                                  fontSize: 11 * widget.fontScale,
                                  color: widget.isDark ? Colors.white70 : AppColors.textGrey,
                                  fontFamily: 'Prompt',
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom Warning Row with expanded text to fix overflow on small screens
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.report_problem_rounded, color: Colors.purpleAccent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'สารหลอนประสาทรบกวนการตัดสินใจและการรับรู้สิ่งรอบตัว ทำให้เกิด อุบัติเหตุ หรือ ระยะยาวทำลายเซลล์สมอง',
                  style: TextStyle(
                    fontSize: 10.5 * widget.fontScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                    fontFamily: 'Prompt',
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HallucinationWarpPainter extends CustomPainter {
  final double animValue;

  HallucinationWarpPainter({
    required this.animValue,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw shifting background color
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purple.withOpacity(0.08),
          Colors.pink.withOpacity(0.05),
          Colors.deepPurple.withOpacity(0.03),
        ],
        center: const Alignment(0, 0),
        radius: 1.0 + sin(animValue * 2 * pi) * 0.2,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), bgPaint);

    // Draw concentric pulsing warped rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 4; i++) {
      final double progress = (i * 0.25 + animValue) % 1.0;
      final double radius = size.width * 0.45 * progress;
      final double opacity = 1.0 - progress;

      ringPaint.color = Colors.purpleAccent.withOpacity(opacity * 0.18);

      final path = Path();
      final pointsCount = 40;
      for (int j = 0; j <= pointsCount; j++) {
        final angle = (j * 2 * pi) / pointsCount;
        // Add waving/warping sine wave offset to simulate reality distortion
        final warp = sin(angle * 6 + animValue * 2 * pi) * (radius * 0.08);
        final currentRadius = radius + warp;
        final x = cx + cos(angle) * currentRadius;
        final y = cy + sin(angle) * currentRadius;

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HallucinationWarpPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

// ============================================================================
// WIDGET 2.3: MixedStormVisual (Stormy Brain Mixer)
// ============================================================================
class MixedStormVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const MixedStormVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<MixedStormVisual> createState() => _MixedStormVisualState();
}

class _MixedStormVisualState extends State<MixedStormVisual> {
  double _stim = 0.2;
  double _depress = 0.2;
  double _hallucinate = 0.2;

  @override
  Widget build(BuildContext context) {
    final mixedVal = _stim + _depress + _hallucinate;
    String brainStatus = 'สมองยังประมวลผลได้ปกติ';
    IconData weatherIcon = Icons.wb_cloudy_rounded;
    Color weatherColor = Colors.amber;
    if (mixedVal > 1.8) {
      brainStatus = 'วิกฤต: สมองสับสนรุนแรง อาจเป็นอันตรายถึงชีวิต!';
      weatherIcon = Icons.thunderstorm_rounded;
      weatherColor = Colors.redAccent;
    } else if (mixedVal > 1.0) {
      brainStatus = 'อารมณ์แปรปรวน ง่วงซึม สับสน ควบคุมตัวเองได้ยาก';
      weatherIcon = Icons.cloud_rounded;
      weatherColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(weatherIcon, size: 32, color: weatherColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            brainStatus,
            style: TextStyle(
              fontSize: 11.5 * widget.fontScale,
              fontWeight: FontWeight.bold,
              color: mixedVal > 1.8 ? Colors.redAccent : Colors.amber,
              fontFamily: 'Prompt',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _buildMixerSlider(Icons.bolt_rounded, 'กระตุ้นประสาท', _stim, (v) => setState(() => _stim = v)),
          _buildMixerSlider(Icons.nightlight_round, 'กดประสาท', _depress, (v) => setState(() => _depress = v)),
          _buildMixerSlider(Icons.blur_on_rounded, 'หลอนประสาท', _hallucinate, (v) => setState(() => _hallucinate = v)),
        ],
      ),
    );
  }

  Widget _buildMixerSlider(IconData icon, String label, double val, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
        ),
        Expanded(
          child: Slider(
            value: val,
            onChanged: onChanged,
            min: 0.0,
            max: 1.0,
            activeColor: AppColors.success,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// WIDGET 3.0: MoodCrackedMirror (Mood Cracked Mirror)
// ============================================================================
class MoodCrackedMirror extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const MoodCrackedMirror({super.key, required this.isDark, required this.fontScale});

  @override
  State<MoodCrackedMirror> createState() => _MoodCrackedMirrorState();
}

class _MoodCrackedMirrorState extends State<MoodCrackedMirror> {
  bool _useDrugs = false;
  String _symptom = 'ปกติ';

  void _onSymptomChanged(String newSymptom) {
    setState(() {
      _symptom = newSymptom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF10B981);
    final purpleColor = const Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Selectors
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _useDrugs = false;
                      _symptom = 'ปกติ';
                    });
                  },
                  icon: const Icon(Icons.favorite_rounded, size: 14),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_useDrugs ? greenColor : (widget.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
                    foregroundColor: !_useDrugs ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  label: const Text('ชีวิตปกติ', style: TextStyle(fontFamily: 'Prompt', fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _useDrugs = true;
                      _symptom = 'หวาดระแวง';
                    });
                  },
                  icon: const Icon(Icons.warning_rounded, size: 14),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _useDrugs ? purpleColor : (widget.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
                    foregroundColor: _useDrugs ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  label: const Text('ใช้สารเสพติด', style: TextStyle(fontFamily: 'Prompt', fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mirror custom paint with physical shake
          TweenAnimationBuilder<double>(
            key: ValueKey(_symptom),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              // Physical mirror shake effect when cracking
              final double shake = _symptom != 'ปกติ'
                  ? sin(progress * pi * 8) * (1.0 - progress) * 6.0
                  : 0.0;

              return Transform.translate(
                offset: Offset(shake, 0),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _useDrugs ? purpleColor.withValues(alpha: 0.2) : greenColor.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: CustomPaint(
                    painter: PsychologicalMirrorPainter(
                      symptom: _symptom,
                      progress: progress,
                      isDark: widget.isDark,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Symptom selector chips (Only visible when drug involvement is true)
          if (_useDrugs) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSymptomChip('หวาดระแวง', Colors.redAccent),
                _buildSymptomChip('ซึมเศร้า', Colors.blueGrey.shade400),
                _buildSymptomChip('หุนหันพลันแล่น', Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _useDrugs ? purpleColor.withValues(alpha: 0.06) : greenColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _useDrugs ? purpleColor.withValues(alpha: 0.2) : greenColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _useDrugs ? 'ผลกระทบต่อจิตใจ ($_symptom):' : 'สภาพจิตใจปกติ:',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.5 * widget.fontScale,
                    fontWeight: FontWeight.bold,
                    color: _useDrugs ? purpleColor : greenColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _useDrugs ? _getSymptomDesc(_symptom) : 'สภาพจิตใจและกระบวนการทำงานของสมองเป็นระบบ ความคิดแจ่มใส ความจำดีเยี่ยม และมีความมั่นคงทางอารมณ์สูง',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 10.5 * widget.fontScale,
                    color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(String name, Color color) {
    final active = _symptom == name;
    return GestureDetector(
      onTap: () => _onSymptomChanged(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: active ? color : (widget.isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade400),
            width: active ? 1.8 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 10.5 * widget.fontScale,
            fontWeight: FontWeight.bold,
            color: active ? color : (widget.isDark ? Colors.white70 : Colors.black87),
            fontFamily: 'Prompt',
          ),
        ),
      ),
    );
  }

  String _getSymptomDesc(String sym) {
    switch (sym) {
      case 'หวาดระแวง':
        return 'ระแวงผู้คนรอบข้าง ไม่ไว้ใจใคร กลัวการปองร้าย สูญเสียการใช้ชีวิตร่วมกับครอบครัวและสังคมอย่างสงบสุข';
      case 'ซึมเศร้า':
        return 'สมองส่วนความสุขเสียหายอย่างถาวร นำไปสู่สภาวะซึมเศร้าเรื้อรัง อารมณ์ดิ่งจม และรู้สึกว่างเปล่าในทุกกิจกรรม';
      case 'หุนหันพลันแล่น':
        return 'การยับยั้งชั่งใจล้มเหลว ตัดสินใจด้วยความก้าวร้าวรุนแรงเฉียบพลัน นำไปสู่พฤติกรรมเสี่ยงอันตรายร้ายแรงต่อชีวิต';
      default:
        return '';
    }
  }
}

class PsychologicalMirrorPainter extends CustomPainter {
  final String symptom;
  final double progress;
  final bool isDark;

  PsychologicalMirrorPainter({required this.symptom, required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Draw Mirror Frame
    final framePaint = Paint()
      ..shader = LinearGradient(
        colors: isDark 
            ? [const Color(0xFF64748B), const Color(0xFF334155), const Color(0xFF1E293B)] 
            : [const Color(0xFFCBD5E1), const Color(0xFF94A3B8), const Color(0xFF64748B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(cx - 50, cy - 60, 100, 120))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
      
    final mirrorPath = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, cy - 10), width: 90, height: 110));
    canvas.drawPath(mirrorPath, framePaint);

    // Draw handle for mirror
    final handlePaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + 45), Offset(cx, cy + 85), handlePaint);

    // Clip inside the mirror glass
    canvas.save();
    canvas.clipPath(mirrorPath);

    // Glass Background Gradient
    Color g1, g2;
    if (symptom == 'ปกติ') {
      g1 = isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F2FE);
      g2 = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBAE6FD);
    } else if (symptom == 'หวาดระแวง') {
      g1 = const Color(0xFF2A0808);
      g2 = const Color(0xFF7F1D1D); // paranoia dark red
    } else if (symptom == 'ซึมเศร้า') {
      g1 = const Color(0xFF0F172A);
      g2 = const Color(0xFF334155); // depression dark grey
    } else {
      g1 = const Color(0xFF2E1065);
      g2 = const Color(0xFF701A75); // impulsivity neon purple
    }

    final glassPaint = Paint()
      ..shader = RadialGradient(colors: [g1, g2]).createShader(Rect.fromCenter(center: Offset(cx, cy), width: 90, height: 110));
    canvas.drawPaint(glassPaint);

    // Reflections (diagonal light streak)
    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: symptom == 'ปกติ' ? 0.15 : 0.05)
      ..strokeWidth = 12;
    canvas.drawLine(Offset(cx - 60, cy - 80), Offset(cx + 60, cy + 40), reflectionPaint);

    // Draw Face/Emotion inside mirror
    String emoji = '😊';
    if (symptom == 'หวาดระแวง') emoji = '😰';
    else if (symptom == 'ซึมเศร้า') emoji = '😢';
    else if (symptom == 'หุนหันพลันแล่น') emoji = '😡';

    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: 32, shadows: [
          Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))
        ]),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 10 - textPainter.height / 2));

    // Draw Cracks based on symptom
    if (symptom != 'ปกติ') {
      final crackPaint = Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      List<List<Offset>> crackPaths = [];
      if (symptom == 'หวาดระแวง') {
        crackPaint.color = Colors.redAccent.withValues(alpha: 0.9);
        crackPaths = [
          [Offset(cx, cy), Offset(cx - 15, cy - 20), Offset(cx - 30, cy - 25), Offset(cx - 45, cy - 35)],
          [Offset(cx, cy), Offset(cx + 20, cy - 10), Offset(cx + 35, cy - 25), Offset(cx + 45, cy - 30)],
          [Offset(cx, cy), Offset(cx - 10, cy + 25), Offset(cx - 15, cy + 45), Offset(cx - 20, cy + 55)],
        ];
      } else if (symptom == 'ซึมเศร้า') {
        crackPaint.strokeWidth = 1.0;
        crackPaint.color = Colors.blueGrey.shade300.withValues(alpha: 0.75);
        crackPaths = [
          [Offset(cx, cy), Offset(cx - 10, cy - 10), Offset(cx - 25, cy - 20), Offset(cx - 35, cy - 40)],
          [Offset(cx, cy), Offset(cx + 12, cy - 8), Offset(cx + 22, cy - 22), Offset(cx + 38, cy - 30)],
          [Offset(cx, cy), Offset(cx - 5, cy + 15), Offset(cx - 12, cy + 30), Offset(cx - 25, cy + 45)],
          [Offset(cx, cy), Offset(cx + 10, cy + 12), Offset(cx + 25, cy + 25), Offset(cx + 35, cy + 38)],
          // Web connectors
          [Offset(cx - 10, cy - 10), Offset(cx + 12, cy - 8)],
          [Offset(cx + 12, cy - 8), Offset(cx + 10, cy + 12)],
          [Offset(cx + 10, cy + 12), Offset(cx - 5, cy + 15)],
          [Offset(cx - 5, cy + 15), Offset(cx - 10, cy - 10)],
        ];
      } else if (symptom == 'หุนหันพลันแล่น') {
        crackPaint.strokeWidth = 2.2;
        crackPaint.color = Colors.orangeAccent.withValues(alpha: 0.9);
        crackPaths = [
          [Offset(cx, cy), Offset(cx - 25, cy - 5), Offset(cx - 45, cy - 10)],
          [Offset(cx, cy), Offset(cx + 25, cy + 5), Offset(cx + 45, cy + 10)],
          [Offset(cx, cy), Offset(cx - 5, cy - 25), Offset(cx - 10, cy - 50)],
          [Offset(cx, cy), Offset(cx + 5, cy + 25), Offset(cx + 10, cy + 50)],
          // diagonal shards
          [Offset(cx - 25, cy - 5), Offset(cx - 5, cy - 25)],
          [Offset(cx - 5, cy - 25), Offset(cx + 25, cy + 5)],
          [Offset(cx + 25, cy + 5), Offset(cx + 5, cy + 25)],
          [Offset(cx + 5, cy + 25), Offset(cx - 25, cy - 5)],
        ];
      }

      for (var path in crackPaths) {
        if (path.isEmpty) continue;
        final Path p = Path()..moveTo(path[0].dx, path[0].dy);
        double drawLimit = progress * (path.length - 1);
        int segmentsToDraw = drawLimit.floor();
        double remainingFraction = drawLimit - segmentsToDraw;

        for (int j = 0; j < segmentsToDraw; j++) {
          p.lineTo(path[j+1].dx, path[j+1].dy);
        }
        if (segmentsToDraw < path.length - 1) {
          final Offset startPoint = path[segmentsToDraw];
          final Offset endPoint = path[segmentsToDraw + 1];
          final Offset currentPoint = startPoint + (endPoint - startPoint) * remainingFraction;
          p.lineTo(currentPoint.dx, currentPoint.dy);
        }
        canvas.drawPath(p, crackPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PsychologicalMirrorPainter oldDelegate) {
    return oldDelegate.symptom != symptom || oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

// ============================================================================
// WIDGET 3.1: HumanBodyScanner (Human Body Scanner)
// ============================================================================
class HumanBodyScanner extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const HumanBodyScanner({super.key, required this.isDark, required this.fontScale});

  @override
  State<HumanBodyScanner> createState() => _HumanBodyScannerState();
}

class _HumanBodyScannerState extends State<HumanBodyScanner> {
  String _selectedOrgan = 'สมอง';

  Widget _buildGlowingIndicator(IconData icon, Color color, String organName) {
    final isSelected = _selectedOrgan == organName;
    return AnimatedOpacity(
      opacity: isSelected ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !isSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.4),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(icon, color: isSelected ? color : (widget.isDark ? Colors.white54 : Colors.black45), size: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Body outline
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.accessibility_new_rounded,
                          size: 110,
                          color: widget.isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      // Brain
                      Align(
                        alignment: const Alignment(0.0, -0.82),
                        child: _buildGlowingIndicator(Icons.bolt_rounded, Colors.amber, 'สมอง'),
                      ),
                      // Skin / Teeth
                      Align(
                        alignment: const Alignment(0.0, -0.55),
                        child: _buildGlowingIndicator(Icons.face_retouching_natural_rounded, Colors.teal, 'ผิวหนัง/ฟัน'),
                      ),
                      // Heart
                      Align(
                        alignment: const Alignment(-0.25, -0.2),
                        child: _buildGlowingIndicator(Icons.favorite_rounded, Colors.redAccent, 'หัวใจ'),
                      ),
                      // Lungs
                      Align(
                        alignment: const Alignment(0.0, -0.2),
                        child: _buildGlowingIndicator(Icons.air_rounded, Colors.orangeAccent, 'ปอด'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrganNode(Icons.psychology_rounded, 'สมอง'),
                    _buildOrganNode(Icons.favorite_rounded, 'หัวใจ'),
                    _buildOrganNode(Icons.air_rounded, 'ปอด'),
                    _buildOrganNode(Icons.face_retouching_natural_rounded, 'ผิวหนัง/ฟัน'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ผลเสียต่อ $_selectedOrgan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5 * widget.fontScale, color: Colors.redAccent, fontFamily: 'Prompt')),
                const SizedBox(height: 4),
                Text(
                  _getOrganDamageDesc(_selectedOrgan),
                  style: TextStyle(fontSize: 11 * widget.fontScale, fontFamily: 'Prompt', height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganNode(IconData icon, String name) {
    final active = _selectedOrgan == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedOrgan = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.redAccent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? Colors.redAccent : Colors.grey),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.redAccent : (widget.isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.85)),
                fontFamily: 'Prompt',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOrganDamageDesc(String organ) {
    switch (organ) {
      case 'สมอง':
        return 'สารพิษทำลายเซลล์ประสาทโดยตรง ส่งผลให้ความจำและสมาธิเสื่อมถอย ความสามารถในการเรียนรู้และวางแผนอนาคตลดลง';
      case 'หัวใจ':
        return 'สารกระตุ้นบางชนิดทำให้หัวใจเต้นผิดจังหวะ เสี่ยงหัวใจวายได้แม้ในคนหนุ่มสาว อาจเกิดขึ้นได้แม้แต่ครั้งแรก';
      case 'ปอด':
        return 'การสูบหรือสูดดมทำให้ปอดอักเสบและมีสารพิษสะสม เสี่ยงมะเร็งและโรคหายใจเรื้อรัง ทำให้เหนื่อยง่ายในระยะยาว';
      case 'ผิวหนัง/ฟัน':
        return 'สารบางชนิดทำให้ผิวแห้ง ริ้วรอยเร็วขึ้น ฟันผุสูงเพราะลดการผลิตน้ำลาย ส่งผลต่อบุคลิกภาพและความมั่นใจ';
      default:
        return '';
    }
  }
}

// ============================================================================
// WIDGET 3.2: FuturePathGpaVisual (Future Path GPA drop)
// ============================================================================
class FuturePathGpaVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const FuturePathGpaVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<FuturePathGpaVisual> createState() => _FuturePathGpaVisualState();
}

class _FuturePathGpaVisualState extends State<FuturePathGpaVisual> {
  double _involvement = 0.0; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    String gpaText = '4.00';
    String futureTitle = 'เส้นทางสดใส & โอกาสเต็มเปี่ยม';
    String futureText = 'เกรดเฉลี่ยดีเลิศ มีสิทธิ์ได้รับทุนการศึกษา โอกาสเรียนต่อต่างประเทศ และอาชีพในฝันรออยู่';
    IconData futureIcon = Icons.school_rounded;
    Color themeColor = AppColors.success;

    if (_involvement > 0.8) {
      gpaText = '0.00 / พ้นสภาพ';
      futureTitle = 'สูญสิ้นโอกาส & ไร้อนาคต';
      futureText = 'ถูกไล่ออก/พ้นสภาพนักศึกษา ประวัติเสีย ไม่สามารถเข้าศึกษาต่อหรือสมัครงานในบริษัทที่มั่นคงได้';
      futureIcon = Icons.cancel_rounded;
      themeColor = Colors.redAccent;
    } else if (_involvement > 0.5) {
      gpaText = '1.50 / คาดทัณฑ์';
      futureTitle = 'วิกฤตการเรียน & โดนทัณฑ์บน';
      futureText = 'ติดโปรต่ำ เสี่ยงถูกรีไทร์ หมดสิทธิ์รับทุนวิจัยหรือการสนับสนุน และโอกาสหางานลดลงอย่างรุนแรง';
      futureIcon = Icons.lock_rounded;
      themeColor = Colors.orangeAccent;
    } else if (_involvement > 0.2) {
      gpaText = '2.30 / ต่ำกว่ามาตรฐาน';
      futureTitle = 'เกรดตกต่ำ & สูญเสียโอกาส';
      futureText = 'เกรดลดฮวบ ต้องลงทะเบียนเรียนซ้ำ โอกาสได้เกียรตินิยมและทุนการศึกษาต่าง ๆ หมดไป';
      futureIcon = Icons.warning_rounded;
      themeColor = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎮 แบบจำลองบันไดอนาคตและผลการเรียน',
            style: TextStyle(
              fontSize: 14 * widget.fontScale,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              fontFamily: 'Prompt',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'เลื่อนสไลเดอร์เพื่อดูผลกระทบของการยุ่งเกี่ยวกับยาเสพติดที่มีต่อเกรดเฉลี่ยและความมั่นคงในอนาคต',
            style: TextStyle(
              fontSize: 11 * widget.fontScale,
              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontFamily: 'Prompt',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ladder representation (Left)
              SizedBox(
                width: 70,
                height: 160,
                child: CustomPaint(
                  painter: CareerLadderPainter(involvement: _involvement, isDark: widget.isDark),
                ),
              ),
              const SizedBox(width: 16),
              // Career Info Card (Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(futureIcon, color: themeColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'เกรดเฉลี่ย: $gpaText',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13 * widget.fontScale,
                                    color: themeColor,
                                    fontFamily: 'Prompt',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 12, thickness: 0.5),
                          Text(
                            futureTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12 * widget.fontScale,
                              color: themeColor,
                              fontFamily: 'Prompt',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            futureText,
                            style: TextStyle(
                              fontSize: 10.5 * widget.fontScale,
                              color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              height: 1.4,
                              fontFamily: 'Prompt',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ระดับความเสี่ยง:',
                          style: TextStyle(
                            fontSize: 10 * widget.fontScale,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${(_involvement * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11 * widget.fontScale,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                            fontFamily: 'Prompt',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: themeColor,
              inactiveTrackColor: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              thumbColor: themeColor,
              overlayColor: themeColor.withValues(alpha: 0.2),
              valueIndicatorColor: themeColor,
            ),
            child: Slider(
              value: _involvement,
              onChanged: (v) => setState(() => _involvement = v),
              min: 0.0,
              max: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class CareerLadderPainter extends CustomPainter {
  final double involvement;
  final bool isDark;

  CareerLadderPainter({required this.involvement, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double leftRail = w * 0.25;
    final double rightRail = w * 0.75;
    
    // Draw Rails with dynamic Gradient representing future health
    final railPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF10B981), // Green at the top
          const Color(0xFFF59E0B), // Yellow/Orange in middle
          const Color(0xFFEF4444), // Red at the bottom
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(leftRail, 10, rightRail, h - 10))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Draw rails
    canvas.drawLine(Offset(leftRail, 10), Offset(leftRail, h - 10), railPaint);
    canvas.drawLine(Offset(rightRail, 10), Offset(rightRail, h - 10), railPaint);

    // Rung configurations: Y-ratio, involvement threshold to break
    final List<Map<String, double>> rungs = [
      {'y': 0.15, 'threshold': 0.85},
      {'y': 0.30, 'threshold': 0.65},
      {'y': 0.45, 'threshold': 0.45},
      {'y': 0.60, 'threshold': 0.25},
      {'y': 0.75, 'threshold': 0.10},
      {'y': 0.90, 'threshold': 0.02},
    ];

    for (var rung in rungs) {
      final double y = rung['y']! * h;
      final double threshold = rung['threshold']!;
      final bool isBroken = involvement >= threshold;

      if (!isBroken) {
        // Draw normal rung
        final rungPaint = Paint()
          ..color = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(leftRail + 3, y), Offset(rightRail - 3, y), rungPaint);
      } else {
        // Draw broken rung hanging down
        final brokenPaint = Paint()
          ..color = Colors.redAccent.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round;

        final double midX = (leftRail + rightRail) / 2;
        // Left half slants down
        canvas.drawLine(Offset(leftRail + 3, y), Offset(midX - 4, y + 14), brokenPaint);
        // Right half slants down
        canvas.drawLine(Offset(rightRail - 3, y), Offset(midX + 4, y + 14), brokenPaint);

        // Draw crack debris
        final sparkPaint = Paint()
          ..color = Colors.redAccent.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(midX, y + 4), 2, sparkPaint);
      }
    }

    // Calculate Avatar position
    // Lerp from top rung to bottom
    final double startY = 0.15 * h;
    final double endY = h - 20;
    
    // Smooth interpolation
    final double avatarY = startY + (endY - startY) * involvement;
    final double avatarX = w / 2;

    // Determine avatar emoji based on involvement
    String emoji = '🎓';
    if (involvement > 0.8) {
      emoji = '💥';
    } else if (involvement > 0.5) {
      emoji = '⚠️';
    } else if (involvement > 0.2) {
      emoji = '🎒';
    }

    // Paint Avatar text
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 26,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(avatarX - textPainter.width / 2, avatarY - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CareerLadderPainter oldDelegate) {
    return oldDelegate.involvement != involvement || oldDelegate.isDark != isDark;
  }
}

// ============================================================================
// WIDGET 3.3: BrokenFamilyNetwork (Broken Family Network)
// ============================================================================
class BrokenFamilyNetwork extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const BrokenFamilyNetwork({super.key, required this.isDark, required this.fontScale});

  @override
  State<BrokenFamilyNetwork> createState() => _BrokenFamilyNetworkState();
}

class _BrokenFamilyNetworkState extends State<BrokenFamilyNetwork> {
  bool _useDrugs = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('สถานการณ์ชีวิตปัจจุบัน:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
              Switch(
                value: _useDrugs,
                onChanged: (v) => setState(() => _useDrugs = v),
                activeColor: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: FamilyNetworkPainter(useDrugs: _useDrugs, isDark: widget.isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _useDrugs
                ? 'ความสัมพันธ์สั่นคลอน คนรอบข้างห่างเหิน เพื่อนหาย ทำให้แก้ปัญหาได้ยากขึ้น'
                : 'ความสัมพันธ์ที่ดีช่วยดูแลและสนับสนุน ผ่านปัญหาได้ง่ายขึ้น ชีวิตมีความสุขและมีคนรับฟัง',
            style: TextStyle(
              fontSize: 11 * widget.fontScale,
              fontWeight: FontWeight.bold,
              color: _useDrugs ? Colors.redAccent : AppColors.success,
              fontFamily: 'Prompt',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FamilyNetworkPainter extends CustomPainter {
  final bool useDrugs;
  final bool isDark;

  FamilyNetworkPainter({required this.useDrugs, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Node locations – spread well apart proportionally
    final self = Offset(cx, cy);
    final parent = Offset(cx - size.width * 0.28, cy - size.height * 0.3);
    final teacher = Offset(cx + size.width * 0.28, cy - size.height * 0.3);
    final friend = Offset(cx, cy + size.height * 0.33);

    // Draw connection lines
    final linePaint = Paint()
      ..color = useDrugs ? Colors.redAccent.withValues(alpha: 0.95) : AppColors.success.withValues(alpha: 0.5)
      ..strokeWidth = useDrugs ? 3.5 : 2.0;

    if (useDrugs) {
      // Draw cracked/jagged lines instead of straight lines
      _drawCrackedLine(canvas, self, parent, linePaint);
      _drawCrackedLine(canvas, self, teacher, linePaint);
      _drawCrackedLine(canvas, self, friend, linePaint);
    } else {
      canvas.drawLine(self, parent, linePaint);
      canvas.drawLine(self, teacher, linePaint);
      canvas.drawLine(self, friend, linePaint);
    }

    // Draw node circles
    final nodePaint = Paint()..style = PaintingStyle.fill;

    nodePaint.color = Colors.blueAccent;
    canvas.drawCircle(self, 14, nodePaint);

    nodePaint.color = Colors.amber;
    canvas.drawCircle(parent, 12, nodePaint);

    nodePaint.color = Colors.purpleAccent;
    canvas.drawCircle(teacher, 12, nodePaint);

    nodePaint.color = Colors.teal;
    canvas.drawCircle(friend, 12, nodePaint);

    // Labels
    _drawLabel(canvas, 'เรา', self);
    _drawLabel(canvas, useDrugs ? 'ผู้ปกครอง' : 'ผู้ปกครอง', parent);
    _drawLabel(canvas, 'ครู', teacher);
    _drawLabel(canvas, useDrugs ? 'เพื่อนทิ้ง' : 'เพื่อน', friend);
  }

  void _drawCrackedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final vector = end - start;
    final length = vector.distance;
    final normal = Offset(-vector.dy / length, vector.dx / length); // perpendicular vector
    
    // Divide the line into segments with alternating zigs and zags
    final p1 = start + vector * 0.22 + normal * 11;
    final p2 = start + vector * 0.42 - normal * 11;
    
    final p3 = start + vector * 0.58 + normal * 9;
    final p4 = start + vector * 0.78 - normal * 9;
    
    // Draw first portion of the crack
    canvas.drawLine(start, p1, paint);
    canvas.drawLine(p1, p2, paint);
    
    // Leave a physical gap/fracture between p2 and p3 (representing the broken bond)
    
    // Draw second portion of the crack
    canvas.drawLine(p3, p4, paint);
    canvas.drawLine(p4, end, paint);
  }

  void _drawLabel(Canvas canvas, String label, Offset pt) {
    final p = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Prompt', color: Colors.grey)),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(canvas, Offset(pt.dx - p.width / 2, pt.dy - p.height - 12));
  }

  @override
  bool shouldRepaint(covariant FamilyNetworkPainter oldDelegate) {
    return oldDelegate.useDrugs != useDrugs || oldDelegate.isDark != isDark;
  }
}

// ============================================================================
// WIDGET 4.0: RefusalChatSimulator (Chat Refusal Simulator)
// ============================================================================
class RefusalChatSimulator extends StatefulWidget {
  final bool isDark;
  const RefusalChatSimulator({super.key, required this.isDark});

  @override
  State<RefusalChatSimulator> createState() => _RefusalChatSimulatorState();
}

class _RefusalChatSimulatorState extends State<RefusalChatSimulator> {
  int _selectedOption = -1;

  @override
  Widget build(BuildContext context) {
    String feedbackText = 'กรุณาเลือกคำตอบที่ถูกต้องเพื่อตอบโต้คำชักชวน';
    Color feedbackColor = Colors.grey;

    if (_selectedOption == 0) {
      feedbackText = '(ผล F): ยอมแพ้แรงกดดันง่ายเกินไป อาจนำไปสู่ความเสี่ยงจากยาเสพติดอย่างรวดเร็ว';
      feedbackColor = Colors.redAccent;
    } else if (_selectedOption == 1) {
      feedbackText = '(ผล C): ตอบเลี่ยงโดยไม่ชัดเจน อาจถูกตีความว่าสนใจหรือลังเล ควรเพิ่มความมั่นใจ';
      feedbackColor = Colors.orangeAccent;
    } else if (_selectedOption == 2) {
      feedbackText = '(ผล A+): ยอดเยี่ยมมาก! ปฏิเสธชัดเจน มั่นใจ รักษาตนเอง ทำให้เพื่อนที่ดีเคารพเราและอยู่ข้างเราต่อไป';
      feedbackColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark 
              ? Colors.white.withValues(alpha: 0.08) 
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Chat Room Header
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.isDark 
                      ? Colors.white.withValues(alpha: 0.08) 
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                // Avatar with online status indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.people_alt_rounded, 
                        size: 18, 
                        color: widget.isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade600
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E), // Online green
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ห้องแชทจำลอง',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Prompt',
                          color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'เพื่อนกำลังออนไลน์',
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: 'Prompt',
                              color: widget.isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Friend's message bubble (Left side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                child: Icon(
                  Icons.face_rounded, 
                  size: 20, 
                  color: widget.isDark ? Colors.blueGrey.shade200 : Colors.blueGrey.shade600
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        'เพื่อน (ผู้ชักชวน)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Prompt',
                          color: widget.isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                          color: widget.isDark 
                              ? Colors.white.withValues(alpha: 0.05) 
                              : Colors.black.withValues(alpha: 0.03),
                        ),
                      ),
                      child: Text(
                        'เห้ย มีตัวนี้มาใหม่ ลองป่ะ โคตรสุด ไม่ต้องกลัวหรอก ครั้งเดียวไม่ติดหรอก มาดิ',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontFamily: 'Prompt',
                          color: widget.isDark ? Colors.grey.shade100 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // User's response bubble (Right side)
          if (_selectedOption != -1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 2),
                        child: Text(
                          'ตัวเรา',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                            color: _selectedOption == 2 
                                ? AppColors.success 
                                : (_selectedOption == 1 ? Colors.orangeAccent : Colors.redAccent),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedOption == 2
                              ? (widget.isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
                              : (_selectedOption == 1
                                  ? (widget.isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5))
                                  : (widget.isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2))),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border.all(
                            color: _selectedOption == 2 
                                ? AppColors.success 
                                : (_selectedOption == 1 ? Colors.orangeAccent : Colors.redAccent),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _selectedOption == 0
                              ? 'โอเค... ลองก็ได้ ครั้งเดียวน่าจะโอเค'
                              : (_selectedOption == 1
                                  ? 'เอ่อ...ยังไม่แน่ใจนะ ขอคิดดูก่อน แวะมาหาใหม่!'
                                  : 'ไม่อ่ะแก เราไม่เล่นเรื่องพวกนี้เลย ขอบใจมาก'),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            fontFamily: 'Prompt',
                            color: _selectedOption == 2
                                ? (widget.isDark ? const Color(0xFFD1FAE5) : const Color(0xFF14532D))
                                : (_selectedOption == 1
                                    ? (widget.isDark ? const Color(0xFFFFEDD5) : const Color(0xFF7C2D12))
                                    : (widget.isDark ? const Color(0xFFFEE2E2) : const Color(0xFF7F1D1D))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _selectedOption == 2
                      ? AppColors.success
                      : (_selectedOption == 1 ? Colors.orangeAccent : Colors.redAccent),
                  child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
                ),
              ],
            ),
          ],

          // Feedback card (only visible after selecting an option)
          if (_selectedOption != -1) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: feedbackColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedOption == 2
                        ? Icons.check_circle_rounded
                        : (_selectedOption == 1 
                            ? Icons.warning_amber_rounded 
                            : Icons.cancel_rounded),
                    color: feedbackColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feedbackText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: feedbackColor,
                        fontFamily: 'Prompt',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // User interaction buttons or restart button
          if (_selectedOption == -1) ...[
            Column(
              children: [
                _buildRefusalOption(0, '1. ยอมตาม ไม่กล้าปฏิเสธ (เสี่ยงอันตราย)', Colors.redAccent),
                _buildRefusalOption(1, '2. ปฏิเสธไม่ชัดเจน (ถูกกดดันต่อเนื่องได้)', Colors.orangeAccent),
                _buildRefusalOption(2, '3. ปฏิเสธชัดเจนมั่นใจ (ทางเลือกที่ดีที่สุด)', AppColors.success),
              ],
            ),
          ] else ...[
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _selectedOption = -1),
                icon: const Icon(Icons.replay_rounded, size: 16),
                label: const Text('ลองใหม่อีกครั้ง', style: TextStyle(fontFamily: 'Prompt', fontSize: 12, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: widget.isDark ? AppColors.success : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefusalOption(int index, String label, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedOption = index),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          backgroundColor: color.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Prompt',
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET 4.1: FriendFilterVisual (Friend Filter Game)
// ============================================================================
class FriendFilterVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const FriendFilterVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<FriendFilterVisual> createState() => _FriendFilterVisualState();
}

class _FriendNode {
  final String name;
  final String detail;
  final bool isPositive;
  final IconData icon;
  final double angle; // in radians
  bool isInside; // True if inside inner circle

  _FriendNode({
    required this.name,
    required this.detail,
    required this.isPositive,
    required this.icon,
    required this.angle,
    required this.isInside,
  });
}

class _FriendFilterVisualState extends State<FriendFilterVisual> {
  late List<_FriendNode> _friends;

  @override
  void initState() {
    super.initState();
    _friends = [
      _FriendNode(
        name: 'นักกีฬา (ชวนออกกำลัง)',
        detail: 'รักสุขภาพ ชวนซ้อมกีฬาและใช้เวลาว่างเป็นประโยชน์',
        isPositive: true,
        icon: Icons.sports_basketball_rounded,
        angle: 45 * 3.14159265 / 180,
        isInside: false,
      ),
      _FriendNode(
        name: 'นักสูบ (ชวนลองพอต)',
        detail: 'มั่วสุม ชักชวนให้ทดลองบุหรี่ไฟฟ้าและสิ่งเสพติด',
        isPositive: false,
        icon: Icons.smoking_rooms_rounded,
        angle: 135 * 3.14159265 / 180,
        isInside: true,
      ),
      _FriendNode(
        name: 'นักเรียนเก่ง (ชวนติว)',
        detail: 'รับผิดชอบ ชวนอ่านหนังสือและเตรียมความพร้อมสอบ',
        isPositive: true,
        icon: Icons.menu_book_rounded,
        angle: 225 * 3.14159265 / 180,
        isInside: false,
      ),
      _FriendNode(
        name: 'นักลอง (ชวนทดลองยา)',
        detail: 'อยากรู้อยากลอง แอบพกพาสารเสพติดมาชวนให้ลองเสพ',
        isPositive: false,
        icon: Icons.warning_amber_rounded,
        angle: 315 * 3.14159265 / 180,
        isInside: true,
      ),
    ];
  }

  int get _safetyPoints {
    int points = 0;
    for (var f in _friends) {
      if ((f.isPositive && f.isInside) || (!f.isPositive && !f.isInside)) {
        points += 25;
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final int safety = _safetyPoints;
    final successColor = AppColors.success;
    final warningColor = Colors.orangeAccent;
    final dangerColor = Colors.redAccent;
    
    Color gaugeColor = safety > 70 
        ? successColor 
        : (safety > 40 ? warningColor : dangerColor);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Safety Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ความปลอดภัยในกลุ่มเพื่อนสนิท:',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              Text(
                '$safety%',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12 * widget.fontScale,
                  fontWeight: FontWeight.w900,
                  color: gaugeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: safety / 100,
              minHeight: 8,
              backgroundColor: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
            ),
          ),
          
          const SizedBox(height: 12),
          Text(
            'แตะที่รูปเพื่อปรับย้ายกลุ่ม (วงใน = สนิท, วงนอก = เฝ้าระวัง)',
            style: TextStyle(
              fontSize: 10 * widget.fontScale,
              fontFamily: 'Prompt',
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          
          // Concentric Radar Stack
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double centerX = constraints.maxWidth / 2;
                final double centerY = 100.0;
                final double innerRadius = 42.0;
                final double outerRadius = 80.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Outer orbit guideline
                    Positioned(
                      left: centerX - outerRadius,
                      top: centerY - outerRadius,
                      child: IgnorePointer(
                        child: Container(
                          width: outerRadius * 2,
                          height: outerRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Inner orbit guideline
                    Positioned(
                      left: centerX - innerRadius,
                      top: centerY - innerRadius,
                      child: IgnorePointer(
                        child: Container(
                          width: innerRadius * 2,
                          height: innerRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isDark ? Colors.white.withValues(alpha: 0.01) : Colors.black.withValues(alpha: 0.01),
                            border: Border.all(
                              color: widget.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Center node (Me)
                    Positioned(
                      left: centerX - 20,
                      top: centerY - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gaugeColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: gaugeColor.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: gaugeColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Friend nodes
                    ..._friends.map((friend) {
                      final double radius = friend.isInside ? innerRadius : outerRadius;
                      final double left = centerX + radius * cos(friend.angle) - 18;
                      final double top = centerY + radius * sin(friend.angle) - 18;
                      
                      Color nodeColor;
                      if (friend.isPositive) {
                        nodeColor = friend.isInside ? successColor : warningColor;
                      } else {
                        nodeColor = friend.isInside ? dangerColor : Colors.blueGrey;
                      }

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutBack,
                        left: left,
                        top: top,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              friend.isInside = !friend.isInside;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: nodeColor,
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: nodeColor.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Icon(
                              friend.icon,
                              color: nodeColor,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          
          // Detailed checklist status
          const SizedBox(height: 8),
          Column(
            children: _friends.map((friend) {
              final isCorrect = (friend.isPositive && friend.isInside) || (!friend.isPositive && !friend.isInside);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? successColor.withValues(alpha: 0.15)
                        : warningColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      friend.icon,
                      size: 16,
                      color: friend.isPositive ? successColor : dangerColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.name,
                            style: TextStyle(
                              fontSize: 11 * widget.fontScale,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Prompt',
                              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            friend.detail,
                            style: TextStyle(
                              fontSize: 9.5 * widget.fontScale,
                              fontFamily: 'Prompt',
                              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? successColor.withValues(alpha: 0.1)
                            : warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCorrect ? 'ปลอดภัย' : 'เฝ้าระวัง',
                        style: TextStyle(
                          fontSize: 9.5 * widget.fontScale,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Prompt',
                          color: isCorrect ? successColor : warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET 4.2: StressBusterVisual (Stress Buster Clicker)
// ============================================================================
class StressBusterVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const StressBusterVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<StressBusterVisual> createState() => _StressBusterVisualState();
}

class _StressBusterVisualState extends State<StressBusterVisual> {
  double _stressVal = 0.9;
  String _act = 'ยังไม่ได้ทำอะไร';

  void _relieve(String action, double val) {
    setState(() {
      _act = action;
      if (action.contains('ยาเสพติด')) {
        // Substance drop then spikes
        _stressVal = 0.2;
        Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _stressVal = 1.0;
              _act = 'ฤทธิ์ยาหมด -> ความเครียดกลับสูงกว่าเดิม!';
            });
          }
        });
      } else {
        _stressVal = (_stressVal - val).clamp(0.0, 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color gaugeColor = _stressVal > 0.7 ? Colors.redAccent : (_stressVal > 0.4 ? Colors.amber : AppColors.success);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ระดับความเครียดชีวิต:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
              Text('${(_stressVal * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: gaugeColor, fontFamily: 'Prompt')),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _stressVal,
              minHeight: 10,
              backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_act.contains('หมด') || _act.contains('ยาเสพติด'))
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 14)
              else if (_act != 'ยังไม่ได้ทำอะไร')
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 14),
              if (_act != 'ยังไม่ได้ทำอะไร') const SizedBox(width: 6),
              Text(
                'กิจกรรมล่าสุด: $_act',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white70 : Colors.black.withOpacity(0.85), fontFamily: 'Prompt'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStressBtn(Icons.sports_basketball_rounded, 'เล่นกีฬา', 0.3),
              const SizedBox(width: 6),
              _buildStressBtn(Icons.music_note_rounded, 'ฟังเพลง', 0.3),
              const SizedBox(width: 6),
              _buildStressBtn(Icons.forum_rounded, 'คุยกับที่ไว้ใจ', 0.4),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _relieve('ใช้ยาเสพติด (ทางเลือกผิด)', 0.7),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              icon: const Icon(Icons.warning_amber_rounded, size: 16),
              label: const Text('ลองใช้ยาเสพติดเพื่อคลายเครียด', style: TextStyle(fontSize: 11, fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressBtn(IconData icon, String name, double factor) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _relieve(name, factor),
        icon: Icon(icon, size: 12),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          foregroundColor: widget.isDark ? Colors.white70 : Colors.black.withOpacity(0.85),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        ),
        label: Text(name, style: const TextStyle(fontSize: 9.5, fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ============================================================================
// WIDGET 5.0: LawDecisionPathways (Pathways of Law)
// ============================================================================
class LawDecisionPathways extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const LawDecisionPathways({super.key, required this.isDark, required this.fontScale});

  @override
  State<LawDecisionPathways> createState() => _LawDecisionPathwaysState();
}

class _LawDecisionPathwaysState extends State<LawDecisionPathways> {
  int _currentStage = 0; // 0: Choice, 1: Process, 2: Summary
  int _userChoice = -1;  // 0: Rehab, 1: Crime

  void _resetGame() {
    setState(() {
      _currentStage = 0;
      _userChoice = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Visual Stepper Header
          _buildStepper(_currentStage),
          const SizedBox(height: 16),

          // Stage content switch
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStageContent(_currentStage),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(int currentStage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot('1. ทางเลือก', currentStage >= 0, currentStage == 0),
        _buildStepLine(currentStage >= 1),
        _buildStepDot('2. ดำเนินการ', currentStage >= 1, currentStage == 1),
        _buildStepLine(currentStage >= 2),
        _buildStepDot('3. จุดจบชีวิต', currentStage >= 2, currentStage == 2),
      ],
    );
  }

  Widget _buildStepDot(String label, bool isCompleted, bool isActive) {
    final Color activeColor = isActive
        ? AppColors.primary
        : (isCompleted
            ? (_userChoice == 0 ? AppColors.success : Colors.redAccent)
            : Colors.grey);
            
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isCompleted ? activeColor : (widget.isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
            shape: BoxShape.circle,
            border: Border.all(
              color: activeColor,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted && !isActive
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5 * widget.fontScale,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Prompt',
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    final activeColor = _userChoice == 0 ? AppColors.success : Colors.redAccent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44,
      height: 2,
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
      color: isCompleted ? activeColor : (widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
    );
  }

  Widget _buildStageContent(int stage) {
    if (stage == 0) {
      return _buildChoiceStage();
    } else if (stage == 1) {
      return _buildProcessStage();
    } else {
      return _buildSummaryStage();
    }
  }

  Widget _buildChoiceStage() {
    return Column(
      key: const ValueKey('stage0'),
      children: [
        Text(
          'เมื่อตกอยู่ในสถานการณ์ที่เกี่ยวพันกับยาเสพติด คุณจะตัดสินใจเลือกเดินเส้นทางใด?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12 * widget.fontScale,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        
        // Choice A: Rehab
        _buildChoiceCard(
          title: 'ทางเลือก A: เข้ารับการบำบัดรักษา',
          desc: 'รับการบำบัดฟื้นฟูโดยสมัครใจตามกฎหมายผู้เสพคือผู้ป่วยเพื่อคืนสู่สังคม',
          color: AppColors.success,
          icon: Icons.local_hospital_rounded,
          onTap: () {
            setState(() {
              _userChoice = 0;
              _currentStage = 1;
            });
          },
        ),
        const SizedBox(height: 10),
        
        // Choice B: Trafficking
        _buildChoiceCard(
          title: 'ทางเลือก B: ยุ่งเกี่ยวกับกระบวนการค้า',
          desc: 'รับจ้างส่งของ ค้าปลีก หรือครอบครองปริมาณสารเกินกว่าที่กฎหมายกำหนด',
          color: Colors.redAccent,
          icon: Icons.gavel_rounded,
          onTap: () {
            setState(() {
              _userChoice = 1;
              _currentStage = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 12.5 * widget.fontScale,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 10.5 * widget.fontScale,
                      color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStage() {
    final bool isRehab = _userChoice == 0;
    final primaryColor = isRehab ? AppColors.success : Colors.redAccent;
    
    return Column(
      key: const ValueKey('stage1'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(
                isRehab ? Icons.medical_services_rounded : Icons.lock_person_rounded,
                color: primaryColor,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                isRehab ? 'กระบวนการสมัครใจเข้าบำบัดรักษา' : 'กระบวนการจับกุมดำเนินคดีทางอาญา',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 13 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRehab
                    ? 'ศาลเล็งเห็นเจตจำนงในการบำบัด ส่งตัวเข้าโปรแกรมฟื้นฟูโดยละเว้นโทษจำคุกชั่วคราว มุ่งเน้นการเยียวยารักษาสุขภาพและจิตใจ'
                    : 'เจ้าหน้าที่เข้าตรวจค้น พบยาเสพติดปริมาณเกินอัตรากำหนด ดำเนินคดีตามกฎหมายยาเสพติดฉบับใหม่ ส่งตัวเข้าห้องขังรอคำตัดสินศาล',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11 * widget.fontScale,
                  color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStage = 2;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRehab ? 'ดูผลลัพธ์และการฟื้นตัว' : 'ดูคำพิพากษาและอนาคต',
                style: const TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStage() {
    final bool isRehab = _userChoice == 0;
    final primaryColor = isRehab ? AppColors.success : Colors.redAccent;

    return Column(
      key: const ValueKey('stage2'),
      children: [
        Text(
          isRehab ? 'เส้นทางชีวิตที่กลับตัวได้สำเร็จ 🛡' : 'จุดจบชีวิตจากความผิดทางกฎหมาย ✗',
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 14 * widget.fontScale,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        // Outcome Dashboard
        Column(
          children: isRehab
              ? [
                  _buildSummaryRow(
                    icon: Icons.shield_rounded,
                    color: AppColors.success,
                    title: 'สถานะประวัติอาชญากรรม',
                    desc: 'ไม่มีประวัติอาชญากรรม (กฎหมายคุ้มครองสิทธิ์ฟื้นฟู)',
                  ),
                  _buildSummaryRow(
                    icon: Icons.local_hospital_rounded,
                    color: AppColors.success,
                    title: 'โทษจำคุก',
                    desc: 'ละเว้นโทษจำคุกจากการให้ความร่วมมือรับบำบัดรักษาตัวจนครบกำหนด',
                  ),
                  _buildSummaryRow(
                    icon: Icons.flight_takeoff_rounded,
                    color: AppColors.success,
                    title: 'การเดินทางและทำงาน',
                    desc: 'เรียนต่อต่างประเทศ ทำงานเอกชน สมัครทุนรัฐบาลได้ตามปกติ',
                  ),
                ]
              : [
                  _buildSummaryRow(
                    icon: Icons.gavel_rounded,
                    color: Colors.redAccent,
                    title: 'สถานะประวัติอาชญากรรม',
                    desc: 'บันทึกประวัติคดีอาญาถาวรในระบบสืบค้นกองทะเบียนประวัติฯ',
                  ),
                  _buildSummaryRow(
                    icon: Icons.lock_clock_rounded,
                    color: Colors.redAccent,
                    title: 'โทษจำคุก',
                    desc: 'โทษหนักขึ้นกับสารเสพติด (โทษสูงสุดจำคุกตลอดชีวิต / ประหารชีวิต)',
                  ),
                  _buildSummaryRow(
                    icon: Icons.no_accounts_rounded,
                    color: Colors.redAccent,
                    title: 'การเดินทางและทำงาน',
                    desc: 'หมดสิทธิ์รับราชการ ไม่ผ่านเงื่อนไขการขอเอกสารเดินทาง ทุนเรียนหาย วีซ่าข้ามแดนถูกแบน',
                  ),
                ],
        ),
        const SizedBox(height: 16),
        
        OutlinedButton.icon(
          onPressed: _resetGame,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text(
            'ย้อนกลับไปจุดเริ่มต้นเพื่อสำรวจเส้นทางอื่น',
            style: TextStyle(fontFamily: 'Prompt', fontSize: 11, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            side: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.5 * widget.fontScale,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 10 * widget.fontScale,
                    color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.3,
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

// ============================================================================
// WIDGET 5.1: ScalesOfJusticeVisual (Scales of Justice Balancer)
// ============================================================================
class ScalesOfJusticeVisual extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const ScalesOfJusticeVisual({super.key, required this.isDark, required this.fontScale});

  @override
  State<ScalesOfJusticeVisual> createState() => _ScalesOfJusticeVisualState();
}

class _ScalesOfJusticeVisualState extends State<ScalesOfJusticeVisual> {
  // Factors definition
  final List<Map<String, dynamic>> _factors = [
    {
      'id': 'possession_use',
      'label': 'ครอบครองเพื่อเสพ (<15 เม็ด)',
      'desc': 'ผู้เสพสมัครใจเข้าบำบัดรักษา',
      'weight': -2, // inclines to rehab
    },
    {
      'id': 'trafficking',
      'label': 'ครอบครองเพื่อจำหน่าย/ค้า',
      'desc': 'พบพฤติการณ์จำหน่าย/แบ่งขาย',
      'weight': 4, // inclines to crime
    },
    {
      'id': 'cooperation',
      'label': 'รับสารภาพ/ให้ความร่วมมือ',
      'desc': 'ให้ข้อมูลที่เป็นประโยชน์ในการปราบปราม',
      'weight': -1, // inclines to rehab/mitigation
    },
    {
      'id': 'escape_destroy',
      'label': 'พยายามหลบหนี/ทำลายหลักฐาน',
      'desc': 'ไม่ยอมให้ความร่วมมือ หรือสู้เจ้าหน้าที่',
      'weight': 2, // inclines to crime
    },
  ];

  final Set<String> _selectedIds = {};

  int get _netWeight {
    int sum = 0;
    for (var factor in _factors) {
      if (_selectedIds.contains(factor['id'])) {
        sum += factor['weight'] as int;
      }
    }
    return sum;
  }

  void _toggleFactor(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final net = _netWeight;
    // Normalized tilt value from -1.0 (max left) to 1.0 (max right)
    final double targetTilt = (net.toDouble() / 4.0).clamp(-1.0, 1.0);

    Color resultColor;
    String resultTitle;
    String resultDesc;
    IconData resultIcon;

    if (net < 0) {
      resultColor = AppColors.success;
      resultTitle = 'แนวโน้ม: เข้ารับการบำบัดรักษา 🏥';
      resultDesc = 'มีน้ำหนักการกระทำความผิดอยู่ในระดับต่ำ และเน้นการฟื้นฟูตามหลัก "ผู้เสพคือผู้ป่วย" หากสมัครใจเข้าบำบัดจะได้รับการยกเว้นโทษจำคุกและไม่มีประวัติอาชญากรรม';
      resultIcon = Icons.healing_rounded;
    } else if (net > 0) {
      resultColor = Colors.redAccent;
      resultTitle = 'แนวโน้ม: ดำเนินคดีทางอาญา ⚖️';
      resultDesc = 'มีพฤติการณ์เกี่ยวกับการค้า หรือพยายามหลบหนีบิดเบือนคดีความ ต้องระวางโทษจำคุกตามระดับของปริมาณยาและเจตนา ไม่สามารถใช้กระบวนการบำบัดเพื่อเลี่ยงโทษได้';
      resultIcon = Icons.gavel_rounded;
    } else {
      resultColor = Colors.amber;
      resultTitle = 'แนวโน้ม: รอการพิจารณา / ดุลพินิจศาล ⚖️';
      resultDesc = 'น้ำหนักคดีความอยู่ในเกณฑ์ก้ำกึ่ง ศาลและพนักงานอัยการจะพิจารณาจากพฤติการณ์จริง ประวัติย้อนหลัง และความสมัครใจในการบำบัดรักษา';
      resultIcon = Icons.balance_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.scale_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เครื่องชั่งน้ำหนักข้อกฎหมาย',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 13.5 * widget.fontScale,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'แตะเลือกปัจจัยเพื่อชั่งน้ำหนักการพิจารณาคดีความ',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.5 * widget.fontScale,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Scale
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: targetTilt),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, tiltValue, child) {
              return Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                  ),
                ),
                child: CustomPaint(
                  painter: LawScalePainter(
                    tiltValue: tiltValue,
                    isDark: widget.isDark,
                    leftBlocks: _selectedIds.where((id) => _factors.firstWhere((f) => f['id'] == id)['weight'] < 0).length,
                    rightBlocks: _selectedIds.where((id) => _factors.firstWhere((f) => f['id'] == id)['weight'] > 0).length,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Factors selector
          Text(
            'ปัจจัยแวดล้อมทางคดีความ:',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 11 * widget.fontScale,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ..._factors.map((factor) {
            final isSelected = _selectedIds.contains(factor['id']);
            final int weight = factor['weight'] as int;
            final isPositive = weight > 0;
            final Color weightColor = isPositive ? Colors.redAccent : AppColors.success;
            final String weightText = isPositive ? '+$weight (คุก)' : '$weight (บำบัด)';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () => _toggleFactor(factor['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isPositive ? Colors.redAccent.withValues(alpha: 0.06) : AppColors.success.withValues(alpha: 0.06))
                        : (widget.isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? weightColor.withValues(alpha: 0.5)
                          : (widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? weightColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? weightColor : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              factor['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 11.5 * widget.fontScale,
                                fontWeight: FontWeight.bold,
                                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              factor['desc'] as String,
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 9.5 * widget.fontScale,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: weightColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          weightText,
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 9 * widget.fontScale,
                            fontWeight: FontWeight.bold,
                            color: weightColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Dynamic Result Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: resultColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resultIcon,
                    color: resultColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultTitle,
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 13 * widget.fontScale,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resultDesc,
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 10.5 * widget.fontScale,
                          color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
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

class LawScalePainter extends CustomPainter {
  final double tiltValue; // -1.0 to 1.0
  final bool isDark;
  final int leftBlocks;
  final int rightBlocks;

  LawScalePainter({
    required this.tiltValue,
    required this.isDark,
    required this.leftBlocks,
    required this.rightBlocks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2 + 10;

    // Colors
    final Color mainColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4);
    final Color brassColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFFB59410);

    // 1. Draw Stand/Pillar Base & Post
    final pillarPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;
    
    // Pillar Base
    final Rect baseRect = Rect.fromLTRB(cx - 30, cy + 40, cx + 30, cy + 48);
    canvas.drawRRect(RRect.fromRectAndRadius(baseRect, const Radius.circular(4)), pillarPaint);

    // Vertical Post
    final postPaint = Paint()
      ..color = mainColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 40), Offset(cx, cy + 40), postPaint);

    // Center pivot knob
    final pivotPaint = Paint()
      ..color = brassColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - 35), 7, pivotPaint);

    // 2. Beam geometry
    final double maxAngle = 15.0 * pi / 180.0;
    final double angle = tiltValue * maxAngle;
    final double beamLength = size.width * 0.55;

    final double bx1 = cx - (beamLength / 2) * cos(angle);
    final double by1 = (cy - 35) - (beamLength / 2) * sin(angle);

    final double bx2 = cx + (beamLength / 2) * cos(angle);
    final double by2 = (cy - 35) + (beamLength / 2) * sin(angle);

    // Draw main beam
    final beamPaint = Paint()
      ..color = brassColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(bx1, by1), Offset(bx2, by2), beamPaint);

    // 3. Hanging Trays
    // Left Tray
    _drawTray(canvas, Offset(bx1, by1), isDark ? AppColors.success : const Color(0xFF2E7D32), "🏥", leftBlocks);
    
    // Right Tray
    _drawTray(canvas, Offset(bx2, by2), isDark ? Colors.redAccent : const Color(0xFFC62828), "⛓️", rightBlocks);
  }

  void _drawTray(Canvas canvas, Offset hangPoint, Color accentColor, String emoji, int blocksCount) {
    const double trayHeight = 45.0;
    const double trayWidth = 34.0;
    final double tx = hangPoint.dx;
    final double ty = hangPoint.dy + trayHeight;

    // Draw suspension strings
    final stringPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black26
      ..strokeWidth = 1.0;
    
    canvas.drawLine(hangPoint, Offset(tx - trayWidth / 2, ty), stringPaint);
    canvas.drawLine(hangPoint, Offset(tx + trayWidth / 2, ty), stringPaint);
    canvas.drawLine(hangPoint, Offset(tx, ty), stringPaint);

    // Draw Tray Plate
    final trayPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(tx - trayWidth / 2 - 2, ty), Offset(tx + trayWidth / 2 + 2, ty), trayPaint);

    // Draw tray stand/bottom lip
    final lipPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final Rect lipRect = Rect.fromLTRB(tx - trayWidth / 2, ty, tx + trayWidth / 2, ty + 4);
    canvas.drawRRect(RRect.fromRectAndRadius(lipRect, const Radius.circular(2)), lipPaint);

    // Draw emoji indicator
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(tx - textPainter.width / 2, ty - 18));

    // Draw blocks representing weight
    if (blocksCount > 0) {
      final blockPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      for (int i = 0; i < blocksCount; i++) {
        final double bx = tx - 4.0 + (i % 2 == 0 ? -4.0 : 4.0);
        final double by = ty - 4.0 - (i / 2).floor() * 6.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, 7, 5), const Radius.circular(1.5)),
          blockPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LawScalePainter oldDelegate) {
    return oldDelegate.tiltValue != tiltValue ||
        oldDelegate.isDark != isDark ||
        oldDelegate.leftBlocks != leftBlocks ||
        oldDelegate.rightBlocks != rightBlocks;
  }
}

// ============================================================================
// WIDGET 5.2: CareerPassportStamps (Career Passport Stamps)
// ============================================================================
class CareerPassportStamps extends StatefulWidget {
  final bool isDark;
  final double fontScale;
  const CareerPassportStamps({super.key, required this.isDark, required this.fontScale});

  @override
  State<CareerPassportStamps> createState() => _CareerPassportStampsState();
}

class _CareerPassportStampsState extends State<CareerPassportStamps> {
  bool _hasRecord = false;
  
  // Stamping animation states
  double _opacity1 = 0.0;
  double _opacity2 = 0.0;
  double _opacity3 = 0.0;
  
  double _scale1 = 2.5;
  double _scale2 = 2.5;
  double _scale3 = 2.5;

  bool _isStamping = false;

  @override
  void initState() {
    super.initState();
    // Trigger initial stamping animation after widget compiles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerStamping();
    });
  }

  void _triggerStamping() async {
    if (_isStamping) return;
    setState(() {
      _isStamping = true;
      _opacity1 = 0.0; _scale1 = 2.5;
      _opacity2 = 0.0; _scale2 = 2.5;
      _opacity3 = 0.0; _scale3 = 2.5;
    });

    // Stamp 1
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _opacity1 = 1.0;
      _scale1 = 1.0;
    });
    
    // Stamp 2
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _opacity2 = 1.0;
      _scale2 = 1.0;
    });

    // Stamp 3
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _opacity3 = 1.0;
      _scale3 = 1.0;
      _isStamping = false;
    });
  }
  
  void _changeProfile(bool hasRecord) {
    if (_isStamping) return;
    setState(() {
      _hasRecord = hasRecord;
    });
    _triggerStamping();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'อนุมัติหนังสือเดินทางอาชีพ',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 13.5 * widget.fontScale,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'ตรวจเช็คประวัติอาชญากรรมเพื่อพิจารณาสิทธิ์การเดินทางและเข้าทำงาน',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10.5 * widget.fontScale,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profiles Selection Row
          Row(
            children: [
              Expanded(
                child: _buildProfileTab(
                  label: 'นายนที',
                  status: 'ผู้บำบัดรักษาฟื้นฟูสำเร็จ',
                  isClean: true,
                  isSelected: !_hasRecord,
                  onTap: () => _changeProfile(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileTab(
                  label: 'นายวายุ',
                  status: 'ผู้มีประวัติคดีอาญาทางยา',
                  isClean: false,
                  isSelected: _hasRecord,
                  onTap: () => _changeProfile(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Passport Layout Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                // Dossier Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _hasRecord ? Colors.redAccent.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                      child: Icon(
                        _hasRecord ? Icons.person_off_rounded : Icons.person_rounded,
                        color: _hasRecord ? Colors.redAccent : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasRecord ? 'ผู้สมัคร: นายวายุ' : 'ผู้สมัคร: นายนที',
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 12 * widget.fontScale,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            _hasRecord
                                ? 'สถานะ: ตรวจพบประวัติยาเสพติดประเภทที่ 1'
                                : 'สถานะ: ผ่านการบำบัดโดยสมัครใจ / ไร้ประวัติคดี',
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 10 * widget.fontScale,
                              color: _hasRecord ? Colors.redAccent : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                // Stamping Grid
                Column(
                  children: [
                    _buildStampRow(
                      icon: Icons.flight_takeoff_rounded,
                      title: 'STUDY VISA (วีซ่าเรียนต่อต่างประเทศ)',
                      description: 'ขอทุนการศึกษาและหนังสือเดินทางประเทศเป้าหมาย',
                      approved: !_hasRecord,
                      opacity: _opacity1,
                      scale: _scale1,
                      rotation: -0.08,
                    ),
                    const SizedBox(height: 12),
                    _buildStampRow(
                      icon: Icons.business_rounded,
                      title: 'WORK PERMIT (บริษัทเทคโนโลยีชั้นนำ)',
                      description: 'ผ่านเกณฑ์ตรวจสอบประวัติบุคคลเข้าทำงานงานไอที',
                      approved: !_hasRecord,
                      opacity: _opacity2,
                      scale: _scale2,
                      rotation: 0.05,
                    ),
                    const SizedBox(height: 12),
                    _buildStampRow(
                      icon: Icons.gavel_rounded,
                      title: 'GOVERNMENT (การสมัครสอบราชการ/ทหาร)',
                      description: 'ตรวจสอบคุณสมบัติต้องห้ามตามพระราชบัญญัติฯ',
                      approved: !_hasRecord,
                      opacity: _opacity3,
                      scale: _scale3,
                      rotation: -0.04,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic Guidance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _hasRecord ? Colors.redAccent.withValues(alpha: 0.08) : AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasRecord ? Colors.redAccent.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _hasRecord ? Icons.lock_rounded : Icons.school_rounded,
                  color: _hasRecord ? Colors.redAccent : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasRecord
                        ? 'ประวัติอาชญากรรมทางเพศ/ยาเสพติด จะถูกเก็บถาวรในทะเบียนประวัติอาชญากร ส่งผลให้ถูกปฏิเสธวีซ่าและขาดคุณสมบัติในการทำงานสำคัญตลอดชีวิต'
                        : 'การเข้ารับการบำบัดรักษาครบตามเกณฑ์ กฎหมายจะไม่บันทึกประวัติอาชญากรรม ทำให้ยังคงได้สิทธิ์ในการเรียนต่อ ทำงานเอกชน และสอบราชการได้ตามปกติ',
                    style: TextStyle(
                      fontSize: 11 * widget.fontScale,
                      fontWeight: FontWeight.bold,
                      color: _hasRecord ? Colors.redAccent : AppColors.success,
                      fontFamily: 'Prompt',
                      height: 1.4,
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

  Widget _buildProfileTab({
    required String label,
    required String status,
    required bool isClean,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = isClean ? AppColors.success : Colors.redAccent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : (widget.isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : (widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 12.5 * widget.fontScale,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : (widget.isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 9 * widget.fontScale,
                color: isSelected ? activeColor.withValues(alpha: 0.8) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStampRow({
    required IconData icon,
    required String title,
    required String description,
    required bool approved,
    required double opacity,
    required double scale,
    required double rotation,
  }) {
    final stampColor = approved ? AppColors.success : Colors.redAccent;
    final stampText = approved ? 'APPROVED' : 'DENIED';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Content
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: widget.isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 11 * widget.fontScale,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 9 * widget.fontScale,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Overlay ink stamp with scale and tilt animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            right: approved ? 24 : 12,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: scale,
                curve: Curves.bounceOut,
                child: Transform.rotate(
                  angle: rotation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stampColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: stampColor,
                        width: 2.2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stampText,
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 9.5 * widget.fontScale,
                            fontWeight: FontWeight.bold,
                            color: stampColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          approved ? 'ผ่านการพิจารณา' : 'ไม่อนุมัติ / มีคดี',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 7.5 * widget.fontScale,
                            fontWeight: FontWeight.bold,
                            color: stampColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
