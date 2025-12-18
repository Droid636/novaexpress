import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/app_theme.dart';
import '../helpers/theme_mode_provider.dart';

class ThemeMenuButton extends ConsumerWidget {
  const ThemeMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Text(
                    'Apariencia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navBackground,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón Modo Oscuro
                  ListTile(
                    leading: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppTheme.navSelected,
                    ),
                    title: Text(
                      themeMode == ThemeMode.dark
                          ? 'Desactivar modo oscuro'
                          : 'Activar modo oscuro',
                    ),
                    onTap: () {
                      ref
                          .read(themeModeProvider.notifier)
                          .state = themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
