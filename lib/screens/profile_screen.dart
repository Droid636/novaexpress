import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/edit_profile_modal.dart';
import '../app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
  }

  void _refreshProfile() {
    setState(() {
      _loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.navBackground : AppTheme.navSelected,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? Center(
                child: Text(
                  'No hay usuario autenticado',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              )
            : FutureBuilder<DocumentSnapshot>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar el perfil',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Text(
                        'No se encontró el usuario en Firestore',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final name = data['name'] ?? '';
                  final lastName = data['lastName'] ?? '';
                  final phone = data['phone'] ?? '';
                  final email = data['email'] ?? user.email ?? '';
                  final photoURL = data['profileImage'] ?? user.photoURL;

                  final birthDate = data['birthDate'] != null
                      ? (data['birthDate'] as Timestamp).toDate()
                      : null;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // CARD CENTRAL CON IMAGEN Y NOMBRE
                        Card(
                          color: isDark ? AppTheme.navBackground : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Imagen central
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      (photoURL != null &&
                                          photoURL.toString().isNotEmpty)
                                      ? NetworkImage(photoURL)
                                      : null,
                                  child:
                                      (photoURL == null ||
                                          photoURL.toString().isEmpty)
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey[700],
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                // Nombre centrado
                                Text(
                                  '$name $lastName',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                // Botón editar
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final updated = await showEditProfileModal(
                                      context,
                                      data,
                                    );
                                    if (updated == true) {
                                      _refreshProfile();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Perfil y foto actualizados con éxito',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit, size: 20),
                                  label: const Text('Editar perfil'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.navSelected,
                                    foregroundColor: Colors.white,
                                    elevation: isDark ? 0 : 3,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // DATOS PERFIL EN MINI-CARDS
                        _profileDataCard(
                          'Correo',
                          email,
                          isDark,
                          icon: Icons.email,
                        ),
                        _profileDataCard(
                          'Teléfono',
                          phone,
                          isDark,
                          icon: Icons.phone,
                        ),
                        _profileDataCard(
                          'Fecha de nacimiento',
                          birthDate == null
                              ? '—'
                              : '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                          isDark,
                          icon: Icons.cake,
                        ),
                        const SizedBox(height: 32),
                        // Botón eliminar cuenta
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Eliminar cuenta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('¿Eliminar cuenta?'),
                                content: const Text(
                                  'Esta acción es irreversible. ¿Deseas continuar?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                // Eliminar todos los comentarios del usuario
                                final commentsSnap = await FirebaseFirestore
                                    .instance
                                    .collection('comments')
                                    .where('userId', isEqualTo: user.uid)
                                    .get();
                                for (final doc in commentsSnap.docs) {
                                  await doc.reference.delete();
                                }
                                // Eliminar de Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .delete();
                                // Eliminar de Auth
                                await user.delete();
                                // Redirigir al home
                                if (mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al eliminar cuenta: \n${e.toString()}',
                                    ),
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
              ),
      ),
    );
  }

  Widget _profileDataCard(
    String label,
    String value,
    bool isDark, {
    IconData? icon,
  }) {
    return Card(
      color: isDark ? const Color(0xFF2C3550) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: isDark ? Colors.white70 : Colors.black54)
            : null,
        title: Text(
          value.isEmpty ? '—' : value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
