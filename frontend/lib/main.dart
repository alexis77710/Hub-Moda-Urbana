import 'package:flutter/material.dart';

void main() {
  runApp(const MiAppModa());
}

class MiAppModa extends StatelessWidget {
  const MiAppModa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hub de Moda',
      home: Scaffold(
        // 1. La barrita de arriba de la app
        appBar: AppBar(
          title: const Text('Login - Hub de Moda'),
          backgroundColor: Colors.black, 
          foregroundColor: Colors.white,
        ),
        // 2. Padding le da un margen a los lados para que no quede pegado a los bordes
        body: Padding(
          padding: const EdgeInsets.all(20.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra la columna verticalmente
            children: [
              // --- HIJO 1: Caja de texto para el Correo ---
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(), // Le da un borde cuadradito
                ),
              ),
              
              // --- HIJO 2: Espacio en blanco ---
              const SizedBox(height: 20), 
              
              // --- HIJO 3: Caja de texto para la Contraseña ---
              const TextField(
                obscureText: true, // ¡La magia! Esto oculta la clave con puntitos
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              
              // --- HIJO 4: Más espacio en blanco ---
              const SizedBox(height: 30), 
              
              // --- HIJO 5: El botón de Iniciar Sesión ---
              ElevatedButton(
                onPressed: () {
                  // Aquí después conectaremos con Node.js
                  print('AJAJAJ le diste clic al botón');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('INICIAR SESIÓN'),
                
              ),
              // --- HIJO 6: Espacio pequeño ---
              const SizedBox(height: 15), 
              
              // --- HIJO 7: El botón para ir a Registro ---
              TextButton(
                onPressed: () {
                  // Más adelante aquí pondremos el código para cambiar de pantalla
                  print('AJAJAJ nos vamos a la pantalla de registro');
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold, // Para que la letra se vea más gordita
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}