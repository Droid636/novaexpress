import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    // Firestore instance
    final firestore = FirebaseAuth.instance.currentUser != null
        ? FirebaseFirestore.instance
        : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: user == null
            ? const Center(child: Text('No hay usuario autenticado'))
            : FutureBuilder(
                future: firestore!.collection('users').doc(user.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text('No se encontró el usuario en Firestore'),
                    );
                  }
                  final rawData = snapshot.data!.data();
                  final userData = rawData is Map<String, dynamic>
                      ? rawData
                      : null;
                  final name = userData?['name'] ?? 'Sin nombre';
                  final photoURL = userData?['profileImage'] ?? user.photoURL;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage:
                                (photoURL != null && photoURL.isNotEmpty)
                                ? NetworkImage(photoURL)
                                : null,
                            child: (photoURL == null || photoURL.isEmpty)
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Nombre:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(name),
                      const SizedBox(height: 24),
                      Text(
                        'Email:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(user.email ?? 'Sin email'),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
