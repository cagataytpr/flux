/// Flux Application - Receipt Confirm Sheet
///
/// A sleek BottomSheet showing AI-extracted receipt data with a save button
/// and smart subscription detection toggle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../subscriptions/domain/subscription_model.dart';
import '../../../transactions/domain/transaction_model.dart';

// ---------------------------------------------------------------------------
// Result record returned by the sheet
// ---------------------------------------------------------------------------

/// Holds the save result: always a [Transaction], optionally a [Subscription].
class ReceiptSaveResult {
  ReceiptSaveResult({
    required this.transaction,
    this.subscription,
  });

  final Transaction transaction;
  final Subscription? subscription;
}

// ---------------------------------------------------------------------------
// Known subscription merchant keywords
// ---------------------------------------------------------------------------

const _subscriptionKeywords = [
  'netflix',
  'spotify',
  'youtube',
  'disney',
  'hbo',
  'apple',
  'icloud',
  'amazon prime',
  'hulu',
  'gym',
  'fitness',
  'adobe',
  'microsoft',
  'office 365',
  'google one',
  'chatgpt',
  'openai',
  'dropbox',
  'evernote',
  'notion',
  'canva',
  'twitch',
  'crunchyroll',
  'deezer',
  'tidal',
];

bool _looksLikeSubscription(String title) {
  final lower = title.toLowerCase();
  return _subscriptionKeywords.any((kw) => lower.contains(kw));
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

/// Displays the AI-parsed receipt data and returns a [ReceiptSaveResult]
/// when the user taps **Save**, or `null` if dismissed.
class ReceiptConfirmSheet extends ConsumerStatefulWidget {
  const ReceiptConfirmSheet({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  ConsumerState<ReceiptConfirmSheet> createState() => _ReceiptConfirmSheetState();
}

class _ReceiptConfirmSheetState extends ConsumerState<ReceiptConfirmSheet> {
  late String _title;
  late double _amount;
  late DateTime _date;
  late TransactionCategory _category;
  late bool _isSubscription;

  @override
  void initState() {
    super.initState();
    _title = (widget.data['title'] as String?) ?? 'Unknown';
    _amount = ((widget.data['amount'] ?? 0) as num).toDouble();
    _date = _parseDate(widget.data['date']);
    _category = _mapCategory(widget.data['category']);
    _isSubscription = _looksLikeSubscription(_title);
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is String) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {}
    }
    return DateTime.now().toLocal();
  }

  TransactionCategory _mapCategory(dynamic raw) {
    if (raw is String) {
      final lower = raw.toLowerCase().trim();
      for (final cat in TransactionCategory.values) {
        if (cat.name == lower) return cat;
      }
      if (lower.contains('grocer') ||
          lower.contains('market') ||
          lower.contains('supermarket')) {
        return TransactionCategory.market;
      }
      if (lower.contains('food') ||
          lower.contains('restaurant') ||
          lower.contains('cafe')) {
        return TransactionCategory.food;
      }
      if (lower.contains('bill') ||
          lower.contains('utility') ||
          lower.contains('electric')) {
        return TransactionCategory.bills;
      }
      if (lower.contains('transport') ||
          lower.contains('uber') ||
          lower.contains('fuel') ||
          lower.contains('gas')) {
        return TransactionCategory.transport;
      }
      if (lower.contains('health') ||
          lower.contains('pharmacy') ||
          lower.contains('medic')) {
        return TransactionCategory.health;
      }
      if (lower.contains('entertain') ||
          lower.contains('movie') ||
          lower.contains('game')) {
        return TransactionCategory.entertainment;
      }
    }
    return TransactionCategory.market;
  }

  void _onSave() {
    final transaction = Transaction.create(
      title: _title,
      amount: _amount,
      date: _date,
      category: _category,
      isIncome: false,
      isAiGenerated: true,
      isSubscription: false,
    );

    Subscription? subscription;
    if (_isSubscription) {
      // Next billing = same day next month.
      final nextBilling = DateTime(
        _date.year,
        _date.month + 1,
        _date.day,
      );
      subscription = Subscription.create(
        name: _title,
        amount: _amount,
        nextBillingDate: nextBilling,
        reminderDays: 3,
        cycle: SubscriptionCycle.monthly,
        category: _category.name,
      );
    }

    Navigator.of(context).pop(
      ReceiptSaveResult(
        transaction: transaction,
        subscription: subscription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final settingsStr = ref.watch(settingsProvider).valueOrNull?.defaultCurrency ?? 'TRY';
    final sym = settingsStr.currencySymbol;
    final dateStr = DateFormat.yMMMd().format(_date);
    final catLabel =
        _category.name[0].toUpperCase() + _category.name.substring(1);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Handle ──
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha:  0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // ── Header ──
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Receipt Scanned',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Review the details below',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha:  0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Data Rows ──
              _DataRow(
                  icon: Icons.storefront_rounded,
                  label: 'Company',
                  value: _title,
                  theme: theme),
              const SizedBox(height: 14),
              _DataRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Amount',
                  value: '$sym${_amount.toStringAsFixed(2)}',
                  theme: theme,
                  valueColor: theme.colorScheme.error),
              const SizedBox(height: 14),
              _DataRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: dateStr,
                  theme: theme,
                  onTap: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (newDate != null) {
                      setState(() => _date = newDate);
                    }
                  }),
              const SizedBox(height: 14),
              _DataRow(
                  icon: Icons.category_rounded,
                  label: 'Category',
                  value: catLabel,
                  theme: theme),

              // ── Subscription Toggle ──
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: _isSubscription
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha:  0.10),
                            theme.colorScheme.secondary
                                .withValues(alpha:  0.06),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: _isSubscription
                        ? theme.colorScheme.primary.withValues(alpha:  0.3)
                        : theme.dividerColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 20,
                      color: _isSubscription
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface
                              .withValues(alpha:  0.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Repeat Monthly?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isSubscription,
                      onChanged: (v) => setState(() => _isSubscription = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(_isSubscription
                      ? 'Save Transaction & Subscription'
                      : 'Save Transaction'),
                  style: FilledButton.styleFrom(
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data Row helper
// ---------------------------------------------------------------------------

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.dividerColor,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.edit_rounded,
                  size: 14,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            ],
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
