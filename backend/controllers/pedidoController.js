// Aquí vamos a manejar todo lo relacionado con los pedidos, 
// como crear un nuevo pedido o mostrar los pedidos de un cliente específico

// Importamos el modelo de Pedido para poder crear nuevos pedidos y buscar los existentes
const Pedido = require('../models/Pedido');

exports.crearPedido = async (req, res) => {
    try {
        const { productos, total, correoComprador, direccionEnvio, telefonoComprador } = req.body;

        const appToken = req.headers['x-app-source'];
        if (appToken !== 'hub_moda_app_2026') {
            return res.status(401).json({ msg: 'Petición rechazada, usa la app oficial bro 🛑' });
        }

        if (!correoComprador || !direccionEnvio || !telefonoComprador) {
            return res.status(400).json({ msg: 'Faltan datos de envío (correo, dirección o teléfono) 📦' });
        }

        // --- ¡EL BLINDAJE BACKEND (REGEX)! ---
        
        // 1. Regex de Correo: Exige texto + @ + texto + . + texto (Acepta .com, .ec, .edu.ec, etc)
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(correoComprador)) {
            return res.status(400).json({ msg: 'El formato del correo es inválido bro, intenta de nuevo 🛑' });
        }

        // 2. Regex de Teléfono de Ecuador: Exige que empiece con 0 y tenga exactamente 10 números en total
        const telefonoRegex = /^0\d{9}$/; 
        if (!telefonoRegex.test(telefonoComprador)) {
            return res.status(400).json({ msg: 'El teléfono debe tener 10 números y empezar con 0 bro 📱' });
        }

        // --- EL PARCHE MAESTRO ---
        // Acomodamos los datos exactos que vienen de Flutter para que encajen en Mongoose
        const productosMapeados = productos.map(item => ({
            producto: item.productoId, // Flutter lo llama productoId, Mongoose lo llama producto
            cantidad: item.cantidad,
            talla: item.talla,
            precio: item.precio
        }));

        const pedido = new Pedido({
            productos: productosMapeados,
            total,
            correoComprador,
            direccionEnvio,
            telefonoComprador
        });

        await pedido.save();

        res.status(201).json({ msg: '¡Pedido creado con éxito, mi bro! 🛒', pedido });

    } catch (error) {
        console.log('Error al crear el pedido:', error);
        res.status(500).send('Hubo un error al procesar la compra bro');
    }
}

exports.obtenerMisPedidos = async (req, res) => {
    try {
        const pedidos = await Pedido.find({ cliente: req.usuario.id });
        res.json(pedidos);
    } catch (error) {
        console.log('Error al obtener pedidos:', error);
        res.status(500).send('Hubo un error al buscar tus compras');
    }
}