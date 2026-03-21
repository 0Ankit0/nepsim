import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/portfolio_provider.dart';
import '../../data/models/portfolio_models.dart';

class UserPortfolioPage extends ConsumerStatefulWidget {
  const UserPortfolioPage({super.key});

  @override
  ConsumerState<UserPortfolioPage> createState() => _UserPortfolioPageState();
}

class _UserPortfolioPageState extends ConsumerState<UserPortfolioPage> {
  bool _isAnalyzing = false;
  List<PortfolioAlertResponse> _latestAlerts = [];

  Future<void> _analyzeAll() async {
    setState(() => _isAnalyzing = true);
    try {
      final alerts = await ref.read(portfolioNotifierProvider.notifier).analyzeAll();
      if (mounted) {
        setState(() {
          _latestAlerts = alerts;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddItemSheet() {
    final symbolController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
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
              Text('Add to Portfolio',
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
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter valid quantity' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Avg Buy Price', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid price' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Buy Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.of(ctx).pop();
                  try {
                    await ref.read(portfolioNotifierProvider.notifier).addItem(
                          PortfolioItemCreate(
                            symbol: symbolController.text.toUpperCase().trim(),
                            quantity: int.parse(quantityController.text),
                            avgBuyPrice: double.parse(priceController.text),
                            buyDate: dateController.text,
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
      case 'SELL_STRONG':
        return Colors.red;
      case 'SELL_CONSIDER':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioNotifierProvider);
    final alertsAsync = ref.watch(portfolioAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        actions: [
          _isAnalyzing
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  tooltip: 'Analyze All',
                  onPressed: _analyzeAll,
                ),
        ],
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final totalCost = items.fold<double>(0, (s, i) => s + i.costBasis);
          final totalValue =
              items.fold<double>(0, (s, i) => s + (i.currentValue ?? i.costBasis));
          final totalPnl = totalValue - totalCost;

          final alerts = _latestAlerts.isNotEmpty
              ? _latestAlerts
              : (alertsAsync.asData?.value ?? []);
          final unreadAlerts = alerts.where((a) => !a.isRead).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(portfolioNotifierProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(label: 'Cost Basis', value: 'Rs. ${totalCost.toStringAsFixed(0)}'),
                        _SummaryItem(label: 'Current Value', value: 'Rs. ${totalValue.toStringAsFixed(0)}'),
                        _SummaryItem(
                          label: 'Total P&L',
                          value:
                              '${totalPnl >= 0 ? '+' : ''}Rs. ${totalPnl.toStringAsFixed(0)}',
                          valueColor: totalPnl >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Alerts section
                if (unreadAlerts.isNotEmpty) ...[
                  Text('Sell Alerts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...unreadAlerts.map((alert) => Card(
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
                              const SizedBox(height: 4),
                              Text('Action: ${alert.recommendedAction}',
                                  style: TextStyle(
                                      color: _alertColor(alert.alertType),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
                // Holdings
                Text('Holdings (${items.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No holdings yet. Tap + to add.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ...items.map((item) {
                  final pnl = item.unrealisedPnl;
                  final pnlPct = item.unrealisedPnlPct;
                  final isProfit = (pnl ?? 0) >= 0;
                  final pnlColor = isProfit ? Colors.green : Colors.red;

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
                                    const SizedBox(width: 8),
                                    Text('×${item.quantity}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Avg Rs.${item.avgBuyPrice.toStringAsFixed(2)} → ${item.currentPrice != null ? 'Rs.${item.currentPrice!.toStringAsFixed(2)}' : 'N/A'}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                if (pnl != null && pnlPct != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${isProfit ? '+' : ''}Rs.${pnl.toStringAsFixed(0)} (${isProfit ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
                                    style: TextStyle(
                                        color: pnlColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ],
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
                                  title: const Text('Remove holding?'),
                                  content: Text(
                                      'Remove ${item.symbol} from your portfolio?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Remove',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await ref
                                      .read(portfolioNotifierProvider.notifier)
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: valueColor)),
      ],
    );
  }
}
