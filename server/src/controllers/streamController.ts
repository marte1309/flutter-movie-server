import { Request, Response } from "express";
import * as fs from "fs";
import path from "path";
import config from "../config";
import { movies } from "../models/movie";
import { stat } from "fs/promises";

export const streamMovie = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
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

    // Obtener información del archivo
    const fileStat = await stat(moviePath);
    const fileSize = fileStat.size;

    // Obtener el tipo MIME basado en la extensión del archivo
    const mimeTypes: any = {
      mp4: "video/mp4",
      mkv: "video/x-matroska",
      avi: "video/x-msvideo",
      mov: "video/quicktime",
      wmv: "video/x-ms-wmv",
      flv: "video/x-flv",
    };

    const extension = path.extname(moviePath).slice(1).toLowerCase();
    const contentType = mimeTypes[extension] || "application/octet-stream";

    // Soporte para streaming con solicitudes de rango (range requests)
    const range = req.headers.range;

    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

      // Limitar el tamaño del chunk para mejor rendimiento
      const maxChunk = 1024 * 1024 * 10; // 10MB
      const finalEnd = Math.min(end, start + maxChunk - 1);

      const chunksize = finalEnd - start + 1;

      const headers = {
        "Content-Range": `bytes ${start}-${finalEnd}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize,
        "Content-Type": contentType,
        "Cache-Control": "max-age=3600", // Agregar caché para mejor rendimiento
      };

      res.writeHead(206, headers);
      const stream = fs.createReadStream(moviePath, { start, end: finalEnd });
      stream.pipe(res);
    } else {
      // Enviar el archivo completo (menos común)
      const headers = {
        "Content-Length": fileSize,
        "Content-Type": contentType,
        "Accept-Ranges": "bytes",
        "Cache-Control": "max-age=3600",
      };

      res.writeHead(200, headers);
      fs.createReadStream(moviePath).pipe(res);
    }
  } catch (error) {
    console.error("Error al transmitir película:", error);
    res.status(500).json({
      message: "Error al transmitir película",
      error: error instanceof Error ? error.message : String(error),
    });
  }
};

export const getMovieThumbnail = (req: Request, res: Response): void => {
  const id = parseInt(req.params.id, 10);
  const movie = movies.find((m) => m.id === id);

  if (!movie) {
    res.status(404).json({ message: "Película no encontrada" });
    return;
  }

  // Usa íconos o imágenes predeterminadas según el formato
  const formatIcons: any = {
    mp4: "mp4_icon.png",
    mkv: "mkv_icon.jpg",
    avi: "avi_icon.jpg",
    default: "video_icon.jpg",
  };

  const iconPath = path.join(
    __dirname,
    "..",
    "public",
    "icons",
    formatIcons[movie.format] || formatIcons["default"]
  );

  if (fs.existsSync(iconPath)) {
    res.sendFile(iconPath);
  } else {
    res.status(404).send("Thumbnail not available");
  }
};
