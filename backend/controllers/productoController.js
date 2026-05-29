// Aquí vamos a manejar todo lo relacionado con los productos, como crear un nuevo producto, 
// mostrar los productos, actualizar o eliminar un producto

const Producto = require("../models/Producto");
const Marca = require("../models/Marca");

// Función para agregar un producto nuevo
exports.crearProducto = async (req, res) => {
  try {
    // Magia pura: Si Multer y Cloudinary hicieron su trabajo,
    // el link de la imagen en la nube estará guardado en req.file.path
    if (req.file) {
      req.body.imagenes = [req.file.path];
    }
// Creamos un nuevo producto con los datos que vienen en el body de la petición
    let producto = new Producto(req.body);
    await producto.save();
// Respondemos con el producto que se acaba de crear para que el frontend lo muestre
    res.status(201).json(producto);
  } catch (error) {
    console.log("Error al crear producto:", error);
    res.status(500).send("Hubo un error en el servidor bro");
  }
};

// Función para obtener todos los productos
exports.obtenerProductos = async (req, res) => {
  try {
    const { estilo, marca, fit, buscar } = req.query;
    let filtro = {};

    // Le agregamos la Expresión Regular con la opción 'i' a cada uno
    if (estilo) {
      filtro.estilo = new RegExp(estilo, "i");
    }
    if (marca) {
      filtro.marca = new RegExp(marca, "i");
    }
    if (fit) {
      filtro.fit = new RegExp(fit, "i");
    }
    // El filtro de la lupa
    if (buscar) {
      // Busca cualquier producto cuyo NOMBRE contenga lo que el usuario escribió
      filtro.nombre = new RegExp(buscar, "i");
    }
    // Buscamos en la base de datos usando el filtro que armamos
    const productos = await Producto.find(filtro);
    res.json(productos);
  } catch (error) {
    console.log("Error al filtrar productos:", error);
    res.status(500).send("Hubo un error al buscar la ropa bro");
  }
};

// Función para actualizar un producto
exports.actualizarProducto = async (req, res) => {
  try {
    // Primero buscamos si el producto existe usando el ID que viene en la URL
    let producto = await Producto.findById(req.params.id);

    if (!producto) {
      return res.status(404).json({ msg: "No existe el producto bro" });
    }

    // Si sí existe, lo actualizamos con los datos nuevos que vengan en req.body
    // El { new: true } es clave para que Mongoose te devuelva el producto YA actualizado
    producto = await Producto.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });

    res.json(producto);
  } catch (error) {
    console.log("Error al actualizar producto:", error);
    res.status(500).send("Hubo un error al actualizar la mercadería bro");
  }
};

// Función para eliminar un producto
exports.eliminarProducto = async (req, res) => {
  try {
    // Igual que antes, buscamos si existe
    let producto = await Producto.findById(req.params.id);

    if (!producto) {
      return res.status(404).json({ msg: "No existe el producto bro" });
    }

    // Si existe, lo mandamos a volar de la base de datos
    await Producto.findByIdAndDelete(req.params.id);

    res.json({ msg: "¡Producto eliminado con éxito!" });
  } catch (error) {
    console.log("Error al eliminar producto:", error);
    res.status(500).send("Hubo un error al borrar el producto bro");
  }
};

// Función para enviarle al frontend una lista limpia de las marcas que existen
exports.obtenerMarcas = async (req, res) => {
    try {
        // Busca en tooooodos los productos y saca solo los nombres de las marcas sin repetir
        const marcas = await Producto.distinct('marca');
        
        // Devuelve un arreglo limpiecito: ["Ecuador Street Cult", "Nike", "Adidas"]
        res.json(marcas);

    } catch (error) {
        console.log('Error al obtener las marcas:', error);
        res.status(500).send('Hubo un error al buscar las marcas bro');
    }
}

// esto se hace para que los del frontend puedan usar estas funciones 
// cuando hagan peticiones a las rutas que definimos en productoRoutes.js