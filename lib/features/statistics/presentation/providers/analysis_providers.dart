/// Flux Application - Analysis Providers
///
/// Providers for advanced analytics: Cash Flow Forecasting and Gamification (Streaks).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

// ---------------------------------------------------------------------------
// Gamification: No-Spend Streak
// ---------------------------------------------------------------------------

/// Calculates the current consecutive days without any expenses.
/// Looks back from today. If today has an expense, checks if yesterday had one, etc.
final noSpendStreakProvider = Provider<int>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  
  if (txns.isEmpty) return 0;

  // Filter only expenses
  final expenses = txns.where((t) => !t.isIncome).toList();
  if (expenses.isEmpty) {
    // If there are transactions but NO expenses ever, the streak is from the first transaction to today.
    final firstTxnDate = txns.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final now = DateTime.now();
    return now.difference(firstTxnDate).inDays;
  }

  // Sort expenses by date descending
  expenses.sort((a, b) => b.date.compareTo(a.date));

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  int streak = 0;
  DateTime currentDate = today;

  while (true) {
    // Check if there is an expense on currentDate
    final hasExpenseOnCurrentDate = expenses.any((e) {
      final localDate = e.date.toLocal();
      return localDate.year == currentDate.year &&
             localDate.month == currentDate.month &&
             localDate.day == currentDate.day;
    });

    if (hasExpenseOnCurrentDate) {
      break; // Streak ends
    } else {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
  }

  // If today has an expense, streak is 0. 
  // If today has no expense, but yesterday does, streak is 1 (today).
  return streak;
});

// ---------------------------------------------------------------------------
// Cash Flow Forecast
// ---------------------------------------------------------------------------

class CashFlowForecast {
  const CashFlowForecast({
    required this.predictedEomBalance,
    required this.averageDailySpend,
    required this.remainingDays,
    required this.upcomingSubscriptionTotal,
  });

  final double predictedEomBalance;
  final double averageDailySpend;
  final int remainingDays;
  final double upcomingSubscriptionTotal;
}

/// Predicts the end-of-month balance based on current spending rate and upcoming subscriptions.
final cashFlowForecastProvider = Provider<CashFlowForecast>((ref) {
  final currentMonthTxns = ref.watch(currentMonthTransactionsProvider);
  final allSubs = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  final currentBalance = ref.watch(totalBalanceProvider); // Overall balance

  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysPassed = now.day;
  final remainingDays = daysInMonth - daysPassed;

  // 1. Calculate Average Daily Spend for this month (excluding subscriptions if possible, but keep simple for now)
  final currentMonthExpenses = currentMonthTxns
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
      
  final avgDailySpend = daysPassed > 0 ? (currentMonthExpenses / daysPassed) : 0.0;

  // 2. Calculate Upcoming Subscriptions for the REST of this month
  double upcomingSubTotal = 0.0;
  for (final sub in allSubs) {
    // Check if the next billing date is within this month and in the future
    final billing = sub.nextBillingDate.toLocal();
    if (billing.year == now.year && billing.month == now.month && billing.day > now.day) {
      upcomingSubTotal += sub.amount;
    }
  }

  // 3. Predict End of Month Balance
  // Current Balance - (Avg Daily Spend * Remaining Days) - Upcoming Subs
  final predictedBalance = currentBalance - (avgDailySpend * remainingDays) - upcomingSubTotal;

  return CashFlowForecast(
    predictedEomBalance: predictedBalance,
    averageDailySpend: avgDailySpend,
    remainingDays: remainingDays,
    upcomingSubscriptionTotal: upcomingSubTotal,
  );
});
