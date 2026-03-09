import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/simulator_provider.dart';
import '../../data/repositories/simulator_repository.dart';

class TradingPage extends ConsumerWidget {
  final int simulationId;

  const TradingPage({super.key, required this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simAsync = ref.watch(simulationDetailProvider(simulationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => context.push('${AppConstants.portfolioRoute}?id=$simulationId'),
            tooltip: 'View Portfolio',
          ),
        ],
      ),
      body: simAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (sim) {
          final isEnded = sim.status == 'ended';
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
                          'Rs. ${sim.totalValue?.toStringAsFixed(2) ?? "0.0"}',
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
                                Text('Rs. ${sim.cashBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Portfolio Return'),
                                Text(
                                  '${(((sim.totalValue ?? sim.initialCapital) / sim.initialCapital) * 100 - 100).toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ((sim.totalValue ?? 0) >= sim.initialCapital) ? Colors.green : Colors.red,
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
                            Text('Current Date: ${sim.currentSimDate.toIso8601String().split("T").first}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (!isEnded)
                              TextButton.icon(
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Next Day'),
                                onPressed: () async {
                                  try {
                                    await ref.read(simulatorListProvider.notifier).advanceDay(simulationId);
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
                      context.push(AppConstants.stockSearchRoute);
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
                        await repository.endSimulation(simulationId);
                        if (context.mounted) {
                          context.go('${AppConstants.analysisLoadingRoute}?id=$simulationId');
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
                    child: const Center(
                      child: Text('This simulation has ended.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
