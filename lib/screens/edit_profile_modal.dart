import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  File? selectedImage;
  bool loading = false;

  final picker = ImagePicker();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final picked = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 70,
            );

            if (picked != null) {
              setState(() {
                selectedImage = File(picked.path);
              });
            }
          }

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

                  // 🖼️ AVATAR EDITABLE
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : (data['profileImage'] != null &&
                                data['profileImage'].toString().isNotEmpty)
                          ? NetworkImage(data['profileImage'])
                          : null,
                      child:
                          selectedImage == null &&
                              (data['profileImage'] == null ||
                                  data['profileImage'].toString().isEmpty)
                          ? const Icon(Icons.camera_alt, size: 32)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

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

                              String profileImageUrl =
                                  data['profileImage'] ?? '';

                              // 🔥 SUBIR IMAGEN SI CAMBIÓ
                              if (selectedImage != null) {
                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child('users')
                                    .child(user.uid)
                                    .child('profile_image.jpg');

                                await ref.putFile(selectedImage!);
                                profileImageUrl = await ref.getDownloadURL();
                              }

                              // 🔄 FIRESTORE
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
                                    'profileImage': profileImageUrl,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });

                              // 🔄 AUTH
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

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
