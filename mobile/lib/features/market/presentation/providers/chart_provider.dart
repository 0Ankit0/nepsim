import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/market_provider.dart';

part 'chart_provider.g.dart';

@riverpod
class ChartDrawings extends _$ChartDrawings {
  @override
  Future<List<dynamic>> build(String symbol) async {
    return ref.watch(marketRepositoryProvider).getChartDrawings(symbol);
  }

  Future<void> addHorizontalLine(double price) async {
    await ref.read(marketRepositoryProvider).saveChartDrawing(
      symbol: symbol,
      type: 'horizontal_line',
      coordinates: {'y': price},
    );
    ref.invalidateSelf();
  }

  Future<void> clearDrawings() async {
    final current = state.value ?? [];
    for (final d in current) {
      await ref.read(marketRepositoryProvider).deleteChartDrawing(d['id'] as int);
    }
    ref.invalidateSelf();
  }
}

class _SelectedIndicatorsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String indicator) {
    final next = Set<String>.from(state);
    if (next.contains(indicator)) {
      next.remove(indicator);
    } else {
      next.add(indicator);
    }
    state = next;
  }
}

final selectedIndicatorsProvider =
    NotifierProvider.autoDispose<_SelectedIndicatorsNotifier, Set<String>>(
        _SelectedIndicatorsNotifier.new);

class _ChartTypeNotifier extends Notifier<String> {
  @override
  String build() => 'candle';

  void set(String type) => state = type;
}

final chartTypeProvider =
    NotifierProvider.autoDispose<_ChartTypeNotifier, String>(
        _ChartTypeNotifier.new);
