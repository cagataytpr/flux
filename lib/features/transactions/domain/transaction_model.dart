import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

/// Categories available for a transaction.
enum TransactionCategory {
  market,
  food,
  bills,
  salary,
  investment,
  transport,
  entertainment,
  health,
}

/// Represents a single financial transaction stored in Isar.
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late String title;

  late double amount;

  late DateTime date;

  @enumerated
  late TransactionCategory category;

  late bool isIncome;

  String? receiptImagePath;

  late bool isAiGenerated;

  late bool isSubscription;

  Transaction();

  /// Convenience factory for creating a [Transaction] with all fields.
  factory Transaction.create({
    required String title,
    required double amount,
    required DateTime date,
    required TransactionCategory category,
    required bool isIncome,
    String? receiptImagePath,
    bool isAiGenerated = false,
    bool isSubscription = false,
  }) {
    return Transaction()
      ..title = title
      ..amount = amount
      ..date = date
      ..category = category
      ..isIncome = isIncome
      ..receiptImagePath = receiptImagePath
      ..isAiGenerated = isAiGenerated
      ..isSubscription = isSubscription;
  }
}
