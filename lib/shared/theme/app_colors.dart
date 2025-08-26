import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (Türkis for Artists)
  static const Color primary = Color(0xFF16bcb4);
  static const Color primaryDark = Color(0xFF0d8a84);
  static const Color primaryLight = Color(0xFF4dd3cb);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary colors (Lila for Venues)
  static const Color secondary = Color(0xFF5d2bbb);
  static const Color secondaryDark = Color(0xFF3f1c7f);
  static const Color secondaryLight = Color(0xFF8e5bd8);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Accent colors (Coral for Events)
  static const Color accent = Color(0xFFf26d6d);
  static const Color accentDark = Color(0xFFd63f3f);
  static const Color accentLight = Color(0xFFf59b9b);

  // Surface colors (Dark theme)
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF999999);

  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color onBackground = Color(0xFFFFFFFF);

  // Error colors
  static const Color error = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);

  // Success colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Warning colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFFF8F00);
  static const Color onWarning = Color(0xFF000000);

  // Info colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color outline = Color(0xFF3A3A3A);
  static const Color outlineVariant = Color(0xFF2A2A2A);
  static const Color shadow = Color(0x33000000);
  static const Color scrim = Color(0x80000000);

  // Status colors
  static const Color pending = Color(0xFFFF9800);
  static const Color confirmed = Color(0xFF4CAF50);
  static const Color cancelled = Color(0xFFFF5252);
  static const Color completed = Color(0xFF9C27B0);

  // Role-specific colors
  static const Color artistPrimary = primary;
  static const Color venuePrimary = secondary;
  static const Color organizerPrimary = accent;

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Chart colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    success,
    warning,
    info,
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
  ];

  // Get color by role
  static Color getColorByRole(String role) {
    switch (role.toLowerCase()) {
      case 'artist':
        return artistPrimary;
      case 'venue':
        return venuePrimary;
      case 'organizer':
        return organizerPrimary;
      default:
        return primary;
    }
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'confirmed':
        return confirmed;
      case 'cancelled':
        return cancelled;
      case 'completed':
        return completed;
      default:
        return onSurfaceVariant;
    }
  }

  // Opacity variants
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Disabled colors
  static const Color disabled = Color(0xFF424242);
  static const Color onDisabled = Color(0xFF757575);

  // Shimmer colors
  static const Color shimmerBase = Color(0xFF2A2A2A);
  static const Color shimmerHighlight = Color(0xFF3A3A3A);

  // Navigation colors
  static const Color navigationBar = surface;
  static const Color navigationBarSelected = primary;
  static const Color navigationBarUnselected = onSurfaceVariant;

  // Card colors
  static const Color cardBackground = surface;
  static const Color cardElevated = surfaceVariant;

  // Input colors
  static const Color inputFill = surface;
  static const Color inputBorder = outline;
  static const Color inputFocused = primary;
  static const Color inputError = error;

  // Divider colors
  static const Color divider = outline;
  static const Color dividerVariant = outlineVariant;
}