import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

/// The Settings Screen for managing user preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading settings: $error')),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            children: [
              // --- Preferences Section ---
              Text(
                'PREFERENCES',
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
                    title: const Text('Theme'),
                    trailing: DropdownButton<String>(
                      value: settings.themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'system', child: Text('System')),
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
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
                    title: const Text('Language'),
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
                    title: const Text('Default Currency'),
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
                'NOTIFICATIONS',
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
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Reminders for bills and budget alerts'),
                    value: settings.notificationsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleNotifications(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Data & Backup Section ---
              Text(
                'DATA & BACKUP',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('Export Data to CSV'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // TODO: Implement CSV export
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(Icons.delete_forever_rounded, color: theme.colorScheme.error),
                    title: Text(
                      'Wipe All Data',
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // TODO: Implement factory reset
                    },
                  ),
                ],
              ),
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
