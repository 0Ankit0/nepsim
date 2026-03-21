import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/watchlist_provider.dart';
import '../../data/models/watchlist_models.dart';

class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage> {
  bool _isChecking = false;
  List<WatchlistAlertResponse> _latestAlerts = [];

  Future<void> _checkSignals() async {
    setState(() => _isChecking = true);
    try {
      final alerts = await ref.read(watchlistNotifierProvider.notifier).checkSignals();
      if (mounted) {
        setState(() {
          _latestAlerts = alerts;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signal check failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddItemSheet() {
    final symbolController = TextEditingController();
    final targetController = TextEditingController();
    final stopController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add to Watchlist',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: symbolController,
                decoration: const InputDecoration(labelText: 'Symbol', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: targetController,
                decoration: const InputDecoration(
                    labelText: 'Target Price (optional)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stopController,
                decoration: const InputDecoration(
                    labelText: 'Stop Loss (optional)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.of(ctx).pop();
                  try {
                    await ref.read(watchlistNotifierProvider.notifier).addItem(
                          WatchlistItemCreate(
                            symbol: symbolController.text.toUpperCase().trim(),
                            targetPrice: targetController.text.isEmpty
                                ? null
                                : double.tryParse(targetController.text),
                            stopLoss: stopController.text.isEmpty
                                ? null
                                : double.tryParse(stopController.text),
                            notes: notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          ),
                        );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _alertColor(String alertType) {
    switch (alertType) {
      case 'BUY_STRONG':
        return Colors.green;
      case 'BUY_CONSIDER':
        return Colors.blue;
      case 'ACCUMULATE':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistNotifierProvider);
    final alertsAsync = ref.watch(watchlistAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          _isChecking
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.search_outlined),
                  tooltip: 'Check Signals',
                  onPressed: _checkSignals,
                ),
        ],
      ),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final alerts = _latestAlerts.isNotEmpty
              ? _latestAlerts
              : (alertsAsync.asData?.value ?? []);
          final buyAlerts = alerts.where((a) => !a.isRead).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(watchlistNotifierProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (buyAlerts.isNotEmpty) ...[
                  Text('Buy Signals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...buyAlerts.map((alert) => Card(
                        color: _alertColor(alert.alertType).withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: _alertColor(alert.alertType), width: 1),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _alertColor(alert.alertType),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      alert.alertType.replaceAll('_', ' '),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(alert.symbol,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const Spacer(),
                                  Text(
                                      'Score: ${alert.signalScore.toStringAsFixed(1)}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(alert.analysisSummary,
                                  style: const TextStyle(fontSize: 13)),
                              if (alert.entryPrice != null ||
                                  alert.targetPrice != null ||
                                  alert.stopLossPrice != null) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    if (alert.entryPrice != null)
                                      Text(
                                          'Entry: Rs.${alert.entryPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    if (alert.targetPrice != null)
                                      Text(
                                          'Target: Rs.${alert.targetPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600)),
                                    if (alert.stopLossPrice != null)
                                      Text(
                                          'Stop: Rs.${alert.stopLossPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
                Text('Watching (${items.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Nothing in watchlist. Tap + to add.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ...items.map((item) {
                  final diffPct = item.diffPct;
                  final isUp = (diffPct ?? 0) >= 0;
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(item.symbol,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const Spacer(),
                                    if (item.currentPrice != null)
                                      Text(
                                          'Rs.${item.currentPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (diffPct != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isUp
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${isUp ? '+' : ''}${diffPct.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: isUp
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    if (item.targetPrice != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                          'Target: Rs.${item.targetPrice!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600])),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Remove from watchlist?'),
                                  content: Text(
                                      'Remove ${item.symbol} from your watchlist?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Remove',
                                            style: TextStyle(
                                                color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await ref
                                      .read(watchlistNotifierProvider.notifier)
                                      .removeItem(item.id);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
