import { Request, Response } from "express";
import config from "../config";
import * as fileScanner from "../utils/fileScanner";
import { Movie } from "../types/movie";
import { movies } from "../models/movie";

let nextId = 1;

export const getAllMovies = (req: Request, res: Response): void => {
  res.json(movies);
};

export const getMovieById = (req: Request, res: Response): void => {
  const id = parseInt(req.params.id, 10);
  const movie = movies.find((m) => m.id === id);

  if (!movie) {
    res.status(404).json({ message: "Película no encontrada" });
    return;
  }

  res.json(movie);
};

export const addMovie = (req: Request, res: Response): void => {
  const { title, path, format } = req.body;

  if (!title || !path) {
    res.status(400).json({ message: "Se requiere título y ruta" });
    return;
  }

  const newMovie: Movie = {
    id: nextId++,
    title,
    path,
    format: format || path.split(".").pop() || "",
    addedAt: new Date().toISOString(),
  };

  movies.push(newMovie);
  res.status(201).json(newMovie);
};

export const updateMovie = (req: Request, res: Response): void => {
  const id = parseInt(req.params.id, 10);
  const movieIndex = movies.findIndex((m) => m.id === id);

  if (movieIndex === -1) {
    res.status(404).json({ message: "Película no encontrada" });
    return;
  }

  const updatedMovie = { ...movies[movieIndex], ...req.body, id };
  movies[movieIndex] = updatedMovie;

  res.json(updatedMovie);
};

export const deleteMovie = (req: Request, res: Response): void => {
  const id = parseInt(req.params.id, 10);
  const movieIndex = movies.findIndex((m) => m.id === id);

  if (movieIndex === -1) {
    res.status(404).json({ message: "Película no encontrada" });
    return;
  }

  const deletedMovie = movies[movieIndex];
  movies.splice(movieIndex, 1);

  res.json(deletedMovie);
};

export const scanDirectory = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const scannedMovies = await fileScanner.scanDirectoryForMovies(
      config.MOVIES_DIR
    );

    // Añadir películas escaneadas a nuestra "base de datos"
    let newMoviesCount = 0;
    scannedMovies.forEach((movie) => {
      if (!movies.some((m) => m.path === movie.path)) {
        movies.push({
          id: nextId++,
          ...movie,
          addedAt: new Date().toISOString(),
        });
        newMoviesCount++;
      }
    });

    res.json({
      message: `Se encontraron ${scannedMovies.length} películas. ${newMoviesCount} nuevas añadidas.`,
      movies,
    });
  } catch (error) {
    console.error("Error al escanear directorio:", error);
    res.status(500).json({
      message: "Error al escanear directorio",
      error: error instanceof Error ? error.message : String(error),
    });
  }
};
