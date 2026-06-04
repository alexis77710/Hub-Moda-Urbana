// Archivo: lib/screens/profile_screen.dart
// Esta pantalla es el perfil del usuario. Por ahora es un placeholder, 
//pero aquí es donde el usuario podrá ver y editar sus datos personales.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_wrapper.dart'; // Para reiniciar la app

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- LA FUNCIÓN DESTRUCTORA DE SESIONES ---
  Future<void> _cerrarSesion(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ¡BOMBA NUCLEAR! Borra el token y el rol de la memoria

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada correctamente bro 👋'),
        backgroundColor: Colors.black,
      ),
    );

    // Reiniciamos la app mandándolo al MainWrapper desde cero
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainWrapper()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MI PERFIL 👤', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black12,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              const SizedBox(height: 20),
              const Text('¡Hola, crack!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Aquí pronto podrás editar tus datos y ver tus compras.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              
              const Spacer(), // Empuja el botón al fondo de la pantalla

              // EL BOTÓN ROJO DE CERRAR SESIÓN
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
                  onPressed: () => _cerrarSesion(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}