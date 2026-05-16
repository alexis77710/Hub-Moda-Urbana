// Archivo: lib/main.dart
// en este archivo se configura el tema global de la app y se llama al MainWrapper 
//que maneja la navegación entre pantallas

import 'package:flutter/material.dart';
import 'package:frontend/main_wrapper.dart';


void main() {
  runApp(const MiAppModa());
}

class MiAppModa extends StatelessWidget {
  const MiAppModa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hub Moda Urbana',
      
      // AQUÍ ESTÁ EL "CSS GLOBAL"
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
      
      home: const MainWrapper(), // Arranca la app mostrando el Login
    );
  }
}