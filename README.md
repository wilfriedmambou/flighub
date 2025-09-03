# 🛩️ FlightHub - Système de Réservation de Vols

Projet fullstack complet pour la recherche et la réservation de vols, construit avec **React + Vite** (frontend) et **Laravel** (backend).

## 🚀 **Vue d'Ensemble**

FlightHub est une plateforme moderne de réservation de vols qui permet aux utilisateurs de :
- 🔍 **Rechercher des vols** avec des filtres avancés
- ✈️ **Comparer les prix** entre différentes compagnies aériennes
- 🎯 **Créer des voyages** (aller simple, aller-retour, multi-villes)
- 💰 **Calculer les prix** en temps réel
- 📱 **Interface responsive** optimisée pour tous les appareils

## 🏗️ **Architecture du Projet**

```
flightHub/
├── frontend/          # Application React + Vite
│   ├── src/
│   │   ├── components/    # Composants React
│   │   ├── services/      # Services API
│   │   └── ...
│   ├── package.json
│   └── README.md
├── backend/           # API Laravel
│   ├── app/
│   │   ├── Http/Controllers/Api/  # Contrôleurs API
│   │   ├── Models/                # Modèles Eloquent
│   │   └── ...
│   ├── database/
│   │   ├── migrations/            # Migrations de base de données
│   │   └── seeders/               # Données d'exemple
│   └── README.md
└── README.md          # Ce fichier
```

## 🚀 **Local Installation with Docker Compose**

### **Prerequisites**
- Docker and Docker Compose installed on your system
- Internet connection (for RDS database access)
- No additional configuration needed (RDS connection is pre-configured)

### **Database Information**

The application connects to a **pre-configured AWS RDS PostgreSQL database**:

- **Database Name:** `flighthub`
- **Host:** `prod-flighthub-db.cgrc2wska579.us-east-1.rds.amazonaws.com`
- **Port:** `5432`
- **Username:** `flighthub_admin`
- **Password:** `flighthub-prod-2025`
- **Region:** `us-east-1`

**Note:** The database is already populated with flight data and ready for testing.

### **Quick Start**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/wilfriedmambou/flighub.git
   cd flighthub
   ```

2. **Start the application:**
   ```bash
   docker compose up --build -d
   ```

3. **Access the application:**
   - **Frontend:** http://localhost:3000
   - **Backend API:** http://localhost:8000
   - **API Health Check:** http://localhost:8000/api/health

### **Step-by-Step Installation**

#### **Step 1: Backend Setup**
The backend service will:
- Connect to the RDS database automatically
- Run database migrations
- Start the Laravel API server
- Be available on port 8000

```bash
# Check backend logs
docker logs flighthub-backend-test

# Test backend health
curl http://localhost:8000/api/health
```

#### **Step 2: Frontend Setup**
The frontend service will:
- Build the React application
- Connect to the backend API
- Start the Nginx web server
- Be available on port 3000

```bash
# Check frontend logs
docker logs flighthub-frontend-test

# Test frontend
curl http://localhost:3000
```

#### **Step 3: Database Connection Test**
A test service verifies the RDS connection:

```bash
# Check database connection test
docker logs flighthub-test-rds
```

### **Database Configuration**

The application is **pre-configured** to connect to an **AWS RDS PostgreSQL database**. The connection parameters are already set in the `docker-compose.yml` file:

```yaml
environment:
  DB_CONNECTION: pgsql
  DB_HOST: prod-flighthub-db.cgrc2wska579.us-east-1.rds.amazonaws.com
  DB_PORT: 5432
  DB_DATABASE: flighthub_prod
  DB_USERNAME: flighthub_user
  DB_PASSWORD: ${DB_PASSWORD}
