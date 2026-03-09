import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/progress.dart';

class ProgressRepository {
  final DioClient _dioClient;

  ProgressRepository(this._dioClient);

  Future<UserProgress> getUserProgress() async {
    final response = await _dioClient.dio.get(ApiEndpoints.userProgress);
    return UserProgress.fromJson(response.data);
  }

  Future<List<UserAchievement>> getUserAchievements() async {
    final response = await _dioClient.dio.get(ApiEndpoints.userAchievements);
    final List data = response.data;
    return data.map((json) => UserAchievement.fromJson(json)).toList();
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(dioClientProvider));
});
