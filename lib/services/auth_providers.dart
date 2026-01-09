import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final registerProvider = FutureProvider.family<void, Map<String, dynamic>>((
  ref,
  userData,
) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final email = userData['email'] as String;
  final password = userData['password'] as String;
  final name = userData['name'] ?? '';
  final lastName = userData['lastName'] ?? '';
  final phone = userData['phone'] ?? '';
  final birthDateString = userData['birthDate'] as String;

  final String? imagePath = userData['profileImagePath'];

  final userCredential = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = userCredential.user;
  if (user == null) {
    throw Exception('No se pudo crear el usuario');
  }

  String profileImageUrl = '';
  if (imagePath != null && imagePath.isNotEmpty) {
    try {
      print('Intentando subir imagen desde: $imagePath');
      final file = File(imagePath);
      print('¿Existe el archivo local?: \'${file.existsSync()}\'');

      final storageRef = storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile_image.jpg');

      final uploadTask = await storageRef.putFile(file);
      print('Subida completada.');

      profileImageUrl = await uploadTask.ref.getDownloadURL();
      print('URL de descarga obtenida: $profileImageUrl');
    } catch (e, stack) {
      print('Error subiendo imagen: $e');
      print('Stacktrace: $stack');
    }
  }

  await user.updateDisplayName('$name $lastName');

  await firestore.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'name': name,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'birthDate': Timestamp.fromDate(DateTime.parse(birthDateString)),
    'profileImage': profileImageUrl,
    'role': 'user',
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
});

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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      return userCredential;
    });
