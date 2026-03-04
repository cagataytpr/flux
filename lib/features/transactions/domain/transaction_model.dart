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

  String currency = 'TRY';

  double? exchangeRate;

  String? paymentMethod; // e.g., 'Cash', 'Credit Card'

  int? currentInstallment;

  int? totalInstallments;

  int? linkedSubscriptionId; // To link this expense to a recurring bill

  int? linkedGoalId; // To link this transaction to a savings goal transfer

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
    String currency = 'TRY',
    double? exchangeRate,
    String? paymentMethod,
    int? currentInstallment,
    int? totalInstallments,
    int? linkedSubscriptionId,
    int? linkedGoalId,
  }) {
    return Transaction()
      ..title = title
      ..amount = amount
      ..date = date
      ..category = category
      ..isIncome = isIncome
      ..receiptImagePath = receiptImagePath
      ..isAiGenerated = isAiGenerated
      ..isSubscription = isSubscription
      ..currency = currency
      ..exchangeRate = exchangeRate
      ..paymentMethod = paymentMethod
      ..currentInstallment = currentInstallment
      ..totalInstallments = totalInstallments
      ..linkedSubscriptionId = linkedSubscriptionId
      ..linkedGoalId = linkedGoalId;
  }
}
