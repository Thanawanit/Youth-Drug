import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../main.dart';
import '../constants/app_colors.dart';
import '../widgets/app_background.dart';

class LawPage extends StatefulWidget {
  const LawPage({super.key});

  @override
  State<LawPage> createState() => _LawPageState();
}

class _LawPageState extends State<LawPage> {
  int _activeCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'กฎหมายน่ารู้',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: BackgroundWrapper(
            child: SafeArea(
              child: Column(
                children: [
                  // 1. Topic Intro Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.gavel_rounded,
                              color: Colors.blueAccent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'กฎหมายมีไว้ปกป้องชุมชน',
                                  style: TextStyle(
                                    fontSize: 14.5 * state.fontScale,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'เรียนรู้หลักกฎหมายเบื้องต้นเพื่อเข้าใจสังคมและความปลอดภัยของตนเอง',
                                  style: TextStyle(
                                    fontSize: 12 * state.fontScale,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Interactive Selector Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSelectorTab(0, 'หลักการสำคัญ', Icons.gavel_rounded, isDark, state.fontScale),
                        _buildSelectorTab(1, 'หน้าที่และอนาคต', Icons.verified_user_rounded, isDark, state.fontScale),
                      ],
                    ),
                  ),

                  // 3. Dynamic Interactive Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildCategoryContent(
                          _activeCategoryIndex,
                          isDark,
                          textColor,
                          subTextColor,
                          cardBg,
                          borderColor,
                          state.fontScale,
                        ),
                      ),
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

  Widget _buildSelectorTab(int index, String label, IconData icon, bool isDark, double fontScale) {
    final isSelected = _activeCategoryIndex == index;
    final activeColor = isDark ? AppColors.success : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: activeColor,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF334155) : AppColors.border),
          ),
        ),
        onSelected: (val) {
          if (val) {
            setState(() {
              _activeCategoryIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildCategoryContent(
    int index,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color cardBg,
    Color borderColor,
    double fontScale,
  ) {
    switch (index) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLawCard(
              title: 'หลักการ "ผู้เสพคือผู้ป่วย"',
              content: 'กฎหมายปัจจุบันของไทยมองว่า ผู้ที่เสพติดยาเสพติดเป็นเหยื่อและผู้ป่วยที่ต้องการความช่วยเหลือ ไม่ใช่คนร้าย\n\nหากยินยอมและสมัครใจเข้ารับการบำบัดรักษาตามแพทย์สั่งจนครบมาตรฐาน กฎหมายจะให้โอกาสโดย "ไม่มีการบันทึกประวัติอาชญากรรม" ทำให้ผู้บำบัดสามารถกลับตัวเป็นพลเมืองดีและไม่มีมลทินติดตัว',
              icon: Icons.health_and_safety_rounded,
              iconColor: AppColors.success,
              isDark: isDark,
              borderColor: borderColor,
              cardBg: cardBg,
              fontScale: fontScale,
            ),
            _buildLawCard(
              title: 'การบำบัดรักษา vs โทษทางอาญา',
              content: '• หากเลือกยอมรับความจริงและยินดีบำบัด: จะได้รับการบำบัดรักษาฟรีและได้รับโอกาสเริ่มต้นใหม่\n\n• หากหลบเลี่ยงไม่ยอมบำบัด หรือฝ่าฝืนข้อตกลง: จะต้องถูกส่งตัวเข้าสู่ระบบกระบวนการยุติธรรมและอาจได้รับโทษปรับหรือคุมประพฤติตามกฎหมายกำหนด',
              icon: Icons.repeat_on_rounded,
              iconColor: Colors.amber,
              isDark: isDark,
              borderColor: borderColor,
              cardBg: cardBg,
              fontScale: fontScale,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'สถานการณ์สมมติกฎหมายใกล้ตัว',
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            _ExpandableScenarioCard(
              title: 'เพื่อนฝากกระเป๋าปริศนา',
              scenario: 'เพื่อนสนิทนำของบางอย่างที่ใส่ไว้ในกระเป๋ามิดชิดมาฝากคุณไว้ในล็อกเกอร์ โดยกำชับว่าห้ามเปิดดูเด็ดขาด และจะมารับคืนหลังเลิกเรียน...',
              question: 'คุณควรตัดสินใจอย่างไรกับสถานการณ์นี้?',
              optionUnsafeText: 'ตกลงรับฝาก (เพราะไว้ใจเพื่อนสนิทและอยากช่วยเหลือ)',
              optionSafeText: 'ปฏิเสธอย่างสุภาพ (ไม่รับฝากของที่ตรวจสอบภายในไม่ได้)',
              outcomeUnsafe: 'มีความเสี่ยงสูงมาก! หากโรงเรียนสุ่มตรวจหรือสุนัขตำรวจตรวจค้นแล้วพบสารเสพติด คุณจะตกเป็นผู้ต้องหาฐานครอบครองยาเสพติดทันที การอ้างว่า "ไม่รู้ตัวยาข้างใน" เป็นข้อพิสูจน์ทางกฎหมายที่ทำได้ยากยิ่งและทำให้ประวัติเสียทันที',
              outcomeSafe: 'ปลอดภัย 100%! การปฏิเสธรับฝากสิ่งของที่คุณตรวจสอบของภายในไม่ได้ เป็นสิทธิขั้นพื้นฐานในการป้องกันตัวเองจากคดีอาญาและรักษาความปลอดภัยในชีวิตคุณ',
              tip: 'หลีกเลี่ยงการรับฝากสิ่งของที่ไม่ชัดเจนจากผู้อื่นเด็ดขาด โดยเฉพาะอย่างยิ่งของที่ปิดผนึกแน่นหนาหรือผู้ฝากสั่งห้ามเปิดดู',
              icon: Icons.backpack_rounded,
              color: Colors.orangeAccent,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _ExpandableScenarioCard(
              title: 'โดนรุ่นพี่ข่มขู่ให้ส่งของ',
              scenario: 'รุ่นพี่ขาใหญ่ในชุมชนข่มขู่ว่าถ้าคุณไม่เอาห่อกระดาษขนาดเล็กไปส่งต่อให้ลูกค้าหลังโรงเรียน จะดักรุมทำร้ายคุณหลังเลิกเรียนวันนี้...',
              question: 'คุณควรจัดการกับภัยคุกคามนี้อย่างไร?',
              optionUnsafeText: 'ยอมเดินไปส่งของให้ (เพื่อหลีกเลี่ยงการถูกทำร้ายร่างกาย)',
              optionSafeText: 'ปฏิเสธเด็ดขาดแล้วรีบแจ้งพ่อแม่และครูฝ่ายปกครองทันที',
              outcomeUnsafe: 'อันตรายร้ายแรง! หากคุณนำส่งมอบยาเสพติด คุณจะมีส่วนร่วมฐานเป็นผู้จัดจำหน่าย/ส่งมอบสารเสพติดทันที มีโทษจำคุกสูง และประวัติคดีอาญาจะติดตัวไปตลอดชีวิต (การอ้างว่าถูกข่มขู่ทำร้ายในทางกฎหมายไม่พ้นโทษฐานร่วมขบวนการ)',
              outcomeSafe: 'ปลอดภัยและได้รับการปกป้อง! ทางโรงเรียน คณะครู และเจ้าหน้าที่ตำรวจมีมาตรการช่วยเหลือและคุ้มครองความปลอดภัยให้นักเรียน คุณจะไม่ต้องมีคดีความทางกฎหมายหรือความเสี่ยงใดๆ',
              tip: 'เมื่อถูกข่มขู่ให้ทำสิ่งผิดกฎหมาย อย่าเก็บบางเรื่องไว้คนเดียว การขอความช่วยเหลือจากผู้ใหญ่ที่ไว้ใจได้คือทางออกที่ถูกต้องและปลอดภัยที่สุด',
              icon: Icons.error_outline_rounded,
              color: Colors.redAccent,
              isDark: isDark,
            ),
          ],
        );
      case 1:
      default:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLawCard(
              title: 'ประวัติสะอาด = อนาคตที่สดใส',
              content: 'การไม่เข้าไปยุ่งเกี่ยวกับยาเสพติดและไม่มีประวัติคดีความทางกฎหมาย ส่งผลดีต่อชีวิตเยาวชนอย่างมหาศาล:\n\n• สามารถสอบคัดเลือกเข้ารับราชการ หรือทหาร-ตำรวจ\n• เดินทางท่องเที่ยวและศึกษาต่อต่างประเทศได้ง่าย (การขอวีซ่าไม่ติดขัด)\n• ได้รับโอกาสรับทุนการศึกษาหรือเข้าฝึกงานในบริษัทเอกชนชั้นนำ',
              icon: Icons.stars_rounded,
              iconColor: Colors.amber,
              isDark: isDark,
              borderColor: borderColor,
              cardBg: cardBg,
              fontScale: fontScale,
            ),
            _buildLawCard(
              title: 'หน้าที่ของเด็กและเยาวชนที่ดี',
              content: 'ในฐานะนักเรียน เราสามารถมีส่วนร่วมปกป้องสังคมได้โดย:\n\n1. คอยสังเกตและเป็นหูเป็นตาช่วยเหลือเพื่อนร่วมชั้น\n2. ไม่เป็นผู้เผยแพร่ข้อมูลหรือบุหรี่ไฟฟ้าให้ผู้อื่น\n3. บอกกล่าวคุณครูหรือสายตรวจเมื่อพบเบาะแสที่น่าสงสัย',
              icon: Icons.gpp_good_rounded,
              iconColor: AppColors.success,
              isDark: isDark,
              borderColor: borderColor,
              cardBg: cardBg,
              fontScale: fontScale,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'สถานการณ์สมมติกฎหมายใกล้ตัว',
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            _ExpandableScenarioCard(
              title: 'บุหรี่ไฟฟ้าในโรงเรียน',
              scenario: 'เพื่อนชวนลองสูบบุหรี่ไฟฟ้าในห้องน้ำ โดยบอกว่าสูบเล่นๆ ไม่มีใครรู้ และกลิ่นหอมเป็นน้ำผลไม้ไม่ผิดกฎหมายรุนแรงเหมือนยาบ้า...',
              question: 'คุณควรรับมือกับการชักชวนนี้อย่างไร?',
              optionUnsafeText: 'ขอลองสูบดูสักครั้ง (เพราะคิดว่าไม่มีอันตรายรุนแรง)',
              optionSafeText: 'ปฏิเสธหนักแน่นแล้วชวนคุยเรื่องอื่นหรือชวนไปเตะบอลแทน',
              outcomeUnsafe: 'คิดผิดมหันต์! บุหรี่ไฟฟ้ายังคงผิดกฎหมายในประเทศไทย (ห้ามนำเข้า ครอบครอง และจำหน่าย) การครอบครองในโรงเรียนจะถูกลงโทษทางวินัยหนัก แจ้งผู้ปกครอง และนิโคตินเข้มข้นจะกัดกินทำลายปอดกับขัดขวางสมองวัยรุ่นทันที',
              outcomeSafe: 'รักษาสุขภาพและวินัย! ปอดและพัฒนาการสมองของคุณปลอดภัย 100% เพื่อนที่ดีจะเคารพการตัดสินใจของคุณ และไม่พาคุณเข้าสู่ความเสี่ยงใดๆ',
              tip: 'บุหรี่ไฟฟ้ามีสารนิโคตินเหลวเข้มข้นสูงมากและสารระเหยพิษทำลายเซลล์ระบบหายใจโดยตรง อย่าลองโดยเด็ดขาด',
              icon: Icons.smoke_free_rounded,
              color: Colors.blueAccent,
              isDark: isDark,
            ),
          ],
        );
    }
  }

  Widget _buildLawCard({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color borderColor,
    required Color cardBg,
    required double fontScale,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5 * fontScale,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Prompt',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13 * fontScale,
              color: isDark ? Colors.white70 : AppColors.textGrey,
              height: 1.5,
              fontFamily: 'Prompt',
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableScenarioCard extends StatefulWidget {
  final String title;
  final String scenario;
  final String question;
  final String optionUnsafeText;
  final String optionSafeText;
  final String outcomeUnsafe;
  final String outcomeSafe;
  final String tip;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ExpandableScenarioCard({
    required this.title,
    required this.scenario,
    required this.question,
    required this.optionUnsafeText,
    required this.optionSafeText,
    required this.outcomeUnsafe,
    required this.outcomeSafe,
    required this.tip,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  State<_ExpandableScenarioCard> createState() => _ExpandableScenarioCardState();
}

class _ExpandableScenarioCardState extends State<_ExpandableScenarioCard> {
  bool _isExpanded = false;
  int? _selectedChoice; // null = unchosen, 1 = unsafe, 2 = safe

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = widget.isDark ? const Color(0xFF334155) : AppColors.border;
    final textColor = widget.isDark ? Colors.white : AppColors.textDark;
    final subTextColor = widget.isDark ? Colors.white70 : AppColors.textGrey;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.15 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ทางเลือกท้าทายความคิด',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: widget.color,
                                letterSpacing: 0.5,
                                fontFamily: 'Prompt',
                              ),
                            ),
                            Text(
                              widget.title,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  fontFamily: 'Prompt'),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: subTextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.scenario,
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 16),
                              ),
                              Text(
                                'สถานการณ์: ${widget.question}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  fontFamily: 'Prompt',
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Choice Buttons
                              if (_selectedChoice == null) ...[
                                Column(
                                  children: [
                                    _buildChoiceButton(
                                      text: widget.optionUnsafeText,
                                      isUnsafe: true,
                                      onTap: () => setState(() => _selectedChoice = 1),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildChoiceButton(
                                      text: widget.optionSafeText,
                                      isUnsafe: false,
                                      onTap: () => setState(() => _selectedChoice = 2),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Result card
                                _buildOutcomeCard(),
                                const SizedBox(height: 10),
                                // reset button
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setState(() => _selectedChoice = null),
                                    icon: const Icon(Icons.refresh_rounded, size: 16),
                                    label: const Text('ทดลองเลือกข้ออื่น', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Prompt')),
                                    style: TextButton.styleFrom(
                                      foregroundColor: widget.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Tips card
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.tips_and_updates_rounded, color: Colors.amber, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'คำแนะนำทางกฎหมาย: ${widget.tip}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isDark ? Colors.amber[200] : Colors.amber[800],
                                          height: 1.45,
                                          fontFamily: 'Prompt',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String text,
    required bool isUnsafe,
    required VoidCallback onTap,
  }) {
    final activeColor = isUnsafe ? AppColors.error : AppColors.success;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: activeColor.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: activeColor,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'Prompt',
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeCard() {
    final isUnsafe = _selectedChoice == 1;
    final titleText = isUnsafe ? 'ผลกระทบทางกฎหมาย (ความเสี่ยงสูงมาก)' : 'ผลลัพธ์การตัดสินใจ (ปลอดภัย)';
    final contentText = isUnsafe ? widget.outcomeUnsafe : widget.outcomeSafe;
    final cardColor = isUnsafe ? AppColors.error : AppColors.success;
    final iconData = isUnsafe ? Icons.dangerous_rounded : Icons.check_circle_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: cardColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cardColor,
                    fontFamily: 'Prompt',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contentText,
            style: TextStyle(
              fontSize: 12.5,
              color: widget.isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.85),
              height: 1.45,
              fontFamily: 'Prompt',
            ),
          ),
        ],
      ),
    );
  }
}
