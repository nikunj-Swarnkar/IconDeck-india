import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget showing swipe direction indicators (Keep/Pass).
class SwipeIndicator extends StatelessWidget {
  final bool isKeep;
  final double opacity;

  const SwipeIndicator({
    super.key,
    required this.isKeep,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: isKeep ? -0.2 : 0.2, // Slight rotation
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isKeep ? AppColors.keepGreen : AppColors.passRed,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Icon(
            isKeep ? Icons.check : Icons.close,
            color: isKeep ? AppColors.keepGreen : AppColors.passRed,
            size: 48,
          ),
        ),
      ),
    );
  }
}

/// Static hint indicators shown below the card.
class SwipeHints extends StatelessWidget {
  const SwipeHints({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pass hint
        _buildHint(
          icon: Icons.close,
          color: AppColors.passRed,
          label: AppStrings.pass,
        ),
        // Keep hint
        _buildHint(
          icon: Icons.check,
          color: AppColors.keepGreen,
          label: AppStrings.keep,
        ),
      ],
    );
  }

  Widget _buildHint({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Opacity(
      opacity: 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
