#!/bin/bash

# FlightHub Backend Docker Entrypoint Script

set -e

echo "FlightHub Backend starting..."

# Attendre que la base de données soit prête
echo "Waiting for database..."
while ! php artisan db:show 2>/dev/null; do
    echo "Database not ready, waiting..."
    sleep 5
done

# Exécuter les migrations
echo "Running migrations..."
php artisan migrate --force

# Vider le cache si nécessaire
echo "Clearing cache..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Recréer le cache
echo "Rebuilding cache..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "FlightHub Backend ready!"

# Exécuter la commande passée en paramètre
exec "$@"

