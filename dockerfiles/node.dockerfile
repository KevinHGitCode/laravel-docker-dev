FROM node:latest

WORKDIR /var/www/html

# Usar el usuario node que ya viene con la imagen
USER node

# Establecer el comando por defecto
ENTRYPOINT ["npm"]