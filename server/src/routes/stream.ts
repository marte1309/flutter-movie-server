import express from 'express';
import * as streamController from '../controllers/streamController';

const router = express.Router();

router.get('/:id', streamController.streamMovie);
router.get('/thumbnail/:id', streamController.getMovieThumbnail);

export default router;