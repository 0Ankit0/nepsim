import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/simulation.dart';
import '../models/trade.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_provider.dart';

part 'simulator_repository.g.dart';

class SimulatorRepository {
  final DioClient _dioClient;

  SimulatorRepository(this._dioClient);

  Future<List<Simulation>> listSimulations() async {
    final response = await _dioClient.dio.get(ApiEndpoints.simulations);
    return (response.data as List).map((e) => Simulation.fromJson(e)).toList();
  }

  Future<Simulation> createSimulation(double initialCapital) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.simulations,
      data: {'initial_capital': initialCapital},
    );
    return Simulation.fromJson(response.data);
  }

  Future<Simulation> getSimulation(int id) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.simulationDetail(id),
      queryParameters: {'include_holdings': true},
    );
    return Simulation.fromJson(response.data);
  }

  Future<Trade> executeTrade(
    int simulationId,
    String symbol,
    String side,
    int quantity,
  ) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.simulationTrade(simulationId),
      data: {'symbol': symbol, 'side': side, 'quantity': quantity},
    );
    return Trade.fromJson(response.data);
  }

  Future<Simulation> advanceDay(int simulationId) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.simulationAdvanceDay(simulationId),
    );
    return Simulation.fromJson(response.data);
  }

  Future<Simulation> endSimulation(int simulationId) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.simulationEnd(simulationId),
    );
    return Simulation.fromJson(response.data);
  }

  Future<List<Trade>> getTrades(int simulationId) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.simulationTrades(simulationId),
    );
    return (response.data as List).map((e) => Trade.fromJson(e)).toList();
  }
}

@riverpod
SimulatorRepository simulatorRepository(Ref ref) {
  return SimulatorRepository(ref.watch(dioClientProvider));
}
