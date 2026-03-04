import 'package:isar/isar.dart';

part 'settings_model.g.dart';

/// Represents global app preferences stored in Isar.
/// Uses a singleton pattern where [id] is always 0.
@collection
class Settings {
  Id id = 0;

  String language = 'tr_TR';

  String themeMode = 'system';

  String defaultCurrency = 'TRY';

  bool notificationsEnabled = true;

  bool biometricEnabled = false;

  Settings();
}
