-- =====================================================
-- FLIGHTHUB - GÉNÉRATEUR DE DONNÉES DE TEST AVANCÉ
-- =====================================================
-- Ce fichier génère des données de test complètes pour :
-- - Vols aller-retour avec correspondances
-- - Différentes classes de prix (Economy, Premium, Business)
-- - Horaires variés sur plusieurs mois
-- - Routes internationales et domestiques
-- - Vols avec escales
-- =====================================================

-- 1. NETTOYAGE DES DONNÉES EXISTANTES (OPTIONNEL)
-- DELETE FROM flights WHERE id > 0;
-- ALTER SEQUENCE flights_id_seq RESTART WITH 1;

-- 2. GÉNÉRATION DE VOLS ALLER-RETOUR COMPLETS
-- =============================================

-- Vols Montréal ↔ Toronto (Route très fréquentée)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    CASE 
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 6 AND 9 THEN 180  -- Heures de pointe
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 17 AND 20 THEN 200 -- Soirée
        ELSE 150 -- Heures creuses
    END + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(6, 22, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND hour IN (6, 8, 10, 12, 14, 16, 18, 20, 22);

-- Vols Toronto ↔ Montréal (Retour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    CASE 
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 6 AND 9 THEN 180
        WHEN EXTRACT(hour FROM dep_time) BETWEEN 17 AND 20 THEN 200
        ELSE 150
    END + (RANDOM() * 50)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 21, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND hour IN (7, 9, 11, 13, 15, 17, 19, 21);

-- 3. VOLS LONGUE DISTANCE (Montréal ↔ Vancouver)
-- ===============================================

-- Montréal → Vancouver (3 vols par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    350 + (RANDOM() * 150)::integer as price, -- Prix plus élevé pour longues distances
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(0, 2) as flight_num
CROSS JOIN LATERAL (
    SELECT flight_date + ((8 + flight_num * 6) || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS')
    AND flight_num IN (0, 1, 2);

-- Vancouver → Montréal (3 vols par jour)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, LPAD(ROW_NUMBER() OVER ()::text, 4, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    350 + (RANDOM() * 150)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(0, 2) as flight_num
CROSS JOIN LATERAL (
    SELECT flight_date + ((10 + flight_num * 6) || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YVR' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS')
    AND flight_num IN (0, 1, 2);

-- 4. VOLS AVEC ESCALES (Montréal → Vancouver via Toronto)
-- ========================================================

-- Montréal → Toronto (Première étape)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CONN', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    120 + (RANDOM() * 40)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(6, 18, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS')
    AND hour IN (6, 9, 12, 15, 18);

-- Toronto → Vancouver (Deuxième étape - correspondance)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'CONN', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    280 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(8, 20, 3) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS')
    AND hour IN (8, 11, 14, 17, 20);

-- 5. VOLS INTERNATIONAUX (Montréal ↔ New York)
-- =============================================

-- Montréal → New York (JFK)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'INT', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    250 + (RANDOM() * 100)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 45 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 19, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'JFK'
    AND a.iata_code IN ('AC', 'UA', 'DL')
    AND hour IN (7, 11, 15, 19);

-- 6. VOLS DE FIN DE SEMAINE (Vendredi soir, Dimanche soir)
-- =========================================================

-- Vols du vendredi soir (Montréal → Toronto)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WKND', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    220 + (RANDOM() * 60)::integer as price, -- Prix plus élevé le weekend
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '7 days'
    ) as flight_date,
    generate_series(18, 22, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND hour IN (18, 19, 20, 21, 22);

-- Vols du dimanche soir (Toronto → Montréal)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'WKND', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    220 + (RANDOM() * 60)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '7 days'
    ) as flight_date,
    generate_series(16, 20, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YYZ' AND arr.iata_code = 'YUL'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND hour IN (16, 17, 18, 19, 20);

-- 7. VOLS DE VACANCES (Périodes de pointe)
-- =========================================

-- Vols de Noël (20-30 décembre)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'XMAS', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    300 + (RANDOM() * 150)::integer as price, -- Prix élevé pendant les vacances
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        '2025-12-20'::date,
        '2025-12-30'::date,
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(6, 22, 2) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND hour IN (6, 8, 10, 12, 14, 16, 18, 20, 22);

-- 8. VOLS DE CORRESPONDANCE POUR VOYAGES MULTI-ÉTAPES
-- ====================================================

-- Montréal → Calgary (via Toronto)
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'MULTI', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    200 + (RANDOM() * 80)::integer as price,
    dep_time as departure_time,
    dep_time + INTERVAL '4 hours' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(7, 19, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYC'
    AND a.iata_code IN ('AC', 'WS')
    AND hour IN (7, 11, 15, 19);

-- 9. VOLS DE DERNIÈRE MINUTE (Prix réduits)
-- ==========================================

-- Vols du lendemain avec prix réduits
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'LAST', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    80 + (RANDOM() * 60)::integer as price, -- Prix réduit pour dernière minute
    dep_time as departure_time,
    dep_time + INTERVAL '1 hour 15 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '30 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(6, 22, 4) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YYZ'
    AND a.iata_code IN ('AC', 'WS', 'PD')
    AND hour IN (6, 10, 14, 18, 22);

-- 10. VOLS DE NUIT (Red-eyes)
-- ============================

-- Vols de nuit Montréal → Vancouver
INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, price, departure_time, arrival_time, created_at, updated_at)
SELECT 
    CONCAT(a.iata_code, 'NITE', LPAD(ROW_NUMBER() OVER ()::text, 3, '0')) as flight_number,
    a.id as airline_id,
    dep.id as departure_airport_id,
    arr.id as arrival_airport_id,
    280 + (RANDOM() * 100)::integer as price, -- Prix réduit pour vols de nuit
    dep_time as departure_time,
    dep_time + INTERVAL '5 hours 30 minutes' as arrival_time,
    NOW() as created_at,
    NOW() as updated_at
FROM 
    airlines a,
    airports dep,
    airports arr,
    generate_series(
        CURRENT_DATE + INTERVAL '1 day',
        CURRENT_DATE + INTERVAL '90 days',
        INTERVAL '1 day'
    ) as flight_date,
    generate_series(23, 23, 1) as hour
CROSS JOIN LATERAL (
    SELECT flight_date + (hour || ' hours')::interval as dep_time
) as times
WHERE 
    dep.iata_code = 'YUL' AND arr.iata_code = 'YVR'
    AND a.iata_code IN ('AC', 'WS')
    AND hour = 23;

-- =====================================================
-- STATISTIQUES APRÈS INSERTION
-- =====================================================

-- Compter le nombre total de vols
SELECT 'Total des vols créés' as description, COUNT(*) as count FROM flights;

-- Compter par route
SELECT 
    CONCAT(dep.iata_code, ' → ', arr.iata_code) as route,
    COUNT(*) as nombre_vols,
    AVG(f.price)::decimal(10,2) as prix_moyen,
    MIN(f.price)::decimal(10,2) as prix_min,
    MAX(f.price)::decimal(10,2) as prix_max
FROM flights f
JOIN airports dep ON f.departure_airport_id = dep.id
JOIN airports arr ON f.arrival_airport_id = arr.id
GROUP BY dep.iata_code, arr.iata_code
ORDER BY nombre_vols DESC;

-- Compter par compagnie
SELECT 
    a.name as compagnie,
    COUNT(*) as nombre_vols,
    AVG(f.price)::decimal(10,2) as prix_moyen
FROM flights f
JOIN airlines a ON f.airline_id = a.id
GROUP BY a.id, a.name
ORDER BY nombre_vols DESC;

-- Distribution des prix
SELECT 
    CASE 
        WHEN price < 100 THEN '0-100€'
        WHEN price < 200 THEN '100-200€'
        WHEN price < 300 THEN '200-300€'
        WHEN price < 400 THEN '300-400€'
        ELSE '400€+'
    END as tranche_prix,
    COUNT(*) as nombre_vols
FROM flights
GROUP BY 
    CASE 
        WHEN price < 100 THEN '0-100€'
        WHEN price < 200 THEN '100-200€'
        WHEN price < 300 THEN '200-300€'
        WHEN price < 400 THEN '300-400€'
        ELSE '400€+'
    END
ORDER BY tranche_prix;


