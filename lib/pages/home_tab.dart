import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../utils/animations.dart';
import '../data/facts.dart';
import '../models/fact_model.dart';
import 'learning_portal_page.dart';
import 'random_fact_page.dart';
import 'about_tab.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeTab({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Fact _featuredFact;
  Timer? _factRotationTimer;

  @override
  void initState() {
    super.initState();
    _selectRandomFact();
    _factRotationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _selectRandomFact();
        });
      }
    });
  }

  @override
  void dispose() {
    _factRotationTimer?.cancel();
    super.dispose();
  }

  void _selectRandomFact() {
    final random = Random();
    if (factsDataset.isNotEmpty) {
      _featuredFact = factsDataset[random.nextInt(factsDataset.length)];
    } else {
      _featuredFact = const Fact(
        id: 'default',
        title: 'หัวข้อหลัก',
        message: 'สมองของวัยรุ่นและเด็กยังเติบโตไม่เต็มที่ การได้รับสารเสพติดแม้เพียงเล็กน้อย ก็สามารถส่งผลทำลายทักษะการคิดวิเคราะห์ ความทรงจำ และสมาธิในระยะยาวได้อย่างรวดเร็ว',
        category: 'รู้ไหม',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    AppText.appTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: textColor),
                tooltip: 'เมนูเพิ่มเติม',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                onSelected: (value) {
                  if (value == 'about') {
                    Navigator.push(
                      context,
                      FadeScalePageRoute(page: const AboutTab()),
                    );
                  } else if (value == 'font') {
                    _showFontScaleDialog(context, state.fontScale);
                  } else if (value == 'reading') {
                    appStateNotifier.toggleReadingMode();
                  } else if (value == 'theme') {
                    appStateNotifier.toggleDarkMode();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: isDark ? Colors.white70 : AppColors.textDark),
                        const SizedBox(width: 12),
                        Text('เกี่ยวกับโครงการ', style: TextStyle(fontFamily: 'Prompt', color: textColor)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'font',
                    child: Row(
                      children: [
                        Icon(Icons.format_size_rounded, color: isDark ? Colors.white70 : AppColors.textDark),
                        const SizedBox(width: 12),
                        Text('ปรับขนาดตัวอักษร', style: TextStyle(fontFamily: 'Prompt', color: textColor)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reading',
                    child: Row(
                      children: [
                        Icon(
                          state.isReadingMode ? Icons.chrome_reader_mode_rounded : Icons.chrome_reader_mode_outlined,
                          color: state.isReadingMode ? AppColors.success : (isDark ? Colors.white70 : AppColors.textDark),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.isReadingMode ? 'ปิดโหมดการอ่าน' : 'เปิดโหมดการอ่าน',
                          style: TextStyle(fontFamily: 'Prompt', color: textColor),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark ? Colors.white70 : AppColors.textDark,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isDark ? 'โหมดสว่าง' : 'โหมดมืด',
                          style: TextStyle(fontFamily: 'Prompt', color: textColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Editorial Hero Banner (Redesigned with Soft Light Blue-to-White Gradient)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [Color(0xFF0C4A6E), Color(0xFF0F172A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFFD6EFFE), Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'เรียนรู้เพื่อป้องกัน\nเข้าใจเพื่อเลือก',
                                    style: TextStyle(
                                      fontSize: 24 * state.fontScale,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.textDark,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 64,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              AppText.appSubtitle,
                              style: TextStyle(
                                fontSize: 13.5 * state.fontScale,
                                color: isDark ? Colors.white70 : AppColors.textGrey,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppText.appSubtitleSupporting,
                              style: TextStyle(
                                fontSize: 12.5 * state.fontScale,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32), // Increased Spacing

                      // 2. Primary Access Card (Full-width, Highlighted)
                      Text(
                        'แหล่งเรียนรู้หลัก',
                        style: TextStyle(
                          fontSize: 16 * state.fontScale,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPrimaryLinkCard(
                        title: 'บทเรียนศึกษา',
                        desc: 'เริ่มต้นเรียนรู้พื้นฐานและทำความเข้าใจผลกระทบหลักด้านต่าง ๆ ของสารเสพติด',
                        icon: Icons.local_library_rounded,
                        color: isDark ? AppColors.success : AppColors.primary,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        fontScale: state.fontScale,
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeScalePageRoute(page: const LearningPortalPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 32), // Increased Spacing

                      // 3. Recommended Activities (Secondary Cards)
                      Text(
                        'ฝึกฝนและทบทวนความเข้าใจ',
                        style: TextStyle(
                          fontSize: 16 * state.fontScale,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildSecondaryLinkCard(
                                title: 'กฎหมายน่ารู้',
                                desc: 'ทำความเข้าใจสิทธิและข้อกฎหมายสำหรับเยาวชน',
                                icon: Icons.balance_rounded,
                                color: Colors.blueAccent,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                fontScale: state.fontScale,
                                onTap: () {
                                  widget.onNavigateToTab?.call(2); // Go to Law Tab (index 2)
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSecondaryLinkCard(
                                title: 'ทบทวนความเข้าใจ',
                                desc: 'ทำแบบทดสอบเพื่อทบทวนสิ่งที่ศึกษา',
                                icon: Icons.assignment_turned_in_rounded,
                                color: Colors.teal,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                fontScale: state.fontScale,
                                onTap: () {
                                  widget.onNavigateToTab?.call(3); // Go to Quiz Tab (index 3)
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Interactive Card Game / Random Fact
                      _buildPrimaryLinkCard(
                        title: 'สุ่มการ์ดความรู้',
                        desc: 'อ่านเกร็ดความรู้สั้น ๆ เพื่อการเรียนรู้ทบทวนที่รวดเร็วและท้าทาย',
                        icon: Icons.casino_rounded,
                        color: Colors.amber,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        fontScale: state.fontScale,
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeScalePageRoute(page: const RandomFactPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 32), // Increased Spacing

                      // 4. Featured Fact Section (รู้หรือไม่?) - Dynamic Rotating Banner with Fade Transition
                      Text(
                        'รู้หรือไม่วันนี้?',
                        style: TextStyle(
                          fontSize: 16 * state.fontScale,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            key: ValueKey<String>(_featuredFact.id),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'รู้หรือไม่? — ${_featuredFact.title}',
                                    style: TextStyle(
                                      fontSize: 13.5 * state.fontScale,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.amberAccent : AppColors.textDark,
                                      fontFamily: 'Prompt',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _featuredFact.message,
                                style: TextStyle(
                                  fontSize: 12.5 * state.fontScale,
                                  color: subTextColor,
                                  height: 1.5,
                                  fontFamily: 'Prompt',
                                ),
                              ),
                              const SizedBox(height: 14),
                              InkWell(
                                onTap: () {
                                  widget.onNavigateToTab?.call(1); // Go to Explore Tab
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'สำรวจความรู้เพิ่มเติม',
                                      style: TextStyle(
                                        fontSize: 12 * state.fontScale,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.success : AppColors.primary,
                                        fontFamily: 'Prompt',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: isDark ? AppColors.success : AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryLinkCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required double fontScale,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.5 * fontScale,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Prompt',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 11 * fontScale,
                          color: AppColors.textGrey,
                          height: 1.4,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textGrey.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryLinkCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required double fontScale,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5 * fontScale,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Prompt',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 10 * fontScale,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontScaleDialog(BuildContext context, double currentScale) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = appStateNotifier.value.isDarkMode;
            final textColor = isDark ? Colors.white : AppColors.textDark;

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'ปรับขนาดตัวอักษร',
                style: TextStyle(color: textColor, fontFamily: 'Prompt'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ข้อความตัวอย่างสำหรับดูขนาดอักษร',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14 * currentScale,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: currentScale,
                    min: 1.0,
                    max: 1.4,
                    divisions: 4,
                    activeColor: isDark ? AppColors.success : AppColors.primary,
                    onChanged: (val) {
                      setDialogState(() {
                        currentScale = val;
                      });
                      appStateNotifier.setFontScale(val);
                    },
                  ),
                  Text(
                    'ขนาด: ${(currentScale * 100).toInt()}%',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textGrey,
                      fontFamily: 'Prompt',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'ตกลง',
                    style: TextStyle(
                      color: isDark ? AppColors.success : AppColors.primary,
                      fontFamily: 'Prompt',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
