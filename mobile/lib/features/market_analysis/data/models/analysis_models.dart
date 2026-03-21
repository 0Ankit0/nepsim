class AnalysisResultResponse {
  final String symbol;
  final String signal;
  final double overallScore;
  final double oscillatorScore;
  final double trendScore;
  final double volumeScore;
  final double volatilityScore;
  final List<String> keySignals;
  final double? currentPrice;
  final double? entryPrice;
  final double? targetPrice;
  final double? stopLoss;
  final double? riskRewardRatio;
  final String analysisDate;

  const AnalysisResultResponse({
    required this.symbol,
    required this.signal,
    required this.overallScore,
    required this.oscillatorScore,
    required this.trendScore,
    required this.volumeScore,
    required this.volatilityScore,
    required this.keySignals,
    this.currentPrice,
    this.entryPrice,
    this.targetPrice,
    this.stopLoss,
    this.riskRewardRatio,
    required this.analysisDate,
  });

  factory AnalysisResultResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResultResponse(
      symbol: json['symbol'] as String,
      signal: json['signal'] as String,
      overallScore: (json['overall_score'] as num).toDouble(),
      oscillatorScore: (json['oscillator_score'] as num).toDouble(),
      trendScore: (json['trend_score'] as num).toDouble(),
      volumeScore: (json['volume_score'] as num).toDouble(),
      volatilityScore: (json['volatility_score'] as num).toDouble(),
      keySignals: List<String>.from(json['key_signals'] as List),
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      entryPrice: (json['entry_price'] as num?)?.toDouble(),
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      stopLoss: (json['stop_loss'] as num?)?.toDouble(),
      riskRewardRatio: (json['risk_reward_ratio'] as num?)?.toDouble(),
      analysisDate: json['analysis_date'] as String,
    );
  }
}

class TopStocksResponse {
  final String generatedAt;
  final int count;
  final List<AnalysisResultResponse> results;

  const TopStocksResponse({
    required this.generatedAt,
    required this.count,
    required this.results,
  });

