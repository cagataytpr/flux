/// Flux Application - Main Entry Point
///
/// Initializes core services (Isar, dotenv) and bootstraps
/// the application with Riverpod.
library;


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'core/constants/app_constants.dart';
import 'core/services/database_service.dart';
import 'core/services/exchange_rate_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await WidgetManager.init(); // Initialize Home Widget

  // Load environment variables.
  await dotenv.load(fileName: '.env');

  // Initialize Isar database with all schemas.
  final isar = await initIsar();

  // Sync exchange rates
  final exchangeRateService = ExchangeRateService(isar);
  await exchangeRateService.syncRatesIfNeeded();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();

  // Initialize Workmanager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
  );

  // Register periodic background notification tasks
  await notificationService.registerPeriodicTasks();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        notificationServiceProvider.overrideWithValue(notificationService),
        exchangeRateServiceProvider.overrideWithValue(exchangeRateService),
      ],
      child: const FluxApp(),
    ),
  );
}

/// Root application widget.
class FluxApp extends ConsumerWidget {
  const FluxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.themeMode ?? 'system'));
    final languageStr = ref.watch(settingsProvider.select((s) => s.valueOrNull?.language ?? 'tr_TR'));
    
    final langParts = languageStr.split('_');
    final locale = langParts.length == 2 
        ? Locale(langParts[0], langParts[1]) 
        : Locale(langParts[0]);
    
    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeOut,
      routerConfig: appRouter,
    );
  }
}
