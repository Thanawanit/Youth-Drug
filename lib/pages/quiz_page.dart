import 'dart:math';
import 'package:flutter/material.dart';
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
    });
  }

  void _onOptionSelected(int index) {
    if (_selectedOptionIndex != null) return; // Answered already
    setState(() {
      _selectedOptionIndex = index;
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
            title: const Text(
              'ทบทวนความเข้าใจ',
              style: TextStyle(fontWeight: FontWeight.w700),
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
    return Center(
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
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_objects_rounded,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ขอบคุณที่ค่อยๆ ทบทวนไปด้วยกัน',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'คุณสามารถย้อนกลับไปอ่านหัวข้อเดิม หรือสุ่มเรียนรู้ต่อได้ทุกเมื่อ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppColors.textGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
  }
}
