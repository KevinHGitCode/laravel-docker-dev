# Instrucciones: Clonar un proyecto Laravel dentro de `src`

Este documento explica, paso a paso, cómo clonar un proyecto Laravel dentro de la carpeta `src` del repositorio `laravel-docker-dev` y dejarlo listo para desarrollo con los contenedores Docker incluidos.

Nota rápida: las instrucciones asumen que estás en la raíz del repositorio (`/home/khafi/ejemplos_docker/docker_lrvl`).

---

## Resumen del flujo

1. Clonar el repo Laravel dentro de `src/` (o copiar los archivos allí).
2. Instalar dependencias PHP usando el contenedor `composer` o localmente.
3. Copiar `.env` desde `.env.example` y ajustar variables (DB_HOST=mysql, DB_PORT=3308).
4. Generar APP_KEY y ejecutar migraciones/seeds con `artisan` dentro del contenedor `artisan`.
5. Instalar dependencias JS y levantar el dev server (HMR) con el servicio `node` o compilar assets para producción.
6. Ajustar permisos y crear el enlace simbólico de `storage`.

---

### 1) Clonar el proyecto Laravel dentro de `src`

Si `src/` está vacío (o quieres reemplazarlo):

```bash
# desde la raíz del repo laravel-docker-dev
git clone <URL-del-repo-laravel> src
```

Si `src` ya existe y quieres traer el contenido a `src` sin crear subcarpeta:

```bash
# clonar en una carpeta temporal y mover solo el contenido
git clone <URL-del-repo-laravel> /tmp/laravel-repo
rsync -av --exclude='.git' /tmp/laravel-repo/ ./src/
rm -rf /tmp/laravel-repo
```

Consejo: evita clonar el proyecto dentro de `src` si ya tienes contenido importante; respalda antes.

### 2) Instalar dependencias PHP (Composer)

Opción recomendada (usar el contenedor `composer` incluido):

```bash
# desde la raíz del proyecto laravel-docker-dev
docker compose run --rm composer install
```

Alternativa (si prefieres usar Composer localmente):

```bash
cd src
composer install
```

Esto creará la carpeta `vendor/` dentro de `src`.

### 3) Configurar el archivo `.env`

Dentro de `src` copia `.env.example` a `.env` y ajusta las variables. Ejemplo mínimo para usar con este entorno Docker:

```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3308   # puerto del host mapeado en docker-compose (host:3308 -> contenedor:3306)
DB_DATABASE=laravel
DB_USERNAME=laraveluser
DB_PASSWORD=laravel.pa55
```

Nota: los servicios se comunican por nombre (`mysql`) dentro de la red Docker y usan el puerto interno 3306; solo cuando conectas desde tu máquina host a MySQL debes usar `3308`.

### 4) Generar APP_KEY y migraciones

Generar la clave de la aplicación y ejecutar migraciones usando el servicio `artisan` (ya definido en `docker-compose.yml`):

```bash
# generar APP_KEY
docker compose run --rm artisan key:generate

# ejecutar migraciones (use --force en entornos no interactivos)
docker compose run --rm artisan migrate --force
```

Si necesitas correr seeders:

```bash
docker compose run --rm artisan db:seed --force
```

### 5) Instalar dependencias JS y arrancar HMR (desarrollo)

Si el proyecto usa Vite / npm, usa el servicio `node` para instalar dependencias y levantar el dev-server con HMR (el `docker-compose.yml` de este proyecto expone el puerto `5173` y configura `HOST=0.0.0.0`):

```bash
# arrancar solo el servicio node en foreground (ver logs)
docker compose up node

# o ejecutar un comando puntual para instalar y arrancar
docker compose run --rm node npm install
docker compose run --rm node npm run dev
```

Para probar, abre `http://localhost:5173` o visita `http://localhost:8080` (NGINX) si tu integración de Vite está configurada detrás de NGINX.

Para producción (compilar assets):

```bash
docker compose run --rm node npm ci
docker compose run --rm node npm run build
```

Luego copia los assets compilados a `public/` (si el proceso no lo hace automáticamente) o inclúyelos en la imagen de producción.

### 6) Permisos y storage link

Laravel necesita que `storage` y `bootstrap/cache` sean escribibles por el usuario del servidor PHP. Ejecuta:

```bash
# crear enlace simbólico para storage
docker compose run --rm artisan storage:link

# opcional: ajustar permisos (depende del usuario/UID en la imagen PHP)
# ejemplo simple (puede necesitar ajuste según la imagen):
sudo chown -R $(id -u):$(id -g) src/storage src/bootstrap/cache
```

### 7) Probar la app

Levanta todos los servicios para desarrollo:

```bash
# levanta los servicios principales en background
docker compose up -d php mysql server

# en otra terminal, arranca node (HMR)
docker compose up node
```

Visita `http://localhost:8080` y verifica que la aplicación se carga. Si dependes de Vite HMR, revisa la consola del navegador y la terminal de `node` para ver que las conexiones HMR se establecen.

---

## Notas y buenas prácticas

- No subas credenciales reales al repo. Mantén `.env` fuera del control de versiones y usa `.env.example` para compartir la plantilla.
- Si trabajas en equipo, añade instrucciones concretas de DB (puerto 3308) y credenciales de desarrollo en la documentación compartida.
- Para producción, evita usar bind-mounts para el código; construye imágenes inmutables con los artefactos compilados.
- Si tienes problemas de sincronización de archivos con HMR en Linux/WSL, prueba con `CHOKIDAR_USEPOLLING=true` (ya incluido en la configuración del servicio `node`).

---

Si quieres, puedo:
- Comprobar si `src/package.json` existe y, si falta, crear un `package.json` básico para Vite + Laravel (Livewire) y añadir scripts `dev`/`build`.
- Generar un `.env.example` o actualizar `mysql/.env` para dejar claro el puerto 3308.

Dime qué prefieres y lo hago.
