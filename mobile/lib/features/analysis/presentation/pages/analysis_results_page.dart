import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/analysis_provider.dart';
import '../../data/models/analysis.dart';

class AnalysisResultsPage extends ConsumerWidget {
  final int simulationId;

  const AnalysisResultsPage({super.key, required this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(aiAnalysisProvider(simulationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Performance Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('${AppConstants.tradeTimelineRoute}?id=$simulationId');
            },
            tooltip: 'Trade Timeline',
          ),
        ],
      ),
      body: aiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load analysis: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(aiAnalysisProvider(simulationId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (analysis) {
          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Summary'),
                    Tab(text: 'Right'),
                    Tab(text: 'Wrong'),
                    Tab(text: 'Could Have Done'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _SummaryTab(analysis: analysis),
                      _SectionTab(sections: analysis.whatYouDidRight, emptyMessage: 'No positive feedback provided.'),
                      _SectionTab(sections: analysis.whatYouDidWrong, emptyMessage: 'No negative feedback provided.'),
                      _SectionTab(sections: analysis.whatYouCouldHaveDone, emptyMessage: 'No alternative suggestions provided.'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final AIAnalysisResponse analysis;

  const _SummaryTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Skill radars / scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreCircle(label: 'Timing', score: analysis.timingScore),
              _ScoreCircle(label: 'Selection', score: analysis.selectionScore),
              _ScoreCircle(label: 'Risk', score: analysis.riskScore),
              _ScoreCircle(label: 'Patience', score: analysis.patienceScore),
            ],
          ),
          const SizedBox(height: 24),
          
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    analysis.summaryNarrative ?? 'No summary generated.',
                    style: const TextStyle(height: 1.5, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Metrics section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Key Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _MetricRow('Total Return', '${analysis.totalPnlPct?.toStringAsFixed(2) ?? 0}%'),
                  _MetricRow('Win Rate', '${analysis.winRate?.toStringAsFixed(1) ?? 0}%'),
                  _MetricRow('Sharpe Ratio', analysis.sharpeRatio?.toStringAsFixed(2) ?? 'N/A'),
                  _MetricRow('Max Drawdown', '${analysis.maxDrawdown?.toStringAsFixed(2) ?? 0}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final String label;
  final int? score;

  const _ScoreCircle({required this.label, this.score});

  @override
  Widget build(BuildContext context) {
    final s = score ?? 0;
    final color = s >= 80 ? Colors.green : (s >= 50 ? Colors.orange : Colors.red);
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: s / 100,
                color: color,
                backgroundColor: Colors.grey[200],
                strokeWidth: 8,
              ),
              Center(
                child: Text('$s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  final List<AnalysisSection>? sections;
  final String emptyMessage;

  const _SectionTab({required this.sections, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (sections == null || sections!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(emptyMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sections!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sec = sections![index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(sec.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(sec.detail, style: const TextStyle(height: 1.5)),
                if (sec.impactPct != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('Impact: ${sec.impactPct! > 0 ? "+" : ""}${sec.impactPct}% P&L', style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
