/// Flux Application - Upcoming Bill Indicator
///
/// Shows the next upcoming subscription payment on the dashboard.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux/l10n/app_localizations.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/dashboard_providers.dart';

/// Displays the closest upcoming subscription bill with due date and amount.
class UpcomingBillIndicator extends ConsumerWidget {
  const UpcomingBillIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return subscriptionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (subs) {
        if (subs.isEmpty) return const SizedBox.shrink();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Find the subscription with the closest billing date
        dynamic nextSub;
        int minDays = 9999;

        for (final sub in subs) {
          final billing = DateTime(sub.nextBillingDate.year,
              sub.nextBillingDate.month, sub.nextBillingDate.day);
          final daysLeft = billing.difference(today).inDays;

          if (daysLeft >= 0 && daysLeft < minDays) {
            minDays = daysLeft;
            nextSub = sub;
          }
        }

        if (nextSub == null) return const SizedBox.shrink();

        final String dueText;
        if (minDays == 0) {
          dueText = l10n.dueToday(nextSub.name);
        } else if (minDays == 1) {
          dueText = l10n.dueTomorrow(nextSub.name);
        } else {
          dueText = l10n.dueInDays(nextSub.name, minDays);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.upcomingPayment,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dueText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$sym${nextSub.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
