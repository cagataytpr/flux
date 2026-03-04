import 'package:isar/isar.dart';

part 'goal_model.g.dart';

/// Represents a savings goal or target stored in Isar.
@collection
class Goal {
  Id id = Isar.autoIncrement;

  late String name;

  late double targetAmount;

  double currentAmount = 0.0;

  String currency = 'TRY';

  DateTime? targetDate;

  String? icon;

  String? colorHex;

  Goal();

  /// Convenience factory for creating a [Goal] with all fields.
  factory Goal.create({
    required String name,
    required double targetAmount,
    double currentAmount = 0.0,
    String currency = 'TRY',
    DateTime? targetDate,
    String? icon,
    String? colorHex,
  }) {
    return Goal()
      ..name = name
      ..targetAmount = targetAmount
      ..currentAmount = currentAmount
      ..currency = currency
      ..targetDate = targetDate
      ..icon = icon
      ..colorHex = colorHex;
  }
}
