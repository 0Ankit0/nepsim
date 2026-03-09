import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/advanced_chart.dart';
import '../providers/market_provider.dart';
import '../../learn/presentation/widgets/ai_context_tooltip.dart';

class StockDetailPage extends ConsumerWidget {
  final String symbol;

  const StockDetailPage({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(stockDetailProvider(symbol));
    final historyAsync = ref.watch(stockHistoryProvider(symbol));

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
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading stock: $err')),
        data: (stock) {
          final price = stock.currentPrice ?? 0.0;
          final prev = stock.previousClose ?? price;
          final changeVal = price - prev;
          final changePct = prev > 0 ? (changeVal / prev) * 100 : 0.0;
          final isPositive = changeVal >= 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stock.companyName, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700])),
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
                
                // Chart
                SizedBox(
                  height: 400,
                  child: historyAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error loading chart: $err'),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(stockHistoryProvider(symbol)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (history) {
                      if (history.isEmpty) {
                        return const Center(child: Text('No historical data available'));
                      }
                      
                      return Column(
                        children: [
                          const _TimeframeSelector(),
                          Expanded(
                            child: AdvancedChart(
                              data: history,
                              symbol: symbol,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Details Grid
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
                            Expanded(child: AiContextTooltip(term: 'Sector', child: _StatRow(label: 'Sector', value: stock.sector))),
                            Expanded(child: AiContextTooltip(term: 'Face Value', child: _StatRow(label: 'Face Value', value: 'Rs. ${stock.faceValue}'))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: AiContextTooltip(term: 'Lot Size', child: _StatRow(label: 'Lot Size', value: stock.lotSize.toString()))),
                            Expanded(child: AiContextTooltip(term: 'Tick Size', child: _StatRow(label: 'Tick Size', value: stock.tickSize.toString()))),
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

class _TimeframeSelector extends ConsumerWidget {
  const _TimeframeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTimeframeProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: Timeframe.values.map((tf) {
          final isSelected = selected == tf;
          return InkWell(
            onTap: () => ref.read(selectedTimeframeProvider.notifier).state = tf,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tf.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
