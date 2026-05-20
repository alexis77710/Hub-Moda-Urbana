// Archivo: lib/screens/login_screen.dart
// Esta pantalla es para que los usuarios puedan iniciar sesión en el Hub de Moda Urbana. Aquí vamos a conectar con el 
//AuthService que creamos para enviar las credenciales al backend y manejar la respuesta (token VIP o errores). 
//También vamos a tener un botón para navegar a la pantalla de registro de usuarios,
// y otro para que las marcas puedan ir a su propio formulario de registro.

import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ¡Importamos el nuevo puente!
import 'brand_register_screen.dart'; // Esta es la pantalla de registro de marcas, que por ahora es un placeholder pero ya la tenemos lista para cuando empecemos a hacer el formulario de registro de marcas.
import 'register_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instanciamos el servicio
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorEmail;
  String? errorPassword;
  bool estaCargando = false; // Para que el botón muestre que está pensando

  Future<void> intentarLogin() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    setState(() {
      errorEmail = null;
      errorPassword = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) errorEmail = 'El correo es obligatorio';
        if (password.isEmpty) errorPassword = 'La contraseña es obligatoria';
      });
      return;
    }

    setState(() {
      estaCargando = true; // Prendemos el "cargando"
    });

    try {
      // ¡AQUÍ ESTÁ LA MAGIA! Llamamos al servicio en una sola línea
      final tokenVip = await _authService.login(email, password);

      if (!mounted) return;

      print('AJAJAJ Pase VIP obtenido desde el servicio: $tokenVip');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido a Hub Moda Urbana! 🚀'),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 2),
        ),
      );

      // Aquí más adelante le diremos: "Navega al inicio ahora que ya tienes token"
    } catch (error) {
      if (!mounted) return;

      final String mensajeError = error.toString().toLowerCase();

      setState(() {
        // Lógica visual: ¿A qué caja le echamos la culpa?
        if (mensajeError.contains('usuario') ||
            mensajeError.contains('correo') ||
            mensajeError.contains('email')) {
          errorEmail = error.toString();
        } else if (mensajeError.contains('contraseña') ||
            mensajeError.contains('clave')) {
          errorPassword = error.toString();
        } else {
          // Si es un error general (ej: backend apagado), lo ponemos en el correo por ahora
          errorEmail = error.toString();
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          estaCargando = false; // Apagamos el "cargando" pase lo que pase
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'HUB\nMODA URBANA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 50),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    errorText: errorEmail,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    errorText: errorPassword,
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: estaCargando
                      ? null
                      : intentarLogin, // Se desactiva si está cargando
                  child: estaCargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('INICIAR SESIÓN'),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    // ¡Revivimos el botón!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'CREAR CUENTA NUEVA',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- NUEVA SECCIÓN PARA VENDEDORES ---
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.black26)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.black26)),
                  ],
                ),
                const SizedBox(height: 20),

                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BrandRegisterScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.storefront, color: Colors.black),
                  label: const Text(
                    '¿Eres una marca? Vende aquí.',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                // -------------------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}
