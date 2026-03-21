import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/watchlist_models.dart';

class WatchlistRepository {
  final Dio _dio;

  WatchlistRepository(this._dio);

  Future<List<WatchlistItemResponse>> getWatchlist() async {
    final response = await _dio.get(ApiEndpoints.watchlist);
    return (response.data as List)
        .map((e) => WatchlistItemResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WatchlistItemResponse> addItem(WatchlistItemCreate item) async {
    final response = await _dio.post(ApiEndpoints.watchlist, data: item.toJson());
    return WatchlistItemResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> removeItem(int id) async {
    await _dio.delete(ApiEndpoints.watchlistDetail(id));
  }

  Future<List<WatchlistAlertResponse>> checkSignals() async {
    final response = await _dio.post(ApiEndpoints.watchlistCheckSignals);
    return (response.data as List)
        .map((e) => WatchlistAlertResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<WatchlistAlertResponse>> getAlerts() async {
    final response = await _dio.get(ApiEndpoints.watchlistAlerts);
    return (response.data as List)
        .map((e) => WatchlistAlertResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAlertRead(int id) async {
    await _dio.patch(ApiEndpoints.watchlistAlertRead(id));
  }
}
