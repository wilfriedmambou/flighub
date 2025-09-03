-- =====================================================
-- FLIGHTHUB - GÉNÉRATEUR DE VOLS 2025-2026
-- =====================================================
-- Ce fichier génère plus de 100 vols du 3 septembre 2025 au 31 décembre 2026
-- avec les routes principales et une fréquence élevée
-- =====================================================

-- 1. NETTOYAGE DES DONNÉES EXISTANTES (OPTIONNEL)
-- DELETE FROM flights WHERE id > 0;
-- ALTER SEQUENCE flights_id_seq RESTART WITH 1;

-- 2. GÉNÉRATION DE VOLS POUR 2025-2026
-- =====================================

-- Vols Montréal ↔ Toronto (Route principale - 4x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    CASE 
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 6 AND 9 THEN 180 + (RANDOM() * 50)::integer  -- Heures de pointe
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 17 AND 20 THEN 200 + (RANDOM() * 60)::integer -- Soirée
        ELSE 150 + (RANDOM() * 40)::integer -- Heures creuses
    END as price,
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 19, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD', 'TS', 'F8');

-- Vols Toronto ↔ Montréal (Retour - 4x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'R', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    CASE 
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 6 AND 9 THEN 180 + (RANDOM() * 50)::integer
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 17 AND 20 THEN 200 + (RANDOM() * 60)::integer
        ELSE 150 + (RANDOM() * 40)::integer
    END as price,
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 20, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD', 'TS', 'F8');

-- Vols Montréal ↔ Vancouver (Route transcontinentale - 3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'V', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    450 + (RANDOM() * 150)::integer as price, -- Prix plus élevé pour long courrier
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 20, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Vancouver ↔ Montréal (Retour - 3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'VR', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    450 + (RANDOM() * 150)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(9, 21, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YVR' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Toronto ↔ Vancouver (3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'TV', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    420 + (RANDOM() * 130)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 19, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Calgary ↔ Toronto (3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CT', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    380 + (RANDOM() * 120)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '3 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 18, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYC' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD', 'F8');

-- Vols Montréal ↔ Calgary (3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'MC', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    400 + (RANDOM() * 140)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(9, 17, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYC'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Ottawa ↔ Toronto (5x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'OT', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    120 + (RANDOM() * 50)::integer as price, -- Prix court courrier
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 21, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YOW' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD', 'TS');

-- Vols Halifax ↔ Toronto (2x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'HT', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    250 + (RANDOM() * 80)::integer as price,
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(10, 18, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YHZ' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols supprimés : Québec (YQB) n'existe pas dans la base de données

-- Vols Winnipeg ↔ Toronto (3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WT', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    320 + (RANDOM() * 100)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '2 hours 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 19, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YWG' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Edmonton ↔ Vancouver (4x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'EV', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    180 + (RANDOM() * 60)::integer as price,
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 20, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YEG' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD', 'F8');

-- Vols Calgary ↔ Vancouver (3x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CV', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    200 + (RANDOM() * 70)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(9, 17, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYC' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Halifax ↔ Montréal (2x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'HM', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    280 + (RANDOM() * 90)::integer as price,
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(11, 19, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YHZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Winnipeg ↔ Montréal (2x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WM', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    350 + (RANDOM() * 110)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '3 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(12, 20, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YWG' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols Edmonton ↔ Toronto (2x par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'ET', LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    400 + (RANDOM() * 120)::integer as price,
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(13, 19, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YEG' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Vols spéciaux pour les weekends (prix plus élevés)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WKND', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    250 + (RANDOM() * 100)::integer as price, -- Prix weekend
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
        '2026-12-31'::date,
        INTERVAL '7 days'
    ) as flight_date,
    generate_series(18, 22, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND EXTRACT(dow FROM flight_date) = 5; -- Vendredi soir

-- Vols du dimanche soir (retour weekend)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'SUN', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    250 + (RANDOM() * 100)::integer as price,
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
        '2026-12-31'::date,
        INTERVAL '7 days'
    ) as flight_date,
    generate_series(16, 20, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND EXTRACT(dow FROM flight_date) = 0; -- Dimanche

-- Vols internationaux simulés (prix élevés)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'INT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    600 + (RANDOM() * 200)::integer as price, -- Prix international
    dep_time as departure_time,
    dep_time + INTERVAL '6 hours' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-09-03'::date,
        '2026-12-31'::date,
        INTERVAL '3 days'
    ) as flight_date,
    generate_series(10, 18, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS');

-- Vols de nuit (prix réduits)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'NIGHT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    120 + (RANDOM() * 50)::integer as price, -- Prix réduit pour vols de nuit
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
        '2026-12-31'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(23, 23, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD');

-- Statistiques finales
SELECT 
    'Vols générés pour 2025-2026' as description,
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
WHERE departure_time >= '2025-09-03' AND departure_time <= '2026-12-31';