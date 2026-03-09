import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/market_provider.dart';

class StockSearchPage extends ConsumerWidget {
  const StockSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredStocksAsync = ref.watch(filteredStockListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search symbol or company...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                ref.read(stockSearchQueryProvider.notifier).updateQuery(val);
              },
            ),
          ),
        ),
      ),
      body: filteredStocksAsync.when(
        data: (stocks) {
          if (stocks.isEmpty) {
            return const Center(child: Text('No stocks found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: stocks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              final price = stock.currentPrice ?? 0.0;
              final change = stock.changePct ?? 0.0;
              final isPositive = change >= 0;

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    stock.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rs. ${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green[700] : Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to stock detail
                    context.push('${AppConstants.stockDetailRoute}?symbol=${stock.symbol}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
