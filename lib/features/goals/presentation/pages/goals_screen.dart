import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/exchange_rate_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

import '../../domain/goal_model.dart';
import '../providers/goals_provider.dart';
import '../widgets/add_goal_sheet.dart';

/// The screen displaying all user savings goals.
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  final Map<String, IconData> _iconMapping = {
    'savings': Icons.savings_rounded,
    'house': Icons.house_rounded,
    'flight': Icons.flight_takeoff_rounded,
    'directions_car': Icons.directions_car_rounded,
    'school': Icons.school_rounded,
    'laptop': Icons.laptop_mac_rounded,
  };

  void _showAddGoalSheet([Goal? existingGoal]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (ctx) => AddGoalSheet(existingGoal: existingGoal),
    );
  }

  void _showAddFundsDialog(Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add to ${goal.name}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Amount',
              suffixText: goal.currency,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  ref.read(goalsProvider.notifier).addFunds(goal.id, amount);
                  // Check if this triggers a completion celebration
                  if (goal.currentAmount + amount >= goal.targetAmount && goal.currentAmount < goal.targetAmount) {
                     _confettiController.play();
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _calculateMotivationText(Goal goal) {
    if (goal.currentAmount >= goal.targetAmount) {
      return 'Goal Achieved! 🎉';
    }
    
    if (goal.targetDate == null) {
      final remaining = goal.targetAmount - goal.currentAmount;
      return '${NumberFormat.compact().format(remaining)} ${goal.currency} left to go!';
    }

    final daysRemaining = goal.targetDate!.difference(DateTime.now()).inDays;
    if (daysRemaining <= 0) {
      return 'Target date reached. Time to evaluate!';
    }

    final dailyTarget = (goal.targetAmount - goal.currentAmount) / daysRemaining;
    return 'Save ${NumberFormat.simpleCurrency(name: goal.currency, decimalDigits: 0).format(dailyTarget)} / day to reach it in time.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(goalsProvider);
    final currencyStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final ex = ref.watch(exchangeRateServiceProvider);
    final fmt = NumberFormat('#,##0.00', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddGoalSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          goalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (goals) {
              if (goals.isEmpty) {
                return _buildEmptyState(theme);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final color = Color(int.parse((goal.colorHex ?? '#4CAF50').replaceFirst('#', '0xFF')));
                  final iconData = _iconMapping[goal.icon] ?? Icons.flag_rounded;
                  final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                  final isComplete = progress >= 1.0;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: color.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    color: color.withValues(alpha: 0.05),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showAddGoalSheet(goal),
                      onLongPress: () {
                        // Confirm delete
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete Goal?'),
                            content: Text('Are you sure you want to delete ${goal.name}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                                  Navigator.pop(c);
                                },
                                child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                              ),
                            ],
                          )
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(iconData, color: color, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _calculateMotivationText(goal),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isComplete ? color : theme.colorScheme.onSurfaceVariant,
                                          fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isComplete)
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(
                                      backgroundColor: color.withValues(alpha: 0.2),
                                      foregroundColor: color,
                                    ),
                                    icon: const Icon(Icons.add_rounded),
                                    onPressed: () => _showAddFundsDialog(goal),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fmt.format(ex.convertToSelected(goal.currentAmount, currencyStr)),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  fmt.format(ex.convertToSelected(goal.targetAmount, currencyStr)),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                backgroundColor: color.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Savings Goals Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start dreaming! Whether it's a new car, a vacation, or an emergency fund, track it here.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddGoalSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Goal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
