-- =====================================================
-- FLIGHTHUB - VOLS DE TEST
-- =====================================================
-- Ce fichier génère des vols de test pour les 8 aéroports disponibles
-- Période : 1er janvier 2025 au 31 décembre 2025
-- =====================================================

-- 1. NETTOYAGE DES DONNÉES EXISTANTES (OPTIONNEL)
-- DELETE FROM flights WHERE id > 0;
-- ALTER SEQUENCE flights_id_seq RESTART WITH 1;

-- 2. GÉNÉRATION DE VOLS DE TEST
-- =============================

-- Vols Montréal ↔ Toronto (Route principale - 2x par jour)
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
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 18, 5) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Toronto ↔ Montréal (Retour - 2x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'R', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
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
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(9, 19, 5) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Montréal ↔ Vancouver (Route transcontinentale - 1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'V', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    450 + (RANDOM() * 100)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(10, 10, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Vancouver ↔ Montréal (Retour - 1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'VR', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    450 + (RANDOM() * 100)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(11, 11, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YVR' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Toronto ↔ Vancouver (1x par jour)
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
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(12, 12, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Calgary ↔ Toronto (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    380 + (RANDOM() * 70)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '3 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(13, 13, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYC' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Montréal ↔ Calgary (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'MC', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    400 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(14, 14, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYC'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Ottawa ↔ Toronto (2x par jour)
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
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 17, 5) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Halifax ↔ Toronto (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'HT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    250 + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '2 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(15, 15, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YHZ' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Winnipeg ↔ Toronto (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    320 + (RANDOM() * 60)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '2 hours 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(16, 16, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YWG' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Edmonton ↔ Vancouver (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'EV', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    180 + (RANDOM() * 40)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(17, 17, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YEG' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Calgary ↔ Vancouver (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CV', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    200 + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(18, 18, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYC' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Halifax ↔ Montréal (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'HM', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    280 + (RANDOM() * 60)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '2 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(19, 19, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YHZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Winnipeg ↔ Montréal (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WM', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    350 + (RANDOM() * 70)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '3 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(20, 20, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YWG' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS');

-- Vols Edmonton ↔ Toronto (1x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'ET', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    400 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(21, 21, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YEG' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS');

-- Statistiques finales
SELECT 
    'Vols de test générés pour 2025' as description,
    COUNT(*) as total_flights,
    MIN(departure_time) as first_flight,
    MAX(departure_time) as last_flight,
    AVG(price)::decimal(10,2) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price,
    COUNT(DISTINCT departure_airport_id) as departure_airports,
    COUNT(DISTINCT arrival_airport_id) as arrival_airports,
    COUNT(DISTINCT airline_id) as airlines
FROM flights 
WHERE departure_time >= '2025-01-01' AND departure_time <= '2025-12-31';
