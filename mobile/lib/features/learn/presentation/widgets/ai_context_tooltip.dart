import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/dio_provider.dart';

class AiContextTooltip extends ConsumerWidget {
  final Widget child;
  final String term;

  const AiContextTooltip({super.key, required this.child, required this.term});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () => _showTooltip(context, ref),
      child: child,
    );
  }

  void _showTooltip(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AiExplanationSheet(term: term),
    );
  }
}

class _AiExplanationSheet extends ConsumerStatefulWidget {
  final String term;
  const _AiExplanationSheet({required this.term});

  @override
  ConsumerState<_AiExplanationSheet> createState() => _AiExplanationSheetState();
}

class _AiExplanationSheetState extends ConsumerState<_AiExplanationSheet> {
  String? _explanation;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExplanation();
  }

  Future<void> _fetchExplanation() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get(
        ApiEndpoints.aiInsights,
        queryParameters: {'term': widget.term},
      );
      if (mounted) {
        setState(() {
          _explanation = response.data['explanation'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI Insights: ${widget.term}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (_error != null)
               Text('Could not load explanation: $_error', style: const TextStyle(color: Colors.red))
            else
              Text(
                _explanation ?? 'No explanation found.',
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
