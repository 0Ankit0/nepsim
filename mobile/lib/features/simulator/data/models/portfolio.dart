class PortfolioHolding {
  final int id;
  final int simulationId;
  final String symbol;
  final int quantity;
  final double averageBuyPrice;
  final double? currentPrice;
  final double? currentValue;
  final double? unrealisedPnl;
  final double? unrealisedPnlPct;

  const PortfolioHolding({
    required this.id,
    required this.simulationId,
    required this.symbol,
    required this.quantity,
    required this.averageBuyPrice,
    this.currentPrice,
    this.currentValue,
    this.unrealisedPnl,
    this.unrealisedPnlPct,
  });

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: json['id'] as int? ?? 0,
      simulationId: json['simulation_id'] as int? ?? 0,
      symbol: json['symbol'] as String,
      quantity: json['quantity'] as int,
      averageBuyPrice: (json['average_buy_price'] as num).toDouble(),
      currentPrice: json['current_price'] != null ? (json['current_price'] as num).toDouble() : null,
      currentValue: json['current_value'] != null ? (json['current_value'] as num).toDouble() : null,
      unrealisedPnl: json['unrealised_pnl'] != null ? (json['unrealised_pnl'] as num).toDouble() : null,
      unrealisedPnlPct: json['unrealised_pnl_pct'] != null ? (json['unrealised_pnl_pct'] as num).toDouble() : null,
    );
  }
}
