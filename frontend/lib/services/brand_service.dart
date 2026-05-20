// Archivo: lib/services/brand_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class BrandService {
  final String _url = 'http://localhost:4000/api/marcas/registro';

  Future<void> solicitarRegistro(String nombre, String identificacion, String instagram, String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'x-app-source': 'hub_moda_app_2026' // ¡El candado anti-bots!
        },
        body: jsonEncode({
          'nombreMarca': nombre,
          'identificacion': identificacion,
          'instagram': instagram,
          'correo': correo,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; // Todo salió perfecto
      } else {
        // Si el backend nos frena (ej: el correo ya existe), leemos el error
        final errorData = jsonDecode(response.body);
        throw errorData['msg'] ?? 'Error al enviar solicitud: ${response.statusCode}';
      }
    } catch (e) {
      if (e is String) throw e;
      throw 'Error de conexión con el servidor bro 😅';
    }
  }
}