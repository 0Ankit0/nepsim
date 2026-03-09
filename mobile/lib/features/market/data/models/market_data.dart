class MarketDataPoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final double? adjustedClose;

  const MarketDataPoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.adjustedClose,
  });

  factory MarketDataPoint.fromJson(Map<String, dynamic> json) {
    return MarketDataPoint(
      date: DateTime.parse(json['date'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: json['volume'] as int,
      adjustedClose: json['adjusted_close'] != null ? (json['adjusted_close'] as num).toDouble() : null,
    );
  }
}
