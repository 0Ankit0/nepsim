// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'simulator_models.freezed.dart';
part 'simulator_models.g.dart';

@freezed
sealed class PortfolioHolding with _$PortfolioHolding {
  const factory PortfolioHolding({
    required String symbol,
    required int quantity,
    required double average_buy_price,
    double? current_price,
    double? current_value,
    double? unrealised_pnl,
    double? unrealised_pnl_pct,
  }) = _PortfolioHolding;

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) => _$PortfolioHoldingFromJson(json);
}

@freezed
sealed class SimulationResponse with _$SimulationResponse {
  const factory SimulationResponse({
    required int id,
    required int user_id,
    String? name,
    required double initial_capital,
    required double cash_balance,
    required String status,
    required String period_start,
    required String period_end,
    required String current_sim_date,
    required String started_at,
    String? ended_at,
    double? portfolio_value,
    double? total_value,
    double? total_pnl,
    double? total_pnl_pct,
    List<PortfolioHolding>? holdings,
  }) = _SimulationResponse;

  factory SimulationResponse.fromJson(Map<String, dynamic> json) => _$SimulationResponseFromJson(json);
}

@freezed
sealed class SimulationSummary with _$SimulationSummary {
  const factory SimulationSummary({
    required int id,
    String? name,
    required String status,
    required double initial_capital,
    required String started_at,
    String? ended_at,
    double? total_pnl,
    double? total_pnl_pct,
    int? total_trades,
  }) = _SimulationSummary;

  factory SimulationSummary.fromJson(Map<String, dynamic> json) => _$SimulationSummaryFromJson(json);
}

@freezed
sealed class TradeRequest with _$TradeRequest {
  const factory TradeRequest({
    required String symbol,
    required String side,
    required int quantity,
  }) = _TradeRequest;

  factory TradeRequest.fromJson(Map<String, dynamic> json) => _$TradeRequestFromJson(json);
}

@freezed
sealed class TradeResponse with _$TradeResponse {
  const factory TradeResponse({
    required int id,
    required int simulation_id,
    required String symbol,
    required String side,
    required int quantity,
    required double executed_price,
    required double sebon_commission,
    required double broker_commission,
    required double dp_charge,
    required double total_cost,
    required String sim_date,
    required String status,
    String? rejection_reason,
    double? realised_pnl,
    required String created_at,
    double? new_cash_balance,
    String? message,
  }) = _TradeResponse;

  factory TradeResponse.fromJson(Map<String, dynamic> json) => _$TradeResponseFromJson(json);
}

@freezed
sealed class EndSimulationResponse with _$EndSimulationResponse {
  const factory EndSimulationResponse({
    required int simulation_id,
    required String status,
    required String message,
    String? analysis_task_id,
  }) = _EndSimulationResponse;

  factory EndSimulationResponse.fromJson(Map<String, dynamic> json) => _$EndSimulationResponseFromJson(json);
}

@freezed
sealed class AnalysisSection with _$AnalysisSection {
  const factory AnalysisSection({
    required String title,
    required String detail,
    List<int>? trade_ids,
    double? impact_pct,
  }) = _AnalysisSection;

  factory AnalysisSection.fromJson(Map<String, dynamic> json) => _$AnalysisSectionFromJson(json);
}

@freezed
sealed class TradeCommentary with _$TradeCommentary {
  const factory TradeCommentary({
    required int trade_id,
    required String symbol,
    required String side,
    required String sim_date,
    required String commentary,
    double? quality_score,
  }) = _TradeCommentary;

  factory TradeCommentary.fromJson(Map<String, dynamic> json) => _$TradeCommentaryFromJson(json);
}

@freezed
sealed class AIAnalysisResponse with _$AIAnalysisResponse {
  const factory AIAnalysisResponse({
    required int id,
    required int simulation_id,
    required String status,
    
    // Metrics
    double? total_pnl,
    double? total_pnl_pct,
    double? win_rate,
    double? sharpe_ratio,
    double? max_drawdown,
    int? total_trades,
    int? winning_trades,
    int? losing_trades,
    double? best_trade_pnl,
    double? worst_trade_pnl,
    double? avg_holding_days,

    // Benchmarks
    double? market_return_pct,
    double? buy_hold_return_pct,

    String? summary_narrative,
    List<AnalysisSection>? what_you_did_right,
    List<AnalysisSection>? what_you_did_wrong,
    List<AnalysisSection>? what_you_could_have_done,
    List<TradeCommentary>? trade_by_trade_commentary,

    double? timing_score,
    double? selection_score,
    double? risk_score,
    double? patience_score,

    String? llm_provider,
    String? created_at,
    String? completed_at,
  }) = _AIAnalysisResponse;

  factory AIAnalysisResponse.fromJson(Map<String, dynamic> json) => _$AIAnalysisResponseFromJson(json);
}
