// Archivo: middleware/auth.js
const jwt = require('jsonwebtoken');

// Función auxiliar para extraer el token sea como sea que venga
const extraerToken = (req) => {
    let token = req.header('x-auth-token'); // Como lo manda Postman a veces
    if (!token && req.header('Authorization')) {
        // Como lo manda Flutter (Authorization: Bearer <token>)
        token = req.header('Authorization').replace('Bearer ', '');
    }
    return token;
};

exports.verificarToken = (req, res, next) => {
    const token = extraerToken(req);
    
    if (!token) {
        return res.status(401).json({ msg: 'No hay token bro, inicia sesión primero 🛑' });
    }

    try {
        const cifrado = jwt.verify(token, process.env.JWT_SECRET);
        req.usuario = cifrado.usuario;
        next();
    } catch (error) {
        res.status(401).json({ msg: 'Token no válido o expirado' });
    }
};

exports.verificarTokenYRol = (req, res, next) => {
    const token = extraerToken(req);
    
    if (!token) {
        return res.status(401).json({ msg: 'No hay token bro 🛑' });
    }

    try {
        const cifrado = jwt.verify(token, process.env.JWT_SECRET);
        req.usuario = cifrado.usuario;

        if (req.usuario.rol !== 'marca' && req.usuario.rol !== 'admin') {
            return res.status(403).json({ msg: 'Solo marcas autorizadas pueden hacer esto 🛑' });
        }
        next();
    } catch (error) {
        res.status(401).json({ msg: 'Token no válido' });
    }
};