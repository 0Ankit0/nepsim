import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/analysis.dart';



import '../../../../core/network/dio_client.dart';

class AnalysisRepository {
  final DioClient _dioClient;

  AnalysisRepository(this._dioClient);

  Future<AIAnalysisResponse> getAnalysis(int simulationId) async {
    final response = await _dioClient.dio.get('${ApiEndpoints.simulations}/$simulationId/analysis');
    
    // HTTP 202 means still generating
    if (response.statusCode == 202) {
      throw AnalysisProcessingException(response.data['detail'] ?? 'Analysis is processing...');
    }
    
    return AIAnalysisResponse.fromJson(response.data);
  }

  Future<void> retryAnalysis(int simulationId) async {
    await _dioClient.dio.post('${ApiEndpoints.simulations}/$simulationId/analysis/retry');
  }
}

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return AnalysisRepository(ref.watch(dioClientProvider));
});
