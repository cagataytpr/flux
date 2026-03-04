import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/goal_model.dart';
import '../providers/goals_provider.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key, this.existingGoal});

  final Goal? existingGoal;

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedIcon = 'savings';
  String _selectedColorHex = '#4CAF50'; // Default Green

  final Map<String, IconData> _iconOptions = {
    'savings': Icons.savings_rounded,
    'house': Icons.house_rounded,
    'flight': Icons.flight_takeoff_rounded,
    'directions_car': Icons.directions_car_rounded,
    'school': Icons.school_rounded,
    'laptop': Icons.laptop_mac_rounded,
  };

  final List<String> _colorOptions = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#FFC107', // Amber
    '#F44336', // Red
    '#00BCD4', // Cyan
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _nameController.text = widget.existingGoal!.name;
      _targetController.text = widget.existingGoal!.targetAmount.toString();
      _selectedDate = widget.existingGoal!.targetDate;
      _selectedIcon = widget.existingGoal!.icon ?? 'savings';
      _selectedColorHex = widget.existingGoal!.colorHex ?? '#4CAF50';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.tryParse(_targetController.text) ?? 0.0;
      
      if (widget.existingGoal != null) {
        // Edit
        final updated = widget.existingGoal!
          ..name = _nameController.text.trim()
          ..targetAmount = targetAmount
          ..targetDate = _selectedDate
          ..icon = _selectedIcon
          ..colorHex = _selectedColorHex;
        ref.read(goalsProvider.notifier).editGoal(updated);
      } else {
        // Create
        final newGoal = Goal.create(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          targetDate: _selectedDate,
          icon: _selectedIcon,
          colorHex: _selectedColorHex,
        );
        ref.read(goalsProvider.notifier).addGoal(newGoal);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingGoal != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  isEditing ? 'Edit Goal' : 'New Savings Goal',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),

                // Target Amount Input
                TextFormField(
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    prefixIcon: Icon(Icons.track_changes_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded),
                  title: Text(_selectedDate == null
                      ? 'Select Target Date (Optional)'
                      : DateFormat.yMMMd().format(_selectedDate!)),
                  trailing: _selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear), 
                        onPressed: () => setState(() => _selectedDate = null),
                      )
                    : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Icon Picker
                Text('Choose Icon', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _iconOptions.entries.map((entry) {
                      final isSelected = _selectedIcon == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedIcon = entry.key),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected 
                                ? Border.all(color: theme.colorScheme.primary, width: 2)
                                : null,
                            ),
                            child: Icon(
                              entry.value, 
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Color Picker
                Text('Choose Color', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _colorOptions.map((hex) {
                      final isSelected = _selectedColorHex == hex;
                      final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedColorHex = hex),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected 
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                              ],
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEditing ? 'Update Goal' : 'Create Goal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
