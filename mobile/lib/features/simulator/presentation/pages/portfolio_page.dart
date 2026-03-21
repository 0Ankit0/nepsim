import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/simulator_provider.dart';

class PortfolioPage extends ConsumerWidget {
  final int simulationId;

  const PortfolioPage({super.key, required this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simAsync = ref.watch(simulationDetailProvider(simulationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Holdings'),
      ),
      body: simAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (sim) {
          final holdings = sim.holdings ?? [];
          if (holdings.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No active holdings in this portfolio yet. Start trading to see them here!', textAlign: TextAlign.center),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: holdings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final holding = holdings[index];
              if (holding.quantity == 0) return const SizedBox.shrink(); // Hide zero quantity
              
              final currentVal = holding.quantity * (holding.current_price ?? 0.0);
              final costBasis = holding.quantity * holding.average_buy_price;
              final pnl = currentVal - costBasis;
              final pnlPct = costBasis > 0 ? (pnl / costBasis) * 100 : 0.0;
              final isPositive = pnl >= 0;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(holding.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                            'Rs. ${currentVal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shares: ${holding.quantity}', style: TextStyle(color: Colors.grey[700])),
                              Text('Avg Price: Rs. ${holding.average_buy_price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Return', style: TextStyle(fontSize: 12)),
                              Text(
                                '${isPositive ? '+' : ''}Rs. ${pnl.toStringAsFixed(2)} (${pnlPct.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: isPositive ? Colors.green[700] : Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
