<?php
// Vérification des aéroports canadiens
echo "=== VÉRIFICATION DES AÉROPORTS CANADIENS ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

// Chercher les aéroports canadiens
$canadianCodes = ['YUL', 'YVR', 'YYZ', 'YYC', 'YEG', 'YOW', 'YHZ', 'YWG'];
$placeholders = str_repeat('?,', count($canadianCodes) - 1) . '?';

$stmt = $pdo->prepare("SELECT id, iata_code, name, city FROM airports WHERE iata_code IN ($placeholders) ORDER BY iata_code");
$stmt->execute($canadianCodes);
$canadianAirports = $stmt->fetchAll();

echo "Aéroports canadiens trouvés:\n";
foreach ($canadianAirports as $airport) {
    echo $airport['iata_code'] . ' - ' . $airport['city'] . ' (ID: ' . $airport['id'] . ")\n";
}

if (empty($canadianAirports)) {
    echo "\n❌ Aucun aéroport canadien trouvé !\n";
    echo "Aéroports disponibles (premiers 20):\n";
    $stmt = $pdo->query('SELECT iata_code, city FROM airports ORDER BY iata_code LIMIT 20');
    $allAirports = $stmt->fetchAll();
    foreach ($allAirports as $airport) {
        echo $airport['iata_code'] . ' - ' . $airport['city'] . "\n";
    }
} else {
    echo "\n✅ " . count($canadianAirports) . " aéroports canadiens trouvés !\n";
}
?>
