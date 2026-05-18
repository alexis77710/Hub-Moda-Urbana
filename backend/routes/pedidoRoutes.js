//archivo: backend/routes/pedidoRoutes.js
// aqui definimos las rutas relacionadas con los pedidos, 
// como hacer una compra y ver el historial de compras del usuario logueado. 
// Estas rutas están protegidas por el middleware de autenticación 
// para asegurar que solo los usuarios autenticados puedan acceder a ellas.

const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');
const auth = require('../middleware/auth'); 

// Ruta para hacer una compra usuarios no logueados también pueden comprar, por eso no usamos el middleware de auth aquí
// POST /api/pedidos
router.post('/', pedidoController.crearPedido);

// Ruta para ver el historial de compras del usuario logueado
// Esta ruta sí requiere autenticación, por eso usamos el middleware de auth
// GET /api/pedidos/mis-pedidos
router.get('/mis-pedidos', auth.verificarToken, pedidoController.obtenerMisPedidos);

module.exports = router;