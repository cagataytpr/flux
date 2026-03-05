import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux/l10n/app_localizations.dart';
import '../../../../core/services/exchange_rate_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

import '../providers/dashboard_providers.dart';

/// A card that displays the user's spending against a monthly budget limit.
class BudgetProgressCard extends ConsumerWidget {
  const BudgetProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;
    final ex = ref.watch(exchangeRateServiceProvider);
    
    // Dynamic budget from provider
    final double baseMonthlyBudget = ref.watch(userBudgetProvider);
    final double baseTotalSpent = ref.watch(currentMonthExpensesProvider);

    final double monthlyBudget = ex.convertToSelected(baseMonthlyBudget, settingsStr);
    final double totalSpent = ex.convertToSelected(baseTotalSpent, settingsStr);

    // Handle division by zero
    double progress = 0.0;
    if (monthlyBudget > 0) {
      progress = (totalSpent / monthlyBudget).clamp(0.0, 1.0);
    }
    
    final double remaining = (monthlyBudget - totalSpent).clamp(0.0, monthlyBudget);

    // Determine the color of the progress bar based on utilization
    Color progressColor;
    if (progress < 0.5) {
      progressColor = const Color(0xFF00E5A0); // Mint Green
    } else if (progress < 0.8) {
      progressColor = Colors.orangeAccent;
    } else {
      progressColor = theme.colorScheme.error; // Red
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    l10n.monthlyBudget,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showBudgetDialog(context, ref, baseMonthlyBudget, sym),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.spent,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$sym${totalSpent.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.remaining,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$sym${remaining.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, double currentBudget, String symbol) {
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Monthly Budget'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            decoration: InputDecoration(
              labelText: 'Amount',
              suffixText: symbol,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget = double.tryParse(controller.text);
                if (newBudget != null && newBudget > 0) {
                  ref.read(settingsProvider.notifier).updateMonthlyBudget(newBudget);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
