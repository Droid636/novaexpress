import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// =======================
/// REGISTRO
/// =======================
final registerProvider = FutureProvider.family<void, Map<String, String>>((
  ref,
  userData,
) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final email = userData['email']!;
  final password = userData['password']!;
  final name = userData['name'] ?? '';
  final lastName = userData['lastName'] ?? '';
  final phone = userData['phone'] ?? '';
  final birthDateString = userData['birthDate']!;

  // 1️⃣ Crear usuario en Firebase Auth
  final userCredential = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = userCredential.user;
  if (user == null) {
    throw Exception('No se pudo crear el usuario');
  }

  // 2️⃣ Actualizar displayName en Auth (opcional pero recomendado)
  await user.updateDisplayName('$name $lastName');

  // 3️⃣ Guardar datos adicionales en Firestore
  await firestore.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'name': name,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'birthDate': Timestamp.fromDate(DateTime.parse(birthDateString)),
    'profileImage': '', // se actualizará en perfil
    'role': 'user',
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
});

/// =======================
/// LOGIN
/// =======================
final loginProvider =
    FutureProvider.family<UserCredential, Map<String, String>>((
      ref,
      credentials,
    ) async {
      final auth = FirebaseAuth.instance;

      final email = credentials['email']!;
      final password = credentials['password']!;

      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔄 Actualizar último login (opcional pero recomendado)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      return userCredential;
    });
