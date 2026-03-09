import 'dart:convert';

class LessonSummary {
  final int id;
  final String title;
  final String section;
  final String difficultyLevel;
  final int orderIndex;
  final int readTimeMinutes;
  final bool hasQuiz;

  LessonSummary({
    required this.id,
    required this.title,
    required this.section,
    required this.difficultyLevel,
    required this.orderIndex,
    required this.readTimeMinutes,
    required this.hasQuiz,
  });

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    return LessonSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      section: json['section'] as String,
      difficultyLevel: json['difficulty_level'] as String,
      orderIndex: json['order_index'] as int,
      readTimeMinutes: json['read_time_minutes'] as int,
      hasQuiz: json['has_quiz'] ?? false,
    );
  }
}

class QuizQuestion {
  final int id;
  final String questionText;
  final List<String> options;
  final int orderIndex;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.orderIndex,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];
    if (json['options'] is String) {
      parsedOptions = List<String>.from(jsonDecode(json['options']));
    } else if (json['options'] is List) {
      parsedOptions = List<String>.from(json['options']);
    }

    return QuizQuestion(
      id: json['id'] as int,
      questionText: json['question_text'] as String,
      options: parsedOptions,
      orderIndex: json['order_index'] as int,
      explanation: json['explanation'] as String?,
    );
  }
}

class Quiz {
  final int id;
  final int lessonId;
  final String title;
  final int passingScore;
  final int? timeLimitSeconds;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.passingScore,
    this.timeLimitSeconds,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int,
      title: json['title'] as String,
      passingScore: json['passing_score'] as int,
      timeLimitSeconds: json['time_limit_seconds'] as int?,
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonDetail {
  final int id;
  final String title;
  final String section;
  final String contentHtml;
  final List<String> imageUrls;
  final String difficultyLevel;
  final int readTimeMinutes;
  final Quiz? quiz;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonDetail({
    required this.id,
    required this.title,
    required this.section,
    required this.contentHtml,
    required this.imageUrls,
    required this.difficultyLevel,
    required this.readTimeMinutes,
    this.quiz,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['image_urls'] is String) {
      parsedImages = List<String>.from(jsonDecode(json['image_urls']));
    } else if (json['image_urls'] is List) {
      parsedImages = List<String>.from(json['image_urls']);
    }

    return LessonDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      section: json['section'] as String,
      contentHtml: json['content_html'] as String,
      imageUrls: parsedImages,
      difficultyLevel: json['difficulty_level'] as String,
      readTimeMinutes: json['read_time_minutes'] as int,
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class CurriculumSection {
  final String section;
  final List<LessonSummary> lessons;

  CurriculumSection({
    required this.section,
    required this.lessons,
  });

  factory CurriculumSection.fromJson(Map<String, dynamic> json) {
    return CurriculumSection(
      section: json['section'] as String,
      lessons: (json['lessons'] as List)
          .map((l) => LessonSummary.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizSubmission {
  final Map<int, int> answers;
  final int? timeTakenSeconds;

  QuizSubmission({
    required this.answers,
    this.timeTakenSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
      'time_taken_seconds': timeTakenSeconds,
    };
  }
}

class QuizResult {
  final int quizId;
  final int lessonId;
  final int score;
  final bool passed;
  final int passingScore;
  final int correctCount;
  final int totalQuestions;
  final List<Map<String, dynamic>> questionResults;

  QuizResult({
    required this.quizId,
    required this.lessonId,
    required this.score,
    required this.passed,
    required this.passingScore,
    required this.correctCount,
    required this.totalQuestions,
    required this.questionResults,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      quizId: json['quiz_id'] as int,
      lessonId: json['lesson_id'] as int,
      score: json['score'] as int,
      passed: json['passed'] as bool,
      passingScore: json['passing_score'] as int,
      correctCount: json['correct_count'] as int,
      totalQuestions: json['total_questions'] as int,
      questionResults: List<Map<String, dynamic>>.from(json['question_results'] as List),
    );
  }
}
