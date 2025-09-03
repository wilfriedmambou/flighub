# 🚀 Générateur de Données de Test Avancées - FlightHub

Ce fichier SQL génère des données de test complètes et réalistes pour votre système de réservation de vols FlightHub.

## 📊 **Données Générées**

### **1. Vols Aller-Retour Complets**
- **Montréal ↔ Toronto** : 9 vols par jour sur 90 jours
- **Horaires variés** : 6h00 à 22h00
- **Prix dynamiques** : Heures de pointe (180-230€), Heures creuses (150-200€)

### **2. Vols Longue Distance**
- **Montréal ↔ Vancouver** : 3 vols par jour sur 90 jours
- **Durée** : 5h30
- **Prix** : 350-500€ (plus élevé pour longues distances)

### **3. Vols avec Escales**
- **Montréal → Vancouver via Toronto** : Correspondances programmées
- **Numéros spéciaux** : Préfixe "CONN" pour identifier les vols de correspondance

### **4. Vols Internationaux**
- **Montréal ↔ New York (JFK)** : 4 vols par jour
- **Compagnies** : Air Canada, United, Delta
- **Prix** : 250-350€

### **5. Vols de Fin de Semaine**
- **Vendredi soir** : Montréal → Toronto (18h00-22h00)
- **Dimanche soir** : Toronto → Montréal (16h00-20h00)
- **Prix** : 220-280€ (plus élevé le weekend)

### **6. Vols de Vacances**
- **Période de Noël** : 20-30 décembre
- **Prix** : 300-450€ (période de pointe)

### **7. Vols Multi-Étapes**
- **Montréal → Calgary** : Via Toronto
- **Numéros spéciaux** : Préfixe "MULTI"

### **8. Vols de Dernière Minute**
- **Prix réduits** : 80-140€
- **Horaires** : 6h00, 10h00, 14h00, 18h00, 22h00

### **9. Vols de Nuit (Red-eyes)**
- **Montréal → Vancouver** : Départ 23h00
- **Prix réduits** : 280-380€

## 🛠️ **Comment Utiliser**

### **Option 1 : Exécution Directe en Base**
```bash
# Se connecter à PostgreSQL
psql -h localhost -U postgres -d flighthub

# Exécuter le script
\i backend/database/seeders/AdvancedFlightDataSeeder.sql
```

### **Option 2 : Via Docker**
```bash
# Copier le fichier dans le container
docker cp backend/database/seeders/AdvancedFlightDataSeeder.sql flighthub-backend-1:/tmp/

# Exécuter dans le container
docker exec -it flighthub-backend-1 psql -U postgres -d flighthub -f /tmp/AdvancedFlightDataSeeder.sql
```

### **Option 3 : Via Laravel Artisan (Recommandé)**
```bash
# Créer un seeder Laravel
php artisan make:seeder AdvancedFlightDataSeeder

# Copier le contenu SQL dans le seeder
# Puis exécuter
php artisan db:seed --class=AdvancedFlightDataSeeder
```

## 📈 **Statistiques Attendues**

Après exécution, vous devriez avoir :
- **~15,000+ vols** sur 90 jours
- **Routes principales** : YUL↔YYZ, YUL↔YVR, YYZ↔YVR
- **Prix variés** : 80€ à 500€ selon distance et période
- **Horaires couverts** : 6h00 à 23h00
- **Compagnies** : Air Canada, WestJet, Porter, United, Delta

## 🔍 **Vérification des Données**

### **Compter les vols par route**
```sql
SELECT 
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    COUNT(*) as nombre_vols,
    AVG(f.price)::decimal(10,2) as prix_moyen
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
GROUP BY dep.iata_code, arr.iata_code
ORDER BY nombre_vols DESC;
```

### **Vérifier les prix par période**
```sql
SELECT 
    EXTRACT(hour FROM departure_time) as heure_depart,
    COUNT(*) as nombre_vols,
    AVG(price)::decimal(10,2) as prix_moyen
FROM flights
GROUP BY EXTRACT(hour FROM departure_time)
ORDER BY heure_depart;
```

### **Analyser les vols de correspondance**
```sql
SELECT 
    flight_number,
    departure_time,
    arrival_time,
    price
FROM flights
WHERE flight_number LIKE '%CONN%'
ORDER BY departure_time;
```

## ⚠️ **Notes Importantes**

1. **Nettoyage** : Le script inclut des lignes commentées pour nettoyer les données existantes
2. **Séquences** : Si vous nettoyez, réinitialisez les séquences d'ID
3. **Performance** : L'exécution peut prendre quelques minutes selon la base
4. **Données existantes** : Le script s'ajoute aux données existantes

## 🎯 **Cas d'Usage Recommandés**

- **Développement** : Tests de fonctionnalités
- **Démonstration** : Présentation client
- **Performance** : Tests de charge
- **Formation** : Apprentissage de l'équipe

## 🔧 **Personnalisation**

Vous pouvez modifier :
- **Périodes** : Changer les dates dans `generate_series()`
- **Prix** : Ajuster les fourchettes de prix
- **Horaires** : Modifier les heures de départ
- **Routes** : Ajouter/supprimer des destinations

---

**FlightHub** - Données de test réalistes pour un développement efficace ! ✈️


