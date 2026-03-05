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
      ..notificationsEnabled = true;

    await isar.writeTxn(() async {
      await isar.settings.put(defaultSettings);
    });

    return defaultSettings;
  }

  /// Updates the application theme (light, dark, system).
  Future<void> updateThemeMode(String mode) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = currentSettings..themeMode = mode;
    state = AsyncValue.data(updatedSettings);
    
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Updates the application language.
  Future<void> updateLanguage(String lang) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = currentSettings..language = lang;
    state = AsyncValue.data(updatedSettings);

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Updates the default currency.
  Future<void> updateDefaultCurrency(String currency) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = currentSettings..defaultCurrency = currency;
    state = AsyncValue.data(updatedSettings);

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.settings.put(updatedSettings);
    });
  }

  /// Toggles push notifications.
  Future<void> toggleNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull ?? await _fetchOrCreateSettings();
    final updatedSettings = currentSettings..notificationsEnabled = enabled;
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
