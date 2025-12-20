import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final registerProvider = FutureProvider.family<void, Map<String, String>>((ref, userData) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final email = userData['email']!;
  final password = userData['password']!;
  final name = userData['name'] ?? '';

  // Crear usuario en Firebase Auth
  final userCredential = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Guardar datos adicionales en Firestore
  await firestore.collection('users').doc(userCredential.user!.uid).set({
    'uid': userCredential.user!.uid,
    'email': email,
    'name': name,
    'createdAt': FieldValue.serverTimestamp(),
  });
});

final loginProvider = FutureProvider.family<UserCredential, Map<String, String>>((ref, credentials) async {
  final auth = FirebaseAuth.instance;
  final email = credentials['email']!;
  final password = credentials['password']!;
  return await auth.signInWithEmailAndPassword(email: email, password: password);
});
