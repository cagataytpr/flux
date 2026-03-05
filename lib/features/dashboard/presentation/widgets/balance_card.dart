/// Flux Application - Balance Card Widget
///
/// Sleek, glowing card showing total balance, income, and expenses.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_ext.dart';
import '../../../../core/services/exchange_rate_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

import '../providers/dashboard_providers.dart';

/// A premium dark-glass balance card with a soft glow effect.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final balance = ref.watch(totalBalanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expenses = ref.watch(totalExpensesProvider);
    final isPositive = balance >= 0;

    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;
    final ex = ref.watch(exchangeRateServiceProvider);

    final cBalance = ex.convertToSelected(balance, settingsStr);
    final cIncome = ex.convertToSelected(income, settingsStr);
    final cExpenses = ex.convertToSelected(expenses, settingsStr);

    final fmt = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha:  0.15),
            theme.colorScheme.secondary.withValues(alpha:  0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha:  0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha:  0.20),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha:  0.10),
            blurRadius: 48,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──
          Text(
            'Total Balance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // ── Balance Amount ──
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isPositive
                    ? const Color(0xFF00E5A0)
                    : theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${isPositive ? '+' : ''}$sym${fmt.format(cBalance)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: isPositive
                          ? const Color(0xFF00E5A0)
                          : theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Income / Expense Row ──
          Row(
            children: [
              _MiniStat(
                icon: Icons.arrow_downward_rounded,
                iconColor: const Color(0xFF00E5A0),
                label: 'Income',
                value: '$sym${fmt.format(cIncome)}',
              ),
              const SizedBox(width: 24),
              _MiniStat(
                icon: Icons.arrow_upward_rounded,
                iconColor: theme.colorScheme.error,
                label: 'Expenses',
                value: '$sym${fmt.format(cExpenses)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini Stat chip used inside the card
// ---------------------------------------------------------------------------

class _MiniStat extends ConsumerWidget {
  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha:  0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      ],
    );
  }
}
