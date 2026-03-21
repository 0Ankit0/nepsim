// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LatestQuoteResponse _$LatestQuoteResponseFromJson(Map<String, dynamic> json) =>
    _LatestQuoteResponse(
      symbol: json['symbol'] as String,
      date: json['date'] as String,
      ltp: (json['ltp'] as num?)?.toDouble(),
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      close: (json['close'] as num?)?.toDouble(),
      prev_close: (json['prev_close'] as num?)?.toDouble(),
      diff: (json['diff'] as num?)?.toDouble(),
      diff_pct: (json['diff_pct'] as num?)?.toDouble(),
      vwap: (json['vwap'] as num?)?.toDouble(),
      vol: (json['vol'] as num?)?.toDouble(),
      turnover: (json['turnover'] as num?)?.toDouble(),
      weeks_52_high: (json['weeks_52_high'] as num?)?.toDouble(),
      weeks_52_low: (json['weeks_52_low'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LatestQuoteResponseToJson(
  _LatestQuoteResponse instance,
) => <String, dynamic>{
  'symbol': instance.symbol,
  'date': instance.date,
  'ltp': instance.ltp,
  'open': instance.open,
  'high': instance.high,
  'low': instance.low,
  'close': instance.close,
  'prev_close': instance.prev_close,
  'diff': instance.diff,
  'diff_pct': instance.diff_pct,
  'vwap': instance.vwap,
  'vol': instance.vol,
  'turnover': instance.turnover,
  'weeks_52_high': instance.weeks_52_high,
  'weeks_52_low': instance.weeks_52_low,
};

_HistoricDataRow _$HistoricDataRowFromJson(Map<String, dynamic> json) =>
    _HistoricDataRow(
      date: json['date'] as String,
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      close: (json['close'] as num?)?.toDouble(),
      vol: (json['vol'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HistoricDataRowToJson(_HistoricDataRow instance) =>
    <String, dynamic>{
      'date': instance.date,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'vol': instance.vol,
    };

_HistoricDataResponse _$HistoricDataResponseFromJson(
  Map<String, dynamic> json,
) => _HistoricDataResponse(
  symbol: json['symbol'] as String,
  count: (json['count'] as num).toInt(),
  data: (json['data'] as List<dynamic>)
      .map((e) => HistoricDataRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HistoricDataResponseToJson(
  _HistoricDataResponse instance,
) => <String, dynamic>{
  'symbol': instance.symbol,
  'count': instance.count,
  'data': instance.data,
};

_IndicatorRow _$IndicatorRowFromJson(Map<String, dynamic> json) =>
    _IndicatorRow(
      date: json['date'] as String,
      rsi_14: (json['rsi_14'] as num?)?.toDouble(),
      macd_line: (json['macd_line'] as num?)?.toDouble(),
      macd_signal: (json['macd_signal'] as num?)?.toDouble(),
      macd_hist: (json['macd_hist'] as num?)?.toDouble(),
      bb_upper: (json['bb_upper'] as num?)?.toDouble(),
      bb_lower: (json['bb_lower'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$IndicatorRowToJson(_IndicatorRow instance) =>
    <String, dynamic>{
      'date': instance.date,
      'rsi_14': instance.rsi_14,
      'macd_line': instance.macd_line,
      'macd_signal': instance.macd_signal,
      'macd_hist': instance.macd_hist,
      'bb_upper': instance.bb_upper,
      'bb_lower': instance.bb_lower,
    };

_IndicatorsResponse _$IndicatorsResponseFromJson(Map<String, dynamic> json) =>
    _IndicatorsResponse(
      symbol: json['symbol'] as String,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => IndicatorRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IndicatorsResponseToJson(_IndicatorsResponse instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'count': instance.count,
      'data': instance.data,
    };

_IndexRow _$IndexRowFromJson(Map<String, dynamic> json) => _IndexRow(
  date: json['date'] as String,
  index: json['index'] as String,
  current: (json['current'] as num?)?.toDouble(),
  point_change: (json['point_change'] as num?)?.toDouble(),
  pct_change: (json['pct_change'] as num?)?.toDouble(),
  turnover: (json['turnover'] as num?)?.toDouble(),
);

Map<String, dynamic> _$IndexRowToJson(_IndexRow instance) => <String, dynamic>{
  'date': instance.date,
  'index': instance.index,
  'current': instance.current,
  'point_change': instance.point_change,
  'pct_change': instance.pct_change,
  'turnover': instance.turnover,
};

_IndicesResponse _$IndicesResponseFromJson(Map<String, dynamic> json) =>
    _IndicesResponse(
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => IndexRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IndicesResponseToJson(_IndicesResponse instance) =>
    <String, dynamic>{'count': instance.count, 'data': instance.data};

_LatestIndicesResponse _$LatestIndicesResponseFromJson(
  Map<String, dynamic> json,
) => _LatestIndicesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => IndexRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LatestIndicesResponseToJson(
  _LatestIndicesResponse instance,
) => <String, dynamic>{'data': instance.data};
