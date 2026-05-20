// Archivo: routes/marcas.js
const express = require('express');
const router = express.Router();
const marcaController = require('../controllers/marcaController');

// POST /api/marcas/registro
router.post('/registro', marcaController.solicitarRegistroMarca);

module.exports = router;