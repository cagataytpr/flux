/// Flux Application - Receipt Scanner
///
/// Orchestrates the source-pick → compress → AI → confirm → save flow.
/// Supports dual save (Transaction + Subscription) when the user enables
/// the monthly repeat toggle.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/ai_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../subscriptions/domain/subscription_model.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/receipt_confirm_sheet.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Shows a styled source picker and then runs the full scan flow.
Future<void> showReceiptSourcePicker(BuildContext context, WidgetRef ref) async {
  final theme = Theme.of(context);

  final source = await showCupertinoModalPopup<ImageSource>(
    context: context,
    builder: (BuildContext sheetCtx) => CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: theme.colorScheme.primary,
        barBackgroundColor: theme.colorScheme.surface,
        scaffoldBackgroundColor: theme.colorScheme.surface,
        textTheme: const CupertinoTextThemeData(
          actionTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: CupertinoActionSheet(
        title: Text(
          'Scan Receipt',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        message: Text(
          'Choose how you want to capture the receipt',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetCtx).pop(ImageSource.camera),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📸', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  'Take Photo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetCtx).pop(ImageSource.gallery),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🖼️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(fontFamily: 'Inter'),
          ),
        ),
      ),
    ),
  );

  if (source == null || !context.mounted) return;

  await _runScanFlow(context, ref, source);
}

// ---------------------------------------------------------------------------
// Core scan flow
// ---------------------------------------------------------------------------

Future<void> _runScanFlow(
  BuildContext context,
  WidgetRef ref,
  ImageSource source,
) async {
  final messenger = ScaffoldMessenger.of(context);

  // ── 1. Pick image ───────────────────────────────────────────────
  final picker = ImagePicker();
  final XFile? photo = await picker.pickImage(
    source: source,
    imageQuality: 85,
  );

  if (photo == null) return;
  if (!context.mounted) return;

  // ── 2. Loading dialog ──────────────────────────────────────────
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      final t = Theme.of(context);
      return PopScope(
        canPop: false,
        child: Center(
          child: Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: t.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: t.colorScheme.primary.withValues(alpha:  0.12),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: t.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'AI is analyzing\nyour receipt…',
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  try {
    // ── 3. Compress ──────────────────────────────────────────────
    final rawBytes = await photo.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      rawBytes,
      minWidth: 1024,
      minHeight: 1024,
      quality: 75,
      format: CompressFormat.jpeg,
    );

    // ── 4. AI analysis ──────────────────────────────────────────
    final aiService = ref.read(aiServiceProvider);
    final parsed = await aiService.analyzeReceipt(compressed);

    if (!context.mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
    }

    if (parsed == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not read the receipt. Please try again.'),
        ),
      );
      return;
    }

    // ── 5. Confirmation sheet ───────────────────────────────────
    final result = await showModalBottomSheet<ReceiptSaveResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptConfirmSheet(data: parsed),
    );

    if (result == null) return;

    // ── 6. Save to Isar ─────────────────────────────────────────
    final isar = ref.read(isarProvider);

    await isar.writeTxn(() async {
      await isar.transactions.put(result.transaction);
      if (result.subscription != null) {
        await isar.subscriptions.put(result.subscription!);
      }
    });

    // ── 7. Refresh ──────────────────────────────────────────────
    ref.invalidate(transactionsProvider);
    ref.invalidate(savingsTipsProvider);
    ref.invalidate(fluxAiAdviceProvider);
    ref.invalidate(subscriptionsProvider);

    if (!context.mounted) return;

    final msg = result.subscription != null
        ? 'Saved: ${result.transaction.title} + Subscription 🔁'
        : 'Saved: ${result.transaction.title}';

    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF00E5A0).withValues(alpha:  0.9),
      ),
    );

    if (context.mounted) {
      context.go('/history');
    }
  } catch (e) {
    if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Detect quota / rate-limit errors and show a friendly message.
    final errStr = e.toString().toLowerCase();
    final isQuota = errStr.contains('quota') ||
        errStr.contains('429') ||
        errStr.contains('resource_exhausted') ||
        errStr.contains('rate');

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isQuota
              ? 'Google kotası doldu kanka, 30 saniye sonra tekrar deneyelim mi? 😅'
              : 'Bir şeyler ters gitti. Lütfen tekrar deneyin.',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
