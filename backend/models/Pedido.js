// Este modelo representa un pedido que un cliente hace en la tienda de moda.
// Contiene información sobre quién hizo el pedido, qué productos compró, a dónde se lo enviamos, cuánto costó y el estado del envío.

const mongoose = require('mongoose');

const PedidoSchema = mongoose.Schema({
    // 1. ¿Quién compra? Enlazamos esto con el ID del cliente
    cliente: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Usuario', // Hace referencia a tu modelo Usuario.js
        required: true
    },
    // 2. ¿Qué compra? Es un arreglo porque puede llevar varias prendas
    productos: [
        {
            producto: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Producto', // Hace referencia a tu modelo Producto.js
                required: true
            },
            cantidad: {
                type: Number,
                required: true,
                default: 1
            }
        }
    ],
    // 3. ¿A dónde se lo enviamos?
    direccionEntrega: {
        type: String,
        required: true
    },
    // 4. ¿Cuánto costó todo?
    total: {
        type: Number,
        required: true
    },
    // 5. ¿En qué estado está el envío?
    estado: {
        type: String,
        default: 'Pendiente' // Puede ser: Pendiente, Pagado, Enviado, Entregado
    },
    fechaCreacion: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Pedido', PedidoSchema);