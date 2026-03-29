import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/simulator_models.dart';

class SimulatorRepository {
  final Dio _dio;

  SimulatorRepository(this._dio);

  Future<SimulationResponse> createSimulation(double initialCapital, {String? name}) async {
    final response = await _dio.post(
      ApiEndpoints.simulations,
      data: {'initial_capital': initialCapital, 'name': ?name},
    );
    return SimulationResponse.fromJson(response.data);
  }

  Future<List<SimulationSummary>> listSimulations() async {
    final response = await _dio.get(ApiEndpoints.simulations);
    return (response.data as List)
        .map((e) => SimulationSummary.fromJson(e))
        .toList();
  }

  Future<SimulationResponse> getSimulation(int id) async {
    final response = await _dio.get(ApiEndpoints.simulationDetail(id));
    return SimulationResponse.fromJson(response.data);
  }

  Future<TradeResponse> executeTrade(int id, TradeRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.simulationTrade(id),
      data: request.toJson(),
    );
    return TradeResponse.fromJson(response.data);
  }

  Future<SimulationResponse> advanceDay(int id) async {
    final response = await _dio.post(ApiEndpoints.simulationAdvanceDay(id));
    return SimulationResponse.fromJson(response.data);
  }

  Future<SimulationResponse> pauseSimulation(int id) async {
    final response = await _dio.post(ApiEndpoints.simulationPause(id));
    return SimulationResponse.fromJson(response.data);
  }

  Future<SimulationResponse> resumeSimulation(int id) async {
    final response = await _dio.post(ApiEndpoints.simulationResume(id));
    return SimulationResponse.fromJson(response.data);
  }

  Future<SimulationResponse> updateTickConfig(int id, int secondsPerDay) async {
    final response = await _dio.patch(
      ApiEndpoints.simulationTickConfig(id),
      data: {'seconds_per_day': secondsPerDay},
    );
    return SimulationResponse.fromJson(response.data);
  }

  Future<EndSimulationResponse> endSimulation(int id) async {
    final response = await _dio.post(ApiEndpoints.simulationEnd(id));
    return EndSimulationResponse.fromJson(response.data);
  }

  Future<AIAnalysisResponse> getAnalysis(int id) async {
    final response = await _dio.get(ApiEndpoints.simulationAnalysis(id));
    return AIAnalysisResponse.fromJson(response.data);
  }
}
