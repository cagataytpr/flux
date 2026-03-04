import 'package:isar/isar.dart';

part 'exchange_rate_model.g.dart';

/// Represents cached exchange rates. Base is always TRY for this app.
@collection
class ExchangeRateModel {
  Id id = 0; // Singleton

  // Store rates as a separate list or embedded object? Isar doesn't support Map<String, double> directly.
  // We can store a Map as JSON string or use a list of embedded objects.
  late String ratesJson; // JSON encoded map of currency code to rate

  late DateTime lastUpdated;

  ExchangeRateModel();
}
