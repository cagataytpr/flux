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
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      final currentSettings = await _fetchOrCreateSettings();
      currentSettings.themeMode = mode;
      await isar.writeTxn(() async {
        await isar.settings.put(currentSettings);
      });
      return currentSettings;
    });
  }

  /// Updates the application language.
  Future<void> updateLanguage(String lang) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      final currentSettings = await _fetchOrCreateSettings();
      currentSettings.language = lang;
      await isar.writeTxn(() async {
        await isar.settings.put(currentSettings);
      });
      return currentSettings;
    });
  }

  /// Updates the default currency.
  Future<void> updateDefaultCurrency(String currency) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      final currentSettings = await _fetchOrCreateSettings();
      currentSettings.defaultCurrency = currency;
      await isar.writeTxn(() async {
        await isar.settings.put(currentSettings);
      });
      return currentSettings;
    });
  }

  /// Toggles push notifications.
  Future<void> toggleNotifications(bool enabled) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(() async {
      final currentSettings = await _fetchOrCreateSettings();
      currentSettings.notificationsEnabled = enabled;
      await isar.writeTxn(() async {
        await isar.settings.put(currentSettings);
      });
      return currentSettings;
    });
  }
}

/// Provider exposing the [SettingsNotifier].
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
