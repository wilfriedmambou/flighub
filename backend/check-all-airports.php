<?php
// Vérification complète des aéroports
echo "=== VÉRIFICATION COMPLÈTE DES AÉROPORTS ===\n";

$pdo = new PDO('pgsql:host=flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com;port=5432;dbname=flighthub', 'flighthub_admin', 'flighthub-prod-2025');

// Vérifier la structure de la table airports
echo "Structure de la table airports:\n";
$stmt = $pdo->query("SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'airports' ORDER BY ordinal_position");
$columns = $stmt->fetchAll();
foreach ($columns as $column) {
    echo "- " . $column['column_name'] . " (" . $column['data_type'] . ")\n";
}

// Vérifier les contraintes
echo "\nContraintes de la table airports:\n";
$stmt = $pdo->query("SELECT constraint_name, constraint_type FROM information_schema.table_constraints WHERE table_name = 'airports'");
$constraints = $stmt->fetchAll();
foreach ($constraints as $constraint) {
    echo "- " . $constraint['constraint_name'] . " (" . $constraint['constraint_type'] . ")\n";
}

// Vérifier tous les aéroports
echo "\nTous les aéroports (premiers 30):\n";
$stmt = $pdo->query('SELECT id, iata_code, name, city FROM airports ORDER BY iata_code LIMIT 30');
$allAirports = $stmt->fetchAll();
foreach ($allAirports as $airport) {
    echo $airport['iata_code'] . ' - ' . $airport['city'] . ' (ID: ' . $airport['id'] . ")\n";
}

// Compter le total
$stmt = $pdo->query('SELECT COUNT(*) as count FROM airports');
$result = $stmt->fetch();
echo "\nTotal d'aéroports: " . $result['count'] . "\n";
?>
