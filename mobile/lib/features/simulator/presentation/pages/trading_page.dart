import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/simulator_provider.dart';
import '../../../market_analysis/presentation/providers/analysis_provider.dart';

class TradingPage extends ConsumerStatefulWidget {
  final int simulationId;

  const TradingPage({super.key, required this.simulationId});

  @override
  ConsumerState<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends ConsumerState<TradingPage> {
  Timer? _tickTimer;
  int _tickSeconds = 10;

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  void _syncAutoTick(String status) {
    _tickTimer?.cancel();
    if (status != 'active') {
      return;
    }

    _tickTimer = Timer.periodic(Duration(seconds: _tickSeconds), (_) async {
      try {
        await ref.read(simulatorListProvider.notifier).advanceDay(widget.simulationId);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final simAsync = ref.watch(simulationDetailProvider(widget.simulationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => context.push('${AppConstants.portfolioRoute}?id=${widget.simulationId}'),
            tooltip: 'View Portfolio',
          ),
        ],
      ),
      body: simAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (sim) {
          final simulationDate = sim.current_sim_date.split('T').first;
          final ideasAsync = ref.watch(
            topStocksBySignalProvider(
              AnalysisScope(signal: 'BUY', limit: 3, asOfDate: simulationDate),
            ),
          );
          final isEnded = sim.status == 'ended' || sim.status == 'analysing' || sim.status == 'analysis_ready';
          final isPaused = sim.status == 'paused';
          _syncAutoTick(sim.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Total Value', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text(
                          'Rs. ${sim.total_value?.toStringAsFixed(2) ?? "0.0"}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cash Balance'),
                                Text('Rs. ${sim.cash_balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Portfolio Return'),
                                Text(
                                  '${(((sim.total_value ?? sim.initial_capital) / sim.initial_capital) * 100 - 100).toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ((sim.total_value ?? 0) >= sim.initial_capital) ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Current Date: ${sim.current_sim_date.split("T").first}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (!isEnded)
                              TextButton.icon(
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Next Day'),
                                onPressed: () async {
                                  try {
                                    await ref.read(simulatorListProvider.notifier).advanceDay(widget.simulationId);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to advance day: $e')),
                                      );
                                    }
                                  }
                                },
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tick Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          isPaused
                              ? 'Simulation is paused. Review ideas and resume when ready.'
                              : 'Simulation advances one trading day every $_tickSeconds seconds.',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _tickSeconds,
                                decoration: const InputDecoration(
                                  labelText: 'Seconds per tick',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [1, 3, 5, 10, 15, 30, 60]
                                    .map((seconds) => DropdownMenuItem<int>(
                                          value: seconds,
                                          child: Text('$seconds sec'),
                                        ))
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null) return;
                                  setState(() => _tickSeconds = value);
                                  await ref.read(simulatorListProvider.notifier).updateTickConfig(widget.simulationId, value);
                                  _syncAutoTick(sim.status);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: isEnded
                                    ? null
                                    : () async {
                                        if (isPaused) {
                                          await ref.read(simulatorListProvider.notifier).resumeSimulation(widget.simulationId);
                                        } else {
                                          await ref.read(simulatorListProvider.notifier).pauseSimulation(widget.simulationId);
                                        }
                                      },
                                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                                label: Text(isPaused ? 'Resume' : 'Pause'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (!isEnded && isPaused)
                  ideasAsync.when(
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (err, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Could not load stock ideas: $err'),
                      ),
                    ),
                    data: (ideas) {
                      final picks = ideas.results.take(3).toList();
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text('Stocks Worth Reviewing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...picks.map((stock) => Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.amber.withValues(alpha: 0.08),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text('${stock.overallScore.toStringAsFixed(0)}/100', style: const TextStyle(fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(stock.signal.replaceAll('_', ' '), style: TextStyle(color: Colors.grey[700])),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => context.push('${AppConstants.stockDetailRoute}?symbol=${stock.symbol}&simId=${widget.simulationId}'),
                                              child: const Text('Open Chart'),
                                            ),
                                            FilledButton.tonal(
                                              onPressed: () => context.push(
                                                '${AppConstants.marketAnalysisDetailRoute}?symbol=${stock.symbol}&simId=${widget.simulationId}',
                                              ),
                                              child: const Text('Open Analysis'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                if (!isEnded && isPaused) const SizedBox(height: 24),

                // Actions
                if (!isEnded) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text('Search Stocks to Trade', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      context.push('${AppConstants.stockSearchRoute}?simId=${widget.simulationId}');
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End Simulation', style: TextStyle(fontSize: 16)),
                    onPressed: () async {
                      try {
                        final repository = ref.read(simulatorRepositoryProvider);
                        await repository.endSimulation(widget.simulationId);
                        if (context.mounted) {
                          context.go('${AppConstants.analysisLoadingRoute}?id=${widget.simulationId}');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to end simulation: $e')));
                        }
                      }
                    },
                  ),
                ] else ...[
                  // Simulation is ended
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('This simulation has ended.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.push('${AppConstants.analysisResultsRoute}?id=${widget.simulationId}'),
                            child: const Text('Open AI Analysis'),
                          ),
                        ],
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
