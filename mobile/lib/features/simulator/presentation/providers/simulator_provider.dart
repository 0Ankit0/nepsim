import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/simulation.dart';
import '../../data/repositories/simulator_repository.dart';

final simulatorListProvider = AsyncNotifierProvider<SimulatorListNotifier, List<Simulation>>(
  SimulatorListNotifier.new,
);

class SimulatorListNotifier extends AsyncNotifier<List<Simulation>> {
  @override
  Future<List<Simulation>> build() async {
    return ref.watch(simulatorRepositoryProvider).listSimulations();
  }

  Future<Simulation> startSimulation(double initialCapital) async {
    final repository = ref.read(simulatorRepositoryProvider);
    final newSimulation = await repository.createSimulation(initialCapital);
    ref.invalidateSelf();
    return newSimulation;
  }

  Future<Simulation> advanceDay(int simulationId) async {
    final repository = ref.read(simulatorRepositoryProvider);
    final updatedSimulation = await repository.advanceDay(simulationId);
    ref.invalidate(simulationDetailProvider(simulationId));
    return updatedSimulation;
  }
}

final simulationDetailProvider = FutureProvider.family.autoDispose<Simulation, int>((ref, id) async {
  return ref.watch(simulatorRepositoryProvider).getSimulation(id);
});
