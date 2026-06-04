// Archivo: lib/services/auth_service.dart
// Este servicio se encarga de manejar la lógica de conexión con el backend para el login
// Archivo: lib/services/auth_service.dart
// Archivo: lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; 

class AuthService {
  final String _urlLogin = 'http://localhost:4000/api/auth/login';
  final String _urlRegistro = 'http://localhost:4000/api/auth/registrar';
  final String _urlOtp = 'http://localhost:4000/api/auth/enviar-otp'; // <-- NUEVA RUTA

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_urlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = data['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String rol = decodedToken['usuario']['rol']; 

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

  // --- NUEVA FUNCIÓN: PEDIR EL CÓDIGO AL CORREO ---
  Future<void> enviarCodigoOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_urlOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return; 
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['msg'] ?? 'Error al pedir código';
      }
    } catch (e) {
      if (e is String) throw e;
      throw 'Error de conexión bro 😅';
    }
  }

  // --- FUNCIÓN REGISTRAR ACTUALIZADA (AHORA EXIGE CÓDIGO) ---
  Future<String> registrar(String nombre, String email, String password, String codigoOtp) async {
    try {
      final response = await http.post(
        Uri.parse(_urlRegistro),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'codigoOtp': codigoOtp, // <-- MANDAMOS EL CÓDIGO
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        String token = data['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String rol = decodedToken['usuario']['rol'];

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

  Future<String?> obtenerRolGuardado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_rol');
  }
}