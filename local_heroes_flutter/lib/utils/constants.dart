import 'package:flutter/material.dart';

/// App color constants - maintaining the dark theme from React app.
class AppColors {
  // Background colors
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBackground = Colors.white;
  static const Color surfaceDark = Color(0xFF252525);
  static const Color surfaceLight = Color(0xFF2A2A2A);

  // Primary colors - Orange gradient
  static const Color primaryLight = Color(0xFFFB923C); // orange-400
  static const Color primary = Color(0xFFF97316); // orange-500
  static const Color primaryDark = Color(0xFFEA580C); // orange-600

  // Action colors
  static const Color keepGreen = Color(0xFF22C55E); // green-500
  static const Color keepGreenLight = Color(0xFF4ADE80); // green-400
  static const Color passRed = Color(0xFFEF4444); // red-500
  static const Color passRedLight = Color(0xFFF87171); // red-400

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF); // gray-400
  static const Color textMuted = Color(0xFF6B7280); // gray-500
  static const Color textDark = Color(0xFF111827); // gray-900

  // Border colors
  static const Color border = Color(0xFF374151); // gray-700
  static const Color borderLight = Color(0xFF4B5563); // gray-600

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Confetti colors
  static const List<Color> confettiColors = [
    Color(0xFFEF4444), // red
    Color(0xFF3B82F6), // blue
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // amber
    Color(0xFF8B5CF6), // purple
    Color(0xFFEC4899), // pink
  ];
}

/// App text styles.
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

/// App dimensions and spacing.
class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 9999.0;

  // Card dimensions
  static const double cardMaxWidth = 360.0;
  static const double cardImageRatio = 0.55;

  // Icon sizes
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Swipe thresholds
  static const double swipeThreshold = 100.0;
  static const double rotationFactor = 0.15; // 15 degrees max rotation
}

/// App strings.
class AppStrings {
  static const String appName = 'Local Heroes';
  static const String tagline = 'Celebrating Community Changemakers';

  // Actions
  static const String keep = 'Keep';
  static const String pass = 'Pass';
  static const String undo = 'Undo';
  static const String restart = 'Restart';
  static const String clearAll = 'Clear All';
  static const String exportCsv = 'Export CSV';
  static const String search = 'Search';

  // Labels
  static const String keptList = 'Kept List';
  static const String deck = 'Deck';
  static const String noHeroesKept = 'No heroes kept yet';
  static const String swipeRightToKeep = 'Swipe right on cards to add them to your collection.';
  static const String deckComplete = 'You\'ve gone through the deck!';
  static const String heroesKept = 'You have kept {count} heroes.';

  // Buttons
  static const String viewKeptList = 'View Kept List';
  static const String restartDeck = 'Restart Deck';
  static const String moreAbout = 'Learn More';
}
