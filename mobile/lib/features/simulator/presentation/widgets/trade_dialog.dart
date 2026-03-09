import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../market/data/models/stock.dart';
import '../providers/simulator_provider.dart';
import '../../data/repositories/simulator_repository.dart';

class TradeDialog extends ConsumerStatefulWidget {
  final int simulationId;
  final StockMetadata stock;
  final String side; // 'buy' or 'sell'

  const TradeDialog({
    super.key,
    required this.simulationId,
    required this.stock,
    required this.side,
  });

  @override
  ConsumerState<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends ConsumerState<TradeDialog> {
  final _quantityController = TextEditingController(text: '10');
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _executeTrade() async {
    final qty = int.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) return;

    setState(() => _isLoading = true);
    try {
      // NOTE: executeTrade doesn't exist on SimulatorListProvider yet, we will call repository directly or create provider method
      final repository = ref.read(simulatorRepositoryProvider);
      await repository.executeTrade(
        widget.simulationId,
        widget.stock.symbol,
        widget.side,
        qty,
      );
      // Invalidate simulation details so it fetches the new balance
      ref.invalidate(simulationDetailProvider(widget.simulationId));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trade failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    final price = widget.stock.currentPrice ?? 0.0;
    
    // Simplistic cost breakdown (SEBON fee + broker roughly 0.6%)
    final baseCost = qty * price;
    final commission = baseCost * 0.005; 
    final sebonFee = baseCost * 0.00015;
    final totalCost = widget.side == 'buy' 
        ? baseCost + commission + sebonFee
        : baseCost - commission - sebonFee;

    final isBuy = widget.side == 'buy';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24, left: 24, right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isBuy ? 'Buy' : 'Sell'} ${widget.stock.symbol}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity (shares)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          const Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _Row('Current Price', 'Rs. ${price.toStringAsFixed(2)}'),
          _Row('Base ${isBuy ? "Cost" : "Value"}', 'Rs. ${baseCost.toStringAsFixed(2)}'),
          _Row('Broker Commission (Est)', 'Rs. ${commission.toStringAsFixed(2)}'),
          _Row('SEBON + DP Fee', 'Rs. ${sebonFee.toStringAsFixed(2)}'),
          const Divider(),
          _Row('Total Estimated ${isBuy ? "Cost" : "Return"}', 'Rs. ${totalCost.toStringAsFixed(2)}', isBold: true),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBuy ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: (qty > 0 && !_isLoading) ? _executeTrade : null,
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('CONFIRM ${isBuy ? 'BUY' : 'SELL'}'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _Row(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
