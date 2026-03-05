/// Flux Application - History & Insights Screen
///
/// A unified view of all transactions (OCR, Manual, and Subscriptions).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/core/services/database_service.dart';
import 'package:flux/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flux/features/transactions/domain/transaction_model.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/exchange_rate_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

String _categoryLabel(TransactionCategory cat, AppLocalizations l10n) {
  switch (cat) {
    case TransactionCategory.market: return l10n.catMarket;
    case TransactionCategory.food: return l10n.catFood;
    case TransactionCategory.bills: return l10n.catBills;
    case TransactionCategory.salary: return l10n.catSalary;
    case TransactionCategory.investment: return l10n.catInvestment;
    case TransactionCategory.transport: return l10n.catTransport;
    case TransactionCategory.entertainment: return l10n.catEntertainment;
    case TransactionCategory.health: return l10n.catHealth;
  }
}

/// Provider for the currently active category filter
final _historyCategoryFilterProvider = StateProvider<TransactionCategory?>((ref) => null);

/// Derived provider to calculate the total spent this month
final _thisMonthTotalProvider = Provider<double>((ref) {
  final txnsAsync = ref.watch(transactionsProvider);
  return txnsAsync.maybeWhen(
    data: (txns) {
      final now = DateTime.now();
      return txns
          .where((t) {
            final localDate = t.date.toLocal();
            return !t.isIncome && localDate.year == now.year && localDate.month == now.month;
          })
          .fold(0.0, (sum, t) => sum + t.amount);
    },
    orElse: () => 0.0,
  );
});

/// History Screen - Displays a filtered, chronological list of transactions.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final txnsAsync = ref.watch(transactionsProvider);
    final activeCategory = ref.watch(_historyCategoryFilterProvider);
    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Title & Total Spent Card
            _buildHeader(context, ref, sym, l10n),
            
            // Filter Bar
            _buildFilterBar(context, ref, activeCategory, l10n),

            // Transactions List
            Expanded(
              child: txnsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (txns) {
                  // Filter by category
                  var filtered = txns;
                  if (activeCategory != null) {
                    filtered = txns.where((t) => t.category == activeCategory).toList();
                  }

                  // Sort newest first
                  filtered.sort((a, b) => b.date.compareTo(a.date));

                  if (filtered.isEmpty) {
                    return _buildEmptyState(theme, activeCategory != null, l10n);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final txn = filtered[index];
                      return Dismissible(
                        key: ValueKey(txn.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          final isar = ref.read(isarProvider);
                          await isar.writeTxn(() async {
                            await isar.transactions.delete(txn.id);
                          });
                        },
                        child: _HistoryTile(transaction: txn, sym: sym),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String sym, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final totalSpent = ref.watch(_thisMonthTotalProvider);
    final currencyStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final ex = ref.watch(exchangeRateServiceProvider);
    
    final cTotalSpent = ex.convertToSelected(totalSpent, currencyStr);
    final fmt = NumberFormat('#,##0.00', 'tr_TR');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.historyAndInsights,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withValues(alpha: 0.1),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.thisMonth,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$sym${fmt.format(cTotalSpent)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    WidgetRef ref,
    TransactionCategory? activeCategory,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(l10n.all),
              selected: activeCategory == null,
              onSelected: (_) => ref.read(_historyCategoryFilterProvider.notifier).state = null,
            ),
          ),
          ...TransactionCategory.values.map((cat) {
            final isSelected = activeCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _categoryLabel(cat, l10n),
                ),
                selected: isSelected,
                onSelected: (_) => ref.read(_historyCategoryFilterProvider.notifier).state = cat,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isFiltered, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? l10n.noExpensesCategory : l10n.noExpensesYet,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.transaction, required this.sym});
  
  final Transaction transaction;
  final String sym;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(settingsProvider.select((s) => s.valueOrNull?.language)) ?? 'en';
    final dateStr = DateFormat('MMMM d, yyyy', lang).format(transaction.date);
    
    final currencyStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final ex = ref.watch(exchangeRateServiceProvider);
    final cAmount = ex.convertToSelected(transaction.amount, currencyStr);
    final fmt = NumberFormat('#,##0.00', 'tr_TR');
    
    // Determine the icon source emoji
    String sourceEmoji = '✍️';
    if (transaction.isSubscription) {
      sourceEmoji = '🔄';
    } else if (transaction.isAiGenerated) {
      sourceEmoji = '📷';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(sourceEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isIncome ? '+' : '-'}$sym${fmt.format(cAmount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: transaction.isIncome ? Colors.green : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
