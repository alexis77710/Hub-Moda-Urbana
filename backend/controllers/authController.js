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

// Función para registrar un nuevo usuario
exports.registrarUsuario = async (req, res) => {
  try {
    // 1. Extraemos TODOS los datos necesarios, incluyendo el nombre
    const { nombre, email, password } = req.body;

    // Validamos que no falten datos (el nombre es obligatorio según tu modelo)
    if (!nombre || !email || !password) {
      return res.status(400).json({
        msg: "Bro, faltan datos. Nombre, email y password son obligatorios 🛑",
      });
    }

    // Blindaje Anti-XSS (para el nombre)
    if (/[<>]/.test(nombre)) {
      return res
        .status(400)
        .json({ msg: "Nada de hacks en el nombre, bro 🛡️" });
    }

    // --- EL NUEVO GUARDIA DE CONTRASEÑAS ---
    const passwordRegex = /^(?=.*[A-Z])(?=.*\d).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        msg: "Bro, la contraseña debe tener al menos 8 caracteres, una letra mayúscula y un número 🛑",
      });
    }

    // 2. Revisamos si el usuario ya existe (pasando el email a minúsculas)
    let usuario = await Usuario.findOne({ email: email.toLowerCase() });
    if (usuario) {
      return res
        .status(400)
        .json({ msg: "Bro, este correo ya está registrado" });
    }

    // 3. Si no existe, creamos el nuevo usuario
    usuario = new Usuario({
      nombre,
      email: email.toLowerCase(), // Guardamos siempre en minúsculas
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

    // 7. Firmamos y entregamos el Token al instante de registrarse
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: "30d" },
      (error, token) => {
        if (error) throw error;
        // Le enviamos el Token y un mensaje de éxito
        res.status(201).json({
          msg: "¡Usuario creado con éxito y sesión iniciada! 🛡️",
          token, // ¡El frontend agradecerá esto!
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
