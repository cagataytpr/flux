import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';

import '../models/exchange_rate_model.dart';
import 'database_service.dart';

/// Provider for the live currency exchange rate service.
final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final isar = ref.watch(isarProvider);
  return ExchangeRateService(isar);
});

class ExchangeRateService {
  final Isar _isar;
  static const String _baseUrl = 'https://api.frankfurter.dev/v1/latest?base=TRY';
  static const Duration _cacheExpiration = Duration(hours: 1);

  ExchangeRateService(this._isar);

  /// Synchronizes rates with the API if the cache is expired.
  Future<void> syncRatesIfNeeded() async {
    final model = _isar.exchangeRateModels.getSync(0);
    final now = DateTime.now();

    if (model == null || now.difference(model.lastUpdated) > _cacheExpiration) {
      await _fetchAndCacheRates();
    }
  }

  Future<void> _fetchAndCacheRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> ratesMap = data['rates'];
        
        ratesMap['TRY'] = 1.0; // Base currency is always 1.0.

        final jsonRates = json.encode(ratesMap);

        await _isar.writeTxn(() async {
          final newModel = ExchangeRateModel()
            ..id = 0
            ..ratesJson = jsonRates
            ..lastUpdated = DateTime.now();
          await _isar.exchangeRateModels.put(newModel);
        });
      }
    } catch (e) {
      // If fetching fails, we silently fallback to whatever is in the cache.
    }
  }

  /// Converts an amount (in TRY base) to the target currency based on cached rates.
  double convertToSelected(double amount, String targetCurrency) {
    if (targetCurrency == 'TRY') return amount;

    final model = _isar.exchangeRateModels.getSync(0);
    if (model == null) return amount; // Fallback to raw amount if no cache exists.

    try {
      final Map<String, dynamic> rates = json.decode(model.ratesJson);
      final double? targetRate = rates[targetCurrency]?.toDouble();

      if (targetRate != null) {
        return amount * targetRate;
      }
    } catch (e) {
      // JSON parsing or cast error
    }

    return amount;
  }
}
