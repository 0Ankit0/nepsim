import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/analysis_provider.dart';
import '../../data/models/analysis.dart';

class AnalysisLoadingPage extends ConsumerWidget {
  final int simulationId;

  const AnalysisLoadingPage({super.key, required this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AIAnalysisResponse>>(
      aiAnalysisProvider(simulationId),
      (previous, next) {
        next.when(
          data: (analysis) {
            // Once data is available, redirect to results page
            context.go('${AppConstants.analysisResultsRoute}?id=$simulationId');
          },
          error: (error, stack) {
            if (error is AnalysisProcessingException) {
              // Ignore this error, it's just telling us to wait
              // We want to poll every few seconds
              Future.delayed(const Duration(seconds: 3), () {
                if (context.mounted) {
                  ref.invalidate(aiAnalysisProvider(simulationId));
                }
              });
            } else {
              // Provide visual error or popup
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load analysis: $error')));
            }
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'AI is analyzing your trades...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Evaluating your timing, risk management, and stock selection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
