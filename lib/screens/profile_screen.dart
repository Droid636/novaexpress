import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/edit_profile_modal.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: user == null
            ? const Center(child: Text('No hay usuario autenticado'))
            : FutureBuilder<DocumentSnapshot>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar el perfil'),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text('No se encontró el usuario en Firestore'),
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
                        Row(
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
                                  ? const Icon(Icons.person, size: 36)
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                '$name $lastName',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
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

                        const SizedBox(height: 32),

                        _profileItem('Nombre', name),
                        _profileItem('Apellido', lastName),
                        _profileItem('Correo', email),
                        _profileItem('Teléfono', phone),
                        _profileItem(
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

  Widget _profileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }
}
