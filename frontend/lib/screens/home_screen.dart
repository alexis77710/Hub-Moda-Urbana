// Archivo: lib/screens/home_screen.dart
// Esta es tu pantalla de inicio, donde se muestran los productos.
import 'product_detail_screen.dart';
import 'package:flutter/material.dart';
import '../services/product_service.dart'; // ¡Importamos el servicio!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instanciamos nuestro servicio (como el constructor de Angular)
  final ProductService _productService = ProductService();

  List<dynamic> productosReales = [];
  bool estaCargando = true;
  String? mensajeError;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  // Mira lo cortita y limpia que quedó esta función ahora 🤩
  Future<void> cargarDatos() async {
    try {
      final data = await _productService.obtenerRopa();
      if (!mounted) return;

      setState(() {
        productosReales = data;
        estaCargando = false;
      });
      print('Productos cargados desde el servicio: ${productosReales.length}');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        mensajeError = error.toString();
        estaCargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HUB MODA URBANA',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => print('Ir al carrito'),
          )
        ],
      ),
      body: estaCargando
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : mensajeError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(mensajeError!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                )
              : productosReales.isEmpty
                  ? const Center(child: Text('No hay ropa en la tienda todavía bro 👕', style: TextStyle(fontSize: 18)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productosReales.length,
                      itemBuilder: (context, index) {
                        final producto = productosReales[index];
                        
                        // Parche inteligente para la imagen
                        String urlImagen = 'https://via.placeholder.com/150';
                        var campoImagen = producto['imagenes']; 
                        if (campoImagen != null) {
                          if (campoImagen is List && campoImagen.isNotEmpty) {
                            urlImagen = campoImagen[0].toString();
                          } else if (campoImagen is String) {
                            urlImagen = campoImagen;
                          }
                        }

                        // Envolvemos la tarjeta en un detector de gestos
                        return GestureDetector(
                          onTap: () {
                            // Cuando lo tocan, navegamos a la pantalla de detalles y le pasamos el producto
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(producto: producto),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: NetworkImage(urlImagen),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                producto['nombre'] ?? 'Sin nombre',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${producto['precio']?.toString() ?? '0.00'}',
                                style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}