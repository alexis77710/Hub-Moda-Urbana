// Este archivo define el modelo de datos para los productos que se van a vender en el Hub de Moda.
// Aquí usamos Mongoose para crear un esquema que luego se convertirá en una colección en MongoDB.
const mongoose = require("mongoose");
// Definimos el esquema del producto con los campos que necesitamos para la app de moda urbana
const productoSchema = new mongoose.Schema(
  {
    nombre: {
      type: String,
      required: true,
      trim: true,
    },
    marca: {
      type: String, // Aquí luego podemos enlazarlo al ID del creador
      required: true,
    },
    precio: {
      type: Number,
      required: true,
    },
    fit: {
      type: String,
      enum: ["oversize", "baggy", "regular", "slim", "crop"], // Clave para la estética urbana
      default: "regular",
    },
    estilo: {
      type: String,
      enum: ["Y2K", "skater", "minimalista", "vintage", "gorpcore"],
      required: true,
    },
    tallas: [
      {
        type: String,
        enum: ["XS", "S", "M", "L", "XL", "XXL"],
      },
    ],
    stock: {
      type: Number,
      default: 0,
    },
    imagenes: [
      {
        type: String, // Aquí irán las URLs de las fotos
      },
    ],
  },
  {
    timestamps: true, // Esto te crea automáticamente la fecha de creación y actualización
  },
);
// Exportamos el modelo para usarlo en otras partes de la app, como en el controlador
module.exports = mongoose.model("Producto", productoSchema);
