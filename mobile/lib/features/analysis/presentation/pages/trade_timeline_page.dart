import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_provider.dart';

class TradeTimelinePage extends ConsumerWidget {
  final int simulationId;

  const TradeTimelinePage({super.key, required this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(aiAnalysisProvider(simulationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Timeline'),
      ),
      body: aiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (analysis) {
          final timeline = analysis.tradeByTradeCommentary;
          if (timeline == null || timeline.isEmpty) {
            return const Center(child: Text('No trades found or no commentary available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              final isBuy = item.side.toLowerCase() == 'buy';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isBuy ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.side.toUpperCase(),
                                  style: TextStyle(
                                    color: isBuy ? Colors.green[700] : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Text(item.simDate.split('T').first, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item.commentary, style: const TextStyle(height: 1.5)),
                      if (item.qualityScore != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('Quality Score: ${item.qualityScore}/100', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ],
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
