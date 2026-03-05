/// Flux Application - Home Page
///
/// The main landing page of the application.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import '../../../dashboard/presentation/pages/receipt_scanner.dart';

/// The root scaffold of the application, managing the bottom navigation bar.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final QuickActions quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    _setupQuickActions();
  }

  void _setupQuickActions() {
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_add_receipt') {
        // Ensure we execute after the frame builds so context is fully mounted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showReceiptSourcePicker(context, ref);
        });
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_add_receipt',
        localizedTitle: 'Scan Receipt',
        icon: 'receipt', // ensure there's a corresponding icon in native assets (optional)
      ),
    ]);
  }

  void _onTap(BuildContext context, int index) {
    /// Navigate to the selected branch.
    /// If the selected tab is tapped again, it navigates to the initial root.
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics_rounded),
            label: l10n.stats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: l10n.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.subscriptions, // Assuming this exists or falls back
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
