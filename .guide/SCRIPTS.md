# Scripts de Utilidad

Este documento explica los scripts disponibles en la carpeta `scripts/` y cómo utilizarlos.

## Preparación de scripts

Antes de usar cualquier script, asegúrate de darle permisos de ejecución:

```bash
# Dar permisos de ejecución al script de inicialización de Laravel
chmod +x scripts/init-laravel.sh
```

## Scripts Disponibles

### 1. Inicialización de Laravel (`init-laravel.sh`)

Este script automatiza los pasos post-clonación de un proyecto Laravel:
- Copia y configura el archivo `.env`
- Instala dependencias de Composer
- Genera la APP_KEY
- Crea el enlace simbólico de storage
- Ejecuta migraciones (opcional)
- Ejecuta seeders (opcional)
- Instala dependencias NPM si existe `package.json` (opcional)

Para usarlo:
```bash
# Desde la raíz del proyecto (donde está docker-compose.yml)
./scripts/init-laravel.sh
```

El script es interactivo y te preguntará antes de ejecutar migraciones, seeders o instalar dependencias de Node.js.

### Permisos y Seguridad

- Los scripts deben ejecutarse desde la raíz del proyecto
- Usa `chmod +x` solo en archivos `.sh` que confíes
- Revisa el contenido de los scripts antes de ejecutarlos
- Los scripts usan `--rm` con Docker Compose para limpiar contenedores temporales

## Comandos NPM y Compilación de Assets

### Desarrollo con Hot Module Replacement (HMR)

```bash
# Instalar dependencias de Node.js
docker compose run --rm node install

# Iniciar el servidor de desarrollo con HMR
docker compose run --rm node run dev

# O iniciar en modo watch
docker compose run --rm node run watch
```

### Compilación para Producción

```bash
# Instalación limpia de dependencias (recomendado para producción)
docker compose run --rm node ci

# Compilar assets para producción
docker compose run --rm node run build
```

### Comandos NPM Adicionales

```bash
# Ver la versión de npm
docker compose run --rm node --version

# Agregar un nuevo paquete
docker compose run --rm node install nombre-paquete

# Actualizar dependencias
docker compose run --rm node update

# Ejecutar scripts personalizados definidos en package.json
docker compose run --rm node run nombre-script
```

### Flujo de Trabajo Recomendado

1. Durante desarrollo:
```bash
# Levantar servicios principales en background
docker compose up -d server php mysql

# En otra terminal, iniciar HMR
docker compose up node
```

2. Para producción:
```bash
# Instalación limpia y build
docker compose run --rm node ci
docker compose run --rm node run build
```

### Solución de Problemas

Si ves un error "Permission denied":
```bash
# Verifica que el script tiene permisos de ejecución
ls -l scripts/init-laravel.sh

# Si no los tiene, aplica los permisos
chmod +x scripts/init-laravel.sh
```

Si el script falla:
1. Asegúrate de ejecutarlo desde la raíz del proyecto
2. Verifica que `docker-compose.yml` existe
3. Comprueba que los servicios de Docker están disponibles

### Problemas Comunes con NPM

Si encuentras errores de permisos con node_modules:
```bash
# Ajustar permisos de node_modules
sudo chown -R $(id -u):$(id -g) src/node_modules
```

Si HMR no detecta cambios:
1. Verifica que estás accediendo a través del puerto correcto (5173)
2. Comprueba que `CHOKIDAR_USEPOLLING=true` está configurado
3. Revisa la consola del navegador para ver errores de conexión