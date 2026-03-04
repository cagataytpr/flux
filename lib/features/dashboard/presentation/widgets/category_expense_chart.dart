import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/transaction_model.dart';
import '../providers/dashboard_providers.dart';

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

class CategoryExpenseChart extends ConsumerWidget {
  const CategoryExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(currentMonthExpenseByCategoryProvider);

    if (data.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No expenses this month yet 💸',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
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
        radius: 60,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 4,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: data.keys.map((cat) {
              final color = _chartColors[cat] ?? theme.colorScheme.primary;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name[0].toUpperCase() + cat.name.substring(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
