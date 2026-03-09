class StockMetadata {
  final int id;
  final String symbol;
  final String companyName;
  final String sector;
  final int lotSize;
  final double tickSize;
  final double faceValue;
  final bool isActive;
  final double? currentPrice;
  final double? previousClose;
  final double? changePct;

  const StockMetadata({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.sector,
    required this.lotSize,
    required this.tickSize,
    required this.faceValue,
    required this.isActive,
    this.currentPrice,
    this.previousClose,
    this.changePct,
  });

  factory StockMetadata.fromJson(Map<String, dynamic> json) {
    return StockMetadata(
      id: json['id'] as int,
      symbol: json['symbol'] as String,
      companyName: json['company_name'] as String,
      sector: json['sector'] as String,
      lotSize: json['lot_size'] as int,
      tickSize: (json['tick_size'] as num).toDouble(),
      faceValue: (json['face_value'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      currentPrice: json['current_price'] != null ? (json['current_price'] as num).toDouble() : null,
      previousClose: json['previous_close'] != null ? (json['previous_close'] as num).toDouble() : null,
      changePct: json['change_pct'] != null ? (json['change_pct'] as num).toDouble() : null,
    );
  }
}
