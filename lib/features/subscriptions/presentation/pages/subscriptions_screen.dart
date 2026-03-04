/// Flux Application - Subscriptions Screen
///
/// Lists upcoming subscription payments sorted by billing date,
/// showing days remaining until the next bill.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/subscription_model.dart';

import '../widgets/add_subscription_sheet.dart';

/// Screen listing all tracked subscriptions.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subsAsync = ref.watch(subscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSubscriptionSheet(context, ref),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: subsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error)),
        ),
        data: (subs) {
          if (subs.isEmpty) {
            return _EmptyState(theme: theme);
          }
          
          final totalMonthly = subs.fold<double>(
            0.0,
            (sum, sub) => sum + sub.amount,
          );

          return Column(
            children: [
              // Monthly Burn Rate Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Monthly Burn Rate',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₺${totalMonthly.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total scheduled payments this month',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Subscriptions List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: subs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _SubscriptionTile(sub: subs[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha:  0.10),
              ),
              child: Icon(Icons.repeat_rounded,
                  size: 36,
                  color: theme.colorScheme.primary.withValues(alpha:  0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Subscriptions Yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'When you scan a receipt from services like Netflix or Spotify, '
              'enable "Repeat Monthly?" to track it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subscription tile
// ---------------------------------------------------------------------------

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.sub});
  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final billing =
        DateTime(sub.nextBillingDate.year, sub.nextBillingDate.month, sub.nextBillingDate.day);
    final daysLeft = billing.difference(today).inDays;

    final Color badgeColor;
    final String badgeText;

    if (daysLeft < 0) {
      badgeColor = theme.colorScheme.error;
      badgeText = 'Overdue';
    } else if (daysLeft == 0) {
      badgeColor = const Color(0xFFFF6E40);
      badgeText = 'Today';
    } else if (daysLeft <= 3) {
      badgeColor = const Color(0xFFFFD740);
      badgeText = '$daysLeft day${daysLeft == 1 ? '' : 's'}';
    } else {
      badgeColor = const Color(0xFF00E5A0);
      badgeText = '$daysLeft days';
    }

    final cycleLabel =
        sub.cycle == SubscriptionCycle.monthly ? 'Monthly' : 'Yearly';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha:  0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.repeat_rounded,
                size: 22, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),

          // Name + cycle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '$cycleLabel · ₺${sub.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha:  0.5),
                  ),
                ),
              ],
            ),
          ),

          // Days-left badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha:  0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
