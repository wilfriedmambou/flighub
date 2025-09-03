# 📋 Correspondance Aéroports - Codes IATA et IDs

## 🛫 Aéroports disponibles dans la base de données

| **ID** | **Code IATA** | **Nom de l'aéroport** | **Ville** |
|--------|---------------|------------------------|-----------|
| **1** | **YUL** | Montréal-Trudeau International Airport | Montréal |
| **2** | **YVR** | Vancouver International Airport | Vancouver |
| **3** | **YYZ** | Toronto Pearson International Airport | Toronto |
| **4** | **YYC** | Calgary International Airport | Calgary |
| **5** | **YEG** | Edmonton International Airport | Edmonton |
| **6** | **YOW** | Ottawa Macdonald-Cartier International Airport | Ottawa |
| **7** | **YHZ** | Halifax Stanfield International Airport | Halifax |
| **8** | **YWG** | Winnipeg James Armstrong Richardson International Airport | Winnipeg |

## ✈️ Routes dans le script Flights2025-2026.sql

### Routes principales (14 combinaisons) :

| **Route** | **Départ** | **Arrivée** | **ID Départ** | **ID Arrivée** | **Fréquence** |
|-----------|------------|-------------|---------------|----------------|---------------|
| **YUL ↔ YYZ** | Montréal | Toronto | 1 | 3 | 4x/jour |
| **YYZ ↔ YUL** | Toronto | Montréal | 3 | 1 | 4x/jour |
| **YUL ↔ YVR** | Montréal | Vancouver | 1 | 2 | 3x/jour |
| **YVR ↔ YUL** | Vancouver | Montréal | 2 | 1 | 3x/jour |
| **YYZ ↔ YVR** | Toronto | Vancouver | 3 | 2 | 3x/jour |
| **YYC ↔ YYZ** | Calgary | Toronto | 4 | 3 | 3x/jour |
| **YUL ↔ YYC** | Montréal | Calgary | 1 | 4 | 3x/jour |
| **YOW ↔ YYZ** | Ottawa | Toronto | 6 | 3 | 5x/jour |
| **YHZ ↔ YYZ** | Halifax | Toronto | 7 | 3 | 2x/jour |
| **YWG ↔ YYZ** | Winnipeg | Toronto | 8 | 3 | 3x/jour |
| **YEG ↔ YVR** | Edmonton | Vancouver | 5 | 2 | 4x/jour |
| **YYC ↔ YVR** | Calgary | Vancouver | 4 | 2 | 3x/jour |
| **YHZ ↔ YUL** | Halifax | Montréal | 7 | 1 | 2x/jour |
| **YWG ↔ YUL** | Winnipeg | Montréal | 8 | 1 | 2x/jour |
| **YEG ↔ YYZ** | Edmonton | Toronto | 5 | 3 | 2x/jour |

### Vols spéciaux :

| **Type** | **Route** | **ID Départ** | **ID Arrivée** | **Fréquence** |
|----------|-----------|---------------|----------------|---------------|
| **Weekend** | YUL ↔ YYZ | 1 ↔ 3 | Vendredi soir | 1x/semaine |
| **Dimanche** | YYZ ↔ YUL | 3 ↔ 1 | Dimanche soir | 1x/semaine |
| **International** | YUL ↔ YVR | 1 ↔ 2 | Tous les 3 jours | 1x/3 jours |
| **Nuit** | YUL ↔ YYZ | 1 ↔ 3 | 23h | 1x/jour |

## 🚫 Vols supprimés

- **YQB ↔ YUL** (Québec ↔ Montréal) : **SUPPRIMÉ** - L'aéroport YQB n'existe pas dans la base de données

## 📊 Statistiques estimées

- **Période** : 3 septembre 2025 → 31 décembre 2026 (485 jours)
- **Routes actives** : 14 combinaisons principales + 4 types spéciaux
- **Vols estimés** : Plus de 2000 vols
- **Aéroports utilisés** : 8 aéroports canadiens
- **Compagnies** : AC, WS, PD, TS, F8

## ✅ Script prêt à exécuter

Le script `Flights2025-2026.sql` est maintenant corrigé et prêt à être exécuté sans erreur.
