/// Flux Application - Subscriptions Screen
///
/// Lists upcoming subscription payments sorted by billing date,
/// showing days remaining until the next bill.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';

import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/subscription_model.dart';

/// Screen listing all tracked subscriptions.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subsAsync = ref.watch(subscriptionsProvider);
    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptions),
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
            return _EmptyState(theme: theme, l10n: l10n);
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
                      l10n.monthlyBurnRate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$sym${totalMonthly.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.totalScheduledPayments,
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
                  itemBuilder: (_, i) => _SubscriptionTile(sub: subs[i], sym: sym),
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
  const _EmptyState({required this.theme, required this.l10n});
  final ThemeData theme;
  final AppLocalizations l10n;

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
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(Icons.repeat_rounded,
                  size: 36,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noSubscriptions,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noSubscriptionsDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile({required this.sub, required this.sym});
  final Subscription sub;
  final String sym;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
                  '$cycleLabel · $sym${sub.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Days-left badge & Menu
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
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
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final isar = ref.read(isarProvider);
                    await isar.writeTxn(() async {
                      await isar.subscriptions.delete(sub.id);
                    });
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
