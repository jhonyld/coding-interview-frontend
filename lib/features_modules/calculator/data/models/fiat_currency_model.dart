class FiatCurrencyModel {
  final String id;
  final String name;
  final String symbol;
  final String logoPath;

  FiatCurrencyModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.logoPath,
  });

  factory FiatCurrencyModel.fromJson(Map<String, dynamic> json) {
    return FiatCurrencyModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      logoPath: json['logoPath'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'symbol': symbol, 'logoPath': logoPath};
}
