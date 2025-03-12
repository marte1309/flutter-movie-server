import express from "express";
import cors from "cors";
import path from "path";
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

// Inicia el servidor HTTP para streaming
app.listen(process.env.PORT, () => {
  console.log(`Servidor HTTP iniciado en http://localhost:${process.env.PORT}`);
});
