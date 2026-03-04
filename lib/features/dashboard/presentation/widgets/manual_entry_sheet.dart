/// Flux Application - Manual Entry Sheet
///
/// A premium form for manually entering transactions into Isar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/database_service.dart';
import '../../../transactions/domain/transaction_model.dart';

/// Shows the manual entry form as a bottom sheet.
void showManualEntrySheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // Allows full height when keyboard appears
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _ManualEntryForm(parentContext: context, ref: ref),
      );
    },
  );
}

class _ManualEntryForm extends StatefulWidget {
  const _ManualEntryForm({required this.parentContext, required this.ref});
  final BuildContext parentContext;
  final WidgetRef ref;

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
      ..isSubscription = false ;

    await isar.writeTxn(() async {
      await isar.transactions.put(txn);
    });

    if (!mounted) return;
    Navigator.pop(context);
    
    if (widget.parentContext.mounted) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Saved "${txn.title}" successfully! 🎉'),
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
                  'Manual Entry',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Type Toggle (Income / Expense)
                _TypeToggle(
                  isIncome: _isIncome,
                  onChanged: (val) => setState(() => _isIncome = val),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Market Alışverişi',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₺)',
                    hintText: 'e.g. 150.50',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final num = double.tryParse(v.replaceAll(',', '.'));
                    if (num == null) return 'Invalid number';
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: TransactionCategory.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
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
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today, size: 20),
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
                  child: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  const _TypeToggle({required this.isIncome, required this.onChanged, required this.theme});
  final bool isIncome;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha:  0.05),
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
                    'Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isIncome ? Colors.white : theme.colorScheme.onSurface.withValues(alpha:  0.5),
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
                    'Income',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.black : theme.colorScheme.onSurface.withValues(alpha:  0.5),
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
