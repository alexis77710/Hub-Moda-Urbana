// Archivo: controllers/marcaController.js
// Aquí definimos la lógica para manejar las solicitudes relacionadas con las marcas,
// como el registro de nuevas marcas. Esta lógica se conecta con el modelo Marca
// para interactuar con la base de datos MongoDB.
const Marca = require("../models/Marca");
const bcrypt = require("bcryptjs"); // <--- ¡Importamos la encriptación!

// --- FUNCIÓN MATEMÁTICA: Módulo 10 para Cédula y RUC ---
const validarIdentificacionEcuatoriana = (id) => {
  if (id.length !== 10 && id.length !== 13) return false;
  if (id.length === 13 && !id.endsWith("001")) return false;

  const cedula = id.substring(0, 10);
  const provincia = parseInt(cedula.substring(0, 2), 10);
  if (provincia < 1 || provincia > 24) return false;

  const tercerDigito = parseInt(cedula[2], 10);
  if (tercerDigito >= 6) return false;

  const coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
  let suma = 0;

  for (let i = 0; i < 9; i++) {
    let valor = parseInt(cedula[i], 10) * coeficientes[i];
    if (valor > 9) valor -= 9;
    suma += valor;
  }

  let digitoEsperado = 10 - (suma % 10);
  if (digitoEsperado === 10) digitoEsperado = 0;

  return digitoEsperado === parseInt(cedula[9], 10);
};

exports.solicitarRegistroMarca = async (req, res) => {
  try {
    const nombreMarca = req.body.nombreMarca?.trim();
    const identificacion = req.body.identificacion?.trim();
    const instagram = req.body.instagram?.trim();
    const correo = req.body.correo?.trim().toLowerCase();
    const password = req.body.password?.trim();

    const appToken = req.headers["x-app-source"];
    if (appToken !== "hub_moda_app_2026") {
      return res
        .status(401)
        .json({ msg: "Petición rechazada, usa la app oficial bro 🛑" });
    }

    if (!nombreMarca || !identificacion || !instagram || !correo || !password) {
      return res
        .status(400)
        .json({ msg: "Todos los campos son obligatorios para las marcas 🛑" });
    }

    // --- 1. BLINDAJE CONTRA XSS (Inyección de código) ---
    // Si el nombre de la marca tiene un "<" o un ">", lo bloqueamos de una.
    if (/[<>]/.test(nombreMarca)) {
      return res.status(400).json({
        msg: "Ese nombre tiene caracteres no permitidos bro, nada de hacks 🛡️",
      });
    }

    // --- 2. VALIDACIÓN DE INSTAGRAM EN EL BACKEND ---
    if (!instagram.startsWith("@")) {
      return res
        .status(400)
        .json({ msg: "El Instagram debe empezar con @ bro 📸" });
    }

    if (!validarIdentificacionEcuatoriana(identificacion)) {
      return res
        .status(400)
        .json({ msg: "Esa Cédula o RUC es matemáticamente inválido bro 🛑" });
    }

    // Actualizado al Regex de tu pana 🔥
    const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!emailRegex.test(correo.toLowerCase())) {
      return res
        .status(400)
        .json({ msg: "El formato del correo es inválido 🛑" });
    }

    const passRegex = /^(?=.*[A-Z])(?=.*\d).{6,}$/;
    if (!passRegex.test(password)) {
      return res.status(400).json({
        msg: "La contraseña es muy débil bro, métele mayúsculas y números 🔒",
      });
    }

    // 3. Verificamos que el correo no esté registrado ya (usando tu mejora de minúsculas)
    let marcaExistente = await Marca.findOne({ correo: correo.toLowerCase() });

    if (marcaExistente) {
      return res
        .status(400)
        .json({ msg: "Este correo ya tiene una solicitud o cuenta activa" });
    }

    // --- 3. BCRYPT: ENCRIPTANDO LA CONTRASEÑA ---
    // Generamos un "salt" (una cadena aleatoria) y luego encriptamos la clave con eso.
    const salt = await bcrypt.genSalt(10);
    const passwordHasheado = await bcrypt.hash(password, salt);

    // Guardamos la marca PERO le pasamos el passwordHasheado
    const nuevaMarca = new Marca({
      nombreMarca,
      identificacion,
      instagram,
      correo: correo.toLowerCase(), // <-- Guardamos el correo siempre en minúsculas
      password: passwordHasheado,
    });

    await nuevaMarca.save();

    // --- 4. LIMPIANDO LA RESPUESTA ---
    // Devolvemos un JSON personalizado sin exponer el password de vuelta.
    res.status(201).json({
      msg: "¡Solicitud de marca enviada con éxito! Queda en estado Pendiente 🏢",
      marca: {
        _id: nuevaMarca._id,
        nombreMarca: nuevaMarca.nombreMarca,
        correo: nuevaMarca.correo,
        estadoAprobacion: nuevaMarca.estadoAprobacion,
      },
    });
  } catch (error) {
    console.error("Error registrar marca:", error.message);
    res.status(500).send("Hubo un error en el servidor bro");
  }
};
