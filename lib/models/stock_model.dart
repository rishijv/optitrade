class Stock {
  final double currentPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double previousClosePrice;
  final double change;
  final double percentChange;

  Stock({
    required this.currentPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.previousClosePrice,
    required this.change,
    required this.percentChange,
  });

  // Handle potential null values safely
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      currentPrice: (json['c'] ?? 0.0).toDouble(),
      openPrice: (json['o'] ?? 0.0).toDouble(),
      highPrice: (json['h'] ?? 0.0).toDouble(),
      lowPrice: (json['l'] ?? 0.0).toDouble(),
      previousClosePrice: (json['pc'] ?? 0.0).toDouble(),
      change: (json['d'] ?? 0.0).toDouble(),
      percentChange: (json['dp'] ?? 0.0).toDouble(),
    );
  }
}
