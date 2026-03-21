import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_models.dart';
import '../providers/analysis_provider.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

extension _Fmt on double? {
  String fmt([int dec = 2]) => this == null ? '—' : this!.toStringAsFixed(dec);
  String fmtPct([int dec = 2]) {
    if (this == null) return '—';
    return '${this! >= 0 ? '+' : ''}${this!.toStringAsFixed(dec)}%';
  }
}

Color _signalColor(String signal) {
  switch (signal) {
    case 'STRONG_BUY': return const Color(0xFF059669);
    case 'BUY':        return const Color(0xFF16A34A);
    case 'HOLD':       return const Color(0xFFD97706);
    case 'SELL':       return const Color(0xFFEA580C);
    case 'STRONG_SELL': return const Color(0xFFDC2626);
    default:           return const Color(0xFF6B7280);
  }
}

Color _indColor(String sig) {
  if (sig == 'BULLISH') return const Color(0xFF059669);
  if (sig == 'BEARISH') return const Color(0xFFDC2626);
  return const Color(0xFF6B7280);
}

// ─── Score bar widget ─────────────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScoreBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            Text('${value.toStringAsFixed(0)}/100', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─── Indicator card widget ────────────────────────────────────────────────────

class _IndicatorCard extends StatefulWidget {
  final IndicatorSignalItem ind;
  const _IndicatorCard({required this.ind});

  @override
  State<_IndicatorCard> createState() => _IndicatorCardState();
}

