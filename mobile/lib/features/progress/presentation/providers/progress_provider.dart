import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/progress.dart';
import '../../data/repositories/progress_repository.dart';

final userProgressProvider = FutureProvider.autoDispose<UserProgress>((ref) async {
  return ref.watch(progressRepositoryProvider).getUserProgress();
});

final userAchievementsProvider = FutureProvider.autoDispose<List<UserAchievement>>((ref) async {
  return ref.watch(progressRepositoryProvider).getUserAchievements();
});
