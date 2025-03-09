export interface Movie {
  id: number;
  title: string;
  path: string;
  format: string;
  size?: number;
  addedAt: string;
  lastModified?: Date;
}

export interface ScanResult {
  title: string;
  path: string;
  format: string;
  size: number;
  lastModified: Date;
}
