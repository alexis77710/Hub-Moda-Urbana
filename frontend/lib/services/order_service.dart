// Archivo: lib/services/order_service.dart
// Este servicio es el puente entre tu app y el backend para todo lo relacionado con las compras.
// Aquí es donde vamos a mandar la información del carrito al backend para crear un pedido.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_provider.dart';

class OrderService {
  // ¡Actualizado a la ruta correcta!
  final String _url = 'http://localhost:4000/api/pedidos'; 

  Future<void> crearOrden(List<CartItem> items, double total, String correo, String direccion, String telefono) async {
    try {
      final listaProductos = items.map((item) => {
        'productoId': item.id.split('_')[0], 
        'cantidad': item.cantidad,
        'talla': item.talla,
        'precio': item.precio
      }).toList();

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          // ¡NUESTRO CANDADO DE SEGURIDAD!
          'x-app-source': 'hub_moda_app_2026' 
        },
        body: jsonEncode({
          'productos': listaProductos,
          'total': total,
          // Mandamos los datos del invitado
          'correoComprador': correo,
          'direccionEnvio': direccion,
          'telefonoComprador': telefono,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; 
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['msg'] ?? 'Error al crear el pedido: ${response.statusCode}';
      }
    } catch (e) {
      if (e is String) throw e;
      throw 'Error de conexión con el servidor bro 😅';
    }
  }
}