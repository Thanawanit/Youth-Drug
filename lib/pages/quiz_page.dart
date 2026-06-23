import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';
import '../data/quiz_data.dart';
import '../models/quiz_model.dart';
import '../widgets/app_background.dart';
import '../widgets/question_card.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizQuestion> _selectedQuestions = [];
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _quizFinished = false;
  int _correctCount = 0;
  List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadRandomQuestions();
  }

  void _loadRandomQuestions() {
    // Pick 5 unique random questions from the dataset (10 questions available)
    final random = Random();
    final List<QuizQuestion> pool = List.from(quizQuestionsDataset);
    final List<QuizQuestion> selected = [];

    for (int i = 0; i < 5; i++) {
      if (pool.isEmpty) break;
      final index = random.nextInt(pool.length);
      selected.add(pool.removeAt(index));
    }

    setState(() {
      _selectedQuestions = selected;
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _quizFinished = false;
      _correctCount = 0;
      _userAnswers = List.filled(selected.length, null);
    });
  }

  void _onOptionSelected(int index) {
    if (_selectedOptionIndex != null) return; // Answered already
    HapticFeedback.lightImpact(); // Play light haptics immediately
    setState(() {
      _selectedOptionIndex = index;
      _userAnswers[_currentIndex] = index;
      if (index == _selectedQuestions[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _selectedQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
    }
  }

  void _showMistakesBottomSheet(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;

    // Filter incorrect questions
    final List<Map<String, dynamic>> incorrectList = [];
    for (int i = 0; i < _selectedQuestions.length; i++) {
      final q = _selectedQuestions[i];
      final userAns = _userAnswers[i];
      if (userAns != q.correctIndex) {
        incorrectList.add({
          'question': q,
          'userIndex': userAns,
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
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
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ทบทวนข้อที่เข้าใจคลาดเคลื่อน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'มาทำความเข้าใจเพิ่มเติมเกี่ยวกับข้อมูลที่คลาดเคลื่อนกันนะ',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: subTextColor,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: incorrectList.map((item) {
                          final QuizQuestion q = item['question'];
                          final int? userIndex = item['userIndex'];
                          final hasUserAnswered = userIndex != null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.questionText,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    fontFamily: 'Prompt',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // User's Answer
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'คำตอบที่คุณเลือก: ${hasUserAnswered ? q.options[userIndex] : "ไม่ได้ตอบ"}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                            fontFamily: 'Prompt',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Correct Answer
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'คำตอบที่ถูกต้อง: ${q.options[q.correctIndex]}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success,
                                            fontFamily: 'Prompt',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Explanation
                                Text(
                                  'คำอธิบาย: ${q.explanation}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: subTextColor,
                                    height: 1.45,
                                    fontFamily: 'Prompt',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.success : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ปิดหน้าต่างนี้',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Prompt'),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'หน้าหลัก > แบบทดสอบ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textGrey,
                    fontFamily: 'Prompt',
                  ),
                ),
                Text(
                  'ทบทวนความเข้าใจ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18 * state.fontScale,
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontFamily: 'Prompt',
                  ),
                ),
              ],
            ),
          ),
          body: BackgroundWrapper(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  12.0,
                  20.0,
                  MediaQuery.of(context).viewInsets.bottom + 12.0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _quizFinished
                      ? _buildCompletionScreen(isDark, cardColor, borderColor)
                      : _buildQuizContent(isDark, subTextColor, cardColor, borderColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizContent(bool isDark, Color subTextColor, Color cardColor, Color borderColor) {
    if (_selectedQuestions.isEmpty) {
      if (quizQuestionsDataset.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'ไม่พบข้อคำถามในขณะนี้',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Prompt'),
              ),
              const SizedBox(height: 8),
              Text(
                'กรุณาลองใหม่อีกครั้งภายหลัง',
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.textGrey, fontFamily: 'Prompt'),
              ),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = _selectedQuestions[_currentIndex];

    return Column(
      children: [
        // Question number indicator & progress indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ช่วงที่ ${_currentIndex + 1} จาก ${_selectedQuestions.length}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'ลองคิดและเรียนรู้ไปทีละข้อ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _selectedQuestions.length,
            minHeight: 4,
            backgroundColor: isDark ? const Color(0xFF334155) : AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              (isDark ? AppColors.success : AppColors.primary).withValues(alpha: 0.65),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Scrollable Question details
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: QuestionCard(
              questionText: currentQuestion.questionText,
              options: currentQuestion.options,
              selectedIndex: _selectedOptionIndex,
              correctIndex: currentQuestion.correctIndex,
              explanation: currentQuestion.explanation,
              onOptionSelected: _onOptionSelected,
            ),
          ),
        ),

        // Bottom Next button
        if (_selectedOptionIndex != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex == _selectedQuestions.length - 1 ? 'ดูสิ่งที่ได้ทบทวน' : 'ไปต่อ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Prompt',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentIndex == _selectedQuestions.length - 1
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletionScreen(bool isDark, Color cardColor, Color borderColor) {
    final showConfetti = _correctCount == 5;
    final hasMistakes = _correctCount < _selectedQuestions.length;

    Widget mainCard = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (showConfetti ? Colors.amber : AppColors.success).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                showConfetti ? Icons.stars_rounded : Icons.emoji_objects_rounded,
                color: showConfetti ? Colors.amber : AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              showConfetti ? 'ยอดเยี่ยมมาก! เข้าใจถูกต้องทั้งหมด' : 'ขอบคุณที่ค่อยๆ ทบทวนไปด้วยกัน',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Prompt',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'คุณทำคะแนนได้ $_correctCount / ${_selectedQuestions.length} ข้อ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: showConfetti ? Colors.amber : (isDark ? Colors.white : AppColors.textDark),
                fontFamily: 'Prompt',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showConfetti
                  ? 'คุณเข้าใจความรู้การป้องกันยาเสพติดอย่างถูกต้องครบถ้วนแล้ว!'
                  : 'คุณสามารถย้อนกลับไปอ่านหัวข้อเดิม หรือสุ่มเรียนรู้ต่อได้ทุกเมื่อ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppColors.textGrey,
                height: 1.5,
                fontFamily: 'Prompt',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasMistakes) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _showMistakesBottomSheet(context, isDark),
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text(
                    'ดูข้อที่เข้าใจคลาดเคลื่อน',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Prompt'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : AppColors.primary,
                    side: BorderSide(color: isDark ? Colors.white24 : AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loadRandomQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'ทบทวนความเข้าใจอีกครั้ง',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Prompt',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (showConfetti) {
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: ConfettiWidget()),
          mainCard,
        ],
      );
    }

    return mainCard;
  }
}

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({super.key});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Map<String, dynamic>> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    final random = Random();
    for (int i = 0; i < 40; i++) {
      _particles.add({
        'x': random.nextDouble(), // horizontal percentage 0..1
        'y': random.nextDouble() * -0.5, // start above screen
        'color': Colors.primaries[random.nextInt(Colors.primaries.length)],
        'size': 6.0 + random.nextDouble() * 8.0,
        'speed': 0.15 + random.nextDouble() * 0.25,
        'drift': -0.1 + random.nextDouble() * 0.2,
        'rotation': random.nextDouble() * 2 * pi,
        'rotationSpeed': -2.0 + random.nextDouble() * 4.0,
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final elapsed = _controller.value;
        return CustomPaint(
          painter: _ConfettiPainter(particles: _particles, progress: elapsed),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Calculate dynamic y position based on speed and progress
      double yPos = (p['y'] + p['speed'] * progress * 2) * size.height;
      // Wrap around height
      if (yPos > size.height) {
        yPos = (yPos % size.height) - 20;
      }

      // Calculate dynamic x position with slight drift
      double xPos = (p['x'] + p['drift'] * progress) * size.width;
      if (xPos > size.width) xPos %= size.width;
      if (xPos < 0) xPos = size.width + (xPos % size.width);

      // Rotation
      final angle = p['rotation'] + p['rotationSpeed'] * progress * 2 * pi;

      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate(angle);

      paint.color = p['color'];
      final double sizeHalf = p['size'] / 2;
      // Draw square or circle
      if (p['size'] % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(-sizeHalf, -sizeHalf, p['size'], p['size']), paint);
      } else {
        canvas.drawCircle(Offset.zero, sizeHalf, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
