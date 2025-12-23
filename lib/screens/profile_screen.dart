import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
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
                                  _refreshProfile(); // 🔥 refresca
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
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }
}

Future<bool?> showEditProfileModal(
  BuildContext context,
  Map<String, dynamic> data,
) {
  final nameController = TextEditingController(text: data['name'] ?? '');
  final lastNameController = TextEditingController(
    text: data['lastName'] ?? '',
  );
  final phoneController = TextEditingController(text: data['phone'] ?? '');

  DateTime? birthDate = data['birthDate'] != null
      ? (data['birthDate'] as Timestamp).toDate()
      : null;

  final birthDateController = TextEditingController(
    text: birthDate == null ? '' : _formatDate(birthDate),
  );

  bool loading = false;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar perfil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 16),

                  // Apellido
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                  ),
                  const SizedBox(height: 16),

                  // Teléfono
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Fecha de nacimiento
                  TextField(
                    controller: birthDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: birthDate ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (date != null) {
                        setState(() {
                          birthDate = date;
                          birthDateController.text = _formatDate(date);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              setState(() => loading = true);

                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              // 🔥 Actualizar Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({
                                    'name': nameController.text.trim(),
                                    'lastName': lastNameController.text.trim(),
                                    'phone': phoneController.text.trim(),
                                    'birthDate': birthDate == null
                                        ? null
                                        : Timestamp.fromDate(birthDate!),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });

                              // 🔄 Sync con Auth
                              await user.updateDisplayName(
                                '${nameController.text.trim()} ${lastNameController.text.trim()}',
                              );

                              Navigator.pop(context, true);
                            },
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Helper fecha
String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
