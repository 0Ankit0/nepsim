import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learn_models.dart';
import '../../data/repositories/learn_repository.dart';

final curriculumProvider = FutureProvider.autoDispose<List<CurriculumSection>>((ref) async {
  return ref.watch(learnRepositoryProvider).getCurriculum();
});

final lessonDetailProvider = FutureProvider.autoDispose.family<LessonDetail, int>((ref, lessonId) async {
  return ref.watch(learnRepositoryProvider).getLessonDetail(lessonId);
});

final quizProgressProvider = FutureProvider.autoDispose<List<int>>((ref) async {
  return ref.watch(learnRepositoryProvider).getQuizProgress();
});
