import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_provider.dart';
import '../repositories/market_repository.dart';
import '../models/market_models.dart';

part 'market_provider.g.dart';

@riverpod
MarketRepository marketRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MarketRepository(dioClient.dio);
}

@riverpod
Future<List<String>> symbols(Ref ref) async {
  return ref.watch(marketRepositoryProvider).getSymbols();
}

@riverpod
Future<LatestQuoteResponse> quote(Ref ref, String symbol) async {
  return ref.watch(marketRepositoryProvider).getQuote(symbol);
}

@riverpod
Future<HistoricDataResponse> history(Ref ref, String symbol, {String? startDate, String? endDate, int limit = 365}) async {
  return ref.watch(marketRepositoryProvider).getHistory(symbol, startDate: startDate, endDate: endDate, limit: limit);
}

@riverpod
Future<IndicatorsResponse> indicators(Ref ref, String symbol, {String? startDate, String? endDate, int limit = 365}) async {
  return ref.watch(marketRepositoryProvider).getIndicators(symbol, startDate: startDate, endDate: endDate, limit: limit);
}

@riverpod
Future<IndicatorRow> latestIndicators(Ref ref, String symbol) async {
  return ref.watch(marketRepositoryProvider).getLatestIndicators(symbol);
}

@riverpod
Future<IndicesResponse> indices(Ref ref, {String? indexName, String? startDate, String? endDate, int limit = 365}) async {
  return ref.watch(marketRepositoryProvider).getIndices(indexName: indexName, startDate: startDate, endDate: endDate, limit: limit);
}

@riverpod
Future<LatestIndicesResponse> latestIndices(Ref ref, {String? indexName}) async {
  return ref.watch(marketRepositoryProvider).getLatestIndices(indexName: indexName);
}

@riverpod
class StockSearchQuery extends _$StockSearchQuery {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
Future<List<String>> filteredStockList(Ref ref) async {
  final query = ref.watch(stockSearchQueryProvider).toLowerCase();
  final symbolsList = await ref.watch(symbolsProvider.future);
  
  if (query.isEmpty) return symbolsList.take(20).toList();
  return symbolsList.where((s) => s.toLowerCase().contains(query)).take(20).toList();
}
