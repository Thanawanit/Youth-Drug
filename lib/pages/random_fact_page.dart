import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';
import '../data/facts.dart';
import '../models/fact_model.dart';
import '../widgets/app_background.dart';

class RandomFactPage extends StatefulWidget {
  const RandomFactPage({super.key});

  @override
  State<RandomFactPage> createState() => _RandomFactPageState();
}

class _RandomFactPageState extends State<RandomFactPage> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  Timer? _rotationTimer;
  bool _isAutoPlaying = false;
  late final AnimationController _cardAnimController;
  late final Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(factsDataset.length);
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _cardScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutBack),
    );
    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _cardAnimController.dispose();
    super.dispose();
  }

  void _shuffleFact() {
    _cardAnimController.reverse().then((_) {
      int newIndex;
      do {
        newIndex = Random().nextInt(factsDataset.length);
      } while (newIndex == _currentIndex && factsDataset.length > 1);

      setState(() {
        _currentIndex = newIndex;
      });
      _cardAnimController.forward();
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });

    if (_isAutoPlaying) {
      _rotationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        _shuffleFact();
      });
    } else {
      _rotationTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fact = factsDataset[_currentIndex];

    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final isReading = state.isReadingMode;
        final fontScale = state.fontScale;

        final cardBg = isReading
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
            : (isDark ? const Color(0xFF1E293B) : Colors.white);
        
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

        Color stripeColor;
        IconData categoryIcon;

        switch (fact.category) {
          case 'รู้ไหม':
            stripeColor = AppColors.catFact;
            categoryIcon = Icons.lightbulb_rounded;
            break;
          case 'การป้องกัน':
            stripeColor = AppColors.catPrevention;
            categoryIcon = Icons.shield_rounded;
            break;
          case 'ข้อควรระวัง':
            stripeColor = AppColors.catWarning;
            categoryIcon = Icons.warning_rounded;
            break;
          case 'ความรู้เพิ่มเติม':
          default:
            stripeColor = AppColors.catMore;
            categoryIcon = Icons.menu_book_rounded;
            break;
        }

        final isBookmarked = state.bookmarkedFactIds.contains(fact.id);

        Gradient? dynamicGradient;
        List<Color>? dynamicBlobs;

        if (isDark) {
          switch (fact.category) {
            case 'รู้ไหม':
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFF1E1B10), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                Colors.amber.withValues(alpha: 0.06),
                Colors.orange.withValues(alpha: 0.04),
              ];
              break;
            case 'การป้องกัน':
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFF062C1D), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                const Color(0xFF10B981).withValues(alpha: 0.06),
                Colors.teal.withValues(alpha: 0.04),
              ];
              break;
            case 'ข้อควรระวัง':
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFF3B0712), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                Colors.red.withValues(alpha: 0.05),
                const Color(0xFFF43F5E).withValues(alpha: 0.04),
              ];
              break;
            case 'ความรู้เพิ่มเติม':
            default:
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                Colors.indigo.withValues(alpha: 0.06),
                Colors.blue.withValues(alpha: 0.04),
              ];
              break;
          }
        } else {
          switch (fact.category) {
            case 'รู้ไหม':
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFFFFFDF5), Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                Colors.amber.withValues(alpha: 0.12),
                Colors.orange.withValues(alpha: 0.08),
              ];
              break;
            case 'การป้องกัน':
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFFF6FDF9), Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                const Color(0xFF10B981).withValues(alpha: 0.12),
                Colors.teal.withValues(alpha: 0.08),
              ];
              break;
            case 'ข้อควรระวัง':
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFFFFF5F5), Color(0xFFFEE2E2), Color(0xFFFECACA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                Colors.red.withValues(alpha: 0.1),
                const Color(0xFFF43F5E).withValues(alpha: 0.08),
              ];
              break;
            case 'ความรู้เพิ่มเติม':
            default:
              dynamicGradient = const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              dynamicBlobs = [
                Colors.indigo.withValues(alpha: 0.12),
                Colors.blue.withValues(alpha: 0.08),
              ];
              break;
          }
        }

        return BackgroundWrapper(
          customGradient: dynamicGradient,
          customBlobColors: dynamicBlobs,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                tooltip: 'ย้อนกลับ',
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'เกร็ดความรู้แบบสุ่ม',
                style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
              ),
              actions: [
                // Auto-play Toggle Icon
                IconButton(
                  icon: Icon(
                    _isAutoPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    color: _isAutoPlaying ? AppColors.success : null,
                  ),
                  tooltip: _isAutoPlaying
                      ? 'หยุดการเปลี่ยนข้อความอัตโนมัติ'
                      : 'เปลี่ยนข้อความอัตโนมัติทุก 8 วินาที',
                  onPressed: _toggleAutoPlay,
                ),
                // Reading Mode toggle button
                IconButton(
                  icon: Icon(
                    isReading ? Icons.chrome_reader_mode_rounded : Icons.chrome_reader_mode_outlined,
                    color: isReading ? AppColors.success : null,
                  ),
                  tooltip: 'โหมดการอ่าน',
                  onPressed: () {
                    appStateNotifier.toggleReadingMode();
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            children: [
                              const Spacer(),
                              // Scale animated fact card
                              ScaleTransition(
                                scale: _cardScaleAnimation,
                                child: Container(
                                  height: (constraints.maxHeight * 0.52).clamp(240.0, 420.0),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: borderColor, width: 1.5),
                                    boxShadow: isReading
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: stripeColor.withValues(alpha: isDark ? 0.2 : 0.04),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isReading) Container(height: 8, color: stripeColor),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: stripeColor.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(categoryIcon, size: 14, color: stripeColor),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          fact.category,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700,
                                                            color: stripeColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (_isAutoPlaying)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.success.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 8,
                                                            height: 8,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 1.5,
                                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                                                            ),
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            'กำลังเปลี่ยนอัตโนมัติ',
                                                            style: TextStyle(
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.w800,
                                                              color: AppColors.success,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                fact.title,
                                                style: TextStyle(
                                                  fontSize: (isReading ? 22.0 : 19.0) * fontScale,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  physics: const BouncingScrollPhysics(),
                                                  child: Text(
                                                    fact.message,
                                                    style: TextStyle(
                                                      fontSize: (isReading ? 16.0 : 14.5) * fontScale,
                                                      color: isDark ? Colors.white70 : AppColors.textGrey,
                                                      height: isReading ? 1.7 : 1.55,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Dynamic Actions Control row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // 1. Bookmarked
                                  _buildBottomButton(
                                    icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    label: isBookmarked ? 'เก็บไว้แล้ว' : 'เก็บไว้อ่าน',
                                    color: isBookmarked ? AppColors.success : (isDark ? Colors.white70 : AppColors.textDark),
                                    onPressed: () {
                                      appStateNotifier.toggleBookmark(fact.id);
                                    },
                                  ),
                                  // 2. Next Random Shuffle
                                  ElevatedButton(
                                    onPressed: _shuffleFact,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? AppColors.success : AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.casino_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'สุ่มอีกใบ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Prompt',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 3. Share Button
                                  _buildBottomButton(
                                    icon: Icons.share_rounded,
                                    label: 'แชร์ต่อ',
                                    color: isDark ? Colors.white70 : AppColors.textDark,
                                    onPressed: () {
                                      _shareFact(fact);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ),
      );
      },
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 28),
          tooltip: label,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
            fontFamily: 'Prompt',
          ),
        ),
      ],
    );
  }

  void _shareFact(Fact fact) {
    final isDark = appStateNotifier.value.isDarkMode;
    Clipboard.setData(ClipboardData(text: '${fact.title}\n\n${fact.message}'));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'คัดลอก "${fact.title}" ไปยังคลิปบอร์ดแล้ว',
          style: const TextStyle(
            fontFamily: 'Prompt',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : Colors.transparent,
            width: 1.5,
          ),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ตกลง',
          textColor: isDark ? AppColors.success : Colors.amberAccent,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
