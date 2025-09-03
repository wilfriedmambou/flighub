<?php
// Vérifier les vols ajoutés en janvier 2026
echo "=== VÉRIFICATION DES VOLS JANVIER 2026 ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

echo "Vols SSR -> TAO en janvier 2026:\n";
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
    WHERE dep.iata_code = 'SSR' AND arr.iata_code = 'XQE'
    AND f.departure_time >= '2026-01-01' AND f.departure_time < '2026-02-01'
    ORDER BY f.departure_time
    LIMIT 10
");
$flights = $stmt->fetchAll();
foreach ($flights as $flight) {
    echo "- " . $flight['flight_number'] . " | " . $flight['departure_time'] . " | $" . $flight['price'] . "\n";
}

echo "\nRésumé des vols ajoutés:\n";
$stmt = $pdo->query("
    SELECT 
        CONCAT(dep.iata_code, ' -> ', arr.iata_code) as route,
        COUNT(*) as flight_count,
        MIN(f.price) as min_price,
        MAX(f.price) as max_price,
        AVG(f.price)::numeric(10,2) as avg_price
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE dep.iata_code = 'SSR' AND arr.iata_code IN ('TAO', 'XQE')
    AND f.departure_time >= '2026-01-01' AND f.departure_time < '2026-02-01'
    GROUP BY dep.iata_code, arr.iata_code
");
$summary = $stmt->fetchAll();
foreach ($summary as $route) {
    echo "- " . $route['route'] . ": " . $route['flight_count'] . " vols, Prix: $" . $route['min_price'] . " - $" . $route['max_price'] . " (moy: $" . $route['avg_price'] . ")\n";
}
?>
