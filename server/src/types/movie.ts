export interface Movie {
  id: number;
  title: string;
  path: string;
  format: string;
  size?: number;
  parentDir?: string;
  poster?: string;
  duration?: number;
  year?: number;
  addedAt: string;
  lastModified?: Date;
}

export interface ScanResult {
  title: string;
  path: string;
  format: string;
  size: number;
  parentDir?: string;
  duration?: number;
  year?: number;
  poster?: string;
  lastModified: Date;
}
