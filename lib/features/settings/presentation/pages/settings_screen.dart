import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';

import '../../../../core/services/widget_manager.dart';
import '../providers/settings_provider.dart';

/// The Settings Screen for managing user preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('${l10n.errorLoadingSettings}: $error')),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            children: [
              // --- Preferences Section ---
              Text(
                l10n.preferences,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  // Theme Selector
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(l10n.theme),
                    trailing: DropdownButton<String>(
                      value: settings.themeMode,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(l10n.system)),
                        DropdownMenuItem(value: 'light', child: Text(l10n.light)),
                        DropdownMenuItem(value: 'dark', child: Text(l10n.dark)),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(settingsProvider.notifier).updateThemeMode(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(l10n.language),
                    trailing: DropdownButton<String>(
                      value: settings.language,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'tr_TR', child: Text('Türkçe')),
                        DropdownMenuItem(value: 'en_US', child: Text('English')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(settingsProvider.notifier).updateLanguage(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Currency Selector
                  ListTile(
                    leading: const Icon(Icons.attach_money_rounded),
                    title: Text(l10n.defaultCurrency),
                    trailing: DropdownButton<String>(
                      value: settings.defaultCurrency,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'TRY', child: Text('TRY (₺)')),
                        DropdownMenuItem(value: 'USD', child: Text('USD (\$ )')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(settingsProvider.notifier).updateDefaultCurrency(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Notifications Section ---
              Text(
                l10n.notificationsUppercase,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(l10n.pushNotifications),
                    subtitle: Text(l10n.pushNotificationsSubtitle),
                    value: settings.notificationsEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleNotifications(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Home Screen Widget Section ---
              Text(
                l10n.homeScreenWidget.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.widgets_outlined),
                    title: Text(l10n.addToHomeScreen),
                    subtitle: Text(l10n.widgetSetupDesc),
                    trailing: const Icon(Icons.add_circle_outline_rounded),
                    onTap: () async {
                      final success = await WidgetManager.requestPinWidget();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pinWidgetError)),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: Text(l10n.manualSetup),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _showWidgetInstructions(context, l10n);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Data & Backup Section ---
              const SizedBox(height: 48),

              // App Version info
              Center(
                child: Text(
                  'Flux App v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

void _showWidgetInstructions(BuildContext context, AppLocalizations l10n) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.widgetInstructionsTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Android',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(l10n.widgetInstructionsAndroid),
            const SizedBox(height: 16),
            Text(
              'iOS',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(l10n.widgetInstructionsiOS),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.done),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

/// A reusable sleek card container for settings groups.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
