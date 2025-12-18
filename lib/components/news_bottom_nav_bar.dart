import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';
import '../components/theme_menu_button.dart';

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

    return Stack(
      alignment: Alignment.topRight,
      children: [
        BottomNavigationBar(
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
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categorías',
            ),
          ],
        ),

        // 🔘 Botón 3 puntos (modo oscuro)
        const Positioned(right: 4, top: 4, child: ThemeMenuButton()),
      ],
    );
  }
}
