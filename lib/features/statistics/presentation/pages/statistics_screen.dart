/// Flux Application - Statistics Screen
///
/// Advanced analytics page with premium bar chart, top spending list,
/// and FluxAI category roast card.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/exchange_rate_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../providers/statistics_providers.dart';
import '../widgets/analysis_widgets.dart';
import '../widgets/goals_section.dart';

// ─── Category Visual Config ─────────────────────────────────────────────────

const _categoryIcons = <TransactionCategory, IconData>{
  TransactionCategory.market: Icons.shopping_cart_rounded,
  TransactionCategory.food: Icons.restaurant_rounded,
  TransactionCategory.bills: Icons.receipt_long_rounded,
  TransactionCategory.salary: Icons.account_balance_wallet_rounded,
  TransactionCategory.investment: Icons.trending_up_rounded,
  TransactionCategory.transport: Icons.directions_car_rounded,
  TransactionCategory.entertainment: Icons.movie_rounded,
  TransactionCategory.health: Icons.favorite_rounded,
};

const _categoryColors = <TransactionCategory, Color>{
  TransactionCategory.market: Color(0xFF00E5A0),
  TransactionCategory.food: Color(0xFFFF6B6B),
  TransactionCategory.bills: Color(0xFFFFD93D),
  TransactionCategory.salary: Color(0xFF6BCB77),
  TransactionCategory.investment: Color(0xFF7C4DFF),
  TransactionCategory.transport: Color(0xFF4ECDC4),
  TransactionCategory.entertainment: Color(0xFFFF6B8A),
  TransactionCategory.health: Color(0xFF45B7D1),
};

String _categoryLabel(TransactionCategory cat, AppLocalizations l10n) {
  switch (cat) {
    case TransactionCategory.market:
      return l10n.catMarket;
    case TransactionCategory.food:
      return l10n.catFood;
    case TransactionCategory.bills:
      return l10n.catBills;
    case TransactionCategory.salary:
      return l10n.catSalary;
    case TransactionCategory.investment:
      return l10n.catInvestment;
    case TransactionCategory.transport:
      return l10n.catTransport;
    case TransactionCategory.entertainment:
      return l10n.catEntertainment;
    case TransactionCategory.health:
      return l10n.catHealth;
  }
}