class _IndicatorCardState extends State<_IndicatorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final col = _indColor(widget.ind.signal);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: col, width: 3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.ind.signal == 'BULLISH' ? Icons.trending_up :
                    widget.ind.signal == 'BEARISH' ? Icons.trending_down : Icons.remove,
                    color: col, size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.ind.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  if (widget.ind.value != null)
                    Text(widget.ind.value!.toStringAsFixed(2), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(width: 8),
                  Text(widget.ind.signal, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: col)),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Colors.grey[400]),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                Text(widget.ind.interpretation, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Similar period card ──────────────────────────────────────────────────────

class _SimilarPeriodCard extends StatelessWidget {
  final SimilarPeriod period;
  const _SimilarPeriodCard({required this.period});

  @override
  Widget build(BuildContext context) {
    final outColor = period.outcome == 'BULLISH'
        ? const Color(0xFF059669)
        : period.outcome == 'BEARISH'
        ? const Color(0xFFDC2626)
        : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${period.startDate} → ${period.endDate}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Similarity: ${period.similarityScore.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: outColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(period.outcome, style: TextStyle(fontSize: 10, color: outColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
              if (period.forward30dReturnPct != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('30d after', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    Text(period.forward30dReturnPct!.fmtPct(),
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold,
                          color: period.forward30dReturnPct! >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        )),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(period.description, style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4)),
        ],
      ),
    );
  }
}

// ─── Sparkline painter (simple price line) ───────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<PricePoint> history;
  final Color color;

  _SparklinePainter(this.history, {this.color = const Color(0xFF3B82F6)});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;
    final prices = history.map((p) => p.ltp ?? p.close ?? 0.0).where((v) => v > 0).toList();
    if (prices.length < 2) return;

    final minP = prices.reduce(math.min);
    final maxP = prices.reduce(math.max);
    final range = maxP - minP;
    if (range == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = i / (prices.length - 1) * size.width;
      final y = size.height - ((prices[i] - minP) / range) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.history != history;
}

// ─── Main page ────────────────────────────────────────────────────────────────

class Stock360Page extends ConsumerStatefulWidget {
  const Stock360Page({super.key});

  @override
  ConsumerState<Stock360Page> createState() => _Stock360PageState();
}

class _Stock360PageState extends ConsumerState<Stock360Page> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  String _activeSymbol = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _search() {
    final sym = _controller.text.trim().toUpperCase();
    if (sym.isNotEmpty) {
      setState(() => _activeSymbol = sym);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Stock 360° View'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter symbol (NABIL, NICA, SCB...)',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Go'),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: _activeSymbol.isEmpty
                ? _buildEmptyState()
                : _buildStockView(_activeSymbol),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Search for a NEPSE stock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Get full historic analysis, indicators,\ntrend view, and similar patterns',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildStockView(String symbol) {
    final asyncData = ref.watch(stock360Provider(symbol));

    return asyncData.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Analyzing $symbol…', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text('Loading full history & running analysis', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text('Symbol "$symbol" not found', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Check the symbol and try again', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(stock360Provider(symbol)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (data) => _buildContent(data),
    );
  }

  Widget _buildContent(Stock360Response data) {
    return Column(
      children: [
        // Compact header
        _buildHeader(data),
        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF2563EB),
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Indicators'),
              Tab(text: 'Trends'),
              Tab(text: 'Patterns'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(data),
              _buildIndicatorsTab(data),
              _buildTrendTab(data),
              _buildPatternsTab(data),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Stock360Response data) {
    final col = _signalColor(data.signal);
    final change = data.changePct ?? 0.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(data.signal.replaceAll('_', ' '), style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Rs. ${data.currentPrice.fmt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(change.fmtPct(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: change >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                  ],
                ),
                Text('As of ${data.analysisDate}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Score', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text(data.overallScore.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              Text('/100', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }

  // ── Overview tab ─────────────────────────────────────────────────────────

  Widget _buildOverviewTab(Stock360Response data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sparkline
        if (data.priceHistory.isNotEmpty) ...[
          _card(
            title: 'Price History',
            child: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _SparklinePainter(
                  data.priceHistory,
                  color: data.trendAnalysis.primaryTrend.contains('UP')
                      ? Colors.green
                      : data.trendAnalysis.primaryTrend.contains('DOWN')
                          ? Colors.red
                          : const Color(0xFF3B82F6),
                ),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Key stats
        _card(
          title: 'Snapshot',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip('Open', 'Rs. ${data.openPrice.fmt()}'),
              _statChip('High', 'Rs. ${data.highPrice.fmt()}'),
              _statChip('Low', 'Rs. ${data.lowPrice.fmt()}'),
              _statChip('Prev Close', 'Rs. ${data.prevClose.fmt()}'),
              _statChip('VWAP', 'Rs. ${data.vwap.fmt()}'),
              _statChip('52W High', 'Rs. ${data.week52High.fmt()}'),
              _statChip('52W Low', 'Rs. ${data.week52Low.fmt()}'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Score breakdown
        _card(
          title: 'Score Breakdown',
          child: Column(
            children: [
              _ScoreBar(label: 'Oscillator', value: data.oscillatorScore, color: const Color(0xFF8B5CF6)),
              const SizedBox(height: 10),
              _ScoreBar(label: 'Trend', value: data.trendScore, color: const Color(0xFF3B82F6)),
              const SizedBox(height: 10),
              _ScoreBar(label: 'Volume', value: data.volumeScore, color: const Color(0xFFF59E0B)),
              const SizedBox(height: 10),
              _ScoreBar(label: 'Volatility', value: data.volatilityScore, color: const Color(0xFFEF4444)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Trading levels
        if (data.entryPrice != null)
          _card(
            title: 'Trading Levels',
            child: Column(
              children: [
                _levelRow('Entry', data.entryPrice.fmt(), const Color(0xFF6B7280)),
                _levelRow('Target', data.targetPrice.fmt(), const Color(0xFF059669)),
                _levelRow('Stop Loss', data.stopLoss.fmt(), const Color(0xFFDC2626)),
                _levelRow('Risk:Reward', '${data.riskRewardRatio.fmt()}x', const Color(0xFF2563EB)),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Performance
        _card(
          title: 'Performance',
          child: Column(
            children: [
              _perfRow('1 Week', data.performance.week1Pct),
              _perfRow('1 Month', data.performance.month1Pct),
              _perfRow('3 Months', data.performance.month3Pct),
              _perfRow('6 Months', data.performance.month6Pct),
              _perfRow('1 Year', data.performance.year1Pct),
              _perfRow('Year to Date', data.performance.ytdPct),
              if (data.performance.maxDrawdownPct != null)
                _twoCol('Max Drawdown', '-${data.performance.maxDrawdownPct!.toStringAsFixed(2)}%', color: const Color(0xFFDC2626)),
              if (data.performance.volatility20dAnnualized != null)
                _twoCol('Volatility (20d ann.)', '${data.performance.volatility20dAnnualized!.toStringAsFixed(2)}%'),
            ],
          ),
        ),

        // Key signals
        if (data.keySignals.isNotEmpty) ...[
          const SizedBox(height: 12),
          _card(
            title: 'Key Signals',
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: data.keySignals.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                child: Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // ── Indicators tab ────────────────────────────────────────────────────────

  Widget _buildIndicatorsTab(Stock360Response data) {
    final bullish = data.indicatorSignals.where((i) => i.signal == 'BULLISH').toList();
    final bearish = data.indicatorSignals.where((i) => i.signal == 'BEARISH').toList();
    final neutral = data.indicatorSignals.where((i) => i.signal == 'NEUTRAL').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary pills
        Row(
          children: [
            _countPill('${bullish.length} Bullish', const Color(0xFF059669)),
            const SizedBox(width: 8),
            _countPill('${bearish.length} Bearish', const Color(0xFFDC2626)),
            const SizedBox(width: 8),
            _countPill('${neutral.length} Neutral', const Color(0xFF6B7280)),
          ],
        ),
        const SizedBox(height: 16),
        ...data.indicatorSignals.map((ind) => _IndicatorCard(ind: ind)),
      ],
    );
  }

  // ── Trend tab ─────────────────────────────────────────────────────────────

  Widget _buildTrendTab(Stock360Response data) {
    final t = data.trendAnalysis;
    final trendColor = t.primaryTrend == 'UPTREND'
        ? const Color(0xFF059669)
        : t.primaryTrend == 'DOWNTREND'
        ? const Color(0xFFDC2626)
        : const Color(0xFF6B7280);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Primary trend banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: trendColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: trendColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                t.primaryTrend == 'UPTREND' ? Icons.trending_up :
                t.primaryTrend == 'DOWNTREND' ? Icons.trending_down : Icons.trending_flat,
                color: trendColor, size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.primaryTrend, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: trendColor)),
                  Text('${t.trendStrength} · MA Alignment: ${t.maAlignment}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cross signals
        if (t.goldenCross)
          _infoBanner('✅ Golden Cross active: SMA50 above SMA200', const Color(0xFF059669)),
        if (t.deathCross)
          _infoBanner('⚠️ Death Cross active: SMA50 below SMA200', const Color(0xFFDC2626)),
        if (t.ichimokuSignal != null)
          _infoBanner('Ichimoku Cloud: ${t.ichimokuSignal}', _indColor(t.ichimokuSignal!)),

        const SizedBox(height: 12),

        // Support / Resistance
        _card(
          title: 'Key Levels',
          child: Column(
            children: [
              _levelRow('Support', 'Rs. ${t.supportLevel.fmt()}', const Color(0xFF059669)),
              _levelRow('Resistance', 'Rs. ${t.resistanceLevel.fmt()}', const Color(0xFFDC2626)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // MA Position
        _card(
          title: 'Price vs Moving Averages',
          child: Column(
            children: [
              _maRow('SMA 20', t.priceVsSma20),
              _maRow('SMA 50', t.priceVsSma50),
              _maRow('SMA 200', t.priceVsSma200),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Summary text
        _card(
          title: 'Analysis Summary',
          child: Text(t.summary, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
        ),
      ],
    );
  }

  // ── Patterns tab ──────────────────────────────────────────────────────────

  Widget _buildPatternsTab(Stock360Response data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Text(
            '⚠️ Disclaimer: Past patterns are not guaranteed to repeat. Use as one input among many — not financial advice.',
            style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        if (data.similarPeriods.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Not enough historical data to find similar patterns',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
            ),
          )
        else ...[
          Text('${data.similarPeriods.length} similar historical periods found',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...data.similarPeriods.map((p) => _SimilarPeriodCard(period: p)),
        ],
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _levelRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _perfRow(String label, double? val) {
    if (val == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const Text('—', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(val.fmtPct(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: val >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626))),
        ],
      ),
    );
  }

  Widget _twoCol(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? const Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _countPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _maRow(String label, String? pos) {
    final col = pos == 'ABOVE' ? const Color(0xFF059669) : pos == 'BELOW' ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(pos ?? '—', style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
