<?php
// Script simple pour créer des vols
echo "=== CRÉATION DE VOLS SIMPLE ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

try {
    echo "✅ Connexion RDS réussie !\n\n";
    
    // Vérifier les aéroports par ville
    echo "Aéroports par ville:\n";
    $stmt = $pdo->query("SELECT city, COUNT(*) as count, STRING_AGG(iata_code, ', ') as codes FROM airports GROUP BY city ORDER BY city");
    $cities = $stmt->fetchAll();
    foreach ($cities as $city) {
        echo "- " . $city['city'] . " (" . $city['count'] . "): " . $city['codes'] . "\n";
    }
    
    // Vérifier les compagnies
    echo "\nCompagnies disponibles:\n";
    $stmt = $pdo->query("SELECT id, iata_code, name FROM airlines ORDER BY id LIMIT 10");
    $airlines = $stmt->fetchAll();
    foreach ($airlines as $airline) {
        echo "- " . $airline['iata_code'] . " (ID: " . $airline['id'] . "): " . $airline['name'] . "\n";
    }
    
    // Créer des vols simples
    echo "\n🔍 Création de vols...\n";
    
    // Vols Montréal → Toronto
    $stmt = $pdo->prepare("
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
            dep.city = 'Montréal' AND arr.city = 'Toronto'
            AND a.iata_code IN ('AC', 'WS', 'PD')
    ");
    
    $result = $stmt->execute();
    echo "✅ Vols Montréal → Toronto créés\n";
    
    // Vols Toronto → Vancouver
    $stmt = $pdo->prepare("
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
            dep.city = 'Toronto' AND arr.city = 'Vancouver'
            AND a.iata_code IN ('AC', 'WS')
    ");
    
    $result = $stmt->execute();
    echo "✅ Vols Toronto → Vancouver créés\n";
    
    // Vols Ottawa → Toronto
    $stmt = $pdo->prepare("
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
            dep.city = 'Ottawa' AND arr.city = 'Toronto'
            AND a.iata_code IN ('AC', 'WS', 'PD')
    ");
    
    $result = $stmt->execute();
    echo "✅ Vols Ottawa → Toronto créés\n";
    
    // Vols Calgary → Toronto
    $stmt = $pdo->prepare("
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
            dep.city = 'Calgary' AND arr.city = 'Toronto'
            AND a.iata_code IN ('AC', 'WS')
    ");
    
    $result = $stmt->execute();
    echo "✅ Vols Calgary → Toronto créés\n";
    
    // Vols Edmonton → Vancouver
    $stmt = $pdo->prepare("
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
            dep.city = 'Edmonton' AND arr.city = 'Vancouver'
            AND a.iata_code IN ('AC', 'WS', 'PD')
    ");
    
    $result = $stmt->execute();
    echo "✅ Vols Edmonton → Vancouver créés\n";
    
    // Statistiques finales
    echo "\n=== STATISTIQUES FINALES ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM flights WHERE departure_time >= '2025-09-03' AND departure_time <= '2026-09-10'");
    $result = $stmt->fetch();
    echo "Total de vols créés: " . $result['count'] . "\n";
    
    $stmt = $pdo->query("
        SELECT 
            CONCAT(dep.city, ' → ', arr.city) as route,
            COUNT(*) as total_flights
        FROM flights f
        JOIN airports dep ON f.departure_airport_id = dep.id
        JOIN airports arr ON f.arrival_airport_id = arr.id
        WHERE f.departure_time >= '2025-09-03' AND f.departure_time <= '2026-09-10'
        GROUP BY dep.city, arr.city
        ORDER BY total_flights DESC
    ");
    $routes = $stmt->fetchAll();
    echo "\nVols par route:\n";
    foreach ($routes as $route) {
        echo "- " . $route['route'] . ": " . $route['total_flights'] . " vols\n";
    }
    
    echo "\n🎉 CRÉATION DE VOLS TERMINÉE !\n";
    
} catch (PDOException $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
}
?>
