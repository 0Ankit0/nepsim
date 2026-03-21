import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/models/market_models.dart';
import '../providers/chart_provider.dart';

class AdvancedChart extends ConsumerStatefulWidget {
  final List<HistoricDataRow> data;
  final String symbol;

  const AdvancedChart({super.key, required this.data, required this.symbol});

  @override
  ConsumerState<AdvancedChart> createState() => _AdvancedChartState();
}

class _AdvancedChartState extends ConsumerState<AdvancedChart> {
  bool _isDrawingMode = false;

  @override
  Widget build(BuildContext context) {
    final chartType = ref.watch(chartTypeProvider);
    final indicators = ref.watch(selectedIndicatorsProvider);
    final drawingsAsync = ref.watch(chartDrawingsProvider(widget.symbol));

    return Column(
      children: [
        _buildToolBar(chartType, indicators),
        Expanded(
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            onChartTouchInteractionDown: (ChartTouchInteractionArgs args) {
              // Drawing mode via touch is not supported in this version; kept for future use
            },
            trackballBehavior: TrackballBehavior(
              enable: !_isDrawingMode,
              activationMode: ActivationMode.singleTap,
              tooltipSettings: const InteractiveTooltip(enable: true, format: 'point.x : point.y'),
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: !_isDrawingMode,
              enableDoubleTapZooming: !_isDrawingMode,
              enablePanning: !_isDrawingMode,
              zoomMode: ZoomMode.x,
            ),
            primaryXAxis: const DateTimeAxis(
              majorGridLines: MajorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            primaryYAxis: NumericAxis(
              opposedPosition: true,
              majorGridLines: const MajorGridLines(width: 0.5),
              anchorRangeToVisiblePoints: true,
              plotBands: drawingsAsync.maybeWhen(
                data: (drawings) => drawings.map((d) {
                  final y = (d['coordinates']['y'] as num).toDouble();
                  return PlotBand(
                    start: y,
                    end: y,
                    borderColor: Colors.red,
                    borderWidth: 2,
                    dashArray: const [5, 5],
                    text: 'Rs. ${y.toStringAsFixed(1)}',
                    textStyle: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  );
                }).toList(),
                orElse: () => [],
              ),
            ),
            axes: [
              if (indicators.contains('rsi') || indicators.contains('macd'))
                const NumericAxis(
                  name: 'secondaryYAxis',
                  opposedPosition: true,
                  majorGridLines: MajorGridLines(width: 0),
                  plotOffset: 10,
                  desiredIntervals: 3,
                ),
            ],
            indicators: [
              if (indicators.contains('sma50'))
                SmaIndicator<HistoricDataRow, DateTime>(
                  period: 50,
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  signalLineColor: Colors.blue,
                ),
              if (indicators.contains('sma200'))
                SmaIndicator<HistoricDataRow, DateTime>(
                  period: 200,
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  signalLineColor: Colors.red,
                ),
              if (indicators.contains('boll'))
                BollingerBandIndicator<HistoricDataRow, DateTime>(
                  period: 20,
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  upperLineColor: Colors.orange.withValues(alpha: 0.5),
                  lowerLineColor: Colors.orange.withValues(alpha: 0.5),
                ),
              if (indicators.contains('rsi'))
                RsiIndicator<HistoricDataRow, DateTime>(
                  period: 14,
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  yAxisName: 'secondaryYAxis',
                  overbought: 70,
                  oversold: 30,
                ),
              if (indicators.contains('macd'))
                MacdIndicator<HistoricDataRow, DateTime>(
                  shortPeriod: 12,
                  longPeriod: 26,
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  yAxisName: 'secondaryYAxis',
                ),
            ],
            series: <CartesianSeries<HistoricDataRow, DateTime>>[
              if (chartType == 'candle')
                CandleSeries<HistoricDataRow, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  lowValueMapper: (HistoricDataRow d, _) => d.low ?? 0,
                  highValueMapper: (HistoricDataRow d, _) => d.high ?? 0,
                  openValueMapper: (HistoricDataRow d, _) => d.open ?? 0,
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  enableSolidCandles: true,
                )
              else if (chartType == 'line')
                LineSeries<HistoricDataRow, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  yValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                )
              else if (chartType == 'area')
                AreaSeries<HistoricDataRow, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  yValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                  gradient: LinearGradient(
                    colors: [Colors.blue.withValues(alpha: 0.5), Colors.blue.withValues(alpha: 0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                )
              else if (chartType == 'hloc')
                HiloOpenCloseSeries<HistoricDataRow, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (HistoricDataRow d, _) => DateTime.parse(d.date),
                  lowValueMapper: (HistoricDataRow d, _) => d.low ?? 0,
                  highValueMapper: (HistoricDataRow d, _) => d.high ?? 0,
                  openValueMapper: (HistoricDataRow d, _) => d.open ?? 0,
                  closeValueMapper: (HistoricDataRow d, _) => d.close ?? 0,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolBar(String chartType, Set<String> indicators) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          DropdownButton<String>(
            value: chartType,
            underline: const SizedBox(),
            icon: const Icon(Icons.show_chart, size: 20),
            items: ['candle', 'line', 'area', 'hloc'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toUpperCase(), style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) ref.read(chartTypeProvider.notifier).set(v);
            },
          ),
          const VerticalDivider(width: 24),
          _buildDrawingButton(),
          const VerticalDivider(width: 24),
          _buildIndicatorToggle('SMA 50', indicators.contains('sma50'), (v) => _toggleIndicator('sma50', v)),
          _buildIndicatorToggle('SMA 200', indicators.contains('sma200'), (v) => _toggleIndicator('sma200', v)),
          _buildIndicatorToggle('BOLL', indicators.contains('boll'), (v) => _toggleIndicator('boll', v)),
          _buildIndicatorToggle('RSI', indicators.contains('rsi'), (v) => _toggleIndicator('rsi', v)),
          _buildIndicatorToggle('MACD', indicators.contains('macd'), (v) => _toggleIndicator('macd', v)),
        ],
      ),
    );
  }

  void _toggleIndicator(String id, bool enabled) {
    final notifier = ref.read(selectedIndicatorsProvider.notifier);
    if (enabled != ref.read(selectedIndicatorsProvider).contains(id)) {
      notifier.toggle(id);
    }
  }

  Widget _buildDrawingButton() {
    final hasDrawings = ref.watch(chartDrawingsProvider(widget.symbol)).maybeWhen(
      data: (d) => d.isNotEmpty,
      orElse: () => false,
    );

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: _isDrawingMode ? Colors.blue : Colors.grey, size: 20),
          onPressed: () {
            setState(() {
              _isDrawingMode = !_isDrawingMode;
            });
            if (_isDrawingMode) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Drawing Mode: Tap chart to drop a horizontal line'), duration: Duration(seconds: 2)),
              );
            }
          },
          tooltip: 'Horizontal Line',
        ),
        if (hasDrawings)
          IconButton(
            icon: const Icon(Icons.layers_clear, size: 20, color: Colors.orange),
            onPressed: () => ref.read(chartDrawingsProvider(widget.symbol).notifier).clearDrawings(),
            tooltip: 'Clear drawings',
          ),
      ],
    );
  }

  Widget _buildIndicatorToggle(String label, bool value, Function(bool) onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: value,
        onSelected: onToggle,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
