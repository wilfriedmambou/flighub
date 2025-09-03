<?php
// Script pour ajouter des vols SSR -> TAO et SSR -> XQE en janvier 2026
echo "=== AJOUT DE VOLS JANVIER 2026 ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

try {
    echo "✅ Connexion RDS réussie !\n\n";
    
    // 1. Vérifier les aéroports existants
    echo "1. Vérification des aéroports:\n";
    
    $stmt = $pdo->prepare("SELECT id, iata_code, name, city FROM airports WHERE iata_code IN ('SSR', 'TAO', 'XQE')");
    $stmt->execute();
    $airports = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $airport_map = [];
    foreach ($airports as $airport) {
        $airport_map[$airport['iata_code']] = $airport;
        echo "- " . $airport['iata_code'] . ": " . $airport['name'] . " (" . $airport['city'] . ") - ID: " . $airport['id'] . "\n";
    }
    
    // 2. Créer TAO si nécessaire
    if (!isset($airport_map['TAO'])) {
        echo "\n2. Création de l'aéroport TAO:\n";
        $stmt = $pdo->prepare("
            INSERT INTO airports (iata_code, name, city, country, timezone) 
            VALUES ('TAO', 'Qingdao Liuting International Airport', 'Qingdao', 'China', 'Asia/Shanghai')
        ");
        $stmt->execute();
        $tao_id = $pdo->lastInsertId();
        echo "✅ TAO créé avec l'ID: " . $tao_id . "\n";
        $airport_map['TAO'] = ['id' => $tao_id, 'iata_code' => 'TAO', 'name' => 'Qingdao Liuting International Airport', 'city' => 'Qingdao'];
    }
    
    // 3. Créer XQE si nécessaire
    if (!isset($airport_map['XQE'])) {
        echo "\n3. Création de l'aéroport XQE:\n";
        $stmt = $pdo->prepare("
            INSERT INTO airports (iata_code, name, city, country, timezone) 
            VALUES ('XQE', 'Quebec City Jean Lesage International Airport', 'Quebec City', 'Canada', 'America/Toronto')
        ");
        $stmt->execute();
        $xqe_id = $pdo->lastInsertId();
        echo "✅ XQE créé avec l'ID: " . $xqe_id . "\n";
        $airport_map['XQE'] = ['id' => $xqe_id, 'iata_code' => 'XQE', 'name' => 'Quebec City Jean Lesage International Airport', 'city' => 'Quebec City'];
    }
    
    // 4. Récupérer une compagnie aérienne
    $stmt = $pdo->query("SELECT id FROM airlines WHERE iata_code = 'AC' LIMIT 1");
    $airline = $stmt->fetch();
    $airline_id = $airline ? $airline['id'] : 1;
    echo "\n4. Utilisation de la compagnie aérienne ID: " . $airline_id . "\n";
    
    // 5. Ajouter des vols SSR -> TAO pour janvier 2026
    echo "\n5. Ajout des vols SSR -> TAO (janvier 2026):\n";
    $ssr_id = $airport_map['SSR']['id'];
    $tao_id = $airport_map['TAO']['id'];
    
    $january_dates = [
        '2026-01-05', '2026-01-07', '2026-01-09', '2026-01-12', '2026-01-14', 
        '2026-01-16', '2026-01-19', '2026-01-21', '2026-01-23', '2026-01-26', 
        '2026-01-28', '2026-01-30'
    ];
    
    $flight_times = ['08:00', '12:00', '16:00', '20:00'];
    $flight_counter = 1;
    
    foreach ($january_dates as $date) {
        foreach ($flight_times as $time) {
            $departure_time = $date . ' ' . $time . ':00';
            $arrival_time = $date . ' ' . (intval(substr($time, 0, 2)) + 14) . ':' . substr($time, 3) . ':00';
            if (intval(substr($arrival_time, 11, 2)) >= 24) {
                $next_day = date('Y-m-d', strtotime($date . ' +1 day'));
                $arrival_hour = intval(substr($arrival_time, 11, 2)) - 24;
                $arrival_time = $next_day . ' ' . sprintf('%02d', $arrival_hour) . ':' . substr($time, 3) . ':00';
            }
            
            $flight_number = 'AC' . (2000 + $flight_counter);
            $price = rand(450, 850);
            
            $stmt = $pdo->prepare("
                INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, price)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([$flight_number, $airline_id, $ssr_id, $tao_id, $departure_time, $arrival_time, $price]);
            
            echo "- " . $flight_number . " | SSR -> TAO | " . $departure_time . " | $" . $price . "\n";
            $flight_counter++;
        }
    }
    
    // 6. Ajouter des vols SSR -> XQE pour janvier 2026
    echo "\n6. Ajout des vols SSR -> XQE (janvier 2026):\n";
    $xqe_id = $airport_map['XQE']['id'];
    
    foreach ($january_dates as $date) {
        foreach ($flight_times as $time) {
            $departure_time = $date . ' ' . $time . ':00';
            $arrival_time = $date . ' ' . (intval(substr($time, 0, 2)) + 2) . ':' . substr($time, 3) . ':00';
            
            $flight_number = 'AC' . (3000 + $flight_counter);
            $price = rand(180, 320);
            
            $stmt = $pdo->prepare("
                INSERT INTO flights (flight_number, airline_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, price)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([$flight_number, $airline_id, $ssr_id, $xqe_id, $departure_time, $arrival_time, $price]);
            
            echo "- " . $flight_number . " | SSR -> XQE | " . $departure_time . " | $" . $price . "\n";
            $flight_counter++;
        }
    }
    
    echo "\n✅ " . ($flight_counter - 1) . " vols ajoutés avec succès !\n";
    
    // 7. Vérification des vols ajoutés
    echo "\n7. Vérification des nouveaux vols:\n";
    
    echo "\nVols SSR -> TAO en janvier 2026:\n";
    $stmt = $pdo->query("
        SELECT f.flight_number, f.departure_time, f.price
        FROM flights f
        JOIN airports dep ON f.departure_airport_id = dep.id
        JOIN airports arr ON f.arrival_airport_id = arr.id
        WHERE dep.iata_code = 'SSR' AND arr.iata_code = 'TAO'
        AND f.departure_time >= '2026-01-01' AND f.departure_time < '2026-02-01'
        ORDER BY f.departure_time
        LIMIT 10
    ");
    $flights = $stmt->fetchAll();
    foreach ($flights as $flight) {
        echo "- " . $flight['flight_number'] . " | " . $flight['departure_time'] . " | $" . $flight['price'] . "\n";
    }
    
    echo "\nVols SSR -> XQE en janvier 2026:\n";
    $stmt = $pdo->query("
        SELECT f.flight_number, f.departure_time, f.price
        FROM flights f
        JOIN airports dep ON f.departure_airport_id = dep.id
        JOIN airports arr ON f.arrival_airport_id = arr.id
        WHERE dep.iata_code = 'SSR' AND arr.iata_code = 'TAO'
        AND f.departure_time >= '2026-01-01' AND f.departure_time < '2026-02-01'
        ORDER BY f.departure_time
        LIMIT 10
    ");
    $flights = $stmt->fetchAll();
    foreach ($flights as $flight) {
        echo "- " . $flight['flight_number'] . " | " . $flight['departure_time'] . " | $" . $flight['price'] . "\n";
    }
    
} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
}
?>
