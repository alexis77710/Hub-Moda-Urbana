// Archivo: lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import 'package:flutter/services.dart'; 
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Limpiecito: Ya no necesitamos _orderService ni _estaProcesando aquí bro ✨
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  void _mostrarFormularioEnvio(CartProvider carrito) {
    _correoController.clear();
    _direccionController.clear();
    _telefonoController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? errorCorreo;
        String? errorDireccion;
        String? errorTelefono;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿A DÓNDE LO ENVIAMOS? 📦',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Tu Correo Electrónico',
                      hintText: 'ejemplo@correo.com',
                      border: const OutlineInputBorder(),
                      errorText: errorCorreo,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _direccionController,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: 'Dirección de Entrega',
                      hintText: 'Ej: Av. 6 de Diciembre y Patria',
                      border: const OutlineInputBorder(),
                      errorText: errorDireccion,
                      counterText: '', 
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Número de Teléfono',
                      hintText: 'Ej: 0991234567',
                      border: const OutlineInputBorder(),
                      errorText: errorTelefono,
                      counterText: '', 
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setModalState(() {
                          final correo = _correoController.text.trim();
                          final bool emailValido = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(correo);

                          if (correo.isEmpty) {
                            errorCorreo = 'Bro, rellena el correo';
                          } else if (!emailValido) {
                            errorCorreo = 'Escribe un correo real (ej: tu@email.com o .ec)';
                          } else {
                            errorCorreo = null;
                          }

                          final direccion = _direccionController.text.trim();
                          if (direccion.isEmpty) {
                            errorDireccion = 'Bro, rellena la ubicación';
                          } else if (direccion.length < 5) {
                            errorDireccion = 'Esa dirección es muy corta, sé más específico';
                          } else {
                            errorDireccion = null;
                          }

                          final telefono = _telefonoController.text.trim();
                          if (telefono.isEmpty) {
                            errorTelefono = 'Bro, rellena el teléfono';
                          } else if (telefono.length != 10) {
                            errorTelefono = 'El número debe tener exactamente 10 dígitos';
                          } else if (!telefono.startsWith('0')) {
                            errorTelefono = 'El número debe empezar con 0';
                          } else {
                            errorTelefono = null;
                          }
                        });

                        if (errorCorreo != null || errorDireccion != null || errorTelefono != null) {
                          return;
                        }

                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              correo: _correoController.text.trim(),
                              direccion: _direccionController.text.trim(),
                              telefono: _telefonoController.text.trim(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'CONTINUAR AL PAGO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TU BOLSITA 🛍️',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: carrito.items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está más vacío que mi billetera bro 💨',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: carrito.items.length,
                    itemBuilder: (context, index) {
                      final item = carrito.items[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade800,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        onDismissed: (direction) {
                          Provider.of<CartProvider>(context, listen: false).eliminarDelCarrito(item.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item.imagen),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Talla: ${item.talla}',
                                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.precio}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () => Provider.of<CartProvider>(context, listen: false).restarCantidad(item.id),
                                    ),
                                    Text(
                                      '${item.cantidad}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => Provider.of<CartProvider>(context, listen: false).sumarCantidad(item.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black12)),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                            Text('\$${carrito.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('IVA (15%)', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                            Text('\$${carrito.impuestosIva.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text('\$${carrito.totalFinal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // --- AQUÍ EL BOTÓN YA LIMPIO SANO Y DIRECTO ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _mostrarFormularioEnvio(carrito), // Directo al modal bro
                            child: const Text(
                              'PROCEDER AL PAGO',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}