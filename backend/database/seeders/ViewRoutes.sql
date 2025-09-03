-- =====================================================
-- FLIGHTHUB - AFFICHAGE DES ROUTES AVEC CODES IATA
-- =====================================================
-- Script pour voir les routes avec les codes IATA au lieu des IDs
-- =====================================================

-- 1. Voir toutes les routes disponibles avec codes IATA
SELECT 'Routes disponibles avec codes IATA:' as info;
SELECT 
    CONCAT(dep.iata_code, ' ↔ ', arr.iata_code) as route,
    CONCAT(dep.city, ' → ', arr.city) as cities,
    COUNT(*) as flight_count,
    MIN(f.price) as min_price,
    MAX(f.price) as max_price,
    AVG(f.price)::decimal(10,2) as avg_price
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
GROUP BY dep.iata_code, arr.iata_code, dep.city, arr.city
ORDER BY flight_count DESC;

-- 2. Voir les vols détaillés avec codes IATA
SELECT 'Vols détaillés avec codes IATA:' as info;
SELECT 
    f.flight_number,
    a.iata_code as airline,
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    CONCAT(dep.city, ' → ', arr.city) as cities,
    f.price,
    f.departure_time,
    f.arrival_time,
    EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time))/3600 as duration_hours
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
ORDER BY f.departure_time
LIMIT 20;

-- 3. Rechercher spécifiquement les routes demandées
SELECT 'Routes spécifiques demandées:' as info;
SELECT 
    CONCAT(dep.iata_code, ' ↔ ', arr.iata_code) as route,
    COUNT(*) as flight_count,
    MIN(f.departure_time) as first_flight,
    MAX(f.departure_time) as last_flight
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE 
    (dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ') OR
    (dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL') OR
    (dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR') OR
    (dep.iata_code = 'YVR' AND arr.iata_code = 'YYZ') OR
    (dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ') OR
    (dep.iata_code = 'YYZ' AND arr.iata_code = 'YOW')
GROUP BY dep.iata_code, arr.iata_code
ORDER BY route;

-- 4. Vérifier si les routes existent dans les deux sens
SELECT 'Routes bidirectionnelles:' as info;
SELECT 
    CASE 
        WHEN dep.iata_code < arr.iata_code 
        THEN CONCAT(dep.iata_code, ' ↔ ', arr.iata_code)
        ELSE CONCAT(arr.iata_code, ' ↔ ', dep.iata_code)
    END as route_bidirectional,
    COUNT(*) as total_flights,
    COUNT(CASE WHEN dep.iata_code < arr.iata_code THEN 1 END) as flights_AB,
    COUNT(CASE WHEN dep.iata_code > arr.iata_code THEN 1 END) as flights_BA
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE 
    (dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ') OR
    (dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL') OR
    (dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR') OR
    (dep.iata_code = 'YVR' AND arr.iata_code = 'YYZ') OR
    (dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ') OR
    (dep.iata_code = 'YYZ' AND arr.iata_code = 'YOW')
GROUP BY 
    CASE 
        WHEN dep.iata_code < arr.iata_code 
        THEN CONCAT(dep.iata_code, ' ↔ ', arr.iata_code)
        ELSE CONCAT(arr.iata_code, ' ↔ ', dep.iata_code)
    END
ORDER BY route_bidirectional;
