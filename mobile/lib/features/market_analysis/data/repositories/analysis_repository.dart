import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/analysis_models.dart';

class MarketAnalysisRepository {
  final Dio _dio;

  MarketAnalysisRepository(this._dio);

  Future<TopStocksResponse> getTopStocks({
    int limit = 20,
    String? signal,
    String? asOfDate,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (signal != null && signal.isNotEmpty) params['signal'] = signal;
    if (asOfDate != null && asOfDate.isNotEmpty) params['as_of_date'] = asOfDate;
    final response = await _dio.get(ApiEndpoints.marketAnalysisTopStocks,
        queryParameters: params);
    return TopStocksResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MarketOverviewResponse> getMarketOverview({String? asOfDate}) async {
    final response = await _dio.get(
      ApiEndpoints.marketAnalysisOverview,
      queryParameters: asOfDate == null || asOfDate.isEmpty
          ? null
          : {'as_of_date': asOfDate},
    );
    return MarketOverviewResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnalysisResultResponse> getSymbolAnalysis(String symbol, {String? asOfDate}) async {
    final response = await _dio.get(
      ApiEndpoints.marketAnalysisSymbol(symbol),
      queryParameters: asOfDate == null || asOfDate.isEmpty
          ? null
          : {'as_of_date': asOfDate},
    );
    return AnalysisResultResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Stock360Response> getStock360View(String symbol, {String? asOfDate}) async {
    final response = await _dio.get(
      ApiEndpoints.marketAnalysis360(symbol),
      queryParameters: asOfDate == null || asOfDate.isEmpty
          ? null
          : {'as_of_date': asOfDate},
    );
    return Stock360Response.fromJson(response.data as Map<String, dynamic>);
  }
}
