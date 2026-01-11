import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/validators.dart';
import '../services/auth_providers.dart';
import '../app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(
        registerProvider({
          'name': _nameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'phone': _phoneController.text.trim(),
          'birthDate': _birthDate!.toIso8601String(),
        }).future,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Registro exitoso!'),
          content: const Text('Tu cuenta ha sido creada correctamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      String errorMessage =
          'No pudimos crear tu cuenta. Por favor, revisa tus datos e inténtalo de nuevo.';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Ups!'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _birthDateText() {
    if (_birthDate == null) return 'Selecciona tu fecha';
    return '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- LÓGICA DE COLORES BASADA EN TU LOGIN ---
    final backgroundStartColor = isDarkMode
        ? AppTheme.navBackground
        : AppTheme.splashBackgroundBottom;
    final backgroundEndColor = isDarkMode
        ? AppTheme.navSelected.withOpacity(0.7)
        : AppTheme.navSelected.withOpacity(0.7);

    final cardBackgroundColor = isDarkMode
        ? AppTheme.navBackground.withOpacity(0.6)
        : Colors.white.withOpacity(0.5);
    final cardBorderColor = isDarkMode
        ? AppTheme.navSelected.withOpacity(0.5)
        : AppTheme.searchBorder.withOpacity(0.7);
    final textColor = isDarkMode ? Colors.white : AppTheme.categoryChipText;
    final hintColor = isDarkMode ? AppTheme.navUnselected : AppTheme.searchHint;
    final iconColor = isDarkMode ? Colors.white : AppTheme.categoryChipText;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundStartColor, backgroundEndColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cardBorderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt_1, color: iconColor, size: 70),
                    const SizedBox(height: 12),
                    Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      validator: Validators.name,
                      textColor: textColor,
                      hintColor: hintColor,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Apellido',
                      validator: Validators.name,
                      textColor: textColor,
                      hintColor: hintColor,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo',
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textColor: textColor,
                      hintColor: hintColor,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      validator: Validators.phone,
                      keyboardType: TextInputType.phone,
                      textColor: textColor,
                      hintColor: hintColor,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _birthDate = date);
                      },
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: TextEditingController(
                            text: _birthDate == null ? "" : _birthDateText(),
                          ),
                          label: 'Fecha de nacimiento',
                          textColor: textColor,
                          hintColor: hintColor,
                          isDarkMode: isDarkMode,
                          validator: (_) =>
                              _birthDate == null ? 'Requerido' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      validator: Validators.password,
                      obscureText: !_showPassword,
                      textColor: textColor,
                      hintColor: hintColor,
                      isDarkMode: isDarkMode,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: hintColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.navSelected,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _submit,
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                          color: isDarkMode
                              ? AppTheme.navUnselected
                              : AppTheme.navSelected,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required Color hintColor,
    required bool isDarkMode,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        // ✅ PLACEHOLDER
        hintText: label,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        filled: true,
        fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white24 : AppTheme.navSelected,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white10
                : AppTheme.searchBorder.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.navSelected, width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
