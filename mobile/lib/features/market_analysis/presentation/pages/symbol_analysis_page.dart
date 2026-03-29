import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_provider.dart';
import '../../../simulator/presentation/providers/simulator_provider.dart';

class SymbolAnalysisPage extends ConsumerWidget {
  final String symbol;
  final int? simulationId;

  const SymbolAnalysisPage({super.key, required this.symbol, this.simulationId});

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
    final scope = SymbolAnalysisScope(symbol: symbol, asOfDate: simulationDate);
    final analysisAsync = ref.watch(symbolAnalysisProvider(scope));

    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(symbolAnalysisProvider(scope)),
          ),
        ],
      ),
      body: analysisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (analysis) {
          final signalColor = _signalColor(analysis.signal);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (simulationDate != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
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
                // Header card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(analysis.symbol,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                Text('As of ${analysis.analysisDate}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600])),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: signalColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    analysis.signal.replaceAll('_', ' '),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${analysis.overallScore.toStringAsFixed(1)}/100',
                                  style: TextStyle(
                                      color: signalColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (analysis.currentPrice != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Rs. ${analysis.currentPrice!.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Score breakdown
                Text('Score Breakdown',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: [
                    _ScoreCard(
                        label: 'Oscillator',
                        score: analysis.oscillatorScore),
                    _ScoreCard(label: 'Trend', score: analysis.trendScore),
                    _ScoreCard(label: 'Volume', score: analysis.volumeScore),
                    _ScoreCard(
                        label: 'Volatility', score: analysis.volatilityScore),
                  ],
                ),
                const SizedBox(height: 16),
                // Trading levels
                if (analysis.entryPrice != null ||
                    analysis.targetPrice != null ||
                    analysis.stopLoss != null) ...[
                  Text('Trading Levels',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (analysis.entryPrice != null)
                            _LevelRow(
                                label: 'Entry',
                                value:
                                    'Rs. ${analysis.entryPrice!.toStringAsFixed(2)}',
                                color: Colors.blue),
                          if (analysis.targetPrice != null)
                            _LevelRow(
                                label: 'Target',
                                value:
                                    'Rs. ${analysis.targetPrice!.toStringAsFixed(2)}',
                                color: Colors.green),
                          if (analysis.stopLoss != null)
                            _LevelRow(
                                label: 'Stop Loss',
                                value:
                                    'Rs. ${analysis.stopLoss!.toStringAsFixed(2)}',
                                color: Colors.red),
                          if (analysis.riskRewardRatio != null) ...[
                            const Divider(),
                            _LevelRow(
                                label: 'Risk : Reward',
                                value:
                                    '1 : ${analysis.riskRewardRatio!.toStringAsFixed(2)}',
                                color: signalColor),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Key signals
                if (analysis.keySignals.isNotEmpty) ...[
                  Text('Key Signals',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: analysis.keySignals
                            .map((s) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.arrow_right,
                                          color: signalColor, size: 20),
                                      const SizedBox(width: 6),
                                      Expanded(
                                          child: Text(s,
                                              style: const TextStyle(
                                                  fontSize: 13))),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreCard({required this.label, required this.score});

  Color _scoreColor(double s) {
    if (s >= 70) return Colors.green;
    if (s >= 50) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (score / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(score.toStringAsFixed(0),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LevelRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
