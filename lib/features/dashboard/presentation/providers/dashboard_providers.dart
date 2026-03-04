/// Flux Application - Dashboard Providers
///
/// Riverpod providers that power the Dashboard screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/services/ai_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../subscriptions/domain/subscription_model.dart';
import '../../../transactions/domain/transaction_model.dart';

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

/// Map of [TransactionCategory] → total spent, excluding income entries.
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
// AI Savings Tips
// ---------------------------------------------------------------------------

/// Fetches personalised savings tips from Gemini based on recent transactions.
final savingsTipsProvider = FutureProvider<List<String>>((ref) async {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  if (txns.isEmpty) {
    return ['Add your first transaction to receive personalised tips!'];
  }
  final aiService = ref.read(aiServiceProvider);
  return aiService.getSavingsTips(txns.take(20).toList());
});

// ---------------------------------------------------------------------------
// FluxAI Savings Coach
// ---------------------------------------------------------------------------

/// Fetches witty, Turkish-language savings advice from the FluxAI persona.
final fluxAiAdviceProvider = FutureProvider<List<String>>((ref) async {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  if (txns.isEmpty) {
    return ['İlk harcamanı ekle, FluxAI seni tanısın! 🚀'];
  }
  final aiService = ref.read(aiServiceProvider);
  return aiService.getSavingsAdvice(txns.take(20).toList());
});
