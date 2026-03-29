import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/analysis_models.dart';
import '../../data/repositories/analysis_repository.dart';

final marketAnalysisRepositoryProvider = Provider<MarketAnalysisRepository>((ref) {
  return MarketAnalysisRepository(ref.watch(dioClientProvider).dio);
});

class AnalysisScope {
  final String? signal;
  final int limit;
  final String? asOfDate;

  const AnalysisScope({
    this.signal,
    this.limit = 20,
    this.asOfDate,
  });

  @override
  bool operator ==(Object other) {
    return other is AnalysisScope &&
        other.signal == signal &&
        other.limit == limit &&
        other.asOfDate == asOfDate;
  }

  @override
  int get hashCode => Object.hash(signal, limit, asOfDate);
}

class SymbolAnalysisScope {
  final String symbol;
  final String? asOfDate;

  const SymbolAnalysisScope({
    required this.symbol,
    this.asOfDate,
  });

  @override
  bool operator ==(Object other) {
    return other is SymbolAnalysisScope &&
        other.symbol == symbol &&
        other.asOfDate == asOfDate;
  }

  @override
  int get hashCode => Object.hash(symbol, asOfDate);
}

// Holds the current signal filter (null = all)
class _SignalFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final topStocksSignalFilterProvider =
    NotifierProvider<_SignalFilterNotifier, String?>(_SignalFilterNotifier.new);

final topStocksProvider =
    FutureProvider.family<TopStocksResponse, AnalysisScope>((ref, scope) async {
  final signal = scope.signal ?? ref.watch(topStocksSignalFilterProvider);
  return ref.watch(marketAnalysisRepositoryProvider).getTopStocks(
        signal: signal,
        limit: scope.limit,
        asOfDate: scope.asOfDate,
      );
});

final topStocksBySignalProvider =
    FutureProvider.family<TopStocksResponse, AnalysisScope>((ref, scope) async {
  return ref.watch(marketAnalysisRepositoryProvider).getTopStocks(
        signal: scope.signal,
        limit: scope.limit,
        asOfDate: scope.asOfDate,
      );
});

final marketOverviewProvider =
    FutureProvider.family<MarketOverviewResponse, String?>((ref, asOfDate) async {
  return ref.watch(marketAnalysisRepositoryProvider).getMarketOverview(
        asOfDate: asOfDate,
      );
});

final symbolAnalysisProvider =
    FutureProvider.family<AnalysisResultResponse, SymbolAnalysisScope>((ref, scope) async {
  return ref.watch(marketAnalysisRepositoryProvider).getSymbolAnalysis(
        scope.symbol,
        asOfDate: scope.asOfDate,
      );
});

final stock360Provider =
    FutureProvider.family<Stock360Response, SymbolAnalysisScope>((ref, scope) async {
  return ref.watch(marketAnalysisRepositoryProvider).getStock360View(
        scope.symbol,
        asOfDate: scope.asOfDate,
      );
});
