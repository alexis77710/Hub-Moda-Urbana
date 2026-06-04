// Archivo: backend/routes/authRoutes.js
// aqui definimos las rutas relacionadas con la autenticación, 
// como el registro y el inicio de sesión de usuarios. 
// Estas rutas se conectan con los controladores correspondientes para manejar la lógica de negocio.

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
// POST /api/usuarios/enviar-otp
router.post('/enviar-otp', authController.generarOtpUsuario);
// Ruta para registrar un usuario nuevo
router.post('/registrar', authController.registrarUsuario);
// Ruta para iniciar sesión
// POST /api/auth/login
router.post('/login', authController.loginUsuario);


module.exports = router;