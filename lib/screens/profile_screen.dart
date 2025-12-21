import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: user == null
            ? const Center(child: Text('No hay usuario autenticado'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        child: Icon(Icons.person, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          user.displayName ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Email:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(user.email ?? 'Sin email'),
                  const SizedBox(height: 24),
                  Text('UID:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(user.uid),
                ],
              ),
      ),
    );
  }
}
