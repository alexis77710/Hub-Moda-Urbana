// Archivo: lib/main.dart
// Este es el punto de entrada de tu app. Aquí es donde se inicializa todo,
// y donde envolvemos la app con el Provider para que toda la app pueda acceder al carrito

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importamos el paquete nuevo
import 'main_wrapper.dart';
import 'services/cart_provider.dart'; // Importamos tu nuevo servicio

void main() {
  // Envolvemos la app entera en el Provider antes de arrancar
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MiAppModa(),
    ),
  );
}

class MiAppModa extends StatelessWidget {
  const MiAppModa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hub Moda Urbana',
      
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        // ... (Aquí dejas todo tu código de estilos globales igualito como lo tenías)
        inputDecorationTheme: const InputDecorationTheme(
          // ...
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // ...
        ),
      ),
      
      home: const MainWrapper(), 
    );
  }
}