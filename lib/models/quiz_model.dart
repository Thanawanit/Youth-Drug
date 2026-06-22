class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class Scenario {
  final String title;
  final String description;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const Scenario({
    required this.title,
    required this.description,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
