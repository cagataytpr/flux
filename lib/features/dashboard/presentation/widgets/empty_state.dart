/// Flux Application - Dashboard Empty State
///
/// Shown when there are no transactions yet.
library;

import 'package:flutter/material.dart';

/// An attractive empty state widget with gradient icon and animated arrow.
class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({required this.theme, super.key});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Glowing icon ──
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 52,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 36),

            // ── Title ──
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ).createShader(bounds),
              child: Text(
                'Welcome to Flux',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white, // masked by shader
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Subtitle ──
            Text(
              'Tap the scan button to capture\nyour first receipt',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // ── Animated hint arrow ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 12),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              builder: (_, value, child) {
                return Padding(
                  padding: EdgeInsets.only(top: value),
                  child: child,
                );
              },
              child: Icon(
                Icons.keyboard_double_arrow_down_rounded,
                size: 28,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              onEnd: () {
                // Restart animation handled by parent rebuild
              },
            ),
          ],
        ),
      ),
    );
  }
}