// ─── Statistics Screen ──────────────────────────────────────────────────────

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final spendingRaw = ref.watch(categorySpendingProvider);
    final totalSpentRaw = ref.watch(filteredExpensesProvider);
    final budgetRaw = ref.watch(userBudgetProvider);
    
    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;
    final ex = ref.watch(exchangeRateServiceProvider);

    final totalSpent = ex.convertToSelected(totalSpentRaw, settingsStr);
    final budget = ex.convertToSelected(budgetRaw, settingsStr);
    
    final spending = spendingRaw.map((s) => CategorySpending(
      category: s.category,
      amount: ex.convertToSelected(s.amount, settingsStr),
      percentage: s.percentage,
    )).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Month Selector (Always Visible) ──
            _MonthSelector(theme: theme, settingsStr: settingsStr),

            Expanded(
              child: spending.isEmpty
                  ? _buildEmptyState(theme, l10n)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      children: [
                        // ── Gamification: Streak Badge (Only show if positive) ──
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: StreakBadge(),
                        ),
                        const SizedBox(height: 16),

                        // ── Header Summary ──
                        _SummaryHeader(
                          totalSpent: totalSpent,
                          budget: budget,
                          theme: theme,
                          sym: sym,
                          l10n: l10n,
                        ),

                        const SizedBox(height: 16),

                        // ── Cash Flow Forecast Card ──
                        const CashFlowForecastCard(),

                        const SizedBox(height: 16),

                        // ── FluxAI Category Roast ──
                        _FluxAiRoastCard(theme: theme, l10n: l10n),

                        const SizedBox(height: 24),

                        // ── Bar Chart ──
                        Text(
                          l10n.spendingByCategory,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SpendingBarChart(spending: spending, theme: theme, sym: sym, l10n: l10n),

                        const SizedBox(height: 28),

                        // ── Top Spending List ──
                        Text(
                          l10n.spendingRank,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...spending.asMap().entries.map(
                          (entry) => _SpendingRankTile(
                            rank: entry.key + 1,
                            spending: entry.value,
                            budget: budget,
                            theme: theme,
                            sym: sym,
                            l10n: l10n,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Savings Goals Section ──
                        const GoalsSection(),

                        const SizedBox(height: 32),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyAnalytics,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Header ─────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.totalSpent,
    required this.budget,
    required this.theme,
    required this.sym,
    required this.l10n,
  });

  final double totalSpent;
  final double budget;
  final ThemeData theme;
  final String sym;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final remaining = budget - totalSpent;
    final progress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;

    Color progressColor;
    if (progress < 0.5) {
      progressColor = const Color(0xFF00E5A0);
    } else if (progress < 0.75) {
      progressColor = const Color(0xFFFFB300);
    } else {
      progressColor = const Color(0xFFFF4081);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.spentThisMonth,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sym${totalSpent.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                     l10n.remaining,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sym${remaining.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: remaining >= 0
                          ? const Color(0xFF00E5A0)
                          : const Color(0xFFFF4081),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bar Chart ──────────────────────────────────────────────────────────────

class _SpendingBarChart extends StatelessWidget {
  const _SpendingBarChart({
    required this.spending,
    required this.theme,
    required this.sym,
    required this.l10n,
  });

  final List<CategorySpending> spending;
  final ThemeData theme;
  final String sym;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final maxAmount = spending.isNotEmpty
        ? spending.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final cat = spending[group.x.toInt()].category;
                return BarTooltipItem(
                  '${_categoryLabel(cat, l10n)}\n$sym${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= spending.length) return const SizedBox.shrink();
                  final cat = spending[idx].category;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      _categoryIcons[cat] ?? Icons.category_rounded,
                      size: 18,
                      color: _categoryColors[cat] ?? theme.colorScheme.primary,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: spending.asMap().entries.map((entry) {
            final color = _categoryColors[entry.value.category] ??
                theme.colorScheme.primary;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.amount,
                  color: color,
                  width: spending.length <= 4 ? 28 : 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxAmount * 1.2,
                    color: color.withValues(alpha: 0.06),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

// ─── Spending Rank Tile ─────────────────────────────────────────────────────

class _SpendingRankTile extends StatelessWidget {
  const _SpendingRankTile({
    required this.rank,
    required this.spending,
    required this.budget,
    required this.theme,
    required this.sym,
    required this.l10n,
  });

  final int rank;
  final CategorySpending spending;
  final double budget;
  final ThemeData theme;
  final String sym;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[spending.category] ?? theme.colorScheme.primary;
    final icon = _categoryIcons[spending.category] ?? Icons.category_rounded;
    final label = _categoryLabel(spending.category, l10n);
    final budgetPercent = budget > 0
        ? (spending.amount / budget * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Label + percentage bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: spending.percentage,
                    minHeight: 5,
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Amount + budget %
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sym${spending.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.budgetPercentage(budgetPercent),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── FluxAI Roast Card ──────────────────────────────────────────────────────

class _FluxAiRoastCard extends ConsumerWidget {
  const _FluxAiRoastCard({required this.theme, required this.l10n});

  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roastAsync = ref.watch(categoryRoastProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.whatshot_rounded,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.fluxAiRealityCheck,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              // Manual Refresh Button
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                tooltip: l10n.refresh,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => ref.invalidate(categoryRoastProvider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          roastAsync.when(
            loading: () => Text(
              l10n.analyzingSpending,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            error: (_, __) => Text(
              l10n.analysisFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            data: (roast) => Text(
              roast,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Month Selector ─────────────────────────────────────────────────────────

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.theme, required this.settingsStr});
  final ThemeData theme;
  final String settingsStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final locale = ref.watch(settingsProvider.select((s) => s.valueOrNull?.language)) ?? 'en';
    
    // Format: 'September 2026' or 'Eylül 2026'
    final label = DateFormat('MMMM yyyy', locale).format(selectedMonth);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).update((state) {
                return DateTime(state.year, state.month - 1);
              });
            },
          ),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).update((state) {
                return DateTime(state.year, state.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }
}
