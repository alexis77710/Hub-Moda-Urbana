// Archivo: routes/marcas.js
const express = require('express');
const router = express.Router();
const marcaController = require('../controllers/marcaController');

// POST /api/marcas/registro
router.post('/registro', marcaController.solicitarRegistroMarca);
// POST /api/marcas/enviar-otp
router.post('/enviar-otp', marcaController.generarOtp);
module.exports = router;