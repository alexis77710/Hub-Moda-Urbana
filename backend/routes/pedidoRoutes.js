// aqui definimos las rutas relacionadas con los pedidos, 
// como hacer una compra y ver el historial de compras del usuario logueado. 
// Estas rutas están protegidas por el middleware de autenticación 
// para asegurar que solo los usuarios autenticados puedan acceder a ellas.

const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');
const auth = require('../middleware/auth'); 

// Ruta para hacer una compra (Cualquier usuario con Token)
// POST /api/pedidos
router.post('/', auth.verificarToken, pedidoController.crearPedido);

// Ruta para ver el historial de compras del usuario logueado
// GET /api/pedidos/mis-pedidos
router.get('/mis-pedidos', auth.verificarToken, pedidoController.obtenerMisPedidos);

module.exports = router;