// Archivo: lib/screens/brand_register_screen.dart
// Esta pantalla es para que las marcas puedan solicitar su registro en el Hub de Moda.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/brand_service.dart';

class BrandRegisterScreen extends StatefulWidget {
  const BrandRegisterScreen({super.key});

  @override
  State<BrandRegisterScreen> createState() => _BrandRegisterScreenState();
}

class _BrandRegisterScreenState extends State<BrandRegisterScreen> {
  final TextEditingController _nombreMarcaController = TextEditingController();
  final TextEditingController _identificacionController =
      TextEditingController(); // Ahora es Cédula o RUC
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final BrandService _brandService =
      BrandService(); // Servicio para conectar con el backend
  bool _estaCargando = false;

  // Variables para guardar los mensajes de error de cada caja
  String? errorNombre;
  String? errorIdentificacion;
  String? errorInstagram;
  String? errorCorreo;
  String? errorPassword;
// --- FUNCIÓN MATEMÁTICA: Módulo 10 para Cédula y RUC ---
  bool _validarIdentificacionEcuatoriana(String id) {
    if (id.length != 10 && id.length != 13) return false;
    
    // Si es RUC (13 dígitos), los últimos 3 deben ser '001' (Para personas naturales)
    if (id.length == 13 && !id.endsWith('001')) return false;

    // Extraemos solo los primeros 10 dígitos (la cédula base)
    final cedula = id.substring(0, 10);
    
    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;
    
    final tercerDigito = int.parse(cedula[2]);
    if (tercerDigito >= 6) return false;

    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;
    
    for (int i = 0; i < 9; i++) {
      int valor = int.parse(cedula[i]) * coeficientes[i];
      if (valor > 9) valor -= 9;
      suma += valor;
    }
    
    int digitoEsperado = 10 - (suma % 10);
    if (digitoEsperado == 10) digitoEsperado = 0;

    return digitoEsperado == int.parse(cedula[9]);
  }
  Future<void> _enviarSolicitud() async {
    // 1. Extraemos los textos primero
    final nombre = _nombreMarcaController.text.trim();
    final identificacion = _identificacionController.text.trim();
    final instagram = _instagramController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    bool hayErrores = false;

    // 2. Ejecutamos el setState SOLO para actualizar los textos rojos en la pantalla
    setState(() {
      errorNombre = null;
      errorIdentificacion = null;
      errorInstagram = null;
      errorCorreo = null;
      errorPassword = null;

      if (nombre.isEmpty) {
        errorNombre = 'Bro, dinos cómo se llama tu marca';
        hayErrores = true;
      }

     // Validamos Cédula (10) o RUC (13) con pura matemática 🇪🇨
      if (identificacion.isEmpty) {
        errorIdentificacion = 'Falta tu número de identificación';
        hayErrores = true;
      } else if (!_validarIdentificacionEcuatoriana(identificacion)) {
        errorIdentificacion = 'Esa Cédula o RUC no es válido o no existe bro 🛑';
        hayErrores = true;
      }

      if (instagram.isEmpty) {
        errorInstagram = 'Déjanos tu usuario para ver tu ropa';
        hayErrores = true;
      } else if (!instagram.startsWith('@')) {
        errorInstagram = 'Debe empezar con @ (Ej: @tu_marca)';
        hayErrores = true;
      }

      final bool emailValido = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(correo);
      if (correo.isEmpty) {
        errorCorreo = 'Ingresa un correo de contacto';
        hayErrores = true;
      } else if (!emailValido) {
        errorCorreo = 'Ese formato de correo no convence bro';
        hayErrores = true;
      }

      if (password.isEmpty) {
        errorPassword = 'Crea una contraseña para tu cuenta';
        hayErrores = true;
      } else if (password.length < 6) {
        errorPassword = 'Pon algo más seguro, mínimo 6 caracteres';
        hayErrores = true;
      } else {
        // Verificamos que tenga al menos una mayúscula y un número
        final tieneMayuscula = RegExp(r'[A-Z]').hasMatch(password);
        final tieneNumero = RegExp(r'[0-9]').hasMatch(password);

        if (!tieneMayuscula || !tieneNumero) {
          errorPassword =
              'Tu contraseña debe tener al menos una letra mayúscula y un número bro';
          hayErrores = true;
        }
      }
    });

    // 3. ¡EL FRENO DE MANO REAL! (Fuera del setState)
    // Si se prendió alguna alerta, la función muere aquí y no avanza al mensaje verde.
    if (hayErrores) return;

    // 4. Si todo está perfecto, encendemos el circulito de carga
    setState(() {
      _estaCargando = true;
    });

    // 5. Enviamos al backend
    // 5. ¡LA CONEXIÓN REAL AL BACKEND!
    try {
      await _brandService.solicitarRegistro(
        nombre,
        identificacion,
        instagram,
        correo,
        password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Solicitud enviada! Revisaremos tu marca y te avisaremos al correo 🏢✨',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      if (Navigator.canPop(context)) {
        // Solo intentamos volver si hay una pantalla atrás, para evitar errores raros
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      // Si Node.js rechaza algo (ej: correo duplicado), mostramos el mensaje rojo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error ❌'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _estaCargando = false; // Apagamos la carga pase lo que pase
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ZONA B2B',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 60,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
                const Text(
                  'ÚNETE AL HUB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vende tu ropa en nuestra plataforma. \nLlena tus datos para evaluar tu solicitud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _nombreMarcaController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Comercial de la Marca',
                    hintText: 'Ej: Streetwear EC',
                    border: const OutlineInputBorder(),
                    errorText: errorNombre, // <-- ALERTA EN LÍNEA
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _identificacionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 13,
                  decoration: InputDecoration(
                    labelText: 'Cédula o RUC',
                    hintText: 'Tus 10 o 13 dígitos fiscales',
                    border: const OutlineInputBorder(),
                    errorText: errorIdentificacion, // <-- ALERTA EN LÍNEA
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _instagramController,
                  decoration: InputDecoration(
                    labelText: 'Instagram Oficial',
                    hintText: 'Ej: @tu_marca',
                    border: const OutlineInputBorder(),
                    errorText: errorInstagram, // <-- ALERTA EN LÍNEA
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo de Contacto',
                    hintText: 'contacto@tumarca.com',
                    border: const OutlineInputBorder(),
                    errorText: errorCorreo, // <-- ALERTA EN LÍNEA
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Crea una contraseña segura',
                    border: const OutlineInputBorder(),
                    errorText: errorPassword, // <-- ALERTA EN LÍNEA
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _estaCargando ? null : _enviarSolicitud,
                    child: _estaCargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ENVIAR SOLICITUD DE MARCA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
