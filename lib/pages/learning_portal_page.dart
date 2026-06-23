import 'package:flutter/material.dart';
import 'dart:math';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/app_background.dart';
import '../utils/animations.dart';
import 'topic_detail_page.dart';

class LearningPortalPage extends StatefulWidget {
  const LearningPortalPage({super.key});

  @override
  State<LearningPortalPage> createState() => _LearningPortalPageState();
}

class _LearningPortalPageState extends State<LearningPortalPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _radialAnimController;
  late final AnimationController _floatingAnimController;
  late final Animation<double> _radialExpansionAnimation;
  String _tab2SubSection = 'ผลกระทบ';
  int _preventionPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // 2 Tabs: บทนำ and ผลกระทบ & ป้องกัน (separated Law into its own navigation tab)
    _tabController = TabController(length: 2, vsync: this);
    
    _radialAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _radialExpansionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radialAnimController, curve: Curves.elasticOut),
    );
    _radialAnimController.forward();

    // Loop for gentle floating wobbly movement in the constellation
    _floatingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _radialAnimController.dispose();
    _floatingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final textColor = isDark ? Colors.white : AppColors.textDark;

        return BackgroundWrapper(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'บทเรียนศึกษา',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: isDark ? AppColors.success : AppColors.primary,
                labelColor: isDark ? AppColors.success : AppColors.primary,
                unselectedLabelColor: isDark ? Colors.white60 : AppColors.textGrey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Prompt',
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'บทนำ'),
                  Tab(text: 'ผลกระทบ & ป้องกัน'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildIntroTab(state),
                _buildImpactPreventionTab(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== 1. INTRODUCTION TAB (CONSTELLATION MENU) ====================
  Widget _buildIntroTab(AppState state) {
    final isDark = state.isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerSize = (constraints.maxWidth * 0.85).clamp(280.0, 340.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  'แผนผังการเรียนรู้',
                  style: TextStyle(
                    fontSize: 18 * state.fontScale,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'แตะที่ดวงดาวแต่ละดวงในกลุ่มดาวเพื่อศึกษาข้อมูลการเรียนรู้',
                  style: TextStyle(
                    fontSize: 12.5 * state.fontScale,
                    color: subTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Constellation Menu Space
                Center(
                  child: SizedBox(
                    width: containerSize,
                    height: containerSize,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Dotted Connecting Lines Painter
                        AnimatedBuilder(
                          animation: _radialExpansionAnimation,
                          builder: (context, child) {
                            final radius = (containerSize / 2 - 40) * _radialExpansionAnimation.value;
                            return CustomPaint(
                              size: Size(containerSize, containerSize),
                              painter: ConstellationLinesPainter(
                                radius: radius,
                                color: isDark ? Colors.white24 : Colors.black.withOpacity(0.08),
                              ),
                            );
                          },
                        ),

                        // Constellation Nodes (Interactive Stars)
                        AnimatedBuilder(
                          animation: Listenable.merge([_radialExpansionAnimation, _floatingAnimController]),
                          builder: (context, child) {
                            final radius = (containerSize / 2 - 42) * _radialExpansionAnimation.value;
                            final elapsed = _floatingAnimController.value * 2 * pi;
                            final centerX = containerSize / 2;
                            final centerY = containerSize / 2;

                            return SizedBox(
                              width: containerSize,
                              height: containerSize,
                              child: Stack(
                                children: [
                                  // Node 1: กฎหมาย (Top Center, angle: -90)
                                  _buildConstellationNode(
                                    angleDegrees: -90,
                                    radius: radius,
                                    elapsed: elapsed,
                                    title: 'กฎหมาย',
                                    icon: Icons.gavel_rounded,
                                    color: Colors.blueAccent,
                                    isDark: isDark,
                                    topicType: TopicType.law,
                                    centerX: centerX,
                                    centerY: centerY,
                                  ),
                                  // Node 2: ผลกระทบ (Middle Left, angle: -150)
                                  _buildConstellationNode(
                                    angleDegrees: -150,
                                    radius: radius,
                                    elapsed: elapsed,
                                    title: 'ผลกระทบ',
                                    icon: Icons.favorite_rounded,
                                    color: Colors.redAccent,
                                    isDark: isDark,
                                    topicType: TopicType.impact,
                                    centerX: centerX,
                                    centerY: centerY,
                                  ),
                                  // Node 3: การป้องกัน (Middle Right, angle: -30)
                                  _buildConstellationNode(
                                    angleDegrees: -30,
                                    radius: radius,
                                    elapsed: elapsed,
                                    title: 'การป้องกัน',
                                    icon: Icons.shield_rounded,
                                    color: AppColors.success,
                                    isDark: isDark,
                                    topicType: TopicType.prevention,
                                    centerX: centerX,
                                    centerY: centerY,
                                  ),
                                  // Node 4: ประเภทสาร (Bottom Left, angle: 135)
                                  _buildConstellationNode(
                                    angleDegrees: 135,
                                    radius: radius,
                                    elapsed: elapsed,
                                    title: 'ประเภทสาร',
                                    icon: Icons.category_rounded,
                                    color: Colors.amber,
                                    isDark: isDark,
                                    topicType: TopicType.classification,
                                    centerX: centerX,
                                    centerY: centerY,
                                  ),
                                  // Node 5: คืออะไร? (Bottom Right, angle: 45)
                                  _buildConstellationNode(
                                    angleDegrees: 45,
                                    radius: radius,
                                    elapsed: elapsed,
                                    title: 'คืออะไร?',
                                    icon: Icons.help_outline_rounded,
                                    color: AppColors.primary,
                                    isDark: isDark,
                                    topicType: TopicType.definition,
                                    centerX: centerX,
                                    centerY: centerY,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Constellation Center Core (YouthShield Hub)
                        _buildConstellationCore(isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConstellationNode({
    required double angleDegrees,
    required double radius,
    required double elapsed,
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required TopicType topicType,
    required double centerX,
    required double centerY,
  }) {
    final double angleRad = angleDegrees * pi / 180;
    
    // Smooth sinusoidal floating translation unique for each angle
    final double wobbleX = sin(elapsed + angleDegrees) * 4.5;
    final double wobbleY = cos(elapsed + angleDegrees * 1.5) * 4.5;

    final double dx = cos(angleRad) * radius + wobbleX;
    final double dy = sin(angleRad) * radius + wobbleY;

    return Positioned(
      left: centerX + dx - 45,
      top: centerY + dy - 35,
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  FadeScalePageRoute(
                    page: TopicDetailPage(topicType: topicType),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.black45 : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : AppColors.textDark,
                fontFamily: 'Prompt',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstellationCore(bool isDark) {
    final baseColor = isDark ? AppColors.success : AppColors.primary;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: baseColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.55),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 2. IMPACT & PREVENTION TAB ====================
  Widget _buildImpactPreventionTab(BuildContext context, AppState state) {
    final isDark = state.isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double bodyHeight = 380.0;
        final double bodyWidth = 280.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segment Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSegmentItem(
                      label: 'ผลกระทบ 4 ด้าน',
                      isSelected: _tab2SubSection == 'ผลกระทบ',
                      onTap: () => setState(() => _tab2SubSection = 'ผลกระทบ'),
                      isDark: isDark,
                    ),
                    _buildSegmentItem(
                      label: 'แนวทางป้องกัน',
                      isSelected: _tab2SubSection == 'การป้องกัน',
                      onTap: () => setState(() => _tab2SubSection = 'การป้องกัน'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Content
              if (_tab2SubSection == 'ผลกระทบ') ...[
                Text(
                  'ผลกระทบต่ออวัยวะร่างกาย 🧍',
                  style: TextStyle(
                    fontSize: 16 * state.fontScale,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'แตะที่จุดเรืองแสงบนร่างกายเพื่อวิเคราะห์ผลกระทบตามด้านต่าง ๆ',
                  style: TextStyle(
                    fontSize: 12.5 * state.fontScale,
                    color: subTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Soft Educational Human Figure Canvas
                Center(
                  child: Container(
                    width: bodyWidth,
                    height: bodyHeight,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withOpacity(0.3) : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: borderColor.withOpacity(0.4)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Custom silhouette painter
                        SizedBox(
                          width: bodyWidth,
                          height: bodyHeight,
                          child: CustomPaint(
                            painter: SilhouettePainter(
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          ),
                        ),

                        // Interactive Hotspots (46x46 tap targets)
                        // 1. Brain (จิตใจ)
                        _buildHotspot(
                          top: bodyHeight * 0.18 - 23,
                          left: bodyWidth * 0.5 - 23,
                          tooltip: 'จิตใจ',
                          icon: Icons.psychology_rounded,
                          color: Colors.deepPurpleAccent,
                          isDark: isDark,
                          onTap: () {
                            _showImpactBottomSheet(
                              context,
                              'จิตใจ',
                              'ประสาทหลอน เกิดภาพลวงตา หวาดระแวง อารมณ์แปรปรวนง่าย และเพิ่มความเสี่ยงต่อภาวะซึมเศร้าและโรคจิตเภทอย่างถาวรในเยาวชน',
                              Icons.psychology_rounded,
                              Colors.deepPurpleAccent,
                              state,
                            );
                          },
                        ),
                        // 2. Heart (ร่างกาย)
                        _buildHotspot(
                          top: bodyHeight * 0.38 - 23,
                          left: bodyWidth * 0.5 - 23,
                          tooltip: 'ร่างกาย',
                          icon: Icons.accessibility_new_rounded,
                          color: Colors.redAccent,
                          isDark: isDark,
                          onTap: () {
                            _showImpactBottomSheet(
                              context,
                              'ร่างกาย',
                              'ทำลายเซลล์สมอง ตับทำงานหนัก ลำไส้อ่อนแอ และส่งผลกระทบให้หัวใจเต้นผิดจังหวะ เสี่ยงหัวใจล้มเหลวเฉียบพลัน',
                              Icons.accessibility_new_rounded,
                              Colors.redAccent,
                              state,
                            );
                          },
                        ),
                        // 3. Right Arm (การเรียน)
                        _buildHotspot(
                          top: bodyHeight * 0.46 - 23,
                          left: bodyWidth * 0.72 - 23,
                          tooltip: 'การเรียน',
                          icon: Icons.school_rounded,
                          color: Colors.blueAccent,
                          isDark: isDark,
                          onTap: () {
                            _showImpactBottomSheet(
                              context,
                              'การเรียน',
                              'ทำลายสมาธิ ความจำสั้นลง ขาดความกระตือรือร้นในการเรียน ส่งผลให้ผลเรียนตกต่ำและสูญเสียโอกาสการรับทุนและการสอบแข่งขัน',
                              Icons.school_rounded,
                              Colors.blueAccent,
                              state,
                            );
                          },
                        ),
                        // 4. Left Arm (สังคม)
                        _buildHotspot(
                          top: bodyHeight * 0.46 - 23,
                          left: bodyWidth * 0.28 - 23,
                          tooltip: 'สังคม',
                          icon: Icons.group_rounded,
                          color: Colors.teal,
                          isDark: isDark,
                          onTap: () {
                            _showImpactBottomSheet(
                              context,
                              'สังคม',
                              'ทำลายความอบอุ่นและความสัมพันธ์ในครอบครัว ขาดความน่าเชื่อถือในหมู่เพื่อนฝูง และปิดกั้นอนาคตในการก้าวเข้าสู่อาชีพการงาน',
                              Icons.group_rounded,
                              Colors.teal,
                              state,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text(
                  '3 ทักษะเหล็กเพื่อการป้องกัน',
                  style: TextStyle(
                    fontSize: 16 * state.fontScale,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Story slides
                SizedBox(
                  height: 190,
                  child: PageView(
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (idx) {
                      setState(() {
                        _preventionPageIndex = idx;
                      });
                    },
                    children: [
                      _buildStorySlideItem(
                        title: '1. ปฏิเสธอย่างสุภาพและหนักแน่น',
                        desc: 'เมื่อโดนชวน ให้ยืนยันคำเดิมโดยยกเหตุผลส่วนตัว เช่น "ไม่ล่ะ ขอบคุณ พอดีฉันต้องรีบกลับบ้านอ่านหนังสือ" แล้วเบี่ยงประเด็นทันที',
                        stepNum: 'Ⅰ',
                        color: AppColors.primary,
                        isDark: isDark,
                        state: state,
                      ),
                      _buildStorySlideItem(
                        title: '2. เลือกคบเพื่อน',
                        desc: 'เพื่อนที่ดีจะชวนกันไปเรียน เล่นกีฬา หรือทำกิจกรรมดนตรี หากรู้สึกว่าเริ่มไม่ปลอดภัย ให้รีบจำกัดระยะความสัมพันธ์',
                        stepNum: 'Ⅱ',
                        color: Colors.amber,
                        isDark: isDark,
                        state: state,
                      ),
                      _buildStorySlideItem(
                        title: '3. ระบายความเครียดอย่างถูกวิธี',
                        desc: 'หากกำลังเจอปัญหาครอบครัว อย่าเก็บกดไว้ระบายความในใจกับผู้ใหญ่ที่ไว้ใจ หรือโทรสายด่วนสุขภาพจิต 1323',
                        stepNum: 'Ⅲ',
                        color: AppColors.success,
                        isDark: isDark,
                        state: state,
                      ),
                    ],
                  ),
                ),
                
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (idx) {
                    final isActive = idx == _preventionPageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 16 : 6,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : (isDark ? Colors.white24 : AppColors.border),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // warnings warnings
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'สัญญาณเตือนภัยที่ควรสังเกต',
                    style: TextStyle(
                      fontSize: 15.5 * state.fontScale,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      _buildSymptomItem(
                        icon: Icons.mood_bad_rounded,
                        title: 'การเปลี่ยนแปลงทางอารมณ์',
                        desc: 'อารมณ์แปรปรวนง่าย ฉุนเฉียว หรือเก็บตัวซึมเศร้าผิดปกติอย่างรวดเร็ว',
                        state: state,
                      ),
                      const Divider(height: 20),
                      _buildSymptomItem(
                        icon: Icons.accessibility_new_rounded,
                        title: 'พฤติกรรมทางร่างกาย',
                        desc: 'ผิวพรรณทรุดโทรม ใบหน้าหมองคล้ำ น้ำหนักลดฮวบ ตาโรย หรือมือสั่นเกร็ง',
                        state: state,
                      ),
                      const Divider(height: 20),
                      _buildSymptomItem(
                        icon: Icons.work_off_rounded,
                        title: 'ความรับผิดชอบตกต่ำ',
                        desc: 'เริ่มขาดเรียน ผลการเรียนตกต่ำอย่างชัดเจน หรือหลีกเลี่ยงกิจกรรมกลุ่ม',
                        state: state,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.success : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white60 : AppColors.textDark),
            fontWeight: FontWeight.w700,
            fontSize: 13,
            fontFamily: 'Prompt',
          ),
        ),
      ),
    );
  }

  Widget _buildHotspot({
    required double top,
    required double left,
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Tooltip(
        message: 'ผลกระทบด้าน $tooltip',
        textStyle: const TextStyle(
          fontFamily: 'Prompt',
          fontSize: 12,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Semantics(
          label: 'จุดวิเคราะห์ผลกระทบด้าน $tooltip',
          button: true,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.18),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorySlideItem({
    required String title,
    required String desc,
    required String stepNum,
    required Color color,
    required bool isDark,
    required AppState state,
  }) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stepNum,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: color,
                    fontFamily: 'Prompt',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Prompt',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textGrey,
                    height: 1.45,
                    fontFamily: 'Prompt',
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImpactBottomSheet(
    BuildContext context,
    String title,
    String summary,
    IconData icon,
    Color iconColor,
    AppState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: state.isDarkMode ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 30),
                  const SizedBox(width: 12),
                  Text(
                    'ผลกระทบต่อ$title',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: state.isDarkMode ? Colors.white : AppColors.textDark,
                      fontFamily: 'Prompt',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                summary,
                style: TextStyle(
                  fontSize: 14.5,
                  color: state.isDarkMode ? Colors.white70 : AppColors.textGrey,
                  height: 1.6,
                  fontFamily: 'Prompt',
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isDarkMode ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'เข้าใจแล้ว',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Prompt'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSymptomItem({
    required IconData icon,
    required String title,
    required String desc,
    required AppState state,
  }) {
    final isDark = state.isDarkMode;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isDark ? AppColors.success : AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== EXPLORE CONSTELLATION CONNECTION LINE PAINTER ====================
class ConstellationLinesPainter extends CustomPainter {
  final double radius;
  final Color color;

  ConstellationLinesPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    const double radianConversion = pi / 180;

    final double angleLaw = -90 * radianConversion;
    final double angleImpact = -150 * radianConversion;
    final double anglePrevention = -30 * radianConversion;
    final double angleClass = 135 * radianConversion;
    final double angleDef = 45 * radianConversion;

    final offsetLaw = center + Offset(cos(angleLaw) * radius, sin(angleLaw) * radius);
    final offsetImpact = center + Offset(cos(angleImpact) * radius, sin(angleImpact) * radius);
    final offsetPrevention = center + Offset(cos(anglePrevention) * radius, sin(anglePrevention) * radius);
    final offsetClass = center + Offset(cos(angleClass) * radius, sin(angleClass) * radius);
    final offsetDef = center + Offset(cos(angleDef) * radius, sin(angleDef) * radius);

    // Draw dashed hub connectors
    _drawDashedLine(canvas, center, offsetLaw, paint);
    _drawDashedLine(canvas, center, offsetImpact, paint);
    _drawDashedLine(canvas, center, offsetPrevention, paint);
    _drawDashedLine(canvas, center, offsetClass, paint);
    _drawDashedLine(canvas, center, offsetDef, paint);

    // Draw dashed outer links representing the constellation pattern
    _drawDashedLine(canvas, offsetImpact, offsetLaw, paint);
    _drawDashedLine(canvas, offsetLaw, offsetPrevention, paint);
    _drawDashedLine(canvas, offsetClass, offsetDef, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    
    final double distance = (p2 - p1).distance;
    final double dx = (p2.dx - p1.dx) / distance;
    final double dy = (p2.dy - p1.dy) / distance;
    
    double currentDist = 0.0;
    while (currentDist < distance) {
      canvas.drawLine(
        Offset(p1.dx + dx * currentDist, p1.dy + dy * currentDist),
        Offset(p1.dx + dx * min(currentDist + dashWidth, distance), p1.dy + dy * min(currentDist + dashWidth, distance)),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationLinesPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}

// ==================== SOFT CHILD-FRIENDLY HUMAN SILHOUETTE PAINTER ====================
class SilhouettePainter extends CustomPainter {
  final Color color;

  SilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final bodyPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // Head
    canvas.drawCircle(Offset(w / 2, h * 0.18), h * 0.08, bodyPaint);
    canvas.drawCircle(Offset(w / 2, h * 0.18), h * 0.08, paint);

    // Neck
    path.moveTo(w * 0.47, h * 0.26);
    path.lineTo(w * 0.47, h * 0.29);
    path.lineTo(w * 0.53, h * 0.29);
    path.lineTo(w * 0.53, h * 0.26);

    // Shoulders & Arms
    path.moveTo(w * 0.47, h * 0.29);
    path.lineTo(w * 0.3, h * 0.35); // Left shoulder
    path.lineTo(w * 0.26, h * 0.55); // Left arm down
    path.lineTo(w * 0.31, h * 0.55); // Left hand thickness
    path.lineTo(w * 0.35, h * 0.39); // Underarm
    
    path.moveTo(w * 0.53, h * 0.29);
    path.lineTo(w * 0.7, h * 0.35); // Right shoulder
    path.lineTo(w * 0.74, h * 0.55); // Right arm down
    path.lineTo(w * 0.69, h * 0.55); // Right hand thickness
    path.lineTo(w * 0.65, h * 0.39); // Underarm

    // Torso
    path.moveTo(w * 0.35, h * 0.39);
    path.lineTo(w * 0.37, h * 0.65); // Left waist
    path.lineTo(w * 0.63, h * 0.65); // Right waist
    path.lineTo(w * 0.65, h * 0.39); // Back up to right underarm
    
    // Hips & Legs
    path.moveTo(w * 0.37, h * 0.65);
    path.lineTo(w * 0.35, h * 0.95); // Left leg
    path.lineTo(w * 0.45, h * 0.95); // Left foot
    path.lineTo(w * 0.48, h * 0.73); // Crotch

    path.moveTo(w * 0.63, h * 0.65);
    path.lineTo(w * 0.65, h * 0.95); // Right leg
    path.lineTo(w * 0.55, h * 0.95); // Right foot
    path.lineTo(w * 0.52, h * 0.73); // Crotch

    // Connect crotch
    path.moveTo(w * 0.48, h * 0.73);
    path.lineTo(w * 0.52, h * 0.73);

    canvas.drawPath(path, paint);
    
    // Fill torso & legs path
    final fillPath = Path()
      ..moveTo(w * 0.47, h * 0.29)
      ..lineTo(w * 0.3, h * 0.35)
      ..lineTo(w * 0.26, h * 0.55)
      ..lineTo(w * 0.31, h * 0.55)
      ..lineTo(w * 0.35, h * 0.39)
      ..lineTo(w * 0.37, h * 0.65)
      ..lineTo(w * 0.35, h * 0.95)
      ..lineTo(w * 0.45, h * 0.95)
      ..lineTo(w * 0.48, h * 0.73)
      ..lineTo(w * 0.52, h * 0.73)
      ..lineTo(w * 0.55, h * 0.95)
      ..lineTo(w * 0.65, h * 0.95)
      ..lineTo(w * 0.63, h * 0.65)
      ..lineTo(w * 0.65, h * 0.39)
      ..lineTo(w * 0.69, h * 0.55)
      ..lineTo(w * 0.74, h * 0.55)
      ..lineTo(w * 0.7, h * 0.35)
      ..lineTo(w * 0.53, h * 0.29)
      ..close();
    
    canvas.drawPath(fillPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
