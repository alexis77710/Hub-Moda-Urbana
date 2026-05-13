// aqui vamos a manejar todo lo relacionado con el registro y login de usuarios

// Importamos el modelo de Usuario para poder crear nuevos usuarios y verificar los existentes
const Usuario = require("../models/Usuario");
// Importamos bcrypt para encriptar las contraseñas y jwt para crear los Tokens de autenticación
const bcrypt = require("bcryptjs");
// 1. Importamos la librería para los Pases VIP
const jwt = require("jsonwebtoken"); 

// Función para registrar un nuevo usuario
exports.registrarUsuario = async (req, res) => {
  try {
    // Extraemos el email y el password de lo que nos manda el frontend/Postman
    const { email, password } = req.body;

    // --- EL NUEVO GUARDIA DE CONTRASEÑAS ---
    // Esta regla (Regex) exige:
    // 1. Mínimo 8 caracteres (.{8,})
    // 2. Al menos una letra mayúscula (?=.*[A-Z])
    // 3. Al menos un número (?=.*\d)
    const passwordRegex = /^(?=.*[A-Z])(?=.*\d).{8,}$/;
    
// Si la contraseña no cumple con esta regla, le decimos al usuario que se ponga las pilas
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        msg: "Bro, la contraseña debe tener al menos 8 caracteres, una letra mayúscula y un número 🛑",
      });
    }
    // 1. Revisamos si el usuario ya existe para no duplicarlo
    let usuario = await Usuario.findOne({ email });

    if (usuario) {
      return res
        .status(400)
        .json({ msg: "Bro, este correo ya está registrado" });
    }

    // 2. Si no existe, creamos el nuevo usuario con los datos del body
    usuario = new Usuario(req.body);

    // 3. ¡LA MAGIA DE LA ENCRIPTACIÓN!
    // Generamos un "salt" (un texto aleatorio para hacer el hash más seguro)
    const salt = await bcrypt.genSalt(10);
    // Sobreescribimos el password real con el password encriptado
    usuario.password = await bcrypt.hash(password, salt);

    // 4. Lo guardamos en la base de datos (Atlas)
    await usuario.save();

    res
      .status(201)
      .json({ msg: "¡Usuario creado con éxito y contraseña blindada! 🛡️" });
  } catch (error) {
    console.log("Error en el registro:", error);
    res.status(500).send("Hubo un error al registrar al usuario bro");
  }
};

// Función para iniciar sesión
exports.loginUsuario = async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Revisamos si el correo existe en la base de datos
    let usuario = await Usuario.findOne({ email });
    if (!usuario) {
      return res.status(400).json({ msg: "El usuario no existe bro" });
    }

    // 2. Comparamos la contraseña que escribió con la encriptada de la base de datos
    const passwordCorrecto = await bcrypt.compare(password, usuario.password);
    if (!passwordCorrecto) {
      return res.status(400).json({ msg: "Contraseña incorrecta pana" });
    }

    // 3. Si todo está bien, le armamos su Pase VIP (El Payload)
    // Aquí metemos los datos clave que el guardia va a leer después
    const payload = {
      usuario: {
        id: usuario.id,
        rol: usuario.rol, // ¡Aquí va si es 'cliente' o 'marca'!
      },
    };

    // 4. Firmamos y entregamos el Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET, // Usamos la llave maestra de tu .env
      { expiresIn: "30d" }, // El pase caduca en 30 días
      (error, token) => {
        if (error) throw error;
        // Si todo sale bien, le enviamos el Token a Postman/Flutter
        res.json({ token });
      },
    );
  } catch (error) {
    console.log("Error en el login:", error);
    res.status(500).send("Hubo un error al iniciar sesión");
  }
};
