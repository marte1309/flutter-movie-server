import * as fs from "fs-extra";
import path from "path";
import config from "../config";
import { ScanResult } from "../types/movie";

export const scanDirectoryForMovies = async (
  directory: string
): Promise<ScanResult[]> => {
  try {
    const files = await fs.readdir(directory);
    const movies: ScanResult[] = [];
    for (const file of files) {
      const filePath = path.join(directory, file);
      console.log("Procesando archivo:", filePath);
      const stat = await fs.stat(filePath);

      if (stat.isDirectory()) {
        // Escanear subdirectorios recursivamente
        const subDirMovies = await scanDirectoryForMovies(filePath);
        movies.push(...subDirMovies);
      } else {
        const ext = path.extname(file).toLowerCase();

        if (config.VIDEO_EXTENSIONS.includes(ext)) {
          // Extraer título de película del nombre del archivo
          let title = path.basename(file, ext);

          // Limpiar título (eliminar año, calidad, etc.)
          title = title.replace(
            /\(\d{4}\)|\.\d{4}\.|\.720p\.|\.1080p\.|\.HDTV\.|\[.*?\]|\.DVDRip\.|\.\w{3}$/gi,
            " "
          );
          title = title.replace(/\./g, " ").trim();

          // Get parent directory name
          const parentDir = path.basename(directory);
          console.log("Directorio padre:", parentDir);
          const poster = `/movies/thumbnails/${
            parentDir !== "Movies" && parentDir !== "movies" ? parentDir : title
          }.webp`;

          movies.push({
            title,
            path: path.relative(config.MOVIES_DIR, filePath),
            format: ext.substring(1),
            size: stat.size,
            lastModified: stat.mtime,
            parentDir,
            poster,
          });
        }
      }
    }

    return movies;
  } catch (error) {
    console.error("Error al escanear directorio:", error);
    throw error;
  }
};
