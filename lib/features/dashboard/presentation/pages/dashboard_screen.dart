/// Flux Application - Dashboard Screen
///
/// The main screen showing balance, expense chart, and AI insights.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../router/app_router.dart';
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

    final theme = Theme.of(context);
    final txnsAsync = ref.watch(transactionsProvider);
    final isEmpty =
        txnsAsync.valueOrNull == null || txnsAsync.valueOrNull!.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_outlined),
            tooltip: 'Subscriptions',
            onPressed: () => context.push(RoutePaths.subscriptions),
          ),
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
              color: theme.colorScheme.primary.withValues(alpha:  0.45),
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
                    // ── Balance Card ────────────────────────────────
                    const BalanceCard(),

                    // ── Budget Progress Card ────────────────────────
                    const BudgetProgressCard(),
                    
                    // ── Upcoming Bill Indicator ─────────────────────
                    const UpcomingBillIndicator(),

                    const SizedBox(height: 28),

                    // ── Section Title: Spending ──
                    Text(
                      'Spending by Category',
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
}
