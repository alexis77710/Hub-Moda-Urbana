// index.js es el punto de entrada de nuestro backend.
// Aquí configuramos el servidor, conectamos a la base de datos y definimos las rutas principales.

const express = require("express"); // Framework para crear el servidor y manejar rutas
const cors = require("cors"); // Middleware para permitir solicitudes desde el frontend (Flutter) 
// sin bloqueos de CORS
const helmet = require("helmet"); // Middleware para configurar cabeceras HTTP seguras y ocultar que usamos Express 
const mongoSanitize = require("express-mongo-sanitize");  // Middleware para limpiar los datos entrantes 
// y prevenir inyecciones NoSQL
const rateLimit = require("express-rate-limit"); // Middleware para limitar
//  la cantidad de peticiones que una IP puede hacer en un tiempo determinado 
require("dotenv").config(); // Carga las variables de entorno desde el archivo .env (como la URI de MongoDB)
const conectarDB = require("./config/db"); // Función para conectar a la base de datos MongoDB Atlas

const app = express();
const PORT = process.env.PORT || 4000;

// Conectar a la base de datos distribuida en la nube
conectarDB();

// ==========================================
//     CAPA 1: SEGURIDAD GLOBAL DE RED
// ==========================================
// Configura cabeceras HTTP seguras ocultando que usamos Express
app.use(helmet()); 

// Permite que la app de Flutter se comunique con el backend sin bloqueos de origen
app.use(cors()); 

// Control de tráfico anti-DDoS: Máximo 100 peticiones cada 10 minutos por IP
const limiter = rateLimit({
  windowMs: 10 * 60 * 1000, 
  max: 100, 
  message: { msg: "Demasiadas peticiones desde esta IP, cálmate bro 🛑" },
});
app.use(limiter);

// ==========================================
//   CAPA 2: PARSING Y DESINFECCIÓN DE DATOS
// ==========================================
// Transformamos los datos entrantes en formato JSON (Crea el req.body)
app.use(express.json()); 
// Middleware personalizado para sanitizar NoSQL Injection
const sanitizarDatos = (req, res, next) => {
  const sanitizeObject = (obj) => {
    if (obj && typeof obj === 'object') {
      Object.keys(obj).forEach(key => {
        // Si el key tiene un $, lo eliminamos (NoSQL Injection)
        if (key.includes('$')) {
          delete obj[key];
        }
        // Si el valor es un string con $, lo reemplazamos
        if (typeof obj[key] === 'string') {
          obj[key] = obj[key].replace(/\$/g, '_');
        }
        // Si es un objeto anidado, recursivo
        if (typeof obj[key] === 'object') {
          sanitizeObject(obj[key]);
        }
      });
    }
  };

  // Solo sanitizamos body, no query
  if (req.body) {
    sanitizeObject(req.body);
  }

  next();
};

app.use(sanitizarDatos);

// ==========================================
//            RUTAS DE LA API REST
// ==========================================
app.use("/api/productos", require("./routes/productoRoutes"));
app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/pedidos", require("./routes/pedidoRoutes"));
app.use("/api/marcas", require("./routes/marcas"));

// Levantar el servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo de forma exitosa en el puerto ${PORT}`);
});