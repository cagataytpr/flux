/// Flux Application - Add Subscription Sheet
///
/// A premium form for manually entering a recurring subscription into Isar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../domain/subscription_model.dart';

/// Shows the manual entry form for subscriptions as a bottom sheet.
void showAddSubscriptionSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // Allows full height when keyboard appears
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _AddSubscriptionForm(parentContext: context, ref: ref),
      );
    },
  );
}

class _AddSubscriptionForm extends StatefulWidget {
  const _AddSubscriptionForm({required this.parentContext, required this.ref});
  final BuildContext parentContext;
  final WidgetRef ref;

  @override
  State<_AddSubscriptionForm> createState() => _AddSubscriptionFormState();
}

class _AddSubscriptionFormState extends State<_AddSubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Streaming';
  
  final List<String> _categories = [
    'Streaming',
    'Rent',
    'Software',
    'Utilities',
    'Internet/Phone',
    'Gym',
    'Insurance',
    'Other'
  ];

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

    final sub = Subscription.create(
      name: _titleController.text.trim(),
      amount: amount,
      nextBillingDate: _selectedDate,
      reminderDays: 3,
      cycle: SubscriptionCycle.monthly,
      category: _selectedCategory,
    );

    // Also record the first instance of this payment as an immediate transaction history item
    final initialTxn = Transaction.create(
      title: _titleController.text.trim(),
      amount: amount,
      date: DateTime.now(),
      category: TransactionCategory.bills, // Default mapping for manual subs
      isIncome: false,
      isSubscription: true,
    );

    await isar.writeTxn(() async {
      await isar.subscriptions.put(sub);
      await isar.transactions.put(initialTxn);
    });

    if (!mounted) return;
    Navigator.pop(context);
    
    if (widget.parentContext.mounted) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Saved "${sub.name}" successfully! 🎉'),
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
      firstDate: DateTime.now(),
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
    final settingsStr = widget.ref.watch(settingsProvider).valueOrNull?.defaultCurrency ?? 'TRY';
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
                  'Add Subscription',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    hintText: 'e.g. Netflix, Rent',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Monthly Cost ($sym)',
                    hintText: 'e.g. 150.50',
                    prefixIcon: const Icon(Icons.attach_money),
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

                // Category Dropdown
                DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),
                
                // Next Billing Date
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Next Billing Date',
                      prefixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
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
                  child: const Text('Save Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
