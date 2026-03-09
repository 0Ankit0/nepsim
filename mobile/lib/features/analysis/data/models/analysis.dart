class TradeCommentary {
  final int tradeId;
  final String symbol;
  final String side;
  final String simDate;
  final String commentary;
  final int? qualityScore;

  const TradeCommentary({
    required this.tradeId,
    required this.symbol,
    required this.side,
    required this.simDate,
    required this.commentary,
    this.qualityScore,
  });

  factory TradeCommentary.fromJson(Map<String, dynamic> json) {
    return TradeCommentary(
      tradeId: json['trade_id'] as int,
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      simDate: json['sim_date'] as String,
      commentary: json['commentary'] as String,
      qualityScore: json['quality_score'] as int?,
    );
  }
}

class AnalysisSection {
  final String title;
  final String detail;
  final List<int>? tradeIds;
  final double? impactPct;

  const AnalysisSection({
    required this.title,
    required this.detail,
    this.tradeIds,
    this.impactPct,
  });

  factory AnalysisSection.fromJson(Map<String, dynamic> json) {
    return AnalysisSection(
      title: json['title'] as String,
      detail: json['detail'] as String,
      tradeIds: (json['trade_ids'] as List?)?.map((e) => e as int).toList(),
      impactPct: (json['impact_pct'] as num?)?.toDouble(),
    );
  }
}

class AIAnalysisResponse {
  final int id;
  final int simulationId;
  final String status;
  
  final double? totalPnl;
  final double? totalPnlPct;
  final double? winRate;
  final double? sharpeRatio;
  final double? maxDrawdown;
  final int? totalTrades;
  final int? winningTrades;
  final int? losingTrades;
  final double? bestTradePnl;
  final double? worstTradePnl;
  final double? avgHoldingDays;
  
  final double? marketReturnPct;
  final double? buyHoldReturnPct;
  
  final String? summaryNarrative;
  final List<AnalysisSection>? whatYouDidRight;
  final List<AnalysisSection>? whatYouDidWrong;
  final List<AnalysisSection>? whatYouCouldHaveDone;
  final List<TradeCommentary>? tradeByTradeCommentary;
  
  final int? timingScore;
  final int? selectionScore;
  final int? riskScore;
  final int? patienceScore;
  
  final String? llmProvider;
  final String createdAt;
  final String? completedAt;

  const AIAnalysisResponse({
    required this.id,
    required this.simulationId,
    required this.status,
    this.totalPnl,
    this.totalPnlPct,
    this.winRate,
    this.sharpeRatio,
    this.maxDrawdown,
    this.totalTrades,
    this.winningTrades,
    this.losingTrades,
    this.bestTradePnl,
    this.worstTradePnl,
    this.avgHoldingDays,
    this.marketReturnPct,
    this.buyHoldReturnPct,
    this.summaryNarrative,
    this.whatYouDidRight,
    this.whatYouDidWrong,
    this.whatYouCouldHaveDone,
    this.tradeByTradeCommentary,
    this.timingScore,
    this.selectionScore,
    this.riskScore,
    this.patienceScore,
    this.llmProvider,
    required this.createdAt,
    this.completedAt,
  });

  factory AIAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResponse(
      id: json['id'] as int,
      simulationId: json['simulation_id'] as int,
      status: json['status'] as String,
      totalPnl: (json['total_pnl'] as num?)?.toDouble(),
      totalPnlPct: (json['total_pnl_pct'] as num?)?.toDouble(),
      winRate: (json['win_rate'] as num?)?.toDouble(),
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble(),
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble(),
      totalTrades: json['total_trades'] as int?,
      winningTrades: json['winning_trades'] as int?,
      losingTrades: json['losing_trades'] as int?,
      bestTradePnl: (json['best_trade_pnl'] as num?)?.toDouble(),
      worstTradePnl: (json['worst_trade_pnl'] as num?)?.toDouble(),
      avgHoldingDays: (json['avg_holding_days'] as num?)?.toDouble(),
      marketReturnPct: (json['market_return_pct'] as num?)?.toDouble(),
      buyHoldReturnPct: (json['buy_hold_return_pct'] as num?)?.toDouble(),
      summaryNarrative: json['summary_narrative'] as String?,
      whatYouDidRight: (json['what_you_did_right'] as List?)?.map((e) => AnalysisSection.fromJson(e)).toList(),
      whatYouDidWrong: (json['what_you_did_wrong'] as List?)?.map((e) => AnalysisSection.fromJson(e)).toList(),
      whatYouCouldHaveDone: (json['what_you_could_have_done'] as List?)?.map((e) => AnalysisSection.fromJson(e)).toList(),
      tradeByTradeCommentary: (json['trade_by_trade_commentary'] as List?)?.map((e) => TradeCommentary.fromJson(e)).toList(),
      timingScore: json['timing_score'] as int?,
      selectionScore: json['selection_score'] as int?,
      riskScore: json['risk_score'] as int?,
      patienceScore: json['patience_score'] as int?,
      llmProvider: json['llm_provider'] as String?,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
    );
  }
}

class AnalysisProcessingException implements Exception {
  final String message;
  AnalysisProcessingException([this.message = 'Analysis is still being generated.']);
  
  @override
  String toString() => message;
}
