import 'crypto_currency_model.dart';
import 'fiat_currency_model.dart';

class CurrencyDataModel {
  final List<CryptoCurrencyModel> cryptocurrencies;
  final List<FiatCurrencyModel> fiatCurrencies;

  CurrencyDataModel({required this.cryptocurrencies, required this.fiatCurrencies});

  factory CurrencyDataModel.fromJson(Map<String, dynamic> json) {
    return CurrencyDataModel(
      cryptocurrencies:
          (json['cryptocurrencies'] as List).map((e) => CryptoCurrencyModel.fromJson(e)).toList(),
      fiatCurrencies:
          (json['fiatCurrencies'] as List).map((e) => FiatCurrencyModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cryptocurrencies': cryptocurrencies.map((e) => e.toJson()).toList(),
    'fiatCurrencies': fiatCurrencies.map((e) => e.toJson()).toList(),
  };
}
