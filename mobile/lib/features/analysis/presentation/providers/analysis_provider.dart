import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis.dart';
import '../../data/repositories/analysis_repository.dart';

final aiAnalysisProvider = FutureProvider.family.autoDispose<AIAnalysisResponse, int>((ref, simulationId) async {
  return ref.watch(analysisRepositoryProvider).getAnalysis(simulationId);
});
