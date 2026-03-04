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
// FluxAI Savings Coach (Manual Refresh Only + 30-min Cooldown)
// ---------------------------------------------------------------------------

/// Timestamp of the last successful AI fetch.
DateTime? _lastAiFetchTime;

/// Cached AI advice to avoid redundant API calls.
List<String>? _cachedAiAdvice;

/// Fetches witty, Turkish-language savings advice from the FluxAI persona.
/// This provider deliberately uses `ref.read` (NOT `ref.watch`) so it does
/// NOT auto-refresh when transactions change. It only fires when the user
/// explicitly calls `ref.invalidate(fluxAiAdviceProvider)`.
///
/// Additionally, results are cached for 30 minutes. If the user clicks
/// refresh within the cooldown window, the cached result is returned.
final fluxAiAdviceProvider = FutureProvider<List<String>>((ref) async {
  // Check 30-minute cooldown
  final now = DateTime.now();
  if (_lastAiFetchTime != null &&
      _cachedAiAdvice != null &&
      now.difference(_lastAiFetchTime!).inMinutes < 30) {
    return _cachedAiAdvice!;
  }

  // Use ref.read to avoid reactive dependency on transactions
  final txns = ref.read(transactionsProvider).valueOrNull ?? [];
  if (txns.isEmpty) {
    return ['İlk harcamanı ekle, FluxAI seni tanısın! 🚀'];
  }

  final aiService = ref.read(aiServiceProvider);
  final advice = await aiService.getSavingsAdvice(txns.take(20).toList());

  // Cache the result and timestamp
  _lastAiFetchTime = now;
  _cachedAiAdvice = advice;

  return advice;
});