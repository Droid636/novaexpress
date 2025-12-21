import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/app_theme.dart';
import '../helpers/theme_mode_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeMenuButton extends ConsumerWidget {
  const ThemeMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

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
                  ListTile(
                    leading: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.navSelected,
                    ),
                    title: Text(
                      isDark ? 'Desactivar modo oscuro' : 'Activar modo oscuro',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppTheme.navBackground,
                      ),
                    ),
                    onTap: () async {
                      await notifier.setTheme(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blueAccent),
                    title: Text(
                      'Mi perfil',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.blue[200] : Colors.blueAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.red[200] : Colors.redAccent,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cerrar sesión: $e'),
                            ),
                          );
                        }
                      }
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
