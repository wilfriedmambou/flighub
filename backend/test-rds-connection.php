<?php
// Test de connexion RDS
echo "=== TEST CONNEXION RDS ===\n";

// Configuration RDS
$host = 'flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com';
$port = 5432;
$database = 'flighthub';
$username = 'flighthub_admin';
$password = 'flighthub-prod-2025';

echo "Host: $host\n";
echo "Port: $port\n";
echo "Database: $database\n";
echo "Username: $username\n";
echo "Password: " . str_repeat('*', strlen($password)) . "\n\n";

try {
    // Test de connexion PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    echo "DSN: $dsn\n\n";
    
    echo "Tentative de connexion...\n";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ CONNEXION RÉUSSIE !\n\n";
    
    // Test de requête simple
    echo "Test de requête simple...\n";
    $stmt = $pdo->query("SELECT version() as version");
    $result = $stmt->fetch();
    echo "Version PostgreSQL: " . $result['version'] . "\n\n";
    
    // Test des tables
    echo "Test des tables...\n";
    $stmt = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name");
    $tables = $stmt->fetchAll();
    
    echo "Tables disponibles:\n";
    foreach ($tables as $table) {
        echo "- " . $table['table_name'] . "\n";
    }
    
    // Test des aéroports
    echo "\nTest des aéroports...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM airports");
    $result = $stmt->fetch();
    echo "Nombre d'aéroports: " . $result['count'] . "\n";
    
    // Test des compagnies
    echo "Test des compagnies...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM airlines");
    $result = $stmt->fetch();
    echo "Nombre de compagnies: " . $result['count'] . "\n";
    
    // Test des vols
    echo "Test des vols...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM flights");
    $result = $stmt->fetch();
    echo "Nombre de vols: " . $result['count'] . "\n";
    
    echo "\n✅ TOUS LES TESTS RÉUSSIS !\n";
    
} catch (PDOException $e) {
    echo "❌ ERREUR DE CONNEXION:\n";
    echo "Code: " . $e->getCode() . "\n";
    echo "Message: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
} catch (Exception $e) {
    echo "❌ ERREUR GÉNÉRALE:\n";
    echo "Message: " . $e->getMessage() . "\n";
}

echo "\n=== FIN DU TEST ===\n";
?>
