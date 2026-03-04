import 'package:isar/isar.dart';

part 'subscription_model.g.dart';

/// Billing cycle for a subscription.
enum SubscriptionCycle {
  monthly,
  yearly,
}

/// Represents a recurring subscription stored in Isar.
@collection
class Subscription {
  Id id = Isar.autoIncrement;

  late String name;

  late double amount;

  late DateTime nextBillingDate;

  /// Number of days before the billing date to trigger a reminder.
  late int reminderDays;

  @enumerated
  late SubscriptionCycle cycle;

  /// E.g., 'Streaming', 'Rent', 'Software', 'Utilities'.
  late String category;

  String type = 'Subscription'; // e.g., 'Subscription', 'Utility Bill', 'Credit Card'

  String currency = 'TRY';

  DateTime? lastPaidDate;

  Subscription();

  /// Convenience factory for creating a [Subscription] with all fields.
  factory Subscription.create({
    required String name,
    required double amount,
    required DateTime nextBillingDate,
    required int reminderDays,
    required SubscriptionCycle cycle,
    required String category,
    String type = 'Subscription',
    String currency = 'TRY',
    DateTime? lastPaidDate,
  }) {
    return Subscription()
      ..name = name
      ..amount = amount
      ..nextBillingDate = nextBillingDate
      ..reminderDays = reminderDays
      ..cycle = cycle
      ..category = category
      ..type = type
      ..currency = currency
      ..lastPaidDate = lastPaidDate;
  }
}
