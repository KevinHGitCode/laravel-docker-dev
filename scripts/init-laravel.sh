#!/bin/bash

# Colores para los mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Inicializando proyecto Laravel ===${NC}"

# Verificar si estamos en la raíz del proyecto (donde está docker-compose.yml)
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: Este script debe ejecutarse desde la raíz del proyecto (donde está docker-compose.yml)${NC}"
    exit 1
fi

# 1. Copiar y configurar .env
echo -e "${GREEN}1. Configurando archivo .env...${NC}"
if [ -f "src/.env.example" ]; then
    cp src/.env.example src/.env
    echo -e "✓ Archivo .env creado desde .env.example"
else
    echo -e "${RED}⚠ No se encuentra src/.env.example${NC}"
    exit 1
fi

# 2. Instalar dependencias de Composer
echo -e "\n${GREEN}2. Instalando dependencias PHP...${NC}"
docker compose run --rm composer install
echo -e "✓ Dependencias de Composer instaladas"

# 3. Generar APP_KEY
echo -e "\n${GREEN}3. Generando APP_KEY...${NC}"
docker compose run --rm artisan key:generate
echo -e "✓ APP_KEY generada"

# 4. Crear enlace simbólico de storage
echo -e "\n${GREEN}4. Creando enlace simbólico de storage...${NC}"
docker compose run --rm artisan storage:link
echo -e "✓ Enlace de storage creado"

# 5. Ejecutar migraciones
echo -e "\n${GREEN}5. Ejecutando migraciones...${NC}"
echo -e "${BLUE}¿Deseas ejecutar las migraciones? [y/N]${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    docker compose run --rm artisan migrate --force
    echo -e "✓ Migraciones completadas"
else
    echo -e "Migraciones omitidas"
fi

# 6. Ejecutar seeders
echo -e "\n${GREEN}6. ¿Deseas ejecutar los seeders? [y/N]${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    docker compose run --rm artisan db:seed --force
    echo -e "✓ Seeders completados"
else
    echo -e "Seeders omitidos"
fi

# 7. Instalar dependencias NPM si existe package.json
if [ -f "src/package.json" ]; then
    echo -e "\n${GREEN}7. Instalando dependencias Node.js...${NC}"
    echo -e "${BLUE}¿Deseas instalar las dependencias de Node.js? [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Override el comando por defecto del contenedor
        docker compose run --rm --entrypoint npm node install
        echo -e "✓ Dependencias Node.js instaladas"
    else
        echo -e "Instalación de dependencias Node.js omitida"
    fi
fi

echo -e "\n${BLUE}=== Inicialización completada ===${NC}"
echo -e "\nPuedes iniciar los servicios con:"
echo -e "${GREEN}docker compose up -d${NC}"