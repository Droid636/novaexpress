import 'package:flutter/material.dart';
import '../app_theme.dart';

class NewsBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NewsBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      // 🎨 Colores según AppTheme
      backgroundColor: isDark
          ? AppTheme.navBackground
          : AppTheme.categoryBackground,
      selectedItemColor: AppTheme.navSelected,
      unselectedItemColor: AppTheme.navUnselected,

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Favoritos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorías',
        ),
      ],
    );
  }
}
