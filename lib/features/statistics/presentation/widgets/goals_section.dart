import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/exchange_rate_service.dart';
import '../../../goals/domain/goal_model.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../goals/presentation/widgets/add_goal_sheet.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class GoalsSection extends ConsumerStatefulWidget {
  const GoalsSection({super.key});

  @override
  ConsumerState<GoalsSection> createState() => _GoalsSectionState();
}

class _GoalsSectionState extends ConsumerState<GoalsSection> {
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
          title: Text(AppLocalizations.of(context)!.addToGoal(goal.name)),
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  ref.read(goalsProvider.notifier).addFunds(goal.id, amount);
                  if (goal.currentAmount + amount >= goal.targetAmount && goal.currentAmount < goal.targetAmount) {
                     _confettiController.play();
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  String _calculateMotivationText(Goal goal, AppLocalizations l10n) {
    if (goal.currentAmount >= goal.targetAmount) return l10n.goalAchieved;
    if (goal.targetDate == null) {
      final remaining = goal.targetAmount - goal.currentAmount;
      return l10n.goalLeftToGo('${NumberFormat.compact().format(remaining)} ${goal.currency}');
    }
    final daysRemaining = goal.targetDate!.difference(DateTime.now()).inDays;
    if (daysRemaining <= 0) return l10n.goalTargetDateReached;
    final dailyTarget = (goal.targetAmount - goal.currentAmount) / daysRemaining;
    return l10n.goalSavePerDay(NumberFormat.simpleCurrency(name: goal.currency, decimalDigits: 0).format(dailyTarget));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(goalsProvider);
    final currencyStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final ex = ref.watch(exchangeRateServiceProvider);
    final fmt = NumberFormat('#,##0.00', 'tr_TR');

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.savingsGoals,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddGoalSheet,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(l10n.add),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (goals) {
                if (goals.isEmpty) {
                  return _buildEmptyState(theme, l10n);
                }
                return Column(
                  children: goals.map((goal) {
                    final color = Color(int.parse((goal.colorHex ?? '#4CAF50').replaceFirst('#', '0xFF')));
                    final iconData = _iconMapping[goal.icon] ?? Icons.flag_rounded;
                    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                    final isComplete = progress >= 1.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          showDialog(
                            context: context,
                            builder: (c) {
                              final localL10n = AppLocalizations.of(c)!;
                              return AlertDialog(
                                title: Text(localL10n.deleteGoal),
                                content: Text(localL10n.deleteGoalConfirm(goal.name)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c), child: Text(localL10n.cancel)),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                                      Navigator.pop(c);
                                    },
                                    child: Text(localL10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                                  ),
                                ],
                              );
                            }
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
                                          _calculateMotivationText(goal, l10n),
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
                  }).toList(),
                );
              },
            ),
          ],
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
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.goalEmptyStateDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddGoalSheet,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.createGoal),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
