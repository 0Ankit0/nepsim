import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/stock.dart';
import '../../data/models/market_data.dart';
import '../../data/repositories/market_repository.dart';
import 'package:intl/intl.dart';

final stockListProvider = FutureProvider.autoDispose<List<StockMetadata>>((ref) async {
  return ref.watch(marketRepositoryProvider).getStocks();
});

final stockSearchQueryProvider = NotifierProvider<StockSearchQueryNotifier, String>(
  StockSearchQueryNotifier.new,
);

class StockSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final filteredStockListProvider = Provider.autoDispose<AsyncValue<List<StockMetadata>>>((ref) {
  final query = ref.watch(stockSearchQueryProvider).toLowerCase();
  final stocksAsync = ref.watch(stockListProvider);

  return stocksAsync.whenData((stocks) {
    if (query.isEmpty) return stocks;
    return stocks.where((stock) => 
      stock.symbol.toLowerCase().contains(query) || 
      stock.companyName.toLowerCase().contains(query)
    ).toList();
  });
});

enum Timeframe { w1, m1, m3, m6, y1, all }

final selectedTimeframeProvider = StateProvider.autoDispose<Timeframe>((ref) => Timeframe.m1);

final stockDetailProvider = FutureProvider.family.autoDispose<StockMetadata, String>((ref, symbol) async {
  return ref.watch(marketRepositoryProvider).getStockDetail(symbol);
});

final stockHistoryProvider = FutureProvider.family.autoDispose<List<MarketDataPoint>, String>((ref, symbol) async {
  final timeframe = ref.watch(selectedTimeframeProvider);
  
  final now = DateTime.now();
  String? startDate;
  int limit = 500;

  switch (timeframe) {
    case Timeframe.w1:
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
      limit = 100;
      break;
    case Timeframe.m1:
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
      limit = 100;
      break;
    case Timeframe.m3:
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 90)));
      limit = 200;
      break;
    case Timeframe.m6:
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 180)));
      limit = 300;
      break;
    case Timeframe.y1:
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 365)));
      limit = 500;
      break;
    case Timeframe.all:
      startDate = null;
      limit = 2000;
      break;
  }

  return ref.watch(marketRepositoryProvider).getStockHistory(symbol, startDate: startDate, limit: limit);
});
