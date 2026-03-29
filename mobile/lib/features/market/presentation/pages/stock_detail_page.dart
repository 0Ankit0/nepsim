import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/advanced_chart.dart';
import '../providers/market_provider.dart';
import '../../data/models/market_models.dart';
import '../../../simulator/presentation/providers/simulator_provider.dart';

class StockDetailPage extends ConsumerWidget {
  final String symbol;
  final int? simulationId;

  const StockDetailPage({super.key, required this.symbol, this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (simulationId == null) {
      final detailAsync = ref.watch(quoteProvider(symbol));
      final historyAsync = ref.watch(historyProvider(symbol));

      return _buildScaffold(
        context,
        detailAsync: detailAsync,
        historyAsync: historyAsync,
      );
    }

    final simulationAsync = ref.watch(simulationDetailProvider(simulationId!));

    return simulationAsync.when(
      loading: () => _buildScaffold(
        context,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => _buildScaffold(
        context,
        body: Center(child: Text('Error loading simulation context: $err')),
      ),
      data: (sim) {
        final simulationDate = sim.current_sim_date.split('T').first;
        final historyAsync = ref.watch(historyProvider(symbol, endDate: simulationDate));

        return _buildScaffold(
          context,
          simulationDate: simulationDate,
          historyAsync: historyAsync,
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    AsyncValue<LatestQuoteResponse>? detailAsync,
    AsyncValue<HistoricDataResponse>? historyAsync,
    String? simulationDate,
    Widget? body,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // TODO: add to watchlist
            },
          )
        ],
      ),
      body: body ??
          historyAsync!.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading chart: $err')),
        data: (historyResp) {
          final history = historyResp.data;
          final latestRow = history.isNotEmpty ? history.last : null;
          final quoteAsync =
              detailAsync ?? AsyncValue.data(const LatestQuoteResponse(symbol: '', date: ''));

          return quoteAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading stock: $err')),
            data: (quoteInfo) {
              final price = latestRow?.close ?? quoteInfo.ltp ?? 0.0;
              final changePct = latestRow?.close != null && history.length > 1 && history[history.length - 2].close != null
                  ? (((latestRow!.close! - history[history.length - 2].close!) / history[history.length - 2].close!) * 100)
                  : (quoteInfo.diff_pct ?? 0.0);
              final changeVal = latestRow?.close != null && history.length > 1 && history[history.length - 2].close != null
                  ? (latestRow!.close! - history[history.length - 2].close!)
                  : (quoteInfo.diff ?? 0.0);
              final isPositive = changeVal >= 0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(symbol, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700])),
                          if (simulationDate != null) ...[
                            const SizedBox(height: 4),
                            Text('Simulation view through $simulationDate', style: TextStyle(color: Colors.indigo[600], fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rs. ${price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Text(
                                '${isPositive ? '+' : ''}${changeVal.toStringAsFixed(2)} (${changePct.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: isPositive ? Colors.green[700] : Colors.red[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 400,
                      child: history.isEmpty
                          ? const Center(child: Text('No historical data available'))
                          : AdvancedChart(
                              data: history,
                              symbol: symbol,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Market Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _StatRow(label: 'Volume', value: '${quoteInfo.vol ?? latestRow?.vol ?? 'N/A'}')),
                                Expanded(child: _StatRow(label: 'Turnover', value: 'Rs. ${quoteInfo.turnover ?? 'N/A'}')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _StatRow(label: '52W High', value: '${quoteInfo.weeks_52_high ?? 'N/A'}')),
                                Expanded(child: _StatRow(label: '52W Low', value: '${quoteInfo.weeks_52_low ?? 'N/A'}')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: show buy dialog
                  },
                  child: const Text('BUY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: show sell dialog
                  },
                  child: const Text('SELL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
