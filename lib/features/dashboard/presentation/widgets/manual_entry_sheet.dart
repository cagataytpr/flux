/// Flux Application - Manual Entry Sheet
///
/// A premium form for manually entering transactions into Isar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../subscriptions/domain/subscription_model.dart';
import '../../../transactions/domain/transaction_model.dart';

/// Shows the manual entry form as a bottom sheet.
void showManualEntrySheet(BuildContext context, WidgetRef ref, {bool isSubscription = false}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // Allows full height when keyboard appears
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _ManualEntryForm(parentContext: context, ref: ref, initialIsSubscription: isSubscription),
      );
    },
  );
}

class _ManualEntryForm extends StatefulWidget {
  const _ManualEntryForm({required this.parentContext, required this.ref, this.initialIsSubscription = false});
  final BuildContext parentContext;
  final WidgetRef ref;
  final bool initialIsSubscription;

  @override
  State<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<_ManualEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TransactionCategory _selectedCategory = TransactionCategory.market;
  bool _isIncome = false;
  late bool _isSubscription;
  SubscriptionCycle _selectedCycle = SubscriptionCycle.monthly;

  @override
  void initState() {
    super.initState();
    _isSubscription = widget.initialIsSubscription;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isar = widget.ref.read(isarProvider);
    final rawAmount = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(rawAmount) ?? 0.0;

    final txn = Transaction()
      ..title = _titleController.text.trim()
      ..amount = amount
      ..date = _selectedDate
      ..category = _selectedCategory
      ..isIncome = _isIncome
      ..isAiGenerated = false
      ..isSubscription = _isSubscription;

    Subscription? sub;
    if (_isSubscription) {
      sub = Subscription.create(
        name: txn.title,
        amount: amount,
        nextBillingDate: _selectedDate,
        reminderDays: 3,
        cycle: _selectedCycle,
        category: _selectedCategory.name,
      );
    }

    await isar.writeTxn(() async {
      await isar.transactions.put(txn);
      if (sub != null) {
        await isar.subscriptions.put(sub);
      }
    });

    if (!mounted) return;
    Navigator.pop(context);
    
    if (widget.parentContext.mounted) {
      final l10n = AppLocalizations.of(widget.parentContext)!;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(l10n.savedSuccessfully(txn.title)),
          backgroundColor: const Color(0xFF00E5A0),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settingsStr = widget.ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24, bottom: 40, left: 24, right: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle pill
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  _isSubscription ? l10n.addSubscriptionTitle : l10n.manualEntry,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Type Toggle (Income / Expense) or Cycle Toggle
                if (_isSubscription)
                  _CycleToggle(
                    cycle: _selectedCycle,
                    onChanged: (val) => setState(() => _selectedCycle = val),
                    theme: theme,
                    l10n: l10n,
                  )
                else
                  _TypeToggle(
                    isIncome: _isIncome,
                    onChanged: (val) => setState(() => _isIncome = val),
                    theme: theme,
                    l10n: l10n,
                  ),
                const SizedBox(height: 24),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.titleLabel,
                    hintText: l10n.titleHint,
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amountLabel(sym),
                    hintText: l10n.amountHint,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.requiredField;
                    final num = double.tryParse(v.replaceAll(',', '.'));
                    if (num == null) return l10n.invalidNumber;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category & Date Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<TransactionCategory>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: l10n.categoryLabel,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: TransactionCategory.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(_categoryLabel(c, l10n)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.dateLabel,
                            prefixIcon: const Icon(Icons.calendar_today, size: 20),
                          ),
                          child: Text(
                            DateFormat('dd MMM').format(_selectedDate),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subscription Toggle
                SwitchListTile.adaptive(
                  title: Text(
                    l10n.recurringSubscription,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    l10n.recurringSubscriptionDesc,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  value: _isSubscription,
                  activeTrackColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() {
                      _isSubscription = val;
                      if (val) _isIncome = false; // Subscriptions are always expenses for now
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_isSubscription ? l10n.saveSubscription : l10n.saveTransaction, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.isIncome, required this.onChanged, required this.theme, required this.l10n});
  final bool isIncome;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isIncome ? theme.colorScheme.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l10n.expenseType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isIncome ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xFF00E5A0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l10n.incomeType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.black : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleToggle extends StatelessWidget {
  const _CycleToggle({required this.cycle, required this.onChanged, required this.theme, required this.l10n});
  final SubscriptionCycle cycle;
  final ValueChanged<SubscriptionCycle> onChanged;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(SubscriptionCycle.monthly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cycle == SubscriptionCycle.monthly ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l10n.monthlyCycle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cycle == SubscriptionCycle.monthly ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(SubscriptionCycle.yearly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cycle == SubscriptionCycle.yearly ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l10n.yearlyCycle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cycle == SubscriptionCycle.yearly ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
