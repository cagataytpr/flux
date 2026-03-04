/// Flux Application - Statistics Providers
///
/// Riverpod providers powering the Statistics/Analytics screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ai_service.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/transaction_model.dart';

// ---------------------------------------------------------------------------
// Category Spending Data
// ---------------------------------------------------------------------------

/// A simple data class for category spending info.
class CategorySpending {
  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final TransactionCategory category;
  final double amount;
  final double percentage; // 0.0 – 1.0
}

/// Provides a list of [CategorySpending] sorted by highest spending first.
final categorySpendingProvider = Provider<List<CategorySpending>>((ref) {
  final categoryMap = ref.watch(currentMonthExpenseByCategoryProvider);
  final totalSpent = ref.watch(currentMonthExpensesProvider);

  if (categoryMap.isEmpty || totalSpent <= 0) return [];

  final list = categoryMap.entries.map((entry) {
    return CategorySpending(
      category: entry.key,
      amount: entry.value,
      percentage: entry.value / totalSpent,
    );
  }).toList();

  // Sort descending by amount
  list.sort((a, b) => b.amount.compareTo(a.amount));

  return list;
});

// ---------------------------------------------------------------------------
// FluxAI Category Roast
// ---------------------------------------------------------------------------

/// Provides a witty FluxAI roast about the user's top spending categories.
/// Implements a 30-minute cooldown and uses ref.read to avoid stream-spam.
class CategoryRoastNotifier extends AsyncNotifier<String> {
  DateTime? _lastFetchTime;
  String? _cachedRoast;

  @override
  Future<String> build() async {
    // 1. Check 30-minute cooldown
    final now = DateTime.now();
    if (_lastFetchTime != null &&
        _cachedRoast != null &&
        now.difference(_lastFetchTime!).inMinutes < 30) {
      return _cachedRoast!;
    }

    // 2. Use ref.read instead of ref.watch so we don't automatically trigger
    // a Gemini API call every time a transaction is added/deleted.
    final spending = ref.read(categorySpendingProvider);
    if (spending.isEmpty) {
      return 'Henüz analiz edecek yeterli harcaman yok. Cüzdanın güvende! 🛡️';
    }

    // Take top 3 categories
    final top3 = spending.take(3).toList();
    final summary = top3.map((s) {
      final name = s.category.name[0].toUpperCase() + s.category.name.substring(1);
      return '$name: ₺${s.amount.toStringAsFixed(0)} (%${(s.percentage * 100).toStringAsFixed(0)})';
    }).join(', ');

    final aiService = ref.read(aiServiceProvider);
    final roast = await aiService.getCategoryRoast(summary);

    // 3. Cache the result
    _lastFetchTime = now;
    _cachedRoast = roast;

    return roast;
  }
}

final categoryRoastProvider =
    AsyncNotifierProvider<CategoryRoastNotifier, String>(
  CategoryRoastNotifier.new,
);
