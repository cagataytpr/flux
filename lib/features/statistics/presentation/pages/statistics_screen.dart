/// Flux Application - Statistics Screen
///
/// Advanced analytics page with premium bar chart, top spending list,
/// and FluxAI category roast card.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../providers/statistics_providers.dart';

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

String _categoryLabel(TransactionCategory cat) {
  switch (cat) {
    case TransactionCategory.market:
      return 'Market';
    case TransactionCategory.food:
      return 'Yemek';
    case TransactionCategory.bills:
      return 'Faturalar';
    case TransactionCategory.salary:
      return 'Maaş';
    case TransactionCategory.investment:
      return 'Yatırım';
    case TransactionCategory.transport:
      return 'Ulaşım';
    case TransactionCategory.entertainment:
      return 'Eğlence';
    case TransactionCategory.health:
      return 'Sağlık';
  }
}

// ─── Statistics Screen ──────────────────────────────────────────────────────

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spending = ref.watch(categorySpendingProvider);
    final totalSpent = ref.watch(currentMonthExpensesProvider);
    final budget = ref.watch(userBudgetProvider);
    final settingsStr = ref.watch(settingsProvider).valueOrNull?.defaultCurrency ?? 'TRY';
    final sym = settingsStr.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: spending.isEmpty
            ? _buildEmptyState(theme)
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // ── Header Summary ──
                  _SummaryHeader(
                    totalSpent: totalSpent,
                    budget: budget,
                    theme: theme,
                    sym: sym,
                  ),

                  const SizedBox(height: 16),

                  // ── FluxAI Category Roast ──
                  _FluxAiRoastCard(theme: theme),

                  const SizedBox(height: 24),

                  // ── Bar Chart ──
                  Text(
                    'Kategori Bazlı Harcamalar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SpendingBarChart(spending: spending, theme: theme, sym: sym),

                  const SizedBox(height: 28),

                  // ── Top Spending List ──
                  Text(
                    'Harcama Sıralaması',
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
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            'Henüz analiz için yeterli veri yok.\nHarcama ekleyerek başla!',
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
  });

  final double totalSpent;
  final double budget;
  final ThemeData theme;
  final String sym;

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
                      'Bu Ay Harcanan',
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
                    'Kalan',
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
  });

  final List<CategorySpending> spending;
  final ThemeData theme;
  final String sym;

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
                  '${_categoryLabel(cat)}\n$sym${rod.toY.toStringAsFixed(0)}',
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
  });

  final int rank;
  final CategorySpending spending;
  final double budget;
  final ThemeData theme;
  final String sym;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[spending.category] ?? theme.colorScheme.primary;
    final icon = _categoryIcons[spending.category] ?? Icons.category_rounded;
    final label = _categoryLabel(spending.category);
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
                '%$budgetPercent bütçe',
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
  const _FluxAiRoastCard({required this.theme});

  final ThemeData theme;

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
                  'FluxAI Reality Check',
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
                tooltip: 'Yenile',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => ref.invalidate(categoryRoastProvider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          roastAsync.when(
            loading: () => Text(
              'Harcamaların analiz ediliyor...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            error: (_, __) => Text(
              'Analiz şu an yapılamıyor.',
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
