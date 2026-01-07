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
      // Guardar sesión iniciada
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
      String errorMessage =
          'No pudimos iniciar sesión. Por favor, revisa tu correo y contraseña e inténtalo de nuevo.';
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

  @override
  Widget build(BuildContext context) {
    // Determinar si estamos en tema oscuro o claro para usar los colores correctos
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundStartColor = isDarkMode
        ? AppTheme.navBackground
        : AppTheme
              .splashBackgroundBottom; // Usar splashBackgroundBottom para el color principal claro
    final backgroundEndColor = isDarkMode
        ? AppTheme.navSelected.withOpacity(0.7)
        : AppTheme.navSelected.withOpacity(
            0.7,
          ); // Un poco más oscuro para el gradiente

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
        : AppTheme.navSelected; // Para "Crear cuenta nueva"
    final iconColor = isDarkMode
        ? Colors.white
        : AppTheme.categoryChipText; // Color del ícono de usuario

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
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: cardBorderColor, width: 1.0),
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
                      const SizedBox(height: 8),
                      // ... Texto 'Completa tus datos' eliminado ...
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo',
                          hintText: 'ejemplo@correo.com',
                          labelStyle: TextStyle(color: hintColor),
                          hintStyle: TextStyle(
                            color: hintColor.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.navBackground.withOpacity(0.8)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide
                                .none, // Quitamos el borde por defecto
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: primaryButtonColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: cardBorderColor.withOpacity(0.7),
                              width: 1.0,
                            ),
                          ),
                        ),
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '********',
                          labelStyle: TextStyle(color: hintColor),
                          hintStyle: TextStyle(
                            color: hintColor.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.navBackground.withOpacity(0.8)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: primaryButtonColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: cardBorderColor.withOpacity(0.7),
                              width: 1.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        validator: Validators.password,
                        obscureText: !_showPassword,
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        // ... Botón de recuperar contraseña eliminado ...
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
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  shadowColor: primaryButtonColor.withOpacity(
                                    0.5,
                                  ),
                                  elevation: 8,
                                ),
                                child: Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _guestLogin,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: secondaryButtonColor,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'Entrar como invitado',
                            style: TextStyle(
                              color: secondaryButtonColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            '/register',
                          ); // Cambiado a pushReplacementNamed
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
}
