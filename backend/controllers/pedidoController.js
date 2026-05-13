// Aquí vamos a manejar todo lo relacionado con los pedidos, 
// como crear un nuevo pedido o mostrar los pedidos de un cliente específico

// Importamos el modelo de Pedido para poder crear nuevos pedidos y buscar los existentes
const Pedido = require('../models/Pedido');

// Función para crear un nuevo pedido
exports.crearPedido = async (req, res) => {
    try {
        // 1. Creamos un nuevo pedido con los datos que mande Postman/Flutter (productos y total)
        const pedido = new Pedido(req.body);

        // 2. ¡EL TOQUE MAESTRO! 
        // Asignamos el ID del cliente sacándolo del Pase VIP (Token)
        // req.usuario.id es la información que nuestro guardia (middleware) ya validó
        pedido.cliente = req.usuario.id;

        // 3. Guardamos el pedido en Mongo Atlas
        await pedido.save();

        res.status(201).json({ msg: '¡Pedido creado con éxito, mi bro! 🛒', pedido });

    } catch (error) {
        console.log('Error al crear el pedido:', error);
        res.status(500).send('Hubo un error al procesar la compra bro');
    }
}

// Función extra para que el cliente vea solo SUS pedidos cuando entre a la app
exports.obtenerMisPedidos = async (req, res) => {
    try {
        // Buscamos solo los pedidos donde el "cliente" sea exactamente igual al ID del Token
        const pedidos = await Pedido.find({ cliente: req.usuario.id });
        res.json(pedidos);
    } catch (error) {
        console.log('Error al obtener pedidos:', error);
        res.status(500).send('Hubo un error al buscar tus compras');
    }
}