import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/currency_data_model.dart';

class CurrencyLocalDataSource {
  Future<CurrencyDataModel> loadCurrencies() async {
    final String jsonString = await rootBundle.loadString('assets/data/currencies.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return CurrencyDataModel.fromJson(jsonMap);
  }
}
