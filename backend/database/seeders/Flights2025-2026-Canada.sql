-- =====================================================
-- FLIGHTHUB - VOLS CANADA 2025-2026
-- =====================================================
-- Script pour créer plus de 200 vols entre les aéroports canadiens
-- Période: 3 septembre 2025 au 10 septembre 2026
-- Plus de 10 vols par jour
-- =====================================================

-- Vérifier les aéroports canadiens disponibles
SELECT 'Aéroports canadiens disponibles:' as info;
SELECT id, iata_code, name, city FROM airports 
WHERE iata_code IN ('YUL', 'YVR', 'YYZ', 'YYC', 'YEG', 'YOW', 'YHZ', 'YWG')
ORDER BY iata_code;

-- Vérifier les compagnies disponibles
SELECT 'Compagnies disponibles:' as info;
SELECT id, iata_code, name FROM airlines ORDER BY id LIMIT 10;

-- Nettoyer les anciens vols de test (optionnel)
-- DELETE FROM flights WHERE id > 0;

-- =====================================================
-- GÉNÉRATION DES VOLS CANADA 2025-2026
-- =====================================================

-- 1. VOLS MONTREAL (YUL) ↔ TORONTO (YYZ) - Route principale
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    120 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(6, 22, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- 2. VOLS TORONTO (YYZ) ↔ VANCOUVER (YVR) - Route transcontinentale
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'TV', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    350 + (RANDOM() * 150)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 20, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- 3. VOLS OTTAWA (YOW) ↔ TORONTO (YYZ) - Route régionale
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'OT', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    100 + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 19, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- 4. VOLS CALGARY (YYC) ↔ TORONTO (YYZ) - Route transcontinentale
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CT', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    280 + (RANDOM() * 120)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '3 hours 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(9, 21, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYC' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS');

-- 5. VOLS EDMONTON (YEG) ↔ VANCOUVER (YVR) - Route ouest
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'EV', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    180 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 18, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YEG' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- 6. VOLS HALIFAX (YHZ) ↔ TORONTO (YYZ) - Route atlantique
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'HT', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    200 + (RANDOM() * 100)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '2 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(10, 20, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YHZ' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS');

-- 7. VOLS WINNIPEG (YWG) ↔ TORONTO (YYZ) - Route centre
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WT', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    220 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '2 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(9, 19, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YWG' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- 8. VOLS MONTREAL (YUL) ↔ VANCOUVER (YVR) - Route directe transcontinentale
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'UV', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    400 + (RANDOM() * 200)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(12, 12, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- 9. VOLS CALGARY (YYC) ↔ VANCOUVER (YVR) - Route ouest
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CV', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    150 + (RANDOM() * 70)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 20 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 21, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYC' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- 10. VOLS EDMONTON (YEG) ↔ CALGARY (YYC) - Route albertaine
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'EC', LPAD(ROW_NUMBER() OVER (ORDER BY flight_date, hour)::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    120 + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-09-10'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 20, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YEG' AND arr.iata_code = 'YYC'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- =====================================================
-- STATISTIQUES DES VOLS CRÉÉS
-- =====================================================

-- Statistiques générales
SELECT 'Statistiques des vols créés:' as info;
SELECT 
    COUNT(*) as total_flights,
    MIN(departure_time) as first_flight,
    MAX(departure_time) as last_flight,
    AVG(price)::decimal(10,2) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM flights 
WHERE departure_time >= '2025-09-03' AND departure_time <= '2026-09-10';

-- Statistiques par route
SELECT 'Statistiques par route:' as info;
SELECT 
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    COUNT(*) as total_flights,
    MIN(f.price) as min_price,
    MAX(f.price) as max_price,
    AVG(f.price)::decimal(10,2) as avg_price
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
WHERE f.departure_time >= '2025-09-03' AND f.departure_time <= '2026-09-10'
GROUP BY dep.iata_code, arr.iata_code
ORDER BY total_flights DESC;

-- Exemples de vols créés
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
WHERE f.departure_time >= '2025-09-03' AND f.departure_time <= '2026-09-10'
ORDER BY f.departure_time
LIMIT 20;
