// Archivo: models/Marca.js
const mongoose = require('mongoose');

const MarcaSchema = mongoose.Schema({
    nombreMarca: {
        type: String,
        required: true,
        trim: true
    },
    identificacion: {
        // Guardamos Cédula (10) o RUC (13)
        type: String,
        required: true,
        trim: true
    },
    instagram: {
        type: String,
        required: true,
        trim: true
    },
    correo: {
        type: String,
        required: true,
        unique: true // ¡Vital! No pueden haber dos marcas con el mismo correo
    },
    password: {
        type: String,
        required: true
    },
    estadoAprobacion: {
        type: String,
        default: 'Pendiente' // Cuando te mandan la solicitud, nace como Pendiente
    },
    fechaSolicitud: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Marca', MarcaSchema);