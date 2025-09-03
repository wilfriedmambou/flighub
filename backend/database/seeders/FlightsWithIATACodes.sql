-- =====================================================
-- FLIGHTHUB - VOLS AVEC CODES IATA
-- =====================================================
-- Script pour voir les vols avec les codes IATA des aéroports
-- =====================================================

-- 1. Voir tous les vols avec codes IATA des aéroports
SELECT 'Tous les vols avec codes IATA:' as info;
SELECT 
    f.id,
    f.flight_number,
    a.iata_code as airline_code,
    dep.iata_code as departure_code,
    arr.iata_code as arrival_code,
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    f.price,
    f.departure_time,
    f.arrival_time,
    EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time))/3600 as duration_hours
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
ORDER BY f.departure_time
LIMIT 50;

-- 2. Voir les vols avec codes IATA et noms des aéroports
SELECT 'Vols avec codes IATA et noms des aéroports:' as info;
SELECT 
    f.flight_number,
    a.iata_code as airline,
    dep.iata_code as dep_code,
    dep.name as departure_airport,
    arr.iata_code as arr_code,
    arr.name as arrival_airport,
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    f.price,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
ORDER BY f.departure_time
LIMIT 30;

-- 3. Rechercher des vols spécifiques par codes IATA
SELECT 'Recherche de vols YUL → YYZ:' as info;
SELECT 
    f.flight_number,
    a.iata_code as airline,
    dep.iata_code as departure,
    arr.iata_code as arrival,
    f.price,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
ORDER BY f.departure_time
LIMIT 10;

-- 4. Rechercher des vols YYZ → YVR
SELECT 'Recherche de vols YYZ → YVR:' as info;
SELECT 
    f.flight_number,
    a.iata_code as airline,
    dep.iata_code as departure,
    arr.iata_code as arrival,
    f.price,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR'
ORDER BY f.departure_time
LIMIT 10;

-- 5. Rechercher des vols YOW → YYZ
SELECT 'Recherche de vols YOW → YYZ:' as info;
SELECT 
    f.flight_number,
    a.iata_code as airline,
    dep.iata_code as departure,
    arr.iata_code as arrival,
    f.price,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ'
ORDER BY f.departure_time
LIMIT 10;

-- 6. Statistiques par route avec codes IATA
SELECT 'Statistiques par route:' as info;
SELECT 
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    COUNT(*) as total_flights,
    MIN(f.price) as min_price,
    MAX(f.price) as max_price,
    AVG(f.price)::decimal(10,2) as avg_price,
    MIN(f.departure_time) as first_flight,
    MAX(f.departure_time) as last_flight
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
GROUP BY dep.iata_code, arr.iata_code
ORDER BY total_flights DESC;

-- 7. Voir les vols d'aujourd'hui avec codes IATA
SELECT 'Vols d''aujourd''hui avec codes IATA:' as info;
SELECT 
    f.flight_number,
    a.iata_code as airline,
    dep.iata_code as departure,
    arr.iata_code as arrival,
    f.price,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airlines a ON f.airline_id = a.id
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE DATE(f.departure_time) = CURRENT_DATE
ORDER BY f.departure_time
LIMIT 20;
