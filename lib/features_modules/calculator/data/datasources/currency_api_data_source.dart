import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiDataSource {
  static const String _baseUrl =
      'https://74j6q7lg6a.execute-api.eu-west-1.amazonaws.com/stage/orderbook/public/recommendations';

  Future<double> fetchExchangeRate({
    required int type, // 0: Crypto->Fiat, 1: Fiat->Crypto
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'type': type.toString(),
        'cryptoCurrencyId': cryptoCurrencyId.toUpperCase(),
        'fiatCurrencyId': fiatCurrencyId.toUpperCase(),
        'amount': amount.toString(),
        'amountCurrencyId': amountCurrencyId.toUpperCase(),
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['byPrice']['fiatToCryptoExchangeRate'] as num).toDouble();
    } else {
      throw Exception('Failed to fetch exchange rate');
    }
  }
}
