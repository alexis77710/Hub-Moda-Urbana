// Archivo: backend/controllers/authController.js
// aqui vamos a manejar todo lo relacionado con el registro y login de usuarios
// Importamos el modelo de Marca para poder crear nuevas marcas y verificar los existentes
const Marca = require("../models/Marca");
// Importamos el modelo de Usuario para poder crear nuevos usuarios y verificar los existentes
const Usuario = require("../models/Usuario");
// Importamos bcrypt para encriptar las contraseñas y jwt para crear los Tokens de autenticación
const bcrypt = require("bcryptjs");
// 1. Importamos la librería para los Pases VIP
const jwt = require("jsonwebtoken");
// Importamos el modelo de Otp para manejar los códigos de verificación por correo
const Otp = require("../models/Otp"); 
// Importamos la función para enviar correos (si es que la usaremos aquí)
const { enviarCorreoOTP } = require("../utils/emailService");

// --- NUEVO: Generar OTP para Clientes Normales ---
exports.generarOtpUsuario = async (req, res) => {
  try {
    const email = req.body.email?.trim().toLowerCase(); 
    const nombre = req.body.nombre?.trim(); // Recibimos el nombre/username de Flutter

    if (!email) return res.status(400).json({ msg: "Falta el correo bro" });

    // 1. Validamos que el correo no esté repetido
    const usuarioExistente = await Usuario.findOne({ email });
    if (usuarioExistente) {
      return res.status(400).json({ msg: "Bro, este correo ya tiene una cuenta activa" });
    }

    // 2. ¡EL NUEVO BLOQUEO!: Evitamos nombres de usuario duplicados (ej: alexis777)
    if (nombre) {
      const usernameRepetido = await Usuario.findOne({ nombre: new RegExp(`^${nombre}$`, 'i') });
      if (usernameRepetido) {
        return res.status(400).json({ msg: "Ese nombre de usuario ya está reclamado, intenta con otro bro 🏃‍♂️" });
      }
    }

    const codigoGenerado = Math.floor(100000 + Math.random() * 900000).toString();
    
    await Otp.deleteMany({ correo: email }); 
    const nuevoOtp = new Otp({ correo: email, codigo: codigoGenerado });
    await nuevoOtp.save();

    await enviarCorreoOTP(email, codigoGenerado);
    res.status(200).json({ msg: "Código enviado al correo 🚀" });
  } catch (error) {
    console.error("Error OTP Usuario:", error);
    res.status(500).send("Hubo un error al generar el código");
  }
};


// Función para registrar un nuevo usuario
exports.registrarUsuario = async (req, res) => {
  try {
    // 1. Extraemos TODOS los datos, incluyendo el NUEVO codigoOtp
    const { nombre, email, password, codigoOtp } = req.body;

    // Validamos que no falten datos
    if (!nombre || !email || !password || !codigoOtp) {
      return res.status(400).json({
        msg: "Bro, faltan datos o el código de verificación 🛑",
      });
    }

    // Blindaje Anti-XSS (para el nombre)
    if (/[<>]/.test(nombre)) {
      return res.status(400).json({ msg: "Nada de hacks en el nombre, bro 🛡️" });
    }

    // --- EL GUARDIA DE CONTRASEÑAS ---
    const passwordRegex = /^(?=.*[A-Z])(?=.*\d).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        msg: "Bro, la contraseña debe tener al menos 8 caracteres, una letra mayúscula y un número 🛑",
      });
    }

    // --- EL NUEVO ESCUDO OTP ---
    // Buscamos si el código coincide con el correo en la base de datos
    const otpGuardado = await Otp.findOne({ correo: email.toLowerCase(), codigo: codigoOtp });
    
    if (!otpGuardado) {
      return res.status(400).json({ msg: "Código incorrecto o ya expiró (duraba 5 min) ⏳" });
    }

    // Si el código es correcto, lo destruimos para que no se re-use
    await Otp.deleteOne({ _id: otpGuardado._id });

    // 2. Revisamos si el usuario ya existe (por si acaso)
    let usuario = await Usuario.findOne({ email: email.toLowerCase() });
    if (usuario) {
      return res.status(400).json({ msg: "Bro, este correo ya está registrado" });
    }

    // 3. Si no existe, creamos el nuevo usuario
    usuario = new Usuario({
      nombre,
      email: email.toLowerCase(),
      password,
    });

    // 4. ¡LA MAGIA DE LA ENCRIPTACIÓN!
    const salt = await bcrypt.genSalt(10);
    usuario.password = await bcrypt.hash(password, salt);

    // 5. Lo guardamos en la base de datos (Atlas)
    await usuario.save();

    // 6. ¡AUTO-LOGIN! Armamos su Pase VIP (El Payload)
    const payload = {
      usuario: {
        id: usuario.id,
        rol: usuario.rol,
      },
    };

    // 7. Firmamos y entregamos el Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: "30d" },
      (error, token) => {
        if (error) throw error;
        res.status(201).json({
          msg: "¡Usuario creado con éxito y sesión iniciada! 🛡️",
          token,
        });
      },
    );
  } catch (error) {
    console.log("Error en el registro:", error);
    res.status(500).send("Hubo un error al registrar al usuario bro");
  }
};

// Función para iniciar sesión

// Función para iniciar sesión
exports.loginUsuario = async (req, res) => {
  const { email, password } = req.body;

  try {
    let esMarca = false;
    
    // --- EL PARCHE MÁGICO ---
    // Convertimos lo que escriba el usuario a minúsculas antes de buscar
    const correoNormalizado = email.toLowerCase(); 

    // 1. Buscamos primero en la colección de clientes normales usando el correo en minúsculas
    let usuario = await Usuario.findOne({ email: correoNormalizado });

    // 2. Si no lo encuentra, buscamos en la colección de marcas
    if (!usuario) {
      // También buscamos aquí con el correo en minúsculas
      usuario = await Marca.findOne({ correo: correoNormalizado });

      if (!usuario) {
        return res.status(400).json({ msg: "El usuario o marca no existe bro" });
      }
      // --- ¡NUEVO ESCUDO ANTI-PENDIENTES! ---
      if (usuario.estadoAprobacion !== "Aceptada") {
        return res
          .status(403)
          .json({
            msg: "Tu marca aún está en revisión bro, espera a que el admin te apruebe 🕒",
          });
      }
      esMarca = true;
    }

    // 3. Comparamos la contraseña encriptada
    const passwordCorrecto = await bcrypt.compare(password, usuario.password);
    if (!passwordCorrecto) {
      return res.status(400).json({ msg: "Contraseña incorrecta pana" });
    }

    // 4. Armamos el Pase VIP dinámico
    const payload = {
      usuario: {
        id: usuario.id,
        rol: esMarca ? "marca" : usuario.rol, // Asignamos el rol correcto
      },
    };

    // 5. Entregamos el Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: "30d" },
      (error, token) => {
        if (error) throw error;
        res.json({ token });
      },
    );
  } catch (error) {
    console.log("Error en el login:", error);
    res.status(500).send("Hubo un error al iniciar sesión");
  }
};
