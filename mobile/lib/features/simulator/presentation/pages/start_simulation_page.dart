import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/simulator_provider.dart';

class StartSimulationPage extends ConsumerStatefulWidget {
  const StartSimulationPage({super.key});

  @override
  ConsumerState<StartSimulationPage> createState() => _StartSimulationPageState();
}

class _StartSimulationPageState extends ConsumerState<StartSimulationPage> {
  final _capitalController = TextEditingController(text: '1000000');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _capitalController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    if (!_formKey.currentState!.validate()) return;
    final capital = double.tryParse(_capitalController.text);
    if (capital == null || capital <= 0) return;

    setState(() => _isLoading = true);
    try {
      final sim = await ref.read(simulatorListProvider.notifier).startSimulation(capital);
      setState(() => _isLoading = false);
      if (mounted) {
        context.go('${AppConstants.tradingRoute}?id=${sim.id}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final simulationsAsync = ref.watch(simulatorListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppConstants.notificationsRoute),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppConstants.profileRoute),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.query_stats, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'NEPSE Market Simulator',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Test out your trading strategies using historical NEPSE data without risking real money.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulation Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _capitalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Initial Capital (NPR)',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter capital';
                          final n = double.tryParse(val);
                          if (n == null) return 'Must be a number';
                          if (n < 10000) return 'Minimum capital is \u20b910,000';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleStart,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Start New Simulation', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            simulationsAsync.when(
              data: (sims) {
                final activeSims = sims.where((s) => s.status == 'active').toList();
                if (activeSims.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Sessions', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...activeSims.map((sim) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_fill, color: Colors.green),
                        title: Text('Simulation #${sim.id}'),
                        subtitle: Text('Capital: Rs. ${sim.initial_capital}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          context.go('${AppConstants.tradingRoute}?id=${sim.id}');
                        },
                      ),
                    )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading active sessions: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
