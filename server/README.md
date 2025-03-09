# Servidor de Películas (TypeScript)

API REST para servir películas desde un servidor casero, implementada con Node.js y TypeScript.

## Características

- Escaneo automático de directorios de películas
- Streaming de vídeo con soporte para range requests
- Generación de miniaturas para las películas
- API RESTful para gestionar la colección

## Requisitos

- Node.js 14+
- TypeScript
- FFmpeg (para generar miniaturas)

## Instalación

1. Clona este repositorio
2. Instala las dependencias:

```bash
cd server
npm install
```

3. Crea un archivo `.env` basado en `.env.example` con tus configuraciones

4. Compila el código TypeScript:

```bash
npm run build
```

5. Inicia el servidor:

```bash
npm start
```

Para desarrollo con recarga automática:

```bash
npm run dev
```

## Estructura del proyecto

```
server/
  ├── package.json         # Dependencias y scripts
  ├── tsconfig.json        # Configuración de TypeScript
  ├── src/
  │   ├── index.ts         # Punto de entrada
  │   ├── config.ts        # Configuraciones
  │   ├── types/           # Definiciones de tipos
  │   ├── routes/          # Rutas de la API
  │   ├── controllers/     # Lógica de negocio
  │   ├── models/          # Modelos de datos
  │   └── utils/           # Utilidades
  └── dist/                # Código compilado (generado)
```

## Endpoints de la API

### Películas

- `GET /api/movies` - Listar todas las películas
- `GET /api/movies/:id` - Obtener detalles de una película
- `POST /api/movies` - Añadir una película manualmente
- `PUT /api/movies/:id` - Actualizar información de una película
- `DELETE /api/movies/:id` - Eliminar una película
- `POST /api/movies/scan` - Escanear el directorio de películas

### Streaming

- `GET /api/stream/:id` - Transmitir una película
- `GET /api/stream/thumbnail/:id` - Obtener la miniatura de una película

## Modelo de datos

```typescript
interface Movie {
  id: number;
  title: string;
  path: string;
  format: string;
  size?: number;
  addedAt: string;
  lastModified?: Date;
}
```

## Configuración

La configuración se realiza a través de variables de entorno:

- `PORT`: Puerto en el que se ejecuta el servidor (predeterminado: 3000)
- `MOVIES_DIR`: Directorio absoluto donde se almacenan las películas

## Instalación en Ubuntu Server

1. Instala las dependencias necesarias:

```bash
sudo apt update
sudo apt install -y nodejs npm ffmpeg
```

2. Instala PM2 para gestionar el proceso:

```bash
sudo npm install -g pm2
```

3. Clona el repositorio, compila e inicia:

```bash
git clone https://github.com/marte1309/flutter-movie-server.git
cd flutter-movie-server/server
npm install
npm run build
pm2 start dist/index.js --name movie-server
pm2 startup
pm2 save
```

4. Configura el firewall:

```bash
sudo ufw allow 3000/tcp
```

## Próximas mejoras

- Implementar autenticación de usuarios
- Agregar base de datos persistente (MongoDB o SQLite)
- Integración con APIs de metadatos de películas (como TMDb)
- Soporte para subtítulos
- Transcodificación en tiempo real para diferentes anchos de banda