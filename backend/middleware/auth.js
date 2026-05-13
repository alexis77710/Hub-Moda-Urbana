// middleware que se encarga de verificar el token JWT y el rol del usuario 
// para proteger rutas específicas.
const jwt = require('jsonwebtoken');

// Guardia 1: Solo verifica que tengas un Token válido (Para comprar y ver perfil)
exports.verificarToken = (req, res, next) => {
    const token = req.header('x-auth-token');
    
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

// Guardia 2: Verifica Token Y que seas Marca (Para crear/borrar ropa)
exports.verificarTokenYRol = (req, res, next) => {
    const token = req.header('x-auth-token');
    
    if (!token) {
        return res.status(401).json({ msg: 'No hay token bro 🛑' });
    }

    try {
        const cifrado = jwt.verify(token, process.env.JWT_SECRET);
        req.usuario = cifrado.usuario;

        // Aquí está la diferencia: este guardia SÍ filtra por rol
        if (req.usuario.rol !== 'marca' && req.usuario.rol !== 'admin') {
            return res.status(403).json({ msg: 'Solo marcas autorizadas pueden hacer esto 🛑' });
        }
        next();
    } catch (error) {
        res.status(401).json({ msg: 'Token no válido' });
    }
};