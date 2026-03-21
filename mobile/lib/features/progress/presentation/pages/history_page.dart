import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../simulator/presentation/providers/simulator_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationsAsync = ref.watch(simulatorListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation History'),
      ),
      body: simulationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading history: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(simulatorListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (simulations) {
          final completedSims = simulations.where((s) => s.status == 'completed').toList();
          
          if (completedSims.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   const Text('No completed simulations found.', style: TextStyle(color: Colors.grey)),
                   const SizedBox(height: 8),
                   const Text('Finish a simulation to see it here!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedSims.length,
            itemBuilder: (context, index) {
              final sim = completedSims[index];
              final date = DateFormat.yMMMd().format(DateTime.parse(sim.ended_at ?? sim.started_at));
              final bool isProfit = (sim.total_pnl_pct ?? 0) >= 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    'Simulation #${sim.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Completed on $date'),
                      const SizedBox(height: 4),
                      Text(
                        'P&L: ${sim.total_pnl_pct?.toStringAsFixed(2) ?? '0.00'}%',
                        style: TextStyle(
                          color: isProfit ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    context.push('${AppConstants.analysisResultsRoute}?id=${sim.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
