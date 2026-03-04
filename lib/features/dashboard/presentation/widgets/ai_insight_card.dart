/// Flux Application - FluxAI Insight Card
///
/// Displays witty, Turkish-language savings advice from the FluxAI coach
/// with a shimmer gradient border and pulsing loading animation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_providers.dart';

/// A premium card with animated gradient border that shows FluxAI advice.
class AiInsightCard extends ConsumerWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final adviceAsync = ref.watch(fluxAiAdviceProvider);

    return _ShimmerBorderCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: adviceAsync.when(
          loading: () => _PulsingLoader(theme: theme),
          error: (_, __) => _ErrorState(theme: theme),
          data: (tips) => _TipsList(theme: theme, tips: tips),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer Gradient Border Card
// ---------------------------------------------------------------------------

class _ShimmerBorderCard extends StatefulWidget {
  const _ShimmerBorderCard({required this.child});
  final Widget child;

  @override
  State<_ShimmerBorderCard> createState() => _ShimmerBorderCardState();
}

class _ShimmerBorderCardState extends State<_ShimmerBorderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0,
              endAngle: 6.28, // 2π
              transform: GradientRotation(_ctrl.value * 6.28),
              colors: const [
                Color(0xFF7C4DFF),
                Color(0xFF00E5A0),
                Color(0xFF2979FF),
                Color(0xFFE040FB),
                Color(0xFF7C4DFF),
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1.2), // border thickness
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              color: theme.colorScheme.surface,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing loader
// ---------------------------------------------------------------------------

class _PulsingLoader extends StatefulWidget {
  const _PulsingLoader({required this.theme});
  final ThemeData theme;

  @override
  State<_PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<_PulsingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 18, color: widget.theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            'FluxAI is thinking…',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline_rounded,
            color: theme.colorScheme.error, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'FluxAI\'ye ulaşılamadı. Yenilemek için aşağı çekin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tips list
// ---------------------------------------------------------------------------

class _TipsList extends StatelessWidget {
  const _TipsList({required this.theme, required this.tips});
  final ThemeData theme;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) {
      return Text(
        'Henüz tavsiye yok.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF00E5A0)],
              ).createShader(bounds),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF00E5A0)],
              ).createShader(bounds),
              child: Text(
                'FluxAI',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white, // masked by shader
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tips
        for (int i = 0; i < tips.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF2979FF)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tips[i],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
