import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/market_data.dart';
import '../models/stock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_provider.dart';

part 'market_repository.g.dart';

class MarketRepository {
  final DioClient _dioClient;

  MarketRepository(this._dioClient);

  Future<List<StockMetadata>> getStocks() async {
    final response = await _dioClient.dio.get(ApiEndpoints.stocks);
    return (response.data as List)
        .map((e) => StockMetadata.fromJson(e))
        .toList();
  }

  Future<StockMetadata> getStockDetail(String symbol) async {
    final response = await _dioClient.dio.get(ApiEndpoints.stockDetail(symbol));
    return StockMetadata.fromJson(response.data);
  }

  Future<List<MarketDataPoint>> getStockHistory(
      String symbol, {String? startDate, String? endDate, int limit = 500}) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.stockHistory(symbol),
      queryParameters: {
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'limit': limit,
      },
    );
    // Backend returns HistoryResponse { symbol: ..., data: [...] }
    final List data = response.data['data'];
    return data.map((e) => MarketDataPoint.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> computeIndicator(
    String symbol,
    String indicator, {
    int period = 14,
    int? fast,
    int? slow,
    int? signal,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.stockIndicators(symbol),
      queryParameters: {
        'indicator': indicator,
        'period': period,
        if (fast != null) 'fast': fast,
        if (slow != null) 'slow': slow,
        if (signal != null) 'signal': signal,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> saveChartDrawing({
    required String symbol,
    required String type,
    required Map<String, dynamic> coordinates,
    Map<String, dynamic>? parameters,
    String? label,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.chartDrawings,
      data: {
        'symbol': symbol,
        'drawing_type': type,
        'coordinates': coordinates,
        'parameters': parameters,
        'label': label,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getChartDrawings(String symbol) async {
    final response = await _dioClient.dio.get(ApiEndpoints.stockChartDrawings(symbol));
    return response.data as List;
  }

  Future<void> deleteChartDrawing(int id) async {
    await _dioClient.dio.delete(ApiEndpoints.deleteChartDrawing(id.toString()));
  }
}

@riverpod
MarketRepository marketRepository(Ref ref) {
  return MarketRepository(ref.watch(dioClientProvider));
}
