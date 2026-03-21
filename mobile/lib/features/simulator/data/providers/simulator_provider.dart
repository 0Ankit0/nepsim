import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_provider.dart';
import '../repositories/simulator_repository.dart';
import '../models/simulator_models.dart';

part 'simulator_provider.g.dart';

@riverpod
SimulatorRepository simulatorRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SimulatorRepository(dioClient.dio);
}

@riverpod
Future<List<SimulationSummary>> simulations(Ref ref) async {
  return ref.watch(simulatorRepositoryProvider).listSimulations();
}

@riverpod
Future<SimulationResponse> simulation(Ref ref, int id) async {
  return ref.watch(simulatorRepositoryProvider).getSimulation(id);
}

@riverpod
Future<AIAnalysisResponse> analysis(Ref ref, int id) async {
  return ref.watch(simulatorRepositoryProvider).getAnalysis(id);
}
