import 'portfolio.dart';

class Simulation {
  final int id;
  final String name;
  final double initialCapital;
  final double cashBalance;
  final String status;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime currentSimDate;
  final double? portfolioValue;
  final double? totalValue;
  final double? totalPnl;
  final double? totalPnlPct;
  final List<PortfolioHolding> holdings;

  const Simulation({
    required this.id,
    required this.name,
    required this.initialCapital,
    required this.cashBalance,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    required this.currentSimDate,
    this.portfolioValue,
    this.totalValue,
    this.totalPnl,
    this.totalPnlPct,
    this.holdings = const [],
  });

  factory Simulation.fromJson(Map<String, dynamic> json) {
    return Simulation(
      id: json['id'] as int,
      name: json['name'] as String,
      initialCapital: (json['initial_capital'] as num).toDouble(),
      cashBalance: (json['cash_balance'] as num).toDouble(),
      status: json['status'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      currentSimDate: DateTime.parse(json['current_sim_date'] as String),
      portfolioValue: json['portfolio_value'] != null ? (json['portfolio_value'] as num).toDouble() : null,
      totalValue: json['total_value'] != null ? (json['total_value'] as num).toDouble() : null,
      totalPnl: json['total_pnl'] != null ? (json['total_pnl'] as num).toDouble() : null,
      totalPnlPct: json['total_pnl_pct'] != null ? (json['total_pnl_pct'] as num).toDouble() : null,
      holdings: json['holdings'] != null ? (json['holdings'] as List).map((i) => PortfolioHolding.fromJson(i)).toList() : const [],
    );
  }
}
