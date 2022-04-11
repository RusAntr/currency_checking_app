import 'dart:convert';
import 'package:currency_checking_app/core/consts/all_currencies.dart';
import 'package:currency_checking_app/core/consts/api_key.dart';
import 'package:http/http.dart' as http;
import 'package:currency_checking_app/data/models/currency_pair.dart';
import 'package:currency_checking_app/data/models/currency_model.dart';

class CurrencyRepository {
  final _apiKey = ApiKey.getKey();

  /// Fetches data from an API, decodes JSON response body and returns a [CurrencyPair]
  Future<CurrencyPair> convertCurrencies({
    required Currency baseCurrency,
    required Currency toCurrency,
    required double amount,
  }) async {
    try {
      final Uri url = Uri.parse(
          'https://exchange-rates.abstractapi.com/v1/convert?api_key=$_apiKey&base=${baseCurrency.currencyCode}&target=${toCurrency.currencyCode}&base_amount=$amount');
      final response = await http.Client().get(url);
      return CurrencyPair.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  /// Returns a list of [Currency] models from a map stored in [AllCurrencies]
  List<Currency> getAllCurrencies() {
    List<Currency> list = [];
    AllCurrencies.currencies.forEach((key, value) {
      value.forEach((key2, value2) {
        list.add(
            Currency(emoji: value2, currencyName: key2, currencyCode: key));
      });
    });
    return list;
  }
}
