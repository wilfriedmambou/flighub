# FlightHub Backend Dockerfile
# Basé sur PHP 8.2 avec Apache

FROM php:8.2-apache

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Installation des dépendances système
       RUN apt-get update && apt-get install -y \
           git \
           curl \
           libpng-dev \
           libonig-dev \
           libxml2-dev \
           libzip-dev \
           zip \
           unzip \
           libpq-dev \
           libicu-dev \
           && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd zip intl \
           && a2enmod rewrite

# Configuration d'Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# CORS sera géré par Laravel uniquement
RUN a2enmod headers

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définition du répertoire de travail
WORKDIR /var/www/html

# Copie des fichiers de l'application
COPY . .

# Copie du fichier de configuration d'environnement
COPY docker.env .env

# Installation des dépendances PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Configuration des permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Exposition du port
EXPOSE 80

# Script de démarrage
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
