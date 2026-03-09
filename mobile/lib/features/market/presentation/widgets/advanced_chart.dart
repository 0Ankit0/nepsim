import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/market_data.dart';
import '../providers/chart_provider.dart';

class AdvancedChart extends ConsumerStatefulWidget {
  final List<MarketDataPoint> data;
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
            onTap: (ChartTapArgs args) {
              if (_isDrawingMode && args.value != null) {
                ref.read(chartDrawingsProvider(widget.symbol).notifier).addHorizontalLine(args.value!.toDouble());
                setState(() => _isDrawingMode = false);
              }
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
                SmaIndicator<MarketDataPoint, DateTime>(
                  period: 50,
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
                  valueLineColor: Colors.blue,
                ),
              if (indicators.contains('sma200'))
                SmaIndicator<MarketDataPoint, DateTime>(
                  period: 200,
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
                  valueLineColor: Colors.red,
                ),
              if (indicators.contains('boll'))
                BollingerIndicator<MarketDataPoint, DateTime>(
                  period: 20,
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
                  upperLineColor: Colors.orange.withOpacity(0.5),
                  lowerLineColor: Colors.orange.withOpacity(0.5),
                ),
              if (indicators.contains('rsi'))
                RsiIndicator<MarketDataPoint, DateTime>(
                  period: 14,
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
                  yAxisName: 'secondaryYAxis',
                  overbought: 70,
                  oversold: 30,
                ),
              if (indicators.contains('macd'))
                MacdIndicator<MarketDataPoint, DateTime>(
                  shortPeriod: 12,
                  longPeriod: 26,
                  signalPeriod: 9,
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
                  yAxisName: 'secondaryYAxis',
                ),
            ],
            series: <CartesianSeries<MarketDataPoint, DateTime>>[
              if (chartType == 'candle')
                CandleSeries<MarketDataPoint, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  lowValueMapper: (MarketDataPoint data, _) => data.low,
                  highValueMapper: (MarketDataPoint data, _) => data.high,
                  openValueMapper: (MarketDataPoint data, _) => data.open,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
                  enableSolidCandles: true,
                )
              else if (chartType == 'line')
                LineSeries<MarketDataPoint, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  yValueMapper: (MarketDataPoint data, _) => data.close,
                )
              else if (chartType == 'area')
                AreaSeries<MarketDataPoint, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  yValueMapper: (MarketDataPoint data, _) => data.close,
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.5), Colors.blue.withOpacity(0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                )
              else if (chartType == 'hloc')
                HiloOpenCloseSeries<MarketDataPoint, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (MarketDataPoint data, _) => data.date,
                  lowValueMapper: (MarketDataPoint data, _) => data.low,
                  highValueMapper: (MarketDataPoint data, _) => data.high,
                  openValueMapper: (MarketDataPoint data, _) => data.open,
                  closeValueMapper: (MarketDataPoint data, _) => data.close,
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
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
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
              if (v != null) ref.read(chartTypeProvider.notifier).state = v;
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
    final current = ref.read(selectedIndicatorsProvider);
    final next = Set<String>.from(current);
    if (enabled) {
      next.add(id);
    } else {
      next.remove(id);
    }
    ref.read(selectedIndicatorsProvider.notifier).state = next;
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
