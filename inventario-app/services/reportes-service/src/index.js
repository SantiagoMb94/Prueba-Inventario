const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3004;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    service: 'reportes-service',
    timestamp: new Date().toISOString()
  });
});

// Rutas básicas
app.get('/', (req, res) => {
  res.json({ 
    message: 'Servicio de Reportes funcionando',
    version: '1.0.0'
  });
});

// Ruta de ejemplo para reportes
app.get('/api/reportes', (req, res) => {
  res.json({
    message: 'API de reportes disponible',
    endpoints: [
      '/api/reportes/inventario',
      '/api/reportes/equipos',
      '/api/reportes/usuarios',
      '/api/reportes/exportar'
    ]
  });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Error interno del servidor' });
});

// 404
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

app.listen(PORT, () => {
  console.log(`Servicio de Reportes corriendo en puerto ${PORT}`);
}); 