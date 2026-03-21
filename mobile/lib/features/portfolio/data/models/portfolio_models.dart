class PortfolioItemResponse {
  final int id;
  final String symbol;
  final int quantity;
  final double avgBuyPrice;
  final String buyDate;
  final String? notes;
  final String createdAt;
  final double? currentPrice;
  final double? currentValue;
  final double costBasis;
  final double? unrealisedPnl;
  final double? unrealisedPnlPct;

  const PortfolioItemResponse({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.avgBuyPrice,
    required this.buyDate,
    this.notes,
    required this.createdAt,
    this.currentPrice,
    this.currentValue,
    required this.costBasis,
    this.unrealisedPnl,
    this.unrealisedPnlPct,
  });

  factory PortfolioItemResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioItemResponse(
      id: json['id'] as int,
      symbol: json['symbol'] as String,
      quantity: json['quantity'] as int,
      avgBuyPrice: (json['avg_buy_price'] as num).toDouble(),
      buyDate: json['buy_date'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      costBasis: (json['cost_basis'] as num).toDouble(),
      unrealisedPnl: (json['unrealised_pnl'] as num?)?.toDouble(),
      unrealisedPnlPct: (json['unrealised_pnl_pct'] as num?)?.toDouble(),
    );
  }
}

class PortfolioItemCreate {
  final String symbol;
  final int quantity;
  final double avgBuyPrice;
  final String buyDate;
  final String? notes;

  const PortfolioItemCreate({
    required this.symbol,
    required this.quantity,
    required this.avgBuyPrice,
    required this.buyDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'avg_buy_price': avgBuyPrice,
        'buy_date': buyDate,
        if (notes != null) 'notes': notes,
      };
}

class PortfolioAlertResponse {
  final int id;
  final int portfolioItemId;
  final String symbol;
  final String alertType;
  final double signalScore;
  final String analysisSummary;
  final List<String> keySignals;
  final String recommendedAction;
  final double? currentPrice;
  final String createdAt;
  final bool isRead;

  const PortfolioAlertResponse({
    required this.id,
    required this.portfolioItemId,
    required this.symbol,
    required this.alertType,
    required this.signalScore,
    required this.analysisSummary,
    required this.keySignals,
    required this.recommendedAction,
    this.currentPrice,
    required this.createdAt,
    required this.isRead,
  });

  factory PortfolioAlertResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioAlertResponse(
      id: json['id'] as int,
      portfolioItemId: json['portfolio_item_id'] as int,
      symbol: json['symbol'] as String,
      alertType: json['alert_type'] as String,
      signalScore: (json['signal_score'] as num).toDouble(),
      analysisSummary: json['analysis_summary'] as String,
      keySignals: List<String>.from(json['key_signals'] as List),
      recommendedAction: json['recommended_action'] as String,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
      isRead: json['is_read'] as bool,
    );
  }
}
