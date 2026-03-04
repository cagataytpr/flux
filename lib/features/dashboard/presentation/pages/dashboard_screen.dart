/// Flux Application - Dashboard Screen
///
/// The main screen showing balance, expense chart, and AI insights.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flux/features/subscriptions/domain/subscription_model.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../router/app_router.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/action_bottom_sheet.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/category_expense_chart.dart';

/// Main dashboard screen of the Flux application.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for budget threshold crossing (75% of mock 20,000 budget)
    ref.listen<double>(currentMonthExpensesProvider, (previous, current) {
      const budget = 20000.0;
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
            ? _EmptyState(theme: theme)
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(transactionsProvider);
                  ref.invalidate(savingsTipsProvider);
                  ref.invalidate(fluxAiAdviceProvider);
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
                    const _UpcomingBillIndicator(),

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

                    // ── Section Title: AI ──
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('FluxAI Insights',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── AI Insight Card ────────────────────────────
                    const AiInsightCard(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Glowing icon ──
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha:  0.15),
                    theme.colorScheme.secondary.withValues(alpha:  0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha:  0.25),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 52,
                color: theme.colorScheme.primary.withValues(alpha:  0.7),
              ),
            ),

            const SizedBox(height: 36),

            // ── Title ──
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ).createShader(bounds),
              child: Text(
                'Welcome to Flux',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white, // masked by shader
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Subtitle ──
            Text(
              'Tap the scan button to capture\nyour first receipt',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // ── Animated hint arrow ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 12),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              builder: (_, value, child) {
                // Bounce by restarting the builder
                return Padding(
                  padding: EdgeInsets.only(top: value),
                  child: child,
                );
              },
              child: Icon(
                Icons.keyboard_double_arrow_down_rounded,
                size: 28,
                color: theme.colorScheme.primary.withValues(alpha:  0.4),
              ),
              onEnd: () {
                // Restart animation handled by parent rebuild
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pie Chart
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Upcoming Bill Indicator
// ---------------------------------------------------------------------------

class _UpcomingBillIndicator extends ConsumerWidget {
  const _UpcomingBillIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subsAsync = ref.watch(subscriptionsProvider);

    return subsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (subs) {
        if (subs.isEmpty) return const SizedBox.shrink();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Find the subscription with the closest billing date
        Subscription? nextSub;
        int minDays = 9999;

        for (final sub in subs) {
          final billing = DateTime(sub.nextBillingDate.year,
              sub.nextBillingDate.month, sub.nextBillingDate.day);
          final daysLeft = billing.difference(today).inDays;

          if (daysLeft >= 0 && daysLeft < minDays) {
            minDays = daysLeft;
            nextSub = sub;
          }
        }

        if (nextSub == null) return const SizedBox.shrink();

        final String dueText;
        if (minDays == 0) {
          dueText = '${nextSub.name} is due today.';
        } else if (minDays == 1) {
          dueText = '${nextSub.name} is due tomorrow.';
        } else {
          dueText = '${nextSub.name} is due in $minDays days.';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Payment',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dueText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₺${nextSub.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

