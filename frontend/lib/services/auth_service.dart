// Archivo: lib/services/auth_service.dart
// Este servicio se encarga de manejar la lógica de conexión con el backend para el login
// Archivo: lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Importante para leer el token

class AuthService {
  final String _url = 'http://localhost:4000/api/auth/login';

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = data['token'];

        // ¡LA MAGIA DEL DECODER! Extraemos el rol del token
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String rol =
            decodedToken['usuario']['rol']; // Sacamos el rol del payload

        // Guardamos el token y el rol en la memoria del celular
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_rol', rol);

        return token;
      } else {
        throw data['msg'] ?? 'Error desconocido al iniciar sesión';
      }
    } catch (e) {
      if (e is String) throw e;
      throw 'Error de conexión con el servidor';
    }
  }

  // --- NUEVA FUNCIÓN: REGISTRAR CLIENTE ---
  Future<String> registrar(String nombre, String email, String password) async {
    final String urlRegistro = 'http://localhost:4000/api/auth/registrar';

    try {
      final response = await http.post(
        Uri.parse(urlRegistro),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // El backend devuelve el token en data['token']
        String token = data['token'];

        // Extraemos el rol (que por defecto será 'cliente')
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String rol = decodedToken['usuario']['rol'];

        // Guardamos todo en memoria
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_rol', rol);

        return token;
      } else {
        throw data['msg'] ?? 'Error desconocido al registrar';
      }
    } catch (e) {
      if (e is String) throw e;
      throw 'Error de conexión con el servidor';
    }
  }

  // Función extra para leer el rol fácilmente desde cualquier pantalla
  Future<String?> obtenerRolGuardado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_rol');
  }
}
