import express from 'express';
import cors from 'cors';
import path from 'path';
import config from './config';
import movieRoutes from './routes/movies';
import streamRoutes from './routes/stream';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/movies', movieRoutes);
app.use('/api/stream', streamRoutes);

// Servir archivos estáticos (para la página web de administración)
app.use('/admin', express.static(path.join(__dirname, '..', 'public')));

app.listen(config.PORT, () => {
  console.log(`Servidor ejecutándose en http://localhost:${config.PORT}`);
});