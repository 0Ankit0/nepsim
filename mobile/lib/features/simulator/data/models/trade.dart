class Trade {
  final int id;
  final int simulationId;
  final String symbol;
  final String side;
  final int quantity;
  final double executedPrice;
  final double sebonCommission;
  final double brokerCommission;
  final double dpCharge;
  final double totalCost;
  final DateTime simDate;
  final String status;
  final double? realisedPnl;
  final DateTime? createdAt;

  const Trade({
    required this.id,
    required this.simulationId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executedPrice,
    required this.sebonCommission,
    required this.brokerCommission,
    required this.dpCharge,
    required this.totalCost,
    required this.simDate,
    required this.status,
    this.realisedPnl,
    this.createdAt,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as int,
      simulationId: json['simulation_id'] as int,
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      quantity: json['quantity'] as int,
      executedPrice: (json['executed_price'] as num).toDouble(),
      sebonCommission: (json['sebon_commission'] as num).toDouble(),
      brokerCommission: (json['broker_commission'] as num).toDouble(),
      dpCharge: (json['dp_charge'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      simDate: DateTime.parse(json['sim_date'] as String),
      status: json['status'] as String,
      realisedPnl: json['realised_pnl'] != null ? (json['realised_pnl'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }
}
