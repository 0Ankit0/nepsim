import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analysis_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../simulator/presentation/providers/simulator_provider.dart';

class MarketAnalysisPage extends ConsumerWidget {
  final int? simulationId;

  const MarketAnalysisPage({super.key, this.simulationId});

  static const _filterSignals = ['', 'STRONG_BUY', 'BUY', 'HOLD', 'SELL', 'STRONG_SELL'];
  static const _filterLabels = ['All', 'Strong Buy', 'Buy', 'Hold', 'Sell', 'Strong Sell'];

  Color _signalColor(String signal) {
    switch (signal) {
      case 'STRONG_BUY':
        return const Color(0xFF1B5E20);
      case 'BUY':
        return Colors.green;
      case 'HOLD':
        return Colors.amber;
      case 'SELL':
        return Colors.red;
      case 'STRONG_SELL':
        return const Color(0xFFB71C1C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationDate = simulationId == null ? null : ref
        .watch(simulationDetailProvider(simulationId!))
        .maybeWhen(
          data: (sim) => sim.current_sim_date.split('T').first,
          orElse: () => null,
        );
    final overviewAsync = ref.watch(marketOverviewProvider(simulationDate));
    final topStocksAsync = ref.watch(topStocksProvider(
      AnalysisScope(asOfDate: simulationDate),
    ));
    final currentFilter = ref.watch(topStocksSignalFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Analysis'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.manage_search, size: 18),
            label: const Text('360° View'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
            onPressed: () => context.push(
              simulationId == null ? '/stock-360' : '/stock-360?simId=$simulationId',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Watchlist',
            onPressed: () => context.push(AppConstants.watchlistRoute),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(topStocksProvider(AnalysisScope(asOfDate: simulationDate)));
              ref.invalidate(marketOverviewProvider(simulationDate));
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Market overview
          SliverToBoxAdapter(
            child: overviewAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Overview error: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (overview) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (simulationDate != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Simulation guardrail active: analysis is capped at $simulationDate.',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Market Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text('${overview.totalAnalyzed} stocks',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: overview.bullishPct / 100,
                            minHeight: 10,
                            backgroundColor: Colors.red[100],
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '🐂 Bullish ${overview.bullishPct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600)),
                            Text(
                                '🐻 Bearish ${overview.bearishPct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _OverviewChip(
                                label: 'SB: ${overview.strongBuy}',
                                color: const Color(0xFF1B5E20)),
                            _OverviewChip(
                                label: 'B: ${overview.buy}',
                                color: Colors.green),
                            _OverviewChip(
                                label: 'H: ${overview.hold}',
                                color: Colors.amber),
                            _OverviewChip(
                                label: 'S: ${overview.sell}',
                                color: Colors.red),
                            _OverviewChip(
                                label: 'SS: ${overview.strongSell}',
                                color: const Color(0xFFB71C1C)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filterSignals.length,
                itemBuilder: (context, idx) {
                  final isSelected = (currentFilter ?? '') == _filterSignals[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: FilterChip(
                      label: Text(_filterLabels[idx]),
                      selected: isSelected,
                      onSelected: (_) {
                        ref
                            .read(topStocksSignalFilterProvider.notifier)
                            .set(_filterSignals[idx].isEmpty ? null : _filterSignals[idx]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // Top stocks
          topStocksAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            data: (data) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                    final stock = data.results[idx];
                    final signalColor = _signalColor(stock.signal);
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final simParam = simulationId != null ? '&simId=$simulationId' : '';
                          context.push(
                            '${AppConstants.marketAnalysisDetailRoute}?symbol=${stock.symbol}$simParam',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('#${idx + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  Text(stock.symbol,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: signalColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      stock.signal.replaceAll('_', ' '),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          stock.overallScore.toStringAsFixed(1),
                                          style: TextStyle(
                                              color: signalColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                      const Text('/100',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                              if (stock.currentPrice != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                    'Rs.${stock.currentPrice!.toStringAsFixed(2)}${stock.entryPrice != null ? ' • Entry: Rs.${stock.entryPrice!.toStringAsFixed(2)}' : ''}${stock.targetPrice != null ? ' • Target: Rs.${stock.targetPrice!.toStringAsFixed(2)}' : ''}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600])),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                      child: _ScoreBar(
                                          label: 'Osc',
                                          value: stock.oscillatorScore / 100)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: _ScoreBar(
                                          label: 'Trend',
                                          value: stock.trendScore / 100)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: _ScoreBar(
                                          label: 'Vol',
                                          value: stock.volumeScore / 100)),
                                ],
                              ),
                              if (stock.keySignals.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: stock.keySignals
                                      .take(3)
                                      .map((s) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: signalColor.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: signalColor
                                                      .withValues(alpha: 0.3)),
                                            ),
                                            child: Text(s,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: signalColor)),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: data.results.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  final String label;
  final Color color;

  const _OverviewChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;

  const _ScoreBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 5,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
