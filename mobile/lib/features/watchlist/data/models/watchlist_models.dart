class WatchlistItemResponse {
  final int id;
  final String symbol;
  final String? notes;
  final double? targetPrice;
  final double? stopLoss;
  final String createdAt;
  final double? currentPrice;
  final double? diffPct;
  final double? weeks52High;
  final double? weeks52Low;

  const WatchlistItemResponse({
    required this.id,
    required this.symbol,
    this.notes,
    this.targetPrice,
    this.stopLoss,
    required this.createdAt,
    this.currentPrice,
    this.diffPct,
    this.weeks52High,
    this.weeks52Low,
  });

  factory WatchlistItemResponse.fromJson(Map<String, dynamic> json) {
    return WatchlistItemResponse(
      id: json['id'] as int,
      symbol: json['symbol'] as String,
      notes: json['notes'] as String?,
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      stopLoss: (json['stop_loss'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      diffPct: (json['diff_pct'] as num?)?.toDouble(),
      weeks52High: (json['weeks_52_high'] as num?)?.toDouble(),
      weeks52Low: (json['weeks_52_low'] as num?)?.toDouble(),
    );
  }
}

class WatchlistItemCreate {
  final String symbol;
  final String? notes;
  final double? targetPrice;
  final double? stopLoss;

  const WatchlistItemCreate({
    required this.symbol,
    this.notes,
    this.targetPrice,
    this.stopLoss,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        if (notes != null) 'notes': notes,
        if (targetPrice != null) 'target_price': targetPrice,
        if (stopLoss != null) 'stop_loss': stopLoss,
      };
}

class WatchlistAlertResponse {
  final int id;
  final int watchlistItemId;
  final String symbol;
  final String alertType;
  final double signalScore;
  final String analysisSummary;
  final List<String> keySignals;
  final double? entryPrice;
  final double? targetPrice;
  final double? stopLossPrice;
  final String createdAt;
  final bool isRead;

  const WatchlistAlertResponse({
    required this.id,
    required this.watchlistItemId,
    required this.symbol,
    required this.alertType,
    required this.signalScore,
    required this.analysisSummary,
    required this.keySignals,
    this.entryPrice,
    this.targetPrice,
    this.stopLossPrice,
    required this.createdAt,
    required this.isRead,
  });

  factory WatchlistAlertResponse.fromJson(Map<String, dynamic> json) {
    return WatchlistAlertResponse(
      id: json['id'] as int,
      watchlistItemId: json['watchlist_item_id'] as int,
      symbol: json['symbol'] as String,
      alertType: json['alert_type'] as String,
      signalScore: (json['signal_score'] as num).toDouble(),
      analysisSummary: json['analysis_summary'] as String,
      keySignals: List<String>.from(json['key_signals'] as List),
      entryPrice: (json['entry_price'] as num?)?.toDouble(),
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      stopLossPrice: (json['stop_loss_price'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
      isRead: json['is_read'] as bool,
    );
  }
}
