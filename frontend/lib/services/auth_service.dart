// Archivo: lib/services/auth_service.dart
// Este servicio se encarga de manejar la lógica de conexión con el backend para el login
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // La ruta exacta de tu backend para el login
  final String _url = 'http://localhost:4000/api/auth/login';

  // Esta función recibe el correo y la clave, y devuelve el Token si todo sale bien, 
  // o lanza (throw) el error exacto si algo falla.
  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ¡Login exitoso! Devolvemos el Token VIP
        return data['token'];
      } else {
        // Si el backend mandó un 400 (ej: clave mala), lanzamos el mensaje del backend
        throw data['msg'] ?? 'Error desconocido al iniciar sesión';
      }
    } catch (e) {
      // Si el error es un String (el que lanzamos arriba), lo pasamos tal cual
      if (e is String) throw e; 
      // Si es otro error (ej: backend apagado)
      throw 'Error de conexión con el servidor';
    }
  }
}