```

**Note:** The database connection is already established and contains flight data for testing.

### **Available Flight Routes for Testing**

The application includes flight data with the following IATA codes:

**Montreal (YUL) → Toronto:**
- YUL → SSR (9 flights per day)
- YUL → ADG (9 flights per day)
- YUL → CAJ (9 flights per day)
- YUL → XRE, YXZ, XXK, USU, VIR, PSE

**Montreal (YUL) → Ottawa:**
- YUL → IVR, XQE, BUW, TAO

### **Testing the Application**

#### **Test 1: Backend API Health Check**
```bash
curl http://localhost:8000/api/health
```
**Expected Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-09-03T00:59:14.740430Z",
  "environment": "production",
  "version": "1.0.0",
  "service": "FlightHub API"
}
```

#### **Test 2: Frontend Access**
```bash
curl http://localhost:3000
```
**Expected Response:** HTML page with React application

#### **Test 3: Flight Search API**
```bash
curl "http://localhost:8000/api/flights/search?departure_airport=YUL&arrival_airport=SSR&date=2026-01-15&per_page=3"
```
**Expected Response:** JSON with flight data

#### **Test 4: Web Interface Testing**

1. **Open your browser and go to:** http://localhost:3000

2. **Search for flights:**
   - **Departure:** YUL (Montreal)
   - **Arrival:** SSR (Toronto)
   - **Date:** 2026-01-15
   - **Expected:** 9 flights found

3. **Test different routes:**
   - YUL → ADG (Montreal → Toronto)
   - YUL → CAJ (Montreal → Toronto)
   - YUL → XRE (Montreal → Toronto)

4. **Test round-trip booking:**
   - Select "Aller-retour" (Round-trip)
   - Choose departure and return dates
   - Select flights for both directions

### **Verification Commands**

#### **Check All Services Status**
```bash
# View all running containers
docker ps

# Check service health
docker compose ps

# View all logs
docker compose logs -f

# View specific service logs
docker compose logs backend
docker compose logs frontend
docker compose logs test-rds
```

#### **Service Health Checks**
```bash
# Backend health check
curl -f http://localhost:8000/api/health || echo "Backend not ready"

# Frontend health check
curl -f http://localhost:3000 || echo "Frontend not ready"

# Database connection test
docker logs flighthub-test-rds | grep -i "success\|error\|connected"
```

### **Development Commands**

```bash
# Stop the application
docker compose down

# Rebuild and restart
docker compose up --build -d

# Access backend container
docker exec -it flighthub-backend-test bash

# Access frontend container
docker exec -it flighthub-frontend-test sh

# Restart specific service
docker compose restart backend
docker compose restart frontend
```

### **Troubleshooting**

**If you encounter CORS errors:**
- The frontend is configured to connect to the backend on the same domain
- CORS is handled by Laravel middleware

**If no flights are found:**
- Ensure you're using the correct IATA codes (YUL, SSR, ADG, etc.)
- Check that the date is in 2026 (flight data is available for 2026)

## 🎯 **Fonctionnalités Principales**

### **Frontend (React + Vite)**
- ✅ Interface moderne et responsive
- ✅ Formulaire de recherche de vols
- ✅ Gestion des types de voyage (aller simple, aller-retour)
- ✅ Composants modulaires et réutilisables
- ✅ Design avec Tailwind CSS v4
- ✅ Intégration API complète

### **Backend (Laravel)**
- ✅ API REST complète
- ✅ Base de données PostgreSQL avec Eloquent ORM
- ✅ Modèles : Airline, Airport, Flight, Trip
- ✅ Validation des données et gestion d'erreurs
- ✅ Documentation Swagger automatique
- ✅ Seeders avec données d'exemple

## 🛠️ **Technologies Utilisées**

### **Frontend**
- **React 18** + **TypeScript**
- **Vite** - Build tool moderne
- **Tailwind CSS v4** - Framework CSS utilitaire
- **Lucide React** - Icônes modernes
- **Fetch API** - Communication avec le backend

### **Backend**
- **Laravel 11** - Framework PHP moderne
- **PostgreSQL** - Base de données relationnelle
- **Eloquent ORM** - Gestion des modèles
- **L5-Swagger** - Documentation API
- **PHPUnit** - Tests automatisés

