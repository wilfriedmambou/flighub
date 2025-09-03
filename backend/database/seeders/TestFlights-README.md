# 🛫 Vols de Test - FlightHub

## 📋 Aperçu
Ce script génère des vols de test pour les 8 aéroports disponibles dans la base de données.

## 🗓️ Période
- **Début** : 1er janvier 2025
- **Fin** : 31 décembre 2025
- **Durée** : 365 jours

## ✈️ Aéroports disponibles
| **ID** | **Code IATA** | **Nom** | **Ville** |
|--------|---------------|---------|-----------|
| 1 | YUL | Montréal-Trudeau International Airport | Montréal |
| 2 | YVR | Vancouver International Airport | Vancouver |
| 3 | YYZ | Toronto Pearson International Airport | Toronto |
| 4 | YYC | Calgary International Airport | Calgary |
| 5 | YEG | Edmonton International Airport | Edmonton |
| 6 | YOW | Ottawa Macdonald-Cartier International Airport | Ottawa |
| 7 | YHZ | Halifax Stanfield International Airport | Halifax |
| 8 | YWG | Winnipeg James Armstrong Richardson International Airport | Winnipeg |

## 🛣️ Routes de test (14 combinaisons)

### Routes principales :
1. **YUL ↔ YYZ** (Montréal ↔ Toronto) - 2x/jour
2. **YUL ↔ YVR** (Montréal ↔ Vancouver) - 1x/jour
3. **YYZ ↔ YVR** (Toronto ↔ Vancouver) - 1x/jour
4. **YYC ↔ YYZ** (Calgary ↔ Toronto) - 1x/jour
5. **YUL ↔ YYC** (Montréal ↔ Calgary) - 1x/jour
6. **YOW ↔ YYZ** (Ottawa ↔ Toronto) - 2x/jour
7. **YHZ ↔ YYZ** (Halifax ↔ Toronto) - 1x/jour
8. **YWG ↔ YYZ** (Winnipeg ↔ Toronto) - 1x/jour
9. **YEG ↔ YVR** (Edmonton ↔ Vancouver) - 1x/jour
10. **YYC ↔ YVR** (Calgary ↔ Vancouver) - 1x/jour
11. **YHZ ↔ YUL** (Halifax ↔ Montréal) - 1x/jour
12. **YWG ↔ YUL** (Winnipeg ↔ Montréal) - 1x/jour
13. **YEG ↔ YYZ** (Edmonton ↔ Toronto) - 1x/jour

## 💰 Fourchettes de prix
- **Court courrier** (Ottawa-Toronto) : 120-150€
- **Moyen courrier** (Montréal-Toronto) : 150-200€
- **Long courrier** (Montréal-Vancouver) : 450-550€
- **Transcontinental** (Toronto-Vancouver) : 420-500€

## ⏰ Horaires
- **Départ** : Entre 7h et 21h
- **Durées** : 45 minutes à 5h30 selon la distance
- **Fréquence** : 1 à 2 vols par jour selon la route

## 🏢 Compagnies aériennes
- **AC** - Air Canada
- **WS** - WestJet
- **PD** - Porter Airlines

## 📊 Statistiques estimées
- **Total des vols** : ~4,500 vols
- **Routes actives** : 13 combinaisons
- **Aéroports utilisés** : 8 aéroports canadiens
- **Compagnies** : 3 compagnies principales

## 🚀 Comment exécuter

### Via psql (recommandé) :
```bash
psql -h flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com -U flighthub_admin -d flighthub -f database/seeders/TestFlights.sql
```

### Via Laravel (alternative) :
```bash
php execute_flights_script.php
```

## ✅ Avantages pour les tests
- **Données réalistes** : Horaires et prix cohérents
- **Couverture complète** : Tous les aéroports disponibles
- **Volume modéré** : Assez de données pour tester sans surcharger
- **Période étendue** : Toute l'année 2025 pour les tests
- **Routes variées** : Court, moyen et long courrier

## 🔍 Exemples de recherches possibles
- **YUL → YYZ** : Recherche Montréal-Toronto
- **YYZ → YVR** : Recherche Toronto-Vancouver
- **YOW → YYZ** : Recherche Ottawa-Toronto
- **YHZ → YUL** : Recherche Halifax-Montréal
- **YEG → YVR** : Recherche Edmonton-Vancouver

Le script est optimisé pour les tests et fournit une base solide pour valider toutes les fonctionnalités de recherche de vols ! 🎉
