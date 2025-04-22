import 'package:flutter/material.dart';

// App Routes
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String qrScanner = '/qr_scanner';
  static const String activityHistory = '/activity_history';
  static const String rewardsShop = '/rewards_shop';
  static const String rewardDetails = '/reward_details';
  static const String claimedRewards = '/claimed_rewards';
  static const String splash = '/';
  static const String settings = '/settings';
  static const String forgotPassword = '/forgot-password';
}

// App Colors
class AppColors {
  static const Color primary = Color(0xFFF36122);    // Orange
  static const Color primaryDark = Color(0xFFD14B13); // Darker orange
  static const Color accent = Color(0xFF87C540);     // Green
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color text = Color(0xFF000000);       // Black
  static const Color textSecondary = Color(0xFF666666); // Gray
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color error = Color(0xFFB00020);      // Red
  static const Color success = Color(0xFF87C540);    // Green
  static const Color warning = Color(0xFFFFC107);    // Yellow
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color divider = Color(0xFFE0E0E0);    // Light gray
  static const Color cardBackground = Colors.white;
}

// Spacing values for consistent UI
class AppSpacing {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// App Text Styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.black,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  // Add compatibility with existing code
  static const TextStyle bodyText = body1;
  static const TextStyle subtitle = body2;
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}

// API Constants
class ApiConstants {
  static const String baseUrl = 'https://api.gravity-rewards.com/v1';
  static const int timeoutDuration = 30; // seconds
}

// Asset Paths
class AppAssets {
  static const String logoPath = 'assets/images/Gravity-Logo.png';
  static const String logoSmall = 'assets/images/Gravity-Logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
}

// Shared Preferences Keys
class PreferenceKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String onboardingComplete = 'onboarding_complete';
  static const String notificationsEnabled = 'notifications_enabled';
}

// App dimensions
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
  static const double cardRadius = 8.0;
  static const double buttonRadius = 4.0;
  static const double inputRadius = 4.0;
}

// Points related constants
class PointsConstants {
  static const int pointsPerJump = 10;
  static const int pointsPerHour = 10;
  static const int bonusPointsForExtraHour = 5;
  static const int pointsForScan = 10;
  static const int pointsPerGroupMember = 10;
}

// Rewards thresholds
class RewardsThresholds {
  static const int freeJump = 100;
  static const int merchandise10PercentOff = 200;
  static const int merchandise20PercentOff = 350;
  static const int freePartyRoomHour = 500;
  static const int privateSessionDiscount = 750;
} 