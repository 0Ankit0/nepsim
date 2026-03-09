import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/progress.dart';

class SkillRadarChart extends StatelessWidget {
  final UserProgress progress;

  const SkillRadarChart({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(enabled: false),
          dataSets: [
            RadarDataSet(
              fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderColor: Theme.of(context).colorScheme.primary,
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: progress.timingScore),
                RadarEntry(value: progress.selectionScore),
                RadarEntry(value: progress.riskScore),
                RadarEntry(value: progress.patienceScore),
              ],
              borderWidth: 2,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          getTitle: (index, angle) {
            switch (index) {
              case 0:
                return const RadarChartTitle(text: 'Timing');
              case 1:
                return const RadarChartTitle(text: 'Selection');
              case 2:
                return const RadarChartTitle(text: 'Risk Mgmt');
              case 3:
                return const RadarChartTitle(text: 'Patience');
              default:
                return const RadarChartTitle(text: '');
            }
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
          tickBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          gridBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.5),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
