import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/market_repository.dart';

class ChartDrawingsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final MarketRepository _repository;
  final String _symbol;

  ChartDrawingsNotifier(this._repository, this._symbol) : super(const AsyncValue.loading()) {
    loadDrawings();
  }

  Future<void> loadDrawings() async {
    try {
      final drawings = await _repository.getChartDrawings(_symbol);
      state = AsyncValue.data(drawings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addHorizontalLine(double price) async {
    try {
      await _repository.saveChartDrawing(
        symbol: _symbol,
        type: 'horizontal_line',
        coordinates: {'y': price},
      );
      await loadDrawings();
    } catch (e) {
      // Error handling can be done via a separate UI feedback mechanism
    }
  }

  Future<void> clearDrawings() async {
    final current = state.value;
    if (current == null) return;
    
    // In a real app, we might want to batch delete or have a "delete all" endpoint
    for (var d in current) {
      await _repository.deleteChartDrawing(d['id']);
    }
    await loadDrawings();
  }
}

final chartDrawingsProvider = StateNotifierProvider.family.autoDispose<ChartDrawingsNotifier, AsyncValue<List<dynamic>>, String>((ref, symbol) {
  return ChartDrawingsNotifier(ref.watch(marketRepositoryProvider), symbol);
});

final selectedIndicatorsProvider = StateProvider.autoDispose<Set<String>>((ref) => {});
final chartTypeProvider = StateProvider.autoDispose<String>((ref) => 'candle');
