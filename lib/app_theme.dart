import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const Color categorySelectedGradientStart = navSelected;
  static const Color categorySelectedGradientEnd = navBackground;
  static const Color categorySelectedText = Colors.white;
  static const Color categorySelectedShadow = Color(0x223578C6);

  static const Color categoryBackground = Color(0xFFF6F7F9);
  static const Color bookmarksBackground = categoryBackground;

  // Serch Bar
  static const Color searchBackground = Color(0xFFF6F7F9);
  static const Color searchBorder = Color(0xFFE0E3EB);
  static const Color searchIconBg = navSelected;
  static const Color searchIconColor = Colors.white;
  static const Color searchHint = Color(0xFFB0B8C1);

  // Chips de categorías
  static const Color categoryChipBackground = Color(0xFFFDFDFD);
  static const Color categoryChipBorder = Color(0xFFE0E3EB);
  static const Color categoryChipText = Color(0xFF2C3550);

  // Bookmarks
  static const Color bookmarksCard = Color(0xFFFDFDFD);
  static const Color bookmarksTitle = Color(0xFF2C3550);
  static const Color bookmarksSubtitle = navSelected;
  static const Color bookmarksEmptyIcon = Color(0xFFB0B8C1);

  // ===========================

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: categoryBackground,
      primaryColor: navSelected,
      fontFamily: 'Roboto',

      colorScheme: const ColorScheme.light(primary: navSelected),

      appBarTheme: const AppBarTheme(
        backgroundColor: navBackground,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  // ===========================

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navBackground,
      primaryColor: navSelected,
      fontFamily: 'Roboto',

      colorScheme: const ColorScheme.dark(primary: navSelected),

      appBarTheme: const AppBarTheme(
        backgroundColor: navBackground,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
