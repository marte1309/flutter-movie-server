import express from "express";
import cors from "cors";
import path from "path";
import https from "https";
import fs from "fs";
import config from "./config";
import movieRoutes from "./routes/movies";
import streamRoutes from "./routes/stream";

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Rutas
app.use("/api/movies", movieRoutes);
app.use("/api/stream", streamRoutes);

// Servir archivos estáticos (para la página web de administración)
app.use("/admin", express.static(path.join(__dirname, "..", "public")));

// Configuración HTTPS
const httpsOptions = {
  key: fs.readFileSync(path.join(__dirname, "..", "certs", "key.pem")),
  cert: fs.readFileSync(path.join(__dirname, "..", "certs", "cert.pem")),
};

// Crear servidor HTTPS
https.createServer(httpsOptions, app).listen(config.PORT, () => {
  console.log(
    `Servidor HTTPS ejecutándose en https://localhost:${config.PORT}`
  );
});
