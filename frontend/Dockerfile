# FlightHub Frontend - Dockerfile propre
# Build multi-stage pour React

# Stage 1: Build
FROM node:18-alpine AS build

WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances
RUN npm ci

# Copie du code source
COPY . .

# Build de l'application en mode développement
ENV NODE_ENV=development
ENV VITE_MODE=development
ENV VITE_API_BASE_URL=http://localhost:8000
RUN npm run build

# Stage 2: Production avec Nginx
FROM nginx:alpine

# Copie des fichiers buildés
COPY --from=build /app/dist /usr/share/nginx/html

# Copie de la configuration Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Exposition du port
EXPOSE 80

# Démarrage de Nginx
CMD ["nginx", "-g", "daemon off;"]