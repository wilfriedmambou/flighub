<?php
// Vérification des vols dans la base de données
echo "=== VÉRIFICATION DES VOLS ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

// Compter les vols
$stmt = $pdo->query('SELECT COUNT(*) as count FROM flights');
$result = $stmt->fetch();
echo "Nombre total de vols: " . $result['count'] . "\n";

// Voir les premiers vols
$stmt = $pdo->query('SELECT * FROM flights ORDER BY id LIMIT 5');
$flights = $stmt->fetchAll();
echo "\nPremiers vols:\n";
foreach ($flights as $flight) {
    echo "ID: " . $flight['id'] . " - Vol: " . $flight['flight_number'] . " - Départ: " . $flight['departure_time'] . "\n";
}

// Voir les vols avec codes IATA
echo "\nVols avec codes IATA:\n";
$stmt = $pdo->query("
    SELECT 
        f.flight_number,
        dep.iata_code as departure_code,
        arr.iata_code as arrival_code,
        f.departure_time,
        f.price
    FROM flights f
    JOIN airports dep ON f.departure_airport_id = dep.id
    JOIN airports arr ON f.arrival_airport_id = arr.id
    ORDER BY f.departure_time
    LIMIT 10
");
$flightsWithCodes = $stmt->fetchAll();
foreach ($flightsWithCodes as $flight) {
    echo $flight['flight_number'] . " - " . $flight['departure_code'] . " → " . $flight['arrival_code'] . " - " . $flight['departure_time'] . " - $" . $flight['price'] . "\n";
}
?>
