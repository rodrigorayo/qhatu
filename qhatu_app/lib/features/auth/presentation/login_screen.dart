import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qhatu_app/core/config/config.dart';
import 'package:qhatu_app/core/theme/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['user']['role']);
        if (data['user']['username'] != null) {
          await prefs.setString('username', data['user']['username']);
        }

        if (!mounted) return;
        
        // Navegación basada en el rol
        final role = data['user']['role'];
        if (role == 'SUPER_ADMIN') {
          context.go('/super_admin');
        } else if (role == 'FERIA_ADMIN') {
          context.go('/feria_admin');
        } else if (role == 'EVALUADOR') {
          context.go('/evaluator');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rol desconocido: $role'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales inválidas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al conectar con el servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/bandera-usa.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(isDark ? 0.65 : 0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: ClipOval(
                child: Material(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.12),
                  child: IconButton(
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      color: isDark ? Colors.white : const Color(0xFF003264),
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                    tooltip: 'Cambiar tema',
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 6,
                    shadowColor: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08),
                      ),
                    ),
                    color: colorScheme.surface.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                           // Logo de UAB / Departamento de Inglés
                           Center(
                             child: Image.asset(
                               'assets/icono-english-uab-without-backgorund.png',
                               height: 100,
                               fit: BoxFit.contain,
                             ),
                           ).animate().scale(delay: 100.ms, duration: 400.ms).fadeIn(),

                          const SizedBox(height: 20),

                          Text(
                            'English Department',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  letterSpacing: 0.5,
                                ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: 6),

                          Text(
                            'UAB • Feria de Evaluación',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 300.ms),

                          const SizedBox(height: 32),

                          // Campo Usuario
                          TextField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              hintText: 'Nombre de usuario',
                              prefixIcon: Icon(Icons.person_rounded, color: colorScheme.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant.withOpacity(0.15),
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                          const SizedBox(height: 18),

                          // Campo Contraseña
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Ingresa tu contraseña',
                              prefixIcon: Icon(Icons.lock_rounded, color: colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant.withOpacity(0.15),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                          const SizedBox(height: 32),

                          // Botón Ingresar
                          FilledButton(
                            onPressed: _isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shadowColor: colorScheme.primary.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Ingresar',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ).animate().fadeIn(delay: 600.ms).scale(),

                          const SizedBox(height: 24),

                          // Versión de parche
                          Center(
                            child: Text(
                              'v0.1.0-patch12',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                                fontSize: 11,
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
            ),
          ),
        ],
      ),
    );
  }
}
