// Archivo: lib/screens/register_screen.dart
// Esta pantalla es para que los clientes puedan crear su cuenta.
// Archivo: lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // <-- IMPORTAMOS EL SERVICIO
import '../main_wrapper.dart'; // Añade esta línea arriba
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _estaCargando = false;
  final AuthService _authService = AuthService(); // <-- INSTANCIAMOS EL SERVICIO

  Future<void> _intentarRegistro() async {
    // 1. Validaciones básicas de la interfaz
    if (_nombreController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bro, llena todos los campos 🛑'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _estaCargando = true;
    });

    try {
      // 2. ¡LLAMADA REAL AL BACKEND!
      await _authService.registrar(
        _nombreController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      
      // 3. Éxito absoluto
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada y sesión iniciada! 🔥'),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Lo mandamos directo al Home (MainWrapper) sin dejar que retroceda
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
        (Route<dynamic> route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      // Si el backend se queja (ej. contraseña débil, correo repetido), mostramos el error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _estaCargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'CREAR CUENTA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Únete para guardar tus hoodies favoritos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Tu Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: _estaCargando ? null : _intentarRegistro,
                    child: _estaCargando 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('REGISTRARME', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}