import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/services/database_service.dart';

/// Notifier to manage the global [Settings] state.
class SettingsNotifier extends AsyncNotifier<Settings> {
  @override
  Future<Settings> build() async {
    return _fetchOrCreateSettings();
  }

  Future<Settings> _fetchOrCreateSettings() async {
    final isar = ref.read(isarProvider);
    final existingSettings = await isar.settings.get(0);

    if (existingSettings != null) {
      return existingSettings;
    }

    // Create default settings if none exist
    final defaultSettings = Settings()
      ..id = 0
      ..language = 'tr_TR'
      ..themeMode = 'system'
      ..defaultCurrency = 'TRY'
      ..notificationsEnabled = true
      ..monthlyBudget = 20000.0;

    await isar.writeTxn(() async {
      await isar.settings.put(defaultSettings);
    });

    return defaultSettings;
  }

  /// Updates the application theme (light, dark, system).
  Future<void> updateThemeMode(String mode) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = Settings()
      ..id = 0
      ..themeMode = mode
      ..language = currentSettings.language
      ..defaultCurrency = currentSettings.defaultCurrency
      ..notificationsEnabled = currentSettings.notificationsEnabled
      ..monthlyBudget = currentSettings.monthlyBudget;
    state = AsyncValue.data(updatedSettings);
    
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Updates the application language.
  Future<void> updateLanguage(String lang) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = Settings()
      ..id = 0
      ..themeMode = currentSettings.themeMode
      ..language = lang
      ..defaultCurrency = currentSettings.defaultCurrency
      ..notificationsEnabled = currentSettings.notificationsEnabled
      ..monthlyBudget = currentSettings.monthlyBudget;
    state = AsyncValue.data(updatedSettings);

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Updates the default currency.
  Future<void> updateDefaultCurrency(String currency) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = Settings()
      ..id = 0
      ..themeMode = currentSettings.themeMode
      ..language = currentSettings.language
      ..defaultCurrency = currency
      ..notificationsEnabled = currentSettings.notificationsEnabled
      ..monthlyBudget = currentSettings.monthlyBudget;
    state = AsyncValue.data(updatedSettings);

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Toggles push notifications.
  Future<void> toggleNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = Settings()
      ..id = 0
      ..themeMode = currentSettings.themeMode
      ..language = currentSettings.language
      ..defaultCurrency = currentSettings.defaultCurrency
      ..notificationsEnabled = enabled
      ..monthlyBudget = currentSettings.monthlyBudget;
    state = AsyncValue.data(updatedSettings);

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Updates the monthly budget.
  Future<void> updateMonthlyBudget(double budget) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = Settings()
      ..id = 0
      ..themeMode = currentSettings.themeMode
      ..language = currentSettings.language
      ..defaultCurrency = currentSettings.defaultCurrency
      ..notificationsEnabled = currentSettings.notificationsEnabled
      ..monthlyBudget = budget;
    state = AsyncValue.data(updatedSettings);

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }
}

/// Provider exposing the [SettingsNotifier].
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
