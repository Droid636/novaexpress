import 'package:flutter/material.dart';

class AppTheme {
  static const Color navBackground = Color(0xFF1A2236);
  static const Color navSelected = Color(0xFF3578C6);
  static const Color navUnselected = Color(0xFF8CA6C6);
  static const Color navIconSelected = navSelected;
  static const Color navIconUnselected = navUnselected;
  static const Color splashBackgroundTop = navBackground;
  static const Color splashBackgroundBottom = navSelected;
  static const Color splashArc = Color(0xFF4FC3F7);
  static const Color splashLogoWhite = Colors.white;
  static const Color splashLogoGlow = Color(0xFFB2E6FF);
  static const Color splashText = Colors.white;
  static const Color splashSubtitle = Color(0xFFB2E6FF);
  static const Color searchBackground = Color(0xFFF3F6FA);
  static const Color searchBorder = Color(0xFFD1D9E6);
  static const Color searchIconBg = navSelected;
  static const Color searchIconColor = Colors.white;
  static const Color searchHint = navUnselected;
  static const Color categoryBackground = Color(0xFFF3F6FA);
  static const Color categoryChipBackground = Colors.white;
  static const Color categoryChipBorder = Color(0xFFD1D9E6);
  static const Color categoryChipText = navBackground;
  static const Color categorySelectedGradientStart = navSelected;
  static const Color categorySelectedGradientEnd = navBackground;
  static const Color categorySelectedText = Colors.white;
  static const Color categorySelectedShadow = Color(0x223578C6);
  static const Color bookmarksBackground = categoryBackground;
  static const Color bookmarksCard = Colors.white;
  static const Color bookmarksTitle = navBackground;
  static const Color bookmarksSubtitle = navSelected;
  static const Color bookmarksEmptyIcon = Color(0xFF8CA6C6);
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: categoryBackground,
      primaryColor: navSelected,
      fontFamily: 'Roboto',
    );
  }
}
