# FlightHub Backend - API Laravel

Backend complet pour le système de réservation de vols FlightHub, construit avec Laravel et PostgreSQL.

## 🚀 **Technologies Utilisées**

- **Laravel 11** - Framework PHP moderne
- **PostgreSQL** - Base de données relationnelle
- **Eloquent ORM** - Gestion des modèles et relations
- **L5-Swagger** - Documentation API automatique
- **PHPUnit** - Tests automatisés

## 📊 **Architecture de la Base de Données**

### **Entités Principales**

#### **Airline (Compagnie Aérienne)**
- `id` - Identifiant unique
- `name` - Nom de la compagnie
- `iata_code` - Code IATA (3 caractères)

#### **Airport (Aéroport)**
- `id` - Identifiant unique
- `name` - Nom de l'aéroport
- `iata_code` - Code IATA (3 caractères)
- `city` - Ville de l'aéroport
- `latitude` - Latitude géographique
- `longitude` - Longitude géographique
- `timezone` - Fuseau horaire
- `city_code` - Code de la ville

#### **Flight (Vol)**
- `id` - Identifiant unique
- `flight_number` - Numéro de vol
- `airline_id` - Référence vers la compagnie
- `departure_airport_id` - Aéroport de départ
- `arrival_airport_id` - Aéroport d'arrivée
- `price` - Prix du vol
- `departure_time` - Heure de départ
- `arrival_time` - Heure d'arrivée

#### **Trip (Voyage)**
- `id` - Identifiant unique
- `trip_type` - Type de voyage (one-way, round-trip, multi-city)
- `total_price` - Prix total du voyage
- `departure_date` - Date de départ
- `return_date` - Date de retour (optionnel)

### **Relations**
- **Airline** ↔ **Flight** : One-to-Many
- **Airport** ↔ **Flight** : One-to-Many (départ et arrivée)
- **Trip** ↔ **Flight** : Many-to-Many (via table pivot `flight_trip`)

## 🔌 **API Endpoints**

### **Compagnies Aériennes**
```
GET /api/airlines          - Liste des compagnies
GET /api/airlines/{id}     - Détails d'une compagnie
```

### **Aéroports**
```
GET /api/airports          - Liste des aéroports
GET /api/airports/search   - Recherche d'aéroports
GET /api/airports/{id}     - Détails d'un aéroport
```

### **Vols**
```
GET /api/flights           - Liste des vols (avec filtres)
GET /api/flights/search    - Recherche avancée de vols
GET /api/flights/{id}      - Détails d'un vol
```

### **Voyages**
```
GET /api/trips             - Liste des voyages
POST /api/trips            - Créer un voyage
GET /api/trips/{id}        - Détails d'un voyage
POST /api/trips/validate   - Valider un voyage
```

## 🛠️ **Installation et Configuration**

### **Prérequis**
- PHP 8.2+
- Composer
- PostgreSQL 12+
- Node.js (pour les assets)

### **Installation**
```bash
# Cloner le projet
git clone <repository-url>
cd flightHub/backend

# Installer les dépendances
composer install

# Copier le fichier d'environnement
cp .env.example .env

# Configurer la base de données dans .env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=flighthub
DB_USERNAME=postgres
DB_PASSWORD=votre_mot_de_passe

# Générer la clé d'application
php artisan key:generate

# Créer les tables
php artisan migrate

# Peupler la base de données
php artisan db:seed

# Démarrer le serveur
php artisan serve
```

## 📚 **Documentation API (Swagger)**

La documentation complète de l'API est disponible à :
```
http://localhost:8000/api/documentation
```

### **Générer la Documentation**
```bash
# Générer la documentation Swagger
php artisan l5-swagger:generate

# Vider le cache si nécessaire
php artisan config:clear
```

## 🗄️ **Base de Données**

### **Création de la Base**
```sql
-- Dans pgAdmin ou psql
CREATE DATABASE flighthub;
CREATE USER flighthub_user WITH PASSWORD 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON DATABASE flighthub TO flighthub_user;
```

### **Migrations**
```bash
# Créer une nouvelle migration
php artisan make:migration nom_de_la_migration

# Exécuter les migrations
php artisan migrate

# Annuler la dernière migration
php artisan migrate:rollback

# Réinitialiser toutes les migrations
php artisan migrate:reset
```

### **Seeders**
```bash
# Exécuter tous les seeders
php artisan db:seed

# Exécuter un seeder spécifique
php artisan db:seed --class=AirlineSeeder

# Réinitialiser et repeupler
php artisan migrate:fresh --seed
```

## 🧪 **Tests**

```bash
# Exécuter tous les tests
php artisan test

# Tests avec couverture
php artisan test --coverage

# Tests en mode watch
php artisan test --watch
```

## 🔧 **Configuration**

### **Variables d'Environnement**
```env
# Application
APP_NAME=FlightHub
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Base de données
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=flighthub
DB_USERNAME=postgres
DB_PASSWORD=votre_mot_de_passe

# Cache et sessions
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
```

### **Fichiers de Configuration**
- `config/database.php` - Configuration des bases de données
- `config/l5-swagger.php` - Configuration Swagger
- `config/cors.php` - Configuration CORS

## 📱 **Intégration Frontend**

Le backend est conçu pour s'intégrer avec le frontend React :
- **CORS** configuré pour permettre les requêtes cross-origin
- **API REST** avec réponses JSON standardisées
- **Validation** des données côté serveur
- **Gestion d'erreurs** avec codes HTTP appropriés

## 🚀 **Déploiement**

### **Production**
```bash
# Optimiser pour la production
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Variables d'environnement
APP_ENV=production
APP_DEBUG=false
DB_HOST=votre_host_production
```

### **Plateformes Supportées**
- **Heroku** - Déploiement simple
- **AWS** - Scalabilité et performance
- **DigitalOcean** - VPS abordable
- **Vercel** - Déploiement automatique

## 🔒 **Sécurité**

- **Validation** des données d'entrée
- **Protection CSRF** activée
- **Rate Limiting** configuré
- **Sanitisation** des données
- **Gestion des erreurs** sécurisée

## 📊 **Monitoring et Logs**

- **Logs Laravel** dans `storage/logs/`
- **Debugbar** en développement
- **Horizon** pour la surveillance des queues
- **Telescope** pour le debugging

## 🤝 **Contribution**

1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push vers la branche
5. Ouvrir une Pull Request

## 📄 **Licence**

Ce projet est sous licence MIT.

---

**FlightHub Backend** - API robuste et scalable pour la réservation de vols ✈️
