import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/market_models.dart';

class MarketRepository {
  final Dio _dio;

  MarketRepository(this._dio);

  Future<List<String>> getSymbols() async {
    final response = await _dio.get(ApiEndpoints.symbols);
    return List<String>.from(response.data);
  }

  Future<LatestQuoteResponse> getQuote(String symbol) async {
    final response = await _dio.get(ApiEndpoints.quote(symbol));
    return LatestQuoteResponse.fromJson(response.data);
  }

  Future<HistoricDataResponse> getHistory(String symbol, {String? startDate, String? endDate, int limit = 500}) async {
    final params = <String, dynamic>{'limit': limit};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final response = await _dio.get(ApiEndpoints.history(symbol), queryParameters: params);
    return HistoricDataResponse.fromJson(response.data);
  }

  Future<IndicatorsResponse> getIndicators(String symbol, {String? startDate, String? endDate, int limit = 500}) async {
    final params = <String, dynamic>{'limit': limit};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final response = await _dio.get(ApiEndpoints.indicators(symbol), queryParameters: params);
    return IndicatorsResponse.fromJson(response.data);
  }

  Future<IndicatorRow> getLatestIndicators(String symbol) async {
    final response = await _dio.get(ApiEndpoints.latestIndicators(symbol));
    return IndicatorRow.fromJson(response.data);
  }

  Future<IndicesResponse> getIndices({String? indexName, String? startDate, String? endDate, int limit = 500}) async {
    final params = <String, dynamic>{'limit': limit};
    if (indexName != null) params['index_name'] = indexName;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final response = await _dio.get(ApiEndpoints.indices, queryParameters: params);
    return IndicesResponse.fromJson(response.data);
  }

  Future<LatestIndicesResponse> getLatestIndices({String? indexName}) async {
    final params = <String, dynamic>{};
    if (indexName != null) params['index_name'] = indexName;
    final response = await _dio.get(ApiEndpoints.latestIndices, queryParameters: params);
    return LatestIndicesResponse.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> getChartDrawings(String symbol) async {
    final response = await _dio.get(ApiEndpoints.chartDrawingsBySymbol(symbol));
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> saveChartDrawing({
    required String symbol,
    required String type,
    required Map<String, dynamic> coordinates,
  }) async {
    await _dio.post(
      ApiEndpoints.chartDrawings,
      data: {'symbol': symbol, 'drawing_type': type, 'coordinates': coordinates},
    );
  }

  Future<void> deleteChartDrawing(int drawingId) async {
    await _dio.delete(ApiEndpoints.deleteChartDrawing(drawingId));
  }
}
