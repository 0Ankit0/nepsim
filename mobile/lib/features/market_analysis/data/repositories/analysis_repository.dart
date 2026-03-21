import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/analysis_models.dart';

class MarketAnalysisRepository {
  final Dio _dio;

  MarketAnalysisRepository(this._dio);

  Future<TopStocksResponse> getTopStocks({int limit = 20, String? signal}) async {
    final params = <String, dynamic>{'limit': limit};
    if (signal != null && signal.isNotEmpty) params['signal'] = signal;
    final response = await _dio.get(ApiEndpoints.marketAnalysisTopStocks,
        queryParameters: params);
    return TopStocksResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MarketOverviewResponse> getMarketOverview() async {
    final response = await _dio.get(ApiEndpoints.marketAnalysisOverview);
    return MarketOverviewResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnalysisResultResponse> getSymbolAnalysis(String symbol) async {
    final response = await _dio.get(ApiEndpoints.marketAnalysisSymbol(symbol));
    return AnalysisResultResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Stock360Response> getStock360View(String symbol) async {
    final response = await _dio.get(ApiEndpoints.marketAnalysis360(symbol));
    return Stock360Response.fromJson(response.data as Map<String, dynamic>);
  }
}
