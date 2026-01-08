import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _guestLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isGuest', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(
        loginProvider({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }).future,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Bienvenido!'),
          content: const Text('Inicio de sesión exitoso.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Ups!'),
          content: const Text(
            'No pudimos iniciar sesión. Revisa tu correo y contraseña.',
          ),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundStartColor = isDarkMode
        ? AppTheme.navBackground
        : AppTheme.splashBackgroundBottom;

    final backgroundEndColor = AppTheme.navSelected.withOpacity(0.7);

    final cardBackgroundColor = isDarkMode
        ? AppTheme.navBackground.withOpacity(0.6)
        : Colors.white.withOpacity(0.5);

    final cardBorderColor = isDarkMode
        ? AppTheme.navSelected.withOpacity(0.5)
        : AppTheme.searchBorder.withOpacity(0.7);

    final textColor = isDarkMode ? Colors.white : AppTheme.categoryChipText;

    final hintColor = isDarkMode ? AppTheme.navUnselected : AppTheme.searchHint;

    final primaryButtonColor = AppTheme.navSelected;
    final secondaryButtonColor = isDarkMode
        ? AppTheme.navUnselected
        : AppTheme.navSelected;

    final iconColor = isDarkMode ? Colors.white : AppTheme.categoryChipText;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundStartColor, backgroundEndColor],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 80, color: iconColor),
                      const SizedBox(height: 16),
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      /// EMAIL
                      TextFormField(
                        controller: _emailController,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor),
                        decoration: _inputDecoration(
                          context,
                          label: 'Correo',
                          hint: 'ejemplo@correo.com',
                          hintColor: hintColor,
                          borderColor: cardBorderColor,
                          primaryColor: primaryButtonColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        validator: Validators.password,
                        obscureText: !_showPassword,
                        style: TextStyle(color: textColor),
                        decoration: _inputDecoration(
                          context,
                          label: 'Contraseña',
                          hint: '********',
                          hintColor: hintColor,
                          borderColor: cardBorderColor,
                          primaryColor: primaryButtonColor,
                          suffix: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: isDarkMode ? Colors.white70 : Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _isLoading
                          ? CircularProgressIndicator(color: primaryButtonColor)
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryButtonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                ),
                                child: const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 16),

                      /// 👉 BOTÓN INVITADO (MISMO DISEÑO QUE CREAR CUENTA)
                      TextButton(
                        onPressed: _guestLogin,
                        child: Text(
                          'Entrar como invitado',
                          style: TextStyle(
                            color: secondaryButtonColor,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      /// CREAR CUENTA
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed('/register');
                        },
                        child: Text(
                          'Crear cuenta nueva',
                          style: TextStyle(
                            color: secondaryButtonColor,
                            fontSize: 16,
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
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required Color hintColor,
    required Color borderColor,
    required Color primaryColor,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: hintColor),
      hintStyle: TextStyle(color: hintColor.withOpacity(0.7)),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.navBackground.withOpacity(0.8)
          : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      suffixIcon: suffix,
    );
  }
}
