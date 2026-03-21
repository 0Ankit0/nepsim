// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulator_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PortfolioHolding _$PortfolioHoldingFromJson(Map<String, dynamic> json) =>
    _PortfolioHolding(
      symbol: json['symbol'] as String,
      quantity: (json['quantity'] as num).toInt(),
      average_buy_price: (json['average_buy_price'] as num).toDouble(),
      current_price: (json['current_price'] as num?)?.toDouble(),
      current_value: (json['current_value'] as num?)?.toDouble(),
      unrealised_pnl: (json['unrealised_pnl'] as num?)?.toDouble(),
      unrealised_pnl_pct: (json['unrealised_pnl_pct'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PortfolioHoldingToJson(_PortfolioHolding instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'quantity': instance.quantity,
      'average_buy_price': instance.average_buy_price,
      'current_price': instance.current_price,
      'current_value': instance.current_value,
      'unrealised_pnl': instance.unrealised_pnl,
      'unrealised_pnl_pct': instance.unrealised_pnl_pct,
    };

_SimulationResponse _$SimulationResponseFromJson(Map<String, dynamic> json) =>
    _SimulationResponse(
      id: (json['id'] as num).toInt(),
      user_id: (json['user_id'] as num).toInt(),
      name: json['name'] as String?,
      initial_capital: (json['initial_capital'] as num).toDouble(),
      cash_balance: (json['cash_balance'] as num).toDouble(),
      status: json['status'] as String,
      period_start: json['period_start'] as String,
      period_end: json['period_end'] as String,
      current_sim_date: json['current_sim_date'] as String,
      started_at: json['started_at'] as String,
      ended_at: json['ended_at'] as String?,
      portfolio_value: (json['portfolio_value'] as num?)?.toDouble(),
      total_value: (json['total_value'] as num?)?.toDouble(),
      total_pnl: (json['total_pnl'] as num?)?.toDouble(),
      total_pnl_pct: (json['total_pnl_pct'] as num?)?.toDouble(),
      holdings: (json['holdings'] as List<dynamic>?)
          ?.map((e) => PortfolioHolding.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SimulationResponseToJson(_SimulationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'name': instance.name,
      'initial_capital': instance.initial_capital,
      'cash_balance': instance.cash_balance,
      'status': instance.status,
      'period_start': instance.period_start,
      'period_end': instance.period_end,
      'current_sim_date': instance.current_sim_date,
      'started_at': instance.started_at,
      'ended_at': instance.ended_at,
      'portfolio_value': instance.portfolio_value,
      'total_value': instance.total_value,
      'total_pnl': instance.total_pnl,
      'total_pnl_pct': instance.total_pnl_pct,
      'holdings': instance.holdings,
    };

_SimulationSummary _$SimulationSummaryFromJson(Map<String, dynamic> json) =>
    _SimulationSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      status: json['status'] as String,
      initial_capital: (json['initial_capital'] as num).toDouble(),
      started_at: json['started_at'] as String,
      ended_at: json['ended_at'] as String?,
      total_pnl: (json['total_pnl'] as num?)?.toDouble(),
      total_pnl_pct: (json['total_pnl_pct'] as num?)?.toDouble(),
      total_trades: (json['total_trades'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SimulationSummaryToJson(_SimulationSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'initial_capital': instance.initial_capital,
      'started_at': instance.started_at,
      'ended_at': instance.ended_at,
      'total_pnl': instance.total_pnl,
      'total_pnl_pct': instance.total_pnl_pct,
      'total_trades': instance.total_trades,
    };

_TradeRequest _$TradeRequestFromJson(Map<String, dynamic> json) =>
    _TradeRequest(
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$TradeRequestToJson(_TradeRequest instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'side': instance.side,
      'quantity': instance.quantity,
    };

_TradeResponse _$TradeResponseFromJson(Map<String, dynamic> json) =>
    _TradeResponse(
      id: (json['id'] as num).toInt(),
      simulation_id: (json['simulation_id'] as num).toInt(),
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      quantity: (json['quantity'] as num).toInt(),
      executed_price: (json['executed_price'] as num).toDouble(),
      sebon_commission: (json['sebon_commission'] as num).toDouble(),
      broker_commission: (json['broker_commission'] as num).toDouble(),
      dp_charge: (json['dp_charge'] as num).toDouble(),
      total_cost: (json['total_cost'] as num).toDouble(),
      sim_date: json['sim_date'] as String,
      status: json['status'] as String,
      rejection_reason: json['rejection_reason'] as String?,
      realised_pnl: (json['realised_pnl'] as num?)?.toDouble(),
      created_at: json['created_at'] as String,
      new_cash_balance: (json['new_cash_balance'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$TradeResponseToJson(_TradeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'simulation_id': instance.simulation_id,
      'symbol': instance.symbol,
      'side': instance.side,
      'quantity': instance.quantity,
      'executed_price': instance.executed_price,
      'sebon_commission': instance.sebon_commission,
      'broker_commission': instance.broker_commission,
      'dp_charge': instance.dp_charge,
      'total_cost': instance.total_cost,
      'sim_date': instance.sim_date,
      'status': instance.status,
      'rejection_reason': instance.rejection_reason,
      'realised_pnl': instance.realised_pnl,
      'created_at': instance.created_at,
      'new_cash_balance': instance.new_cash_balance,
      'message': instance.message,
    };

_EndSimulationResponse _$EndSimulationResponseFromJson(
  Map<String, dynamic> json,
) => _EndSimulationResponse(
  simulation_id: (json['simulation_id'] as num).toInt(),
  status: json['status'] as String,
  message: json['message'] as String,
  analysis_task_id: json['analysis_task_id'] as String?,
);

Map<String, dynamic> _$EndSimulationResponseToJson(
  _EndSimulationResponse instance,
) => <String, dynamic>{
  'simulation_id': instance.simulation_id,
  'status': instance.status,
  'message': instance.message,
  'analysis_task_id': instance.analysis_task_id,
};

_AnalysisSection _$AnalysisSectionFromJson(Map<String, dynamic> json) =>
    _AnalysisSection(
      title: json['title'] as String,
      detail: json['detail'] as String,
      trade_ids: (json['trade_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      impact_pct: (json['impact_pct'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AnalysisSectionToJson(_AnalysisSection instance) =>
    <String, dynamic>{
      'title': instance.title,
      'detail': instance.detail,
      'trade_ids': instance.trade_ids,
      'impact_pct': instance.impact_pct,
    };

_TradeCommentary _$TradeCommentaryFromJson(Map<String, dynamic> json) =>
    _TradeCommentary(
      trade_id: (json['trade_id'] as num).toInt(),
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      sim_date: json['sim_date'] as String,
      commentary: json['commentary'] as String,
      quality_score: (json['quality_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TradeCommentaryToJson(_TradeCommentary instance) =>
    <String, dynamic>{
      'trade_id': instance.trade_id,
      'symbol': instance.symbol,
      'side': instance.side,
      'sim_date': instance.sim_date,
      'commentary': instance.commentary,
      'quality_score': instance.quality_score,
    };

_AIAnalysisResponse _$AIAnalysisResponseFromJson(Map<String, dynamic> json) =>
    _AIAnalysisResponse(
      id: (json['id'] as num).toInt(),
      simulation_id: (json['simulation_id'] as num).toInt(),
      status: json['status'] as String,
      total_pnl: (json['total_pnl'] as num?)?.toDouble(),
      total_pnl_pct: (json['total_pnl_pct'] as num?)?.toDouble(),
      win_rate: (json['win_rate'] as num?)?.toDouble(),
      sharpe_ratio: (json['sharpe_ratio'] as num?)?.toDouble(),
      max_drawdown: (json['max_drawdown'] as num?)?.toDouble(),
      total_trades: (json['total_trades'] as num?)?.toInt(),
      winning_trades: (json['winning_trades'] as num?)?.toInt(),
      losing_trades: (json['losing_trades'] as num?)?.toInt(),
      best_trade_pnl: (json['best_trade_pnl'] as num?)?.toDouble(),
      worst_trade_pnl: (json['worst_trade_pnl'] as num?)?.toDouble(),
      avg_holding_days: (json['avg_holding_days'] as num?)?.toDouble(),
      market_return_pct: (json['market_return_pct'] as num?)?.toDouble(),
      buy_hold_return_pct: (json['buy_hold_return_pct'] as num?)?.toDouble(),
      summary_narrative: json['summary_narrative'] as String?,
      what_you_did_right: (json['what_you_did_right'] as List<dynamic>?)
          ?.map((e) => AnalysisSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      what_you_did_wrong: (json['what_you_did_wrong'] as List<dynamic>?)
          ?.map((e) => AnalysisSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      what_you_could_have_done:
          (json['what_you_could_have_done'] as List<dynamic>?)
              ?.map((e) => AnalysisSection.fromJson(e as Map<String, dynamic>))
              .toList(),
      trade_by_trade_commentary:
          (json['trade_by_trade_commentary'] as List<dynamic>?)
              ?.map((e) => TradeCommentary.fromJson(e as Map<String, dynamic>))
              .toList(),
      timing_score: (json['timing_score'] as num?)?.toDouble(),
      selection_score: (json['selection_score'] as num?)?.toDouble(),
      risk_score: (json['risk_score'] as num?)?.toDouble(),
      patience_score: (json['patience_score'] as num?)?.toDouble(),
      llm_provider: json['llm_provider'] as String?,
      created_at: json['created_at'] as String?,
      completed_at: json['completed_at'] as String?,
    );

Map<String, dynamic> _$AIAnalysisResponseToJson(_AIAnalysisResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'simulation_id': instance.simulation_id,
      'status': instance.status,
      'total_pnl': instance.total_pnl,
      'total_pnl_pct': instance.total_pnl_pct,
      'win_rate': instance.win_rate,
      'sharpe_ratio': instance.sharpe_ratio,
      'max_drawdown': instance.max_drawdown,
      'total_trades': instance.total_trades,
      'winning_trades': instance.winning_trades,
      'losing_trades': instance.losing_trades,
      'best_trade_pnl': instance.best_trade_pnl,
      'worst_trade_pnl': instance.worst_trade_pnl,
      'avg_holding_days': instance.avg_holding_days,
      'market_return_pct': instance.market_return_pct,
      'buy_hold_return_pct': instance.buy_hold_return_pct,
      'summary_narrative': instance.summary_narrative,
      'what_you_did_right': instance.what_you_did_right,
      'what_you_did_wrong': instance.what_you_did_wrong,
      'what_you_could_have_done': instance.what_you_could_have_done,
      'trade_by_trade_commentary': instance.trade_by_trade_commentary,
      'timing_score': instance.timing_score,
      'selection_score': instance.selection_score,
      'risk_score': instance.risk_score,
      'patience_score': instance.patience_score,
      'llm_provider': instance.llm_provider,
      'created_at': instance.created_at,
      'completed_at': instance.completed_at,
    };
