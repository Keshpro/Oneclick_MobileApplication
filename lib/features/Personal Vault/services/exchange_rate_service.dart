import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _url =
      'https://open.er-api.com/v6/latest/USD';

  Future<double> getUsdToLkrRate() async {
    final response = await http.get(
      Uri.parse(_url),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load exchange rate.',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    if (data['result'] != 'success') {
      throw Exception(
        'Exchange rate request failed.',
      );
    }

    final rates =
        data['rates']
            as Map<String, dynamic>?;

    final lkrRate = rates?['LKR'];

    if (lkrRate == null) {
      throw Exception(
        'LKR exchange rate is unavailable.',
      );
    }

    return (lkrRate as num).toDouble();
  }
}