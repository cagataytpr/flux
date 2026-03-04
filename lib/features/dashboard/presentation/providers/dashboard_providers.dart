/// Flux Application - Dashboard Providers
///
/// Riverpod providers that power the Dashboard screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/database_service.dart';
import '../../../subscriptions/domain/subscription_model.dart';
import '../../../transactions/domain/transaction_model.dart';

// ---------------------------------------------------------------------------
// User Budget
// ---------------------------------------------------------------------------

/// The user's monthly budget. Defaults to 20,000 TL.
/// This will be made user-editable in a future phase.
final userBudgetProvider = StateProvider<double>((ref) => 20000.0);

// ---------------------------------------------------------------------------
// Transactions
// ---------------------------------------------------------------------------

/// Streams all transactions from the Isar database, ordered by date (newest
/// first).
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.transactions
      .where()
      .sortByDateDesc()
      .watch(fireImmediately: true);
});

// ---------------------------------------------------------------------------
// Subscriptions
// ---------------------------------------------------------------------------

/// Streams all subscriptions from the Isar database, sorted by next billing
/// date (soonest first).
final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.subscriptions
      .where()
      .sortByNextBillingDate()
      .watch(fireImmediately: true);
});

// ---------------------------------------------------------------------------
// Balance Calculations
// ---------------------------------------------------------------------------

/// Total income derived from [transactionsProvider].
final totalIncomeProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  return txns
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Total expenses derived from [transactionsProvider].
final totalExpensesProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  return txns
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Net balance (income – expenses).
final totalBalanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpensesProvider);
});

// ---------------------------------------------------------------------------
// Expense-by-Category Map (for the PieChart)
// ---------------------------------------------------------------------------

/// Map of [TransactionCategory] → total spent (All Time), excluding income entries.
final expenseByCategoryProvider =
    Provider<Map<TransactionCategory, double>>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final map = <TransactionCategory, double>{};
  for (final t in txns.where((t) => !t.isIncome)) {
    map[t.category] = (map[t.category] ?? 0) + t.amount;
  }
  return map;
});

// ---------------------------------------------------------------------------
// Current Month Calculations
// ---------------------------------------------------------------------------

/// Filters all transactions to only include the current month and year.
final currentMonthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  
  // BURASI DÜZELTİLDİ: t.date.toLocal() eklendi
  return txns.where((t) {
    final localDate = t.date.toLocal();
    return localDate.year == now.year && localDate.month == now.month;
  }).toList();
});

/// Total expenses for the current month.
final currentMonthExpensesProvider = Provider<double>((ref) {
  final txns = ref.watch(currentMonthTransactionsProvider);
  return txns
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Map of [TransactionCategory] → total spent for the current month.
final currentMonthExpenseByCategoryProvider =
    Provider<Map<TransactionCategory, double>>((ref) {
  final txns = ref.watch(currentMonthTransactionsProvider);
  final map = <TransactionCategory, double>{};
  for (final t in txns.where((t) => !t.isIncome)) {
    map[t.category] = (map[t.category] ?? 0) + t.amount;
  }
  return map;
});

