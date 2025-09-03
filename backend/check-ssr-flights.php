<?php
// Vérifier les vols YUL -> SSR et SSR vers d'autres destinations
echo "=== VOLS POUR TESTS MULTI-VILLES ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

// 1. Vérifier si SSR existe
echo "1. Vérification de l'aéroport SSR:\n";
$stmt = $pdo->prepare("SELECT * FROM airports WHERE iata_code = 'SSR'");
$stmt->execute();
$ssr = $stmt->fetch();
if ($ssr) {
    echo "✅ SSR trouvé: " . $ssr['name'] . " - " . $ssr['city'] . "\n";
} else {
    echo "❌ SSR non trouvé\n";
    echo "Aéroports commençant par 'S':\n";
    $stmt = $pdo->query("SELECT iata_code, name, city FROM airports WHERE iata_code LIKE 'S%' ORDER BY iata_code LIMIT 10");
    $airports = $stmt->fetchAll();
    foreach ($airports as $airport) {
        echo "- " . $airport['iata_code'] . ": " . $airport['name'] . " (" . $airport['city'] . ")\n";
    }
}

// 2. Vérifier YUL -> SSR
echo "\n2. Vols YUL -> SSR:\n";
$stmt = $pdo->query("
    SELECT 
        f.flight_number,
        dep.iata_code as departure,
        arr.iata_code as arrival,
        f.departure_time,
        f.arrival_time,
        f.price,
        DATE(f.departure_time) as flight_date
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE dep.iata_code = 'YUL' AND arr.iata_code = 'SSR'
    ORDER BY f.departure_time
    LIMIT 10
");
$yul_ssr_flights = $stmt->fetchAll();
if (empty($yul_ssr_flights)) {
    echo "❌ Aucun vol YUL -> SSR trouvé\n";
} else {
    foreach ($yul_ssr_flights as $flight) {
        echo "- " . $flight['flight_number'] . " | " . $flight['departure'] . " → " . $flight['arrival'] . " | " . $flight['flight_date'] . " | " . $flight['departure_time'] . " | $" . $flight['price'] . "\n";
    }
}

// 3. Vérifier SSR vers autres destinations
echo "\n3. Vols depuis SSR vers d'autres destinations:\n";
$stmt = $pdo->query("
    SELECT 
        f.flight_number,
        dep.iata_code as departure,
        arr.iata_code as arrival,
        arr.city as arrival_city,
        f.departure_time,
        f.arrival_time,
        f.price,
        DATE(f.departure_time) as flight_date
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE dep.iata_code = 'SSR'
    ORDER BY f.departure_time
    LIMIT 10
");
$ssr_outbound_flights = $stmt->fetchAll();
if (empty($ssr_outbound_flights)) {
    echo "❌ Aucun vol depuis SSR trouvé\n";
} else {
    foreach ($ssr_outbound_flights as $flight) {
        echo "- " . $flight['flight_number'] . " | " . $flight['departure'] . " → " . $flight['arrival'] . " (" . $flight['arrival_city'] . ") | " . $flight['flight_date'] . " | " . $flight['departure_time'] . " | $" . $flight['price'] . "\n";
    }
}

// 4. Suggérer des alternatives avec des codes proches
echo "\n4. Aéroports alternatifs (codes similaires ou destinations courantes):\n";
$stmt = $pdo->query("
    SELECT DISTINCT arr.iata_code, arr.city, arr.name
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE dep.iata_code = 'YUL'
    AND arr.iata_code IN ('YYZ', 'YVR', 'YYC', 'YOW', 'YHZ', 'LAX', 'JFK', 'CDG', 'LHR')
    ORDER BY arr.iata_code
");
$alternatives = $stmt->fetchAll();
foreach ($alternatives as $alt) {
    echo "- " . $alt['iata_code'] . ": " . $alt['name'] . " (" . $alt['city'] . ")\n";
}

// 5. Dates disponibles pour YUL vers destinations populaires
echo "\n5. Dates disponibles pour YUL vers destinations populaires:\n";
$stmt = $pdo->query("
    SELECT 
        arr.iata_code as destination,
        arr.city,
        COUNT(*) as flight_count,
        MIN(DATE(f.departure_time)) as earliest_date,
        MAX(DATE(f.departure_time)) as latest_date
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE dep.iata_code = 'YUL'
    GROUP BY arr.iata_code, arr.city
    HAVING COUNT(*) > 5
    ORDER BY flight_count DESC
    LIMIT 10
");
$destinations = $stmt->fetchAll();
foreach ($destinations as $dest) {
    echo "- YUL → " . $dest['destination'] . " (" . $dest['city'] . "): " . $dest['flight_count'] . " vols, du " . $dest['earliest_date'] . " au " . $dest['latest_date'] . "\n";
}
?>
