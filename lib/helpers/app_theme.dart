import 'package:flutter/material.dart';

class AppTheme {
  // ===========================
  // 🔵 COLORES OSCUROS (BASE)
  // ===========================

  static const Color navBackground = Color(0xFF1A2236);
  static const Color navSelected = Color(0xFF3578C6);
  static const Color navUnselected = Color(0xFF8CA6C6);

  static const Color navIconSelected = navSelected;
  static const Color navIconUnselected = navUnselected;

  // Splash (fondos oscuros)
  static const Color splashBackgroundTop = navBackground;
  static const Color splashBackgroundBottom = navSelected;
  static const Color splashArc = Color(0xFF4FC3F7);

  // Textos sobre fondo oscuro
  static const Color splashLogoWhite = Colors.white;
  static const Color splashLogoGlow = Color(0xFFB2E6FF);
  static const Color splashText = Colors.white;
  static const Color splashSubtitle = Color(0xFFB2E6FF);

  // Categorías seleccionadas (oscuras)
  static const Color categorySelectedGradientStart = navSelected;
  static const Color categorySelectedGradientEnd = navBackground;
  static const Color categorySelectedText = Colors.white;
  static const Color categorySelectedShadow = Color(0x223578C6);

  // ===========================
  // ⚪ COLORES CLAROS (UI)
  // ===========================

  // Paleta clara mejorada para menos fatiga visual
  static const Color categoryBackground = Color(
    0xFFF6F7F9,
  ); // fondo general, gris muy suave
  static const Color bookmarksBackground = categoryBackground;

  // Search
  static const Color searchBackground = Color(0xFFF6F7F9); // igual que fondo
  static const Color searchBorder = Color(0xFFE0E3EB); // gris más suave
  static const Color searchIconBg = navSelected;
  static const Color searchIconColor = Colors.white;
  static const Color searchHint = Color(0xFFB0B8C1); // gris medio para hint

  // Chips de categorías
  static const Color categoryChipBackground = Color(
    0xFFFDFDFD,
  ); // casi blanco, pero no puro
  static const Color categoryChipBorder = Color(0xFFE0E3EB);
  static const Color categoryChipText = Color(
    0xFF2C3550,
  ); // azul grisáceo oscuro

  // Bookmarks
  static const Color bookmarksCard = Color(
    0xFFFDFDFD,
  ); // igual que chip background
  static const Color bookmarksTitle = Color(0xFF2C3550); // azul grisáceo oscuro
  static const Color bookmarksSubtitle = Color(0xFF3578C6); // azul principal
  static const Color bookmarksEmptyIcon = Color(0xFFB0B8C1); // gris medio

  // ===========================
  // 🎨 THEME DATA
  // ===========================

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: categoryBackground,
      primaryColor: navSelected,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: navBackground,
        foregroundColor: Colors.white,
      ),
    );
  }
}
