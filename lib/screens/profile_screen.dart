import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/edit_profile_modal.dart';
import '../app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            ? const Center(child: Text('No hay usuario autenticado'))
            : FutureBuilder<DocumentSnapshot>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Usuario no encontrado'));
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
                      children: [
                        const SizedBox(height: 24),

                        /// CARD PERFIL
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      photoURL != null && photoURL.isNotEmpty
                                      ? NetworkImage(photoURL)
                                      : null,
                                  child: photoURL == null || photoURL.isEmpty
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '$name $lastName',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar perfil'),
                                  onPressed: () async {
                                    final updated = await showEditProfileModal(
                                      context,
                                      data,
                                    );
                                    if (updated == true) {
                                      _refreshProfile();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

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

                        /// 🗑️ ELIMINAR CUENTA
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Eliminar cuenta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deleteButton,
                            foregroundColor: AppTheme.deleteButtonText,
                          ),
                          onPressed: () => _confirmDeleteAccount(context, user),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// ===============================
  /// 🔐 CONFIRMAR ELIMINACIÓN
  /// ===============================
  Future<void> _confirmDeleteAccount(BuildContext context, User user) async {
    final passwordController = TextEditingController();
    bool obscure = true;
    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ingresa tu contraseña para continuar'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deleteButton,
                    foregroundColor: AppTheme.deleteButtonText,
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          if (passwordController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa tu contraseña'),
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            loading = true;
                          });

                          try {
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: passwordController.text.trim(),
                            );

                            await user.reauthenticateWithCredential(credential);

                            final comments = await FirebaseFirestore.instance
                                .collection('comments')
                                .where('userId', isEqualTo: user.uid)
                                .get();

                            for (final doc in comments.docs) {
                              await doc.reference.delete();
                            }

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .delete();

                            await user.delete();

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('isLoggedIn');
                            await prefs.remove('isGuest');

                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String msg = 'Error al eliminar cuenta';

                            if (e.code == 'wrong-password') {
                              msg = 'Contraseña incorrecta';
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(msg)));
                          } finally {
                            setModalState(() {
                              loading = false;
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _profileDataCard(
    String label,
    String value,
    bool isDark, {
    IconData? icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(value.isEmpty ? '—' : value),
        subtitle: Text(label),
      ),
    );
  }
}
