-- =====================================================
-- FLIGHTHUB - VOLS DE TEST (VERSION CONSOLE AWS)
-- =====================================================
-- Script simplifié pour exécution directe sur la console AWS
-- =====================================================

-- Vérifier les aéroports disponibles
SELECT 'Aéroports disponibles:' as info;
SELECT id, iata_code, name, city FROM airports ORDER BY id;

-- Vérifier les compagnies disponibles
SELECT 'Compagnies disponibles:' as info;
SELECT id, iata_code, name FROM airlines ORDER BY id;

-- Nettoyer les vols existants (optionnel)
-- DELETE FROM flights WHERE id > 0;

-- Générer quelques vols de test pour Montréal-Toronto
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    150 + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-01-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 18, 5) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Générer quelques vols pour Toronto-Vancouver
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'TV', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    420 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-01-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(12, 12, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- Générer quelques vols pour Ottawa-Toronto
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'OT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    120 + (RANDOM() * 30)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-01-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 17, 5) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Statistiques des vols créés
SELECT 'Statistiques des vols créés:' as info;
SELECT 
    COUNT(*) as total_flights,
    MIN(departure_time) as first_flight,
    MAX(departure_time) as last_flight,
    AVG(price)::decimal(10,2) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM flights 
WHERE departure_time >= '2025-01-01' AND departure_time <= '2025-01-31';

-- Afficher quelques exemples de vols
SELECT 'Exemples de vols créés:' as info;
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
WHERE f.departure_time >= '2025-01-01' AND f.departure_time <= '2025-01-31'
ORDER BY f.departure_time
LIMIT 10;
