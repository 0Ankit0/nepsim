import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/learn_models.dart';

class LearnRepository {
  final DioClient _dioClient;

  LearnRepository(this._dioClient);

  Future<List<CurriculumSection>> getCurriculum() async {
    final response = await _dioClient.dio.get(ApiEndpoints.lessons);
    final List data = response.data;
    return data.map((json) => CurriculumSection.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<LessonDetail> getLessonDetail(int lessonId) async {
    final response = await _dioClient.dio.get(ApiEndpoints.lessonDetail(lessonId));
    return LessonDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<QuizResult> submitQuiz(int quizId, QuizSubmission submission) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.submitQuiz(quizId),
      data: submission.toJson(),
    );
    return QuizResult.fromJson(response.data as Map<String, dynamic>);
  }
  
  Future<List<int>> getQuizProgress() async {
    final response = await _dioClient.dio.get(ApiEndpoints.quizProgress);
    return List<int>.from(response.data['completed_lesson_ids'] as List);
  }
}

final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return LearnRepository(ref.watch(dioClientProvider));
});
