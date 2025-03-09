import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config();

interface Config {
  PORT: number;
  MOVIES_DIR: string;
  VIDEO_EXTENSIONS: string[];
}

const config: Config = {
  PORT: parseInt(process.env.PORT || '3000', 10),
  MOVIES_DIR: process.env.MOVIES_DIR || path.join(__dirname, '..', 'movies'),
  VIDEO_EXTENSIONS: ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv']
};

export default config;