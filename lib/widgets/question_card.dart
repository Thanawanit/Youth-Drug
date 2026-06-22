import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../main.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final int? selectedIndex;
  final int correctIndex;
  final String explanation;
  final Function(int) onOptionSelected;

  const QuestionCard({
    super.key,
    required this.questionText,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.explanation,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswered = selectedIndex != null;
    final isDark = appStateNotifier.value.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Bubble Choices staggered layout
        _buildBubbleChoices(context, hasAnswered),
        
        const SizedBox(height: 16),
        // Explanation card (expanded dynamically)
        if (hasAnswered) ...[
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : (selectedIndex == correctIndex
                        ? AppColors.success.withOpacity(0.04)
                        : AppColors.error.withOpacity(0.04)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : (selectedIndex == correctIndex
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2)),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedIndex == correctIndex
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: selectedIndex == correctIndex ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedIndex == correctIndex ? 'ถูกต้อง!' : 'คำตอบไม่ถูกต้อง',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: selectedIndex == correctIndex ? AppColors.success : AppColors.error,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (selectedIndex != correctIndex) ...[
                    Text(
                      'คำตอบที่ถูกต้องคือ: ${options[correctIndex]}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        fontFamily: 'Prompt',
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13.0,
                        color: isDark ? Colors.white70 : AppColors.textGrey,
                        height: 1.5,
                        fontFamily: 'Prompt',
                      ),
                      children: [
                        TextSpan(
                          text: selectedIndex == correctIndex ? 'คำอธิบาย: ' : 'เหตุผล: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: explanation),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBubbleChoices(BuildContext context, bool hasAnswered) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          final isCorrect = index == correctIndex;

          // Staggered horizontal alignment:
          // A (0): aligned left-heavy
          // B (1): aligned right-heavy
          // C (2): aligned center-left
          // D (3): aligned center-right
          Alignment bubbleAlignment = Alignment.centerLeft;
          if (index == 1) {
            bubbleAlignment = Alignment.centerRight;
          } else if (index == 2) {
            bubbleAlignment = const Alignment(-0.35, 0);
          } else if (index == 3) {
            bubbleAlignment = const Alignment(0.35, 0);
          }

          return Align(
            alignment: bubbleAlignment,
            child: BubbleChoiceButton(
              optionText: options[index],
              index: index,
              isSelected: isSelected,
              isCorrect: isCorrect,
              hasAnswered: hasAnswered,
              onTap: () => onOptionSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

class BubbleChoiceButton extends StatefulWidget {
  final String optionText;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback onTap;

  const BubbleChoiceButton({
    super.key,
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.onTap,
  });

  @override
  State<BubbleChoiceButton> createState() => _BubbleChoiceButtonState();
}

class _BubbleChoiceButtonState extends State<BubbleChoiceButton> with TickerProviderStateMixin {
  late AnimationController _bobController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    // Continuous floating/bobbing animation
    // Each bubble has a slightly different duration to avoid synchronized movement
    _bobController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500 + widget.index * 400),
    );
    _bobController.repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.hasAnswered) return;
    _scaleController.animateTo(0.95, curve: Curves.easeOut).then((_) {
      _scaleController.animateTo(1.0, curve: Curves.elasticOut);
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStateNotifier.value.isDarkMode;
    final isSelected = widget.isSelected;
    final isCorrect = widget.isCorrect;
    final hasAnswered = widget.hasAnswered;

    Color cardBorderColor = isDark ? const Color(0xFF334155) : AppColors.border;
    Color cardBgColor = isDark ? const Color(0xFF1E293B) : AppColors.surface;
    Color textColor = isDark ? Colors.white : AppColors.textDark;
    IconData? trailingIcon;

    if (hasAnswered) {
      if (isSelected) {
        if (isCorrect) {
          cardBorderColor = AppColors.success;
          cardBgColor = AppColors.success;
          textColor = Colors.white;
          trailingIcon = Icons.check_circle_rounded;
        } else {
          cardBorderColor = AppColors.error;
          cardBgColor = AppColors.error;
          textColor = Colors.white;
          trailingIcon = Icons.cancel_rounded;
        }
      } else if (isCorrect) {
        cardBorderColor = AppColors.success;
        cardBgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        trailingIcon = Icons.check_circle_outline_rounded;
      } else {
        textColor = isDark ? Colors.white30 : AppColors.textLight;
        cardBgColor = isDark ? const Color(0xFF0F172A).withOpacity(0.3) : AppColors.background.withOpacity(0.5);
        cardBorderColor = isDark ? const Color(0xFF1E293B).withOpacity(0.5) : AppColors.border.withOpacity(0.4);
      }
    }

    // Dynamic horizontal padding based on option length to look organic, but bounded
    final double paddingHorizontal = 22.0 + (widget.index % 2) * 4.0;
    final double paddingVertical = 15.0 + (widget.index % 3) * 2.0;

    return AnimatedBuilder(
      animation: _bobController,
      builder: (context, child) {
        // Safe natural fluid floating bobbing offset
        final double bobOffset = sin(_bobController.value * 2 * pi) * 5.0;
        return Transform.translate(
          offset: Offset(0, bobOffset),
          child: ScaleTransition(
            scale: _scaleController,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          minWidth: 140,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasAnswered ? null : _handleTap,
            borderRadius: BorderRadius.circular(50),
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: cardBorderColor,
                  width: isSelected || (hasAnswered && isCorrect) ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular bullet prefix (A, B, C, D)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : (hasAnswered && isCorrect
                              ? AppColors.success
                              : (isDark ? const Color(0xFF334155) : AppColors.primary.withOpacity(0.08))),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + widget.index), // A, B, C, D
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? (isCorrect ? AppColors.success : AppColors.error)
                              : (hasAnswered && isCorrect
                                  ? Colors.white
                                  : (isDark ? Colors.white : AppColors.primary)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Choice string
                  Flexible(
                    child: Text(
                      widget.optionText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected || (hasAnswered && isCorrect)
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: textColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                  // Verification icon
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    Icon(
                      trailingIcon,
                      color: isSelected ? Colors.white : AppColors.success,
                      size: 22,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

