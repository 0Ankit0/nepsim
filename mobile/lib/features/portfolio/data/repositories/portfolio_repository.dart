import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/portfolio_models.dart';

class PortfolioRepository {
  final Dio _dio;

  PortfolioRepository(this._dio);

  Future<List<PortfolioItemResponse>> getPortfolio() async {
    final response = await _dio.get(ApiEndpoints.portfolio);
    return (response.data as List)
        .map((e) => PortfolioItemResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PortfolioItemResponse> addItem(PortfolioItemCreate item) async {
    final response = await _dio.post(ApiEndpoints.portfolio, data: item.toJson());
    return PortfolioItemResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> removeItem(int id) async {
    await _dio.delete(ApiEndpoints.portfolioDetail(id));
  }

  Future<List<PortfolioAlertResponse>> analyzeAll() async {
    final response = await _dio.post(ApiEndpoints.portfolioAnalyzeAll);
    return (response.data as List)
        .map((e) => PortfolioAlertResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PortfolioAlertResponse>> getAlerts() async {
    final response = await _dio.get(ApiEndpoints.portfolioAlerts);
    return (response.data as List)
        .map((e) => PortfolioAlertResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAlertRead(int id) async {
    await _dio.patch(ApiEndpoints.portfolioAlertRead(id));
  }
}
