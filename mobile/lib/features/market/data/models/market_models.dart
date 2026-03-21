// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_models.freezed.dart';
part 'market_models.g.dart';

@freezed
sealed class LatestQuoteResponse with _$LatestQuoteResponse {
  const factory LatestQuoteResponse({
    required String symbol,
    required String date,
    double? ltp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? prev_close,
    double? diff,
    double? diff_pct,
    double? vwap,
    double? vol,
    double? turnover,
    double? weeks_52_high,
    double? weeks_52_low,
  }) = _LatestQuoteResponse;

  factory LatestQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$LatestQuoteResponseFromJson(json);
}

@freezed
sealed class HistoricDataRow with _$HistoricDataRow {
  const factory HistoricDataRow({
    required String date,
    double? open,
    double? high,
    double? low,
    double? close,
    double? vol,
  }) = _HistoricDataRow;

  factory HistoricDataRow.fromJson(Map<String, dynamic> json) =>
      _$HistoricDataRowFromJson(json);
}

@freezed
sealed class HistoricDataResponse with _$HistoricDataResponse {
  const factory HistoricDataResponse({
    required String symbol,
    required int count,
    required List<HistoricDataRow> data,
  }) = _HistoricDataResponse;

  factory HistoricDataResponse.fromJson(Map<String, dynamic> json) =>
      _$HistoricDataResponseFromJson(json);
}

@freezed
sealed class IndicatorRow with _$IndicatorRow {
  const factory IndicatorRow({
    required String date,
    double? rsi_14,
    double? macd_line,
    double? macd_signal,
    double? macd_hist,
    double? bb_upper,
    double? bb_lower,
  }) = _IndicatorRow;

  factory IndicatorRow.fromJson(Map<String, dynamic> json) =>
      _$IndicatorRowFromJson(json);
}

@freezed
sealed class IndicatorsResponse with _$IndicatorsResponse {
  const factory IndicatorsResponse({
    required String symbol,
    required int count,
    required List<IndicatorRow> data,
  }) = _IndicatorsResponse;

  factory IndicatorsResponse.fromJson(Map<String, dynamic> json) =>
      _$IndicatorsResponseFromJson(json);
}

@freezed
sealed class IndexRow with _$IndexRow {
  const factory IndexRow({
    required String date,
    required String index,
    double? current,
    double? point_change,
    double? pct_change,
    double? turnover,
  }) = _IndexRow;

  factory IndexRow.fromJson(Map<String, dynamic> json) =>
      _$IndexRowFromJson(json);
}

@freezed
sealed class IndicesResponse with _$IndicesResponse {
  const factory IndicesResponse({
    required int count,
    required List<IndexRow> data,
  }) = _IndicesResponse;

  factory IndicesResponse.fromJson(Map<String, dynamic> json) =>
      _$IndicesResponseFromJson(json);
}

@freezed
sealed class LatestIndicesResponse with _$LatestIndicesResponse {
  const factory LatestIndicesResponse({
    required List<IndexRow> data,
  }) = _LatestIndicesResponse;

  factory LatestIndicesResponse.fromJson(Map<String, dynamic> json) =>
      _$LatestIndicesResponseFromJson(json);
}
