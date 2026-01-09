import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../helpers/theme_mode_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/notification_topics_screen.dart';

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
        final user = FirebaseAuth.instance.currentUser;

        showModalBottomSheet(
          context: context,
          backgroundColor: isDark ? AppTheme.navBackground : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20, top: 5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  if (user != null) ...[
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get(),
                      builder: (context, snapshot) {
                        String name = '';
                        String photoURL = '';

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            name =
                                '${data['name'] ?? ''} ${data['lastName'] ?? ''}'
                                    .trim();
                            photoURL = (data['profileImage'] ?? '') as String;
                          }
                        }

                        if (name.isEmpty) {
                          name = user.displayName ?? 'Usuario';
                        }
                        if (photoURL.isEmpty) {
                          photoURL = user.photoURL ?? '';
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.navSelected.withOpacity(
                                      0.5,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppTheme.navSelected
                                      .withOpacity(0.1),
                                  backgroundImage: photoURL.isNotEmpty
                                      ? NetworkImage(photoURL)
                                      : null,
                                  child: photoURL.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: AppTheme.navSelected,
                                          size: 30,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.bookmarksTitle,
                                      ),
                                    ),
                                    Text(
                                      user.email ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppTheme.navUnselected
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 15, endIndent: 15),
                  ],

                  _buildOption(
                    context,
                    isDark: isDark,
                    icon: isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    label: isDark
                        ? 'Activar modo claro'
                        : 'Activar modo oscuro',
                    iconColor: isDark ? Colors.amber : AppTheme.navBackground,
                    onTap: () async {
                      await notifier.setTheme(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                      Navigator.pop(context);
                    },
                  ),

                  if (user != null)
                    _buildOption(
                      context,
                      isDark: isDark,
                      icon: Icons.notifications_active_outlined,
                      label: 'Notificaciones por categoría',
                      iconColor: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationTopicsScreen(),
                          ),
                        );
                      },
                    ),

                  if (user != null) ...[
                    _buildOption(
                      context,
                      isDark: isDark,
                      icon: Icons.account_circle_outlined,
                      label: 'Mi perfil',
                      iconColor: AppTheme.navSelected,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/profile');
                      },
                    ),
                    const Divider(indent: 15, endIndent: 15),
                    _buildOption(
                      context,
                      isDark: isDark,
                      icon: Icons.logout_rounded,
                      label: 'Cerrar sesión',
                      iconColor: Colors.redAccent,
                      onTap: () async {
                        Navigator.pop(context);
                        await _handleSignOut(context);
                      },
                    ),
                  ] else ...[
                    const Divider(indent: 15, endIndent: 15),
                    _buildOption(
                      context,
                      isDark: isDark,
                      icon: Icons.login_rounded,
                      label: 'Regístrate o inicia sesión',
                      iconColor: AppTheme.navSelected,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/login');
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===============================
  // OPCIÓN REUTILIZABLE
  // ===============================
  Widget _buildOption(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppTheme.bookmarksTitle,
        ),
      ),
      onTap: onTap,
    );
  }

  // ===============================
  // LOGOUT
  // ===============================
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }
}
