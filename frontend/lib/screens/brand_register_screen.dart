// Archivo: lib/screens/brand_register_screen.dart
// Esta pantalla es un placeholder por ahora, pero la tenemos lista para cuando empecemos a hacer el formulario de registro de marcas.
import 'package:flutter/material.dart';

class BrandRegisterScreen extends StatelessWidget {
  const BrandRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTRO DE MARCA 🏢', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_outlined, size: 80, color: Colors.black),
              SizedBox(height: 20),
              Text(
                'ZONA DE VENDEDORES',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Aquí armaremos el formulario para pedir RUC, redes sociales y cuenta bancaria de las marcas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}