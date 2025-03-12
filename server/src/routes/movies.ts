import express from "express";
import * as movieController from "../controllers/movieController";

const router = express.Router();

router.get("/", movieController.getAllMovies);
router.get("/:id", movieController.getMovieById);
router.post("/", movieController.addMovie);
router.put("/:id", movieController.updateMovie);
router.delete("/:id", movieController.deleteMovie);
router.post("/scan", movieController.scanDirectory);
router.get("/thumbnails/:filename", movieController.getMovieThumbnail);

export default router;
