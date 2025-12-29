import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app_theme.dart';

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
          final isDark = Theme.of(context).brightness == Brightness.dark;

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

          Future<void> saveChanges() async {
            // 🔹 Validaciones básicas
            if (nameController.text.trim().isEmpty ||
                lastNameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nombre y apellido no pueden estar vacíos'),
                ),
              );
              return;
            }

            setState(() => loading = true);

            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            String profileImageUrl = data['profileImage'] ?? '';

            try {
              // 🔹 Subir imagen si cambió
              if (selectedImage != null) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('users')
                    .child(user.uid)
                    .child('profile_image.jpg');

                await ref.putFile(selectedImage!);
                profileImageUrl = await ref.getDownloadURL();
              }

              // 🔹 Actualizar Firestore
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

              // 🔹 Actualizar Firebase Auth displayName
              await user.updateDisplayName(
                '${nameController.text.trim()} ${lastNameController.text.trim()}',
              );

              // 🔹 Mensaje de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado correctamente'),
                ),
              );

              Navigator.pop(context, true);
            } catch (e) {
              setState(() => loading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar perfil: $e')),
              );
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
                  Text(
                    'Editar perfil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🖼️ AVATAR EDITABLE
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: isDark
                          ? AppTheme.navUnselected
                          : Colors.grey[200],
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
                          ? Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildTextField('Nombre', nameController, isDark),
                  const SizedBox(height: 16),
                  _buildTextField('Apellido', lastNameController, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Teléfono',
                    phoneController,
                    isDark,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: birthDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.navSelected,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? Color(0xFF2C3550) : Colors.white,
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
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navSelected,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loading ? null : saveChanges,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
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

TextField _buildTextField(
  String label,
  TextEditingController controller,
  bool isDark, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.navSelected, width: 2),
      ),
      filled: true,
      fillColor: isDark ? Color(0xFF2C3550) : Colors.white,
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
