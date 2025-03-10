import { Request, Response } from "express";
import * as fs from "fs";
import path from "path";
import ffmpeg from "fluent-ffmpeg";
import config from "../config";
import { movies } from "../models/movie";

export const streamMovie = (req: Request, res: Response): void => {
  const id = parseInt(req.params.id, 10);
  const movie = movies.find((m) => m.id === id);

  if (!movie) {
    res.status(404).json({ message: "Película no encontrada" });
    return;
  }

  const moviePath = path.join(config.MOVIES_DIR, movie.path);

  if (!fs.existsSync(moviePath)) {
    res.status(404).json({ message: "Archivo de película no encontrado" });
    return;
  }

  const stat = fs.statSync(moviePath);
  const fileSize = stat.size;
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
    const chunksize = end - start + 1;
    const file = fs.createReadStream(moviePath, { start, end });
    const head = {
      "Content-Range": `bytes ${start}-${end}/${fileSize}`,
      "Accept-Ranges": "bytes",
      "Content-Length": chunksize,
      "Content-Type": "video/mp4",
    };

    res.writeHead(206, head);
    file.pipe(res);
  } else {
    const head = {
      "Content-Length": fileSize,
      "Content-Type": "video/mp4",
    };

    res.writeHead(200, head);
    fs.createReadStream(moviePath).pipe(res);
  }
};

export const getMovieThumbnail = (req: Request, res: Response): void => {
  const id = parseInt(req.params.id, 10);
  const movie = movies.find((m) => m.id === id);

  if (!movie) {
    res.status(404).json({ message: "Película no encontrada" });
    return;
  }

  const moviePath = path.join(config.MOVIES_DIR, movie.path);
  const thumbPath = path.join(
    config.MOVIES_DIR,
    "thumbnails",
    `${movie.id}.jpg`
  );

  // Verifica si ya existe una miniatura
  if (fs.existsSync(thumbPath)) {
    res.sendFile(thumbPath);
    return;
  }

  // Crea el directorio de miniaturas si no existe
  if (!fs.existsSync(path.dirname(thumbPath))) {
    fs.mkdirSync(path.dirname(thumbPath), { recursive: true });
  }

  // Genera una miniatura usando FFmpeg
  ffmpeg(moviePath)
    .screenshots({
      count: 1,
      folder: path.dirname(thumbPath),
      filename: path.basename(thumbPath),
      size: "320x240",
    })
    .on("end", () => {
      if (fs.existsSync(thumbPath)) {
        res.sendFile(thumbPath);
      } else {
        res.status(500).json({ message: "Error al generar miniatura" });
      }
    })
    .on("error", (err) => {
      res.status(500).json({
        message: "Error al generar miniatura",
        error: err instanceof Error ? err.message : String(err),
      });
    });
};
