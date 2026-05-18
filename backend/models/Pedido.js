// Este modelo representa un pedido que un cliente hace en la tienda de moda.
// Contiene información sobre quién hizo el pedido, qué productos compró, a dónde se lo enviamos, cuánto costó y el estado del envío.

const mongoose = require('mongoose');

const PedidoSchema = mongoose.Schema({
    cliente: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Usuario',
        required: false 
    },
    correoComprador: { type: String, required: true },
    direccionEnvio: { type: String, required: true }, // Unificamos a un solo campo de dirección
    telefonoComprador: { type: String, required: true },
    
    productos: [
        {
            producto: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Producto',
                required: true
            },
            cantidad: { type: Number, required: true, default: 1 },
            talla: { type: String, required: true }, // ¡NUEVO! Vital para ropa
            precio: { type: Number, required: true } // ¡NUEVO! Historial del precio
        }
    ],
    
    total: { type: Number, required: true },
    estado: { type: String, default: 'Pendiente' },
    fechaCreacion: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Pedido', PedidoSchema);