## 📊 **Modèle de Données**

### **Entités Principales**
- **Airline** : Compagnies aériennes (nom, code IATA)
- **Airport** : Aéroports (nom, ville, coordonnées, fuseau horaire)
- **Flight** : Vols (numéro, prix, horaires, relations)
- **Trip** : Voyages (type, prix total, dates, vols associés)

### **Relations**
- **Airline** ↔ **Flight** : One-to-Many
- **Airport** ↔ **Flight** : One-to-Many (départ et arrivée)
- **Trip** ↔ **Flight** : Many-to-Many (via table pivot)

## 🚀 **Installation et Démarrage**

### **Prérequis**
- Node.js 18+
- PHP 8.2+
- Composer
- PostgreSQL 12+
- Git

### **1. Cloner le Projet**
```bash
git clone <repository-url>
cd flightHub
```

### **2. Configuration Frontend**
```bash
cd frontend
npm install
npm run dev
```

### **3. Configuration Backend**
```bash
cd backend
composer install

# Configurer la base de données dans .env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=flighthub
DB_USERNAME=postgres
DB_PASSWORD=votre_mot_de_passe

# Créer les tables et peupler la base
php artisan migrate
php artisan db:seed

# Démarrer le serveur
php artisan serve
```

### **4. Accès aux Applications**
- **Frontend** : http://localhost:5173
- **Backend API** : http://localhost:8000/api
- **Documentation Swagger** : http://localhost:8000/api/docs

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

## 🎨 **Interface Utilisateur**

### **Design System**
- **Couleurs** : Palette bleue professionnelle
- **Typographie** : Inter font pour la lisibilité
- **Composants** : Cards, boutons, formulaires modernes
- **Responsive** : Mobile-first design

### **Composants Principaux**
- **HeroSection** : Titre principal avec arrière-plan stylisé
- **FlightSearchForm** : Formulaire de recherche intuitif
- **FeaturesSection** : Présentation des avantages
- **ApiService** : Service de communication avec le backend

## 🧪 **Tests et Qualité**

### **Frontend**
```bash
npm run test          # Exécuter les tests
npm run test:watch    # Tests en mode watch
npm run lint          # Vérification du code
```

### **Backend**
```bash
php artisan test      # Tests PHPUnit
php artisan test --coverage  # Avec couverture
```

## 📚 **Documentation**

- **Frontend** : [README Frontend](frontend/README.md)
- **Backend** : [README Backend](backend/README.md)
- **API** : [Documentation Swagger](http://localhost:8000/api/docs) - Interface interactive complète

## 🚀 **Déploiement**

### **Frontend**
- **Vercel** : Déploiement automatique
- **Netlify** : Drag & drop
- **AWS S3** : Hébergement statique

### **Backend**
- **Heroku** : Déploiement simple
- **AWS** : Scalabilité et performance
- **DigitalOcean** : VPS abordable

## 🔒 **Sécurité**

- **Validation** des données d'entrée
- **CORS** configuré pour le frontend
- **Rate Limiting** sur l'API
- **Sanitisation** des données
- **Gestion d'erreurs** sécurisée

## 🤝 **Contribution**

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 **Licence**

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 **Support**

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation technique
- Contacter l'équipe de développement

---

**FlightHub** - Votre compagnon de voyage intelligent ✈️

*Développé avec ❤️ en utilisant les technologies web modernes*


<!-- backend API  -->
http://52.90.108.95/api/docs

<!-- frontend  -->

http://52.90.108.95:8080/


<!-- Résultat attendu : 9 vols aller + 9 vols retour -->

Départ : YUL
Arrivée : ADG
Date aller : 2026-01-20
Date retour : 2026-01-22
Type : Aller-retour
Résultat attendu : 9 vols aller + 9 vols retour

<!-- alle simple ici  -->

Départ : YUL
Arrivée : SSR
Date : 2026-01-15
Type : Aller simple
Résultat attendu : 9 vols trouvés