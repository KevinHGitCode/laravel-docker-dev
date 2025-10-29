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