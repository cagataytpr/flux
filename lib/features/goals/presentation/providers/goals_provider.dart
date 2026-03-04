import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/services/database_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../domain/goal_model.dart';

/// Notifier to manage the list of [Goal] states.
class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    return _fetchGoals();
  }

  Future<List<Goal>> _fetchGoals() async {
    final isar = ref.read(isarProvider);
    return await isar.goals.where().findAll();
  }

  /// Adds a new savings goal.
  Future<void> addGoal(Goal goal) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    
    // Assign global currency if not explicitly set
    final settingsStr = ref.read(settingsProvider).valueOrNull?.defaultCurrency ?? 'TRY';
    if(goal.currency == 'TRY' && settingsStr != 'TRY') {
      goal.currency = settingsStr; // Very simplistic mapping, adjust if needed
    }

    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.goals.put(goal);
      });
      return _fetchGoals();
    });
  }

  /// Adds funds to an existing goal.
  Future<void> addFunds(int id, double amountToAdd) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        final goal = await isar.goals.get(id);
        if (goal != null) {
          goal.currentAmount += amountToAdd;
          if (goal.currentAmount > goal.targetAmount) {
            goal.currentAmount = goal.targetAmount;
          }
          await isar.goals.put(goal);

          // Automatically record this transfer to history
          final transferTransaction = Transaction.create(
            title: 'Transfer to \${goal.name}',
            amount: amountToAdd,
            date: DateTime.now(),
            category: TransactionCategory.market, // Using an available category
            isIncome: false,
            currency: goal.currency,
            linkedGoalId: goal.id,
          );
          await isar.transactions.put(transferTransaction);
        }
      });
      return _fetchGoals();
    });
  }

  /// Edits an existing goal entirely.
  Future<void> editGoal(Goal updatedGoal) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.goals.put(updatedGoal);
      });
      return _fetchGoals();
    });
  }

  /// Deletes a goal by ID.
  Future<void> deleteGoal(int id) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.goals.delete(id);
      });
      return _fetchGoals();
    });
  }
}

/// Provider exposing the [GoalsNotifier] and the list of goals.
final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);
