import 'package:flutter/material.dart';

/// This is a structural mockup demonstrating how the iOS/Android Home Widget
/// will look before integrating the native swift/kotlin `home_widget` package
/// channels.
class HomeWidgetMockup extends StatelessWidget {
  const HomeWidgetMockup({
    required this.totalSpent,
    required this.monthlyBudget,
    super.key,
  });

  final double totalSpent;
  final double monthlyBudget;

  @override
  Widget build(BuildContext context) {
    // 2x2 or 4x2 representation
    final progress = (monthlyBudget > 0) ? (totalSpent / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    
    // Determine bar color
    Color barColor;
    if (progress < 0.5) {
      barColor = const Color(0xFF00E5A0); // Green
    } else if (progress < 0.8) {
      barColor = const Color(0xFFFFB300); // Orange
    } else {
      barColor = const Color(0xFFFF4081); // Red
    }

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Theme surface equivalent
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2D2D3A), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Flux',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Spent This Month',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₺${totalSpent.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
