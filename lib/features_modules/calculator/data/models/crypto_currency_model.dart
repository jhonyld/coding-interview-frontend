class CryptoCurrencyModel {
  final String id;
  final String name;
  final String symbol;
  final String logoPath;
  final Map<String, double> conversionRates;

  CryptoCurrencyModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.logoPath,
    required this.conversionRates,
  });

  factory CryptoCurrencyModel.fromJson(Map<String, dynamic> json) {
    return CryptoCurrencyModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      logoPath: json['logoPath'],
      conversionRates: Map<String, double>.from(json['conversionRates'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'symbol': symbol,
    'logoPath': logoPath,
    'conversionRates': conversionRates,
  };
}
