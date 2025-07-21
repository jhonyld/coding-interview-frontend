import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coding_interview_frontend/common/constants/api_constants.dart';

abstract class ICurrencyApiDataSource {
  Future<double> getExchangeRate({
    required int type, // 0: Crypto->Fiat, 1: Fiat->Crypto
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  });
}

class CurrencyApiDataSource implements ICurrencyApiDataSource {
  static String get _baseUrl => ApiConstants.baseUrl;

  @override
  Future<double> getExchangeRate({
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
      return double.parse(data['data']['byPrice']["fiatToCryptoExchangeRate"]);
    } else {
      throw Exception('Failed to fetch exchange rate');
    }
  }
}
