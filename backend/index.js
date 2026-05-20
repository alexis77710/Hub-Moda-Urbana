// index.js es el punto de entrada de nuestro backend.
//  Aquí configuramos el servidor, 
// conectamos a la base de datos y definimos las rutas principales.

const express = require('express');
const cors = require('cors');
require('dotenv').config();
const conectarDB = require('./config/db');
const app = express();
const PORT = process.env.PORT || 4000;
// process.env.PORT es para que Heroku o cualquier plataforma pueda asignar el puerto automáticamente, 
// y si no, usamos el 4000 para desarrollo local.

// Conectar a la base de datos
conectarDB();

// Middlewares
// un middleware es una función que se ejecuta antes de llegar a las rutas.
// CORS es clave para que la app de Flutter pueda comunicarse con este backend sin problemas de seguridad
app.use(cors());
app.use(express.json()); // Clave para poder recibir JSON desde la app de Flutter


//  AQUÍ IMPORTAMOS Y USAMOS LAS RUTAS
app.use('/api/productos', require('./routes/productoRoutes'));
// Agregamos la ruta de autenticación
app.use('/api/auth', require('./routes/authRoutes'));
// Agregamos la ruta de pedidos
app.use('/api/pedidos', require('./routes/pedidoRoutes'));
app.use('/api/marcas', require('./routes/marcas'));

// Levantar el servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en el puerto ${PORT}`);
});