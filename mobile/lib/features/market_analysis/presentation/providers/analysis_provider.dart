import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/analysis_models.dart';
import '../../data/repositories/analysis_repository.dart';

final marketAnalysisRepositoryProvider = Provider<MarketAnalysisRepository>((ref) {
  return MarketAnalysisRepository(ref.watch(dioClientProvider).dio);
});

// Holds the current signal filter (null = all)
class _SignalFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final topStocksSignalFilterProvider =
    NotifierProvider<_SignalFilterNotifier, String?>(_SignalFilterNotifier.new);

final topStocksProvider = FutureProvider<TopStocksResponse>((ref) async {
  final signal = ref.watch(topStocksSignalFilterProvider);
  return ref.watch(marketAnalysisRepositoryProvider).getTopStocks(signal: signal);
});

final marketOverviewProvider = FutureProvider<MarketOverviewResponse>((ref) async {
  return ref.watch(marketAnalysisRepositoryProvider).getMarketOverview();
});

final symbolAnalysisProvider =
    FutureProvider.family<AnalysisResultResponse, String>((ref, symbol) async {
  return ref.watch(marketAnalysisRepositoryProvider).getSymbolAnalysis(symbol);
});

final stock360Provider =
    FutureProvider.family<Stock360Response, String>((ref, symbol) async {
  return ref.watch(marketAnalysisRepositoryProvider).getStock360View(symbol);
});
