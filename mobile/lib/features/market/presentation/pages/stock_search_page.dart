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
                hintText: 'Search symbol...',
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
            return const Center(child: Text('No symbols found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: stocks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final symbol = stocks[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                    'Tap to view interactive chart and trade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    context.push('${AppConstants.stockDetailRoute}?symbol=$symbol');
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
