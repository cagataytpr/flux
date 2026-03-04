/// Flux Application - Database Service
///
/// Provides the Isar database instance via Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/subscriptions/domain/subscription_model.dart';
import '../../features/transactions/domain/transaction_model.dart';
import '../constants/app_constants.dart';

/// Provider that initialises and exposes the [Isar] instance.
///
/// Kept alive for the lifetime of the app so the database connection
/// is never closed while the app is running.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden with the initialised Isar instance.',
  );
});

/// Initialises the Isar database with all collection schemas.
///
/// Call this once during app startup and pass the result into
/// [ProviderScope.overrides].
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.openSync(
    [TransactionSchema, SubscriptionSchema],
    directory: dir.path,
    name: AppConstants.isarDbName,
  );
}
