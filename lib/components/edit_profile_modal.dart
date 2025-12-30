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
              if (selectedImage != null) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('users')
                    .child(user.uid)
                    .child('profile_image.jpg');
                await ref.putFile(selectedImage!);
                profileImageUrl = await ref.getDownloadURL();
              }

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

              await user.updateDisplayName(
                '${nameController.text.trim()} ${lastNameController.text.trim()}',
              );

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
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Card(
                color: isDark ? AppTheme.navBackground : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Imagen central
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 50,
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
                                  size: 36,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[700],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nombre centrado
                      Text(
                        '${nameController.text} ${lastNameController.text}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Campos alineados a la izquierda
                      _buildLeftAlignedTextField(
                        'Nombre',
                        nameController,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildLeftAlignedTextField(
                        'Apellido',
                        lastNameController,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildLeftAlignedTextField(
                        'Teléfono',
                        phoneController,
                        isDark,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: birthDateController,
                        readOnly: true,
                        textAlign:
                            TextAlign.start, // ← fecha alineada a la izquierda
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
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300,
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
                          fillColor: isDark
                              ? const Color(0xFF2C3550)
                              : Colors.white,
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
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // Mantenemos navSelected en ambos, pero ajustamos la intensidad si es necesario
                            backgroundColor: AppTheme.navSelected,
                            foregroundColor: Colors.white,
                            elevation: isDark
                                ? 0
                                : 2, // Menos sombra en dark para un look más moderno
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: loading ? null : saveChanges,
                          child: loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth:
                                        2, // Más fino para que quepa bien en el botón
                                  ),
                                )
                              : const Text(
                                  'Guardar cambios',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

TextField _buildLeftAlignedTextField(
  String label,
  TextEditingController controller,
  bool isDark, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    textAlign: TextAlign.start, // ← Alineado a la izquierda
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
      fillColor: isDark ? const Color(0xFF2C3550) : Colors.white,
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
