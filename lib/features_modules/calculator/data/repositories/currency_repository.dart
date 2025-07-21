import '../datasources/currency_local_data_source.dart';
import '../datasources/currency_api_data_source.dart';
import '../models/currency_data_model.dart';

class CurrencyRepository {
  final ICurrencyLocalDataSource localDataSource;
  final ICurrencyApiDataSource apiDataSource;

  CurrencyRepository({required this.localDataSource, required this.apiDataSource});

  Future<CurrencyDataModel> getCurrencies() async {
    return await localDataSource.loadCurrencies();
  }

  Future<double> getExchangeRate({
    required int type,
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  }) async {
    return await apiDataSource.getExchangeRate(
      type: type,
      cryptoCurrencyId: cryptoCurrencyId,
      fiatCurrencyId: fiatCurrencyId,
      amount: amount,
      amountCurrencyId: amountCurrencyId,
    );
  }
}
