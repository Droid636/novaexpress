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
        backgroundColor: AppTheme.navBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        /// HEADER PERFIL
                        Card(
                          color: isDark ? AppTheme.navBackground : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 38,
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
                                          size: 36,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.grey[700],
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    '$name $lastName',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppTheme.navSelected,
                                  ),
                                  onPressed: () async {
                                    final updated = await showEditProfileModal(
                                      context,
                                      data,
                                    );

                                    if (updated == true) {
                                      _refreshProfile();

                                      // 🔹 Mostrar Snackbar de éxito
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// DATOS PERFIL
                        _profileItem(context, 'Nombre', name),
                        _profileItem(context, 'Apellido', lastName),
                        _profileItem(context, 'Correo', email),
                        _profileItem(context, 'Teléfono', phone),
                        _profileItem(
                          context,
                          'Fecha de nacimiento',
                          birthDate == null
                              ? ''
                              : '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _profileItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF2C3550) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
