/// Flux Application - Action Bottom Sheet
///
/// Presents a choice between scanning a receipt or manually entering data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux/l10n/app_localizations.dart';
import '../pages/receipt_scanner.dart';
import 'manual_entry_sheet.dart';

/// Shows the action picker (Scan vs Manual) as a bottom sheet.
void showActionPickerSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext ctx) {
      final theme = Theme.of(ctx);
      final l10n = AppLocalizations.of(ctx)!;

      return Container(
        padding: const EdgeInsets.only(top: 24, bottom: 40, left: 24, right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle pill
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              l10n.newTransaction,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.newTransactionDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),

            // Scan Option
            _ActionTile(
              icon: Icons.document_scanner_rounded,
              title: l10n.scanReceipt,
              subtitle: l10n.scanReceiptDesc,
              color: theme.colorScheme.primary,
              onTap: () {
                Navigator.pop(ctx);
                showReceiptSourcePicker(context, ref);
              },
            ),
            const SizedBox(height: 16),

            // Manual Option
            _ActionTile(
              icon: Icons.edit_document,
              title: l10n.manualEntry,
              subtitle: l10n.manualEntryDesc,
              color: const Color(0xFF00E5A0),
              onTap: () {
                Navigator.pop(ctx);
                showManualEntrySheet(context, ref);
              },
            ),
            const SizedBox(height: 16),

            // Subscription Option
            _ActionTile(
              icon: Icons.repeat_rounded,
              title: l10n.regularSubscription,
              subtitle: l10n.regularSubscriptionDesc,
              color: const Color(0xFFFFB300),
              onTap: () {
                Navigator.pop(ctx);
                showManualEntrySheet(context, ref, isSubscription: true);
              },
            ),
          ],
        ),
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
