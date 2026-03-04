/// Flux Application - Dashboard Screen
///
/// The main screen showing balance, expense chart, and AI insights.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flux/features/subscriptions/domain/subscription_model.dart';

import '../../../../router/app_router.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/action_bottom_sheet.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/balance_card.dart';

/// Primary color palette for the pie-chart slices.
const _chartColors = <TransactionCategory, Color>{
  TransactionCategory.market: Color(0xFF7C4DFF), // Deep Purple
  TransactionCategory.food: Color(0xFF00E5A0), // Mint Green
  TransactionCategory.bills: Color(0xFF2979FF), // Electric Blue
  TransactionCategory.salary: Color(0xFFFFD740), // Amber
  TransactionCategory.investment: Color(0xFF00E5FF), // Cyan
  TransactionCategory.transport: Color(0xFFFF6E40), // Deep Orange
  TransactionCategory.entertainment: Color(0xFFE040FB), // Purple Accent
  TransactionCategory.health: Color(0xFF69F0AE), // Green Accent
};

/// Main dashboard screen of the Flux application.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                    const SizedBox(height: 16),
                    
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
                    _ExpensePieChart(),

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

class _ExpensePieChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(expenseByCategoryProvider);

    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor, width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart_outline_rounded,
                  size: 48,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha:  0.3)),
              const SizedBox(height: 12),
              Text(
                'No expenses yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha:  0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalExpense = data.values.fold(0.0, (a, b) => a + b);

    final sections = data.entries.map((e) {
      final pct = (e.value / totalExpense * 100);
      final color = _chartColors[e.key] ?? theme.colorScheme.primary;

      return PieChartSectionData(
        value: e.value,
        color: color,
        radius: 56,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.keys.map((cat) {
              final color = _chartColors[cat] ?? theme.colorScheme.primary;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name[0].toUpperCase() + cat.name.substring(1),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

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

