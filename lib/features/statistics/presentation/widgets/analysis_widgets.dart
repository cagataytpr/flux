/// Flux Application - Analytics Widgets
///
/// New widgets for Phase 10: Cash Flow Forecast & Gamification.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';

import '../../../../core/services/exchange_rate_service.dart';
import '../../../../core/utils/currency_ext.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/analysis_providers.dart';

// ---------------------------------------------------------------------------
// Gamification: Streak Badge
// ---------------------------------------------------------------------------

class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final streak = ref.watch(noSpendStreakProvider);

    if (streak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFFB300), size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.streakDays(streak),
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFFFFB300),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cash Flow Forecast Card
// ---------------------------------------------------------------------------

class CashFlowForecastCard extends ConsumerWidget {
  const CashFlowForecastCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final forecast = ref.watch(cashFlowForecastProvider);
    final settingsStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.defaultCurrency)) ?? 'TRY';
    final sym = settingsStr.currencySymbol;
    final ex = ref.watch(exchangeRateServiceProvider);

    final predictedBalance = ex.convertToSelected(forecast.predictedEomBalance, settingsStr);
    
    final isPositive = predictedBalance >= 0;
    final valueColor = isPositive ? const Color(0xFF00E5A0) : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights_rounded, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.eomForecast,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.predictedBalance,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$sym${predictedBalance.toStringAsFixed(0)}',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: valueColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.forecastBasedOn(sym, ex.convertToSelected(forecast.averageDailySpend, settingsStr).toStringAsFixed(0)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
