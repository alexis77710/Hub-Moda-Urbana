// Archivo: lib/screens/product_detail_screen.dart
//Esta pantalla va a recibir la información del producto que el usuario tocó y la va a dibujar en grande.
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  // Esta variable va a recibir toda la info del producto desde el Home
  final dynamic producto;

  const ProductDetailScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    // 1. Reciclamos tu parche inteligente para la imagen
    String urlImagen = 'https://via.placeholder.com/400';
    var campoImagen = producto['imagenes']; 
    if (campoImagen != null) {
      if (campoImagen is List && campoImagen.isNotEmpty) {
        urlImagen = campoImagen[0].toString();
      } else if (campoImagen is String) {
        urlImagen = campoImagen;
      }
    }

    return Scaffold(
      // Un AppBar transparente. Flutter pone la flecha de "Volver" automáticamente.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // SingleChildScrollView por si la pantalla es pequeña y hay que hacer scroll
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
          children: [
            // 2. LA FOTO GIGANTE ESTILO REVISTA
            Container(
              width: double.infinity,
              height: 450, // Bien alta para que luzca la prenda
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: DecorationImage(
                  image: NetworkImage(urlImagen),
                  fit: BoxFit.cover, // Llena todo el espacio
                ),
              ),
            ),
            
            // 3. LA INFO DEL PRODUCTO
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: -1.0, // Letras juntas, estética urbana
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${producto['precio']?.toString() ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 22, 
                      color: Colors.black54, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 30), // Espacio grande antes del botón
                  
                  // 4. EL BOTÓN DE COMPRA
                  SizedBox(
                    width: double.infinity, // Hace que el botón ocupe todo el ancho
                    child: ElevatedButton(
                      onPressed: () {
                        print('AJAJAJ Producto añadido al carrito 🛒');
                      },
                      child: const Text('AÑADIR AL CARRITO'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}