  factory TopStocksResponse.fromJson(Map<String, dynamic> json) {
    return TopStocksResponse(
      generatedAt: json['generated_at'] as String,
      count: json['count'] as int,
      results: (json['results'] as List)
          .map((e) => AnalysisResultResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MarketOverviewResponse {
  final String date;
  final int totalAnalyzed;
  final int strongBuy;
  final int buy;
  final int hold;
  final int sell;
  final int strongSell;
  final double bullishPct;
  final double bearishPct;

  const MarketOverviewResponse({
    required this.date,
    required this.totalAnalyzed,
    required this.strongBuy,
    required this.buy,
    required this.hold,
    required this.sell,
    required this.strongSell,
    required this.bullishPct,
    required this.bearishPct,
  });

  factory MarketOverviewResponse.fromJson(Map<String, dynamic> json) {
    return MarketOverviewResponse(
      date: json['date'] as String,
      totalAnalyzed: json['total_analyzed'] as int,
      strongBuy: json['strong_buy'] as int,
      buy: json['buy'] as int,
      hold: json['hold'] as int,
      sell: json['sell'] as int,
      strongSell: json['strong_sell'] as int,
      bullishPct: (json['bullish_pct'] as num).toDouble(),
      bearishPct: (json['bearish_pct'] as num).toDouble(),
    );
  }
}

// ─── 360 View Models ─────────────────────────────────────────────────────────

class PricePoint {
  final String date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final double? ltp;
  final double? vol;
  final double? vwap;
  final double? turnover;

  const PricePoint({
    required this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.ltp,
    this.vol,
    this.vwap,
    this.turnover,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
        date: json['date'] as String,
        open: (json['open'] as num?)?.toDouble(),
        high: (json['high'] as num?)?.toDouble(),
        low: (json['low'] as num?)?.toDouble(),
        close: (json['close'] as num?)?.toDouble(),
        ltp: (json['ltp'] as num?)?.toDouble(),
        vol: (json['vol'] as num?)?.toDouble(),
        vwap: (json['vwap'] as num?)?.toDouble(),
        turnover: (json['turnover'] as num?)?.toDouble(),
      );
}

class IndicatorSignalItem {
  final String name;
  final double? value;
  final String signal; // BULLISH | BEARISH | NEUTRAL
  final String interpretation;

  const IndicatorSignalItem({
    required this.name,
    this.value,
    required this.signal,
    required this.interpretation,
  });

  factory IndicatorSignalItem.fromJson(Map<String, dynamic> json) => IndicatorSignalItem(
        name: json['name'] as String,
        value: (json['value'] as num?)?.toDouble(),
        signal: json['signal'] as String,
        interpretation: json['interpretation'] as String,
      );
}

class PerformanceMetrics {
  final double? week1Pct;
  final double? month1Pct;
  final double? month3Pct;
  final double? month6Pct;
  final double? year1Pct;
  final double? ytdPct;
  final double? maxDrawdownPct;
  final double? volatility20dAnnualized;
  final double? avgVolume20d;

  const PerformanceMetrics({
    this.week1Pct,
    this.month1Pct,
    this.month3Pct,
    this.month6Pct,
    this.year1Pct,
    this.ytdPct,
    this.maxDrawdownPct,
    this.volatility20dAnnualized,
    this.avgVolume20d,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) => PerformanceMetrics(
        week1Pct: (json['week_1_pct'] as num?)?.toDouble(),
        month1Pct: (json['month_1_pct'] as num?)?.toDouble(),
        month3Pct: (json['month_3_pct'] as num?)?.toDouble(),
        month6Pct: (json['month_6_pct'] as num?)?.toDouble(),
        year1Pct: (json['year_1_pct'] as num?)?.toDouble(),
        ytdPct: (json['ytd_pct'] as num?)?.toDouble(),
        maxDrawdownPct: (json['max_drawdown_pct'] as num?)?.toDouble(),
        volatility20dAnnualized: (json['volatility_20d_annualized'] as num?)?.toDouble(),
        avgVolume20d: (json['avg_volume_20d'] as num?)?.toDouble(),
      );
}

class SimilarPeriod {
  final String startDate;
  final String endDate;
  final double similarityScore;
  final double? forward30dReturnPct;
  final String outcome; // BULLISH | BEARISH | NEUTRAL
  final String description;

  const SimilarPeriod({
    required this.startDate,
    required this.endDate,
    required this.similarityScore,
    this.forward30dReturnPct,
    required this.outcome,
    required this.description,
  });

  factory SimilarPeriod.fromJson(Map<String, dynamic> json) => SimilarPeriod(
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String,
        similarityScore: (json['similarity_score'] as num).toDouble(),
        forward30dReturnPct: (json['forward_30d_return_pct'] as num?)?.toDouble(),
        outcome: json['outcome'] as String,
        description: json['description'] as String,
      );
}

class TrendAnalysisData {
  final String primaryTrend; // UPTREND | DOWNTREND | SIDEWAYS
  final String trendStrength; // STRONG | MODERATE | WEAK
  final String maAlignment;  // BULLISH | BEARISH | MIXED
  final double? supportLevel;
  final double? resistanceLevel;
  final String? priceVsSma20;
  final String? priceVsSma50;
  final String? priceVsSma200;
  final bool goldenCross;
  final bool deathCross;
  final String? ichimokuSignal;
  final String summary;

  const TrendAnalysisData({
    required this.primaryTrend,
    required this.trendStrength,
    required this.maAlignment,
    this.supportLevel,
    this.resistanceLevel,
    this.priceVsSma20,
    this.priceVsSma50,
    this.priceVsSma200,
    required this.goldenCross,
    required this.deathCross,
    this.ichimokuSignal,
    required this.summary,
  });

  factory TrendAnalysisData.fromJson(Map<String, dynamic> json) => TrendAnalysisData(
        primaryTrend: json['primary_trend'] as String,
        trendStrength: json['trend_strength'] as String,
        maAlignment: json['ma_alignment'] as String,
        supportLevel: (json['support_level'] as num?)?.toDouble(),
        resistanceLevel: (json['resistance_level'] as num?)?.toDouble(),
        priceVsSma20: json['price_vs_sma20'] as String?,
        priceVsSma50: json['price_vs_sma50'] as String?,
        priceVsSma200: json['price_vs_sma200'] as String?,
        goldenCross: json['golden_cross'] as bool? ?? false,
        deathCross: json['death_cross'] as bool? ?? false,
        ichimokuSignal: json['ichimoku_signal'] as String?,
        summary: json['summary'] as String,
      );
}

class Stock360Response {
  final String symbol;
  final String analysisDate;
  final double? currentPrice;
  final double? openPrice;
  final double? highPrice;
  final double? lowPrice;
  final double? volume;
  final double? turnover;
  final double? vwap;
  final double? week52High;
  final double? week52Low;
  final double? changePct;
  final double? prevClose;
  final String signal;
  final double overallScore;
  final double oscillatorScore;
  final double trendScore;
  final double volumeScore;
  final double volatilityScore;
  final List<String> keySignals;
  final double? entryPrice;
  final double? targetPrice;
  final double? stopLoss;
  final double? riskRewardRatio;
  final List<IndicatorSignalItem> indicatorSignals;
  final PerformanceMetrics performance;
  final TrendAnalysisData trendAnalysis;
  final List<SimilarPeriod> similarPeriods;
  final List<PricePoint> priceHistory;
  final String? aiSummary;

  const Stock360Response({
    required this.symbol,
    required this.analysisDate,
    this.currentPrice,
    this.openPrice,
    this.highPrice,
    this.lowPrice,
    this.volume,
    this.turnover,
    this.vwap,
    this.week52High,
    this.week52Low,
    this.changePct,
    this.prevClose,
    required this.signal,
    required this.overallScore,
    required this.oscillatorScore,
    required this.trendScore,
    required this.volumeScore,
    required this.volatilityScore,
    required this.keySignals,
    this.entryPrice,
    this.targetPrice,
    this.stopLoss,
    this.riskRewardRatio,
    required this.indicatorSignals,
    required this.performance,
    required this.trendAnalysis,
    required this.similarPeriods,
    required this.priceHistory,
    this.aiSummary,
  });

  factory Stock360Response.fromJson(Map<String, dynamic> json) => Stock360Response(
        symbol: json['symbol'] as String,
        analysisDate: json['analysis_date'] as String,
        currentPrice: (json['current_price'] as num?)?.toDouble(),
        openPrice: (json['open_price'] as num?)?.toDouble(),
        highPrice: (json['high_price'] as num?)?.toDouble(),
        lowPrice: (json['low_price'] as num?)?.toDouble(),
        volume: (json['volume'] as num?)?.toDouble(),
        turnover: (json['turnover'] as num?)?.toDouble(),
        vwap: (json['vwap'] as num?)?.toDouble(),
        week52High: (json['week_52_high'] as num?)?.toDouble(),
        week52Low: (json['week_52_low'] as num?)?.toDouble(),
        changePct: (json['change_pct'] as num?)?.toDouble(),
        prevClose: (json['prev_close'] as num?)?.toDouble(),
        signal: json['signal'] as String,
        overallScore: (json['overall_score'] as num).toDouble(),
        oscillatorScore: (json['oscillator_score'] as num).toDouble(),
        trendScore: (json['trend_score'] as num).toDouble(),
        volumeScore: (json['volume_score'] as num).toDouble(),
        volatilityScore: (json['volatility_score'] as num).toDouble(),
        keySignals: List<String>.from(json['key_signals'] as List),
        entryPrice: (json['entry_price'] as num?)?.toDouble(),
        targetPrice: (json['target_price'] as num?)?.toDouble(),
        stopLoss: (json['stop_loss'] as num?)?.toDouble(),
        riskRewardRatio: (json['risk_reward_ratio'] as num?)?.toDouble(),
        indicatorSignals: (json['indicator_signals'] as List)
            .map((e) => IndicatorSignalItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        performance: PerformanceMetrics.fromJson(json['performance'] as Map<String, dynamic>),
        trendAnalysis: TrendAnalysisData.fromJson(json['trend_analysis'] as Map<String, dynamic>),
        similarPeriods: (json['similar_periods'] as List)
            .map((e) => SimilarPeriod.fromJson(e as Map<String, dynamic>))
            .toList(),
        priceHistory: (json['price_history'] as List)
            .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        aiSummary: json['ai_summary'] as String?,
      );
}
