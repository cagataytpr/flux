/// Flux Application - Dashboard Screen
///
/// The main screen showing balance, expense chart, and AI insights.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/exchange_rate_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/widget_manager.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../statistics/presentation/widgets/analysis_widgets.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/action_bottom_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/category_expense_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/upcoming_bill_indicator.dart';

/// Main dashboard screen of the Flux application.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for budget threshold crossing (75% of user budget)
    ref.listen<double>(currentMonthExpensesProvider, (previous, current) {
      final budget = ref.read(userBudgetProvider);
      final threshold = budget * 0.75;
      if ((previous ?? 0) < threshold && current >= threshold) {
        ref.read(notificationServiceProvider).showBudgetThresholdAlert();
      }
    });

    // Listen to changes to update Native Widget data
    ref.listen(totalBalanceProvider, (_, balance) {
      _updateNativeWidget(ref, balance);
    });
    ref.listen(currentMonthExpensesProvider, (_, __) {
      // Provide current balance since callback needs it
      _updateNativeWidget(ref, ref.read(totalBalanceProvider));
    });
    ref.listen(userBudgetProvider, (_, __) {
      _updateNativeWidget(ref, ref.read(totalBalanceProvider));
    });

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final txnsAsync = ref.watch(transactionsProvider);
    final isEmpty =
        txnsAsync.valueOrNull == null || txnsAsync.valueOrNull!.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l10n.flux),
            const SizedBox(width: 12),
            const StreakBadge(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      // ── Glowing FAB ──
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => showActionPickerSheet(context, ref),
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
      body: SafeArea(
        child: isEmpty
            ? DashboardEmptyState(theme: theme)
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(transactionsProvider);
                },
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // ── Filter Selector ──
                    const _DashboardFilterSelector(),
                    const SizedBox(height: 12),

                    // ── Balance Card ────────────────────────────────
                    const BalanceCard(),

                    // ── Budget Progress Card ────────────────────────
                    const BudgetProgressCard(),
                    
                    // ── Upcoming Bill Indicator ─────────────────────
                    const UpcomingBillIndicator(),

                    const SizedBox(height: 28),

                    // ── Section Title: Spending ──
                    Text(
                      l10n.spendingByCategory,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // ── Pie Chart ──────────────────────────────────
                    const CategoryExpenseChart(),

                    const SizedBox(height: 28),


                  ],
                ),
              ),
      ),
    );
  }

  void _updateNativeWidget(WidgetRef ref, double balance) {
    final expenses = ref.read(currentMonthExpensesProvider);
    final budget = ref.read(userBudgetProvider);
    final settingsStr = ref.read(settingsProvider).valueOrNull?.defaultCurrency ?? 'TRY';
    final ex = ref.read(exchangeRateServiceProvider);

    final convertedBalance = ex.convertToSelected(balance, settingsStr);
    final convertedExpenses = ex.convertToSelected(expenses, settingsStr);
    final convertedBudget = ex.convertToSelected(budget, settingsStr);

    WidgetManager.updateWidgetData(
      totalBalance: convertedBalance,
      currentMonthSpent: convertedExpenses,
      currentMonthBudget: convertedBudget,
      currencySymbol: settingsStr.currencySymbol,
    );
  }
}

class _DashboardFilterSelector extends ConsumerWidget {
  const _DashboardFilterSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final selectedMonth = ref.watch(dashboardMonthFilterProvider);
    final locale = ref.watch(settingsProvider.select((s) => s.valueOrNull?.language)) ?? 'en';
    
    final monthLabel = selectedMonth != null 
      ? DateFormat('MMMM yyyy', locale).format(selectedMonth)
      : l10n.all;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: theme.colorScheme.onSurface),
            onPressed: selectedMonth == null ? null : () {
              ref.read(dashboardMonthFilterProvider.notifier).update((state) {
                if (state == null) return null;
                return DateTime(state.year, state.month - 1);
              });
            },
          ),
          // Toggle between "All Time" and Current Month
          GestureDetector(
            onTap: () {
              ref.read(dashboardMonthFilterProvider.notifier).update((state) {
                if (state == null) {
                  final now = DateTime.now();
                  return DateTime(now.year, now.month);
                } else {
                  return null; // All time
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  monthLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface),
            onPressed: selectedMonth == null ? null : () {
              ref.read(dashboardMonthFilterProvider.notifier).update((state) {
                if (state == null) return null;
                return DateTime(state.year, state.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }
}
