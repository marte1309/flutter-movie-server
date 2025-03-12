import * as dotenv from "dotenv";
import path from "path";

dotenv.config();

interface Config {
  PORT: number;
  MOVIES_DIR: string;
  VIDEO_EXTENSIONS: string[];
  HTTPS_ENABLED: boolean;
  THUMBNAILS_DIR?: string;
}

const config: Config = {
  PORT: parseInt(process.env.PORT ?? "8084", 10),
  MOVIES_DIR: process.env.MOVIES_DIR ?? path.join(__dirname, "..", "movies"),
  VIDEO_EXTENSIONS: [".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv"],
  HTTPS_ENABLED: process.env.HTTPS_ENABLED === "true",
  THUMBNAILS_DIR: process.env.THUMBNAILS_DIR,
};

export default config;
