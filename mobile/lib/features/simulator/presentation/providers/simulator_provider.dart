// Re-export data layer providers so pages importing this file get access to
// simulatorRepositoryProvider, simulationsProvider, simulationProvider, analysisProvider.
export '../../data/providers/simulator_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/simulator_provider.dart';
import '../../data/models/simulator_models.dart';

/// Notifier-backed list provider: exposes [startSimulation] and [advanceDay].
final simulatorListProvider = AsyncNotifierProvider<SimulatorListNotifier, List<SimulationSummary>>(
  SimulatorListNotifier.new,
);

class SimulatorListNotifier extends AsyncNotifier<List<SimulationSummary>> {
  @override
  Future<List<SimulationSummary>> build() async {
    return ref.watch(simulatorRepositoryProvider).listSimulations();
  }

  Future<SimulationResponse> startSimulation(double initialCapital, {String? name}) async {
    final repo = ref.read(simulatorRepositoryProvider);
    final sim = await repo.createSimulation(initialCapital, name: name);
    ref.invalidateSelf();
    return sim;
  }

  Future<SimulationResponse> advanceDay(int simulationId) async {
    final repo = ref.read(simulatorRepositoryProvider);
    final updated = await repo.advanceDay(simulationId);
    ref.invalidate(simulationDetailProvider(simulationId));
    return updated;
  }

  Future<SimulationResponse> pauseSimulation(int simulationId) async {
    final repo = ref.read(simulatorRepositoryProvider);
    final updated = await repo.pauseSimulation(simulationId);
    ref.invalidate(simulationDetailProvider(simulationId));
    ref.invalidateSelf();
    return updated;
  }

  Future<SimulationResponse> resumeSimulation(int simulationId) async {
    final repo = ref.read(simulatorRepositoryProvider);
    final updated = await repo.resumeSimulation(simulationId);
    ref.invalidate(simulationDetailProvider(simulationId));
    ref.invalidateSelf();
    return updated;
  }

  Future<SimulationResponse> updateTickConfig(int simulationId, int secondsPerDay) async {
    final repo = ref.read(simulatorRepositoryProvider);
    final updated = await repo.updateTickConfig(simulationId, secondsPerDay);
    ref.invalidate(simulationDetailProvider(simulationId));
    ref.invalidateSelf();
    return updated;
  }
}

/// Detail provider — pages watch this; invalidated by [SimulatorListNotifier.advanceDay].
final simulationDetailProvider = FutureProvider.family.autoDispose<SimulationResponse, int>((ref, id) async {
  return ref.watch(simulatorRepositoryProvider).getSimulation(id);
});
