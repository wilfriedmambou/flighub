<?php
// Vérifier les vols depuis YUL
echo "=== VOLS DEPUIS YUL (MONTRÉAL) ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

echo "Vols depuis YUL (Montréal):\n";
$stmt = $pdo->query("
    SELECT 
        f.flight_number,
        dep.iata_code as departure,
        arr.iata_code as arrival,
        arr.city as arrival_city,
        f.departure_time,
        f.price
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE dep.iata_code = 'YUL'
    ORDER BY f.departure_time
    LIMIT 10
");
$flights = $stmt->fetchAll();
foreach ($flights as $flight) {
    echo $flight['flight_number'] . ' - ' . $flight['departure'] . ' → ' . $flight['arrival'] . ' (' . $flight['arrival_city'] . ') - ' . $flight['departure_time'] . ' - $' . $flight['price'] . "\n";
}

echo "\nVols vers Ottawa (tous codes):\n";
$stmt = $pdo->query("
    SELECT 
        f.flight_number,
        dep.iata_code as departure,
        dep.city as departure_city,
        arr.iata_code as arrival,
        arr.city as arrival_city,
        f.departure_time,
        f.price
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    WHERE arr.city = 'Ottawa'
    ORDER BY f.departure_time
    LIMIT 10
");
$flights = $stmt->fetchAll();
foreach ($flights as $flight) {
    echo $flight['flight_number'] . ' - ' . $flight['departure'] . ' (' . $flight['departure_city'] . ') → ' . $flight['arrival'] . ' (' . $flight['arrival_city'] . ') - ' . $flight['departure_time'] . ' - $' . $flight['price'] . "\n";
}
?>
