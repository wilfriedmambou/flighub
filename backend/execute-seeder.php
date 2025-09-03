<?php
// Script pour exécuter le seeder de test de vols
echo "=== EXÉCUTION DU SEEDER DE TEST DE VOLS ===\n";

// Configuration RDS
$host = 'flighthub-prod-2025.cgrc2wska579.us-east-1.rds.amazonaws.com';
$port = 5432;
$database = 'flighthub';
$username = 'flighthub_admin';
$password = 'flighthub-prod-2025';

try {
    // Connexion à la base de données
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ Connexion RDS réussie !\n\n";
    
    // Lire le script SQL
    $sqlFile = __DIR__ . '/Flights2025-2026-RealCodes.sql';
    if (!file_exists($sqlFile)) {
        echo "❌ Fichier SQL non trouvé: $sqlFile\n";
        exit(1);
    }
    
    $sql = file_get_contents($sqlFile);
    if (!$sql) {
        echo "❌ Impossible de lire le fichier SQL\n";
        exit(1);
    }
    
    echo "📄 Fichier SQL lu avec succès (" . strlen($sql) . " caractères)\n\n";
    
    // Diviser le script en requêtes individuelles
    $queries = array_filter(array_map('trim', explode(';', $sql)));
    
    echo "🔍 Exécution de " . count($queries) . " requêtes...\n\n";
    
    $successCount = 0;
    $errorCount = 0;
    
    foreach ($queries as $index => $query) {
        if (empty($query) || strpos($query, '--') === 0) {
            continue; // Ignorer les commentaires et lignes vides
        }
        
        try {
            echo "Requête " . ($index + 1) . ": ";
            
            if (stripos($query, 'SELECT') === 0) {
                // Requête SELECT - afficher les résultats
                $stmt = $pdo->query($query);
                $results = $stmt->fetchAll();
                
                if (count($results) > 0) {
                    echo "✅ " . count($results) . " résultats\n";
                    // Afficher les premiers résultats
                    foreach (array_slice($results, 0, 3) as $row) {
                        echo "   " . json_encode($row) . "\n";
                    }
                    if (count($results) > 3) {
                        echo "   ... et " . (count($results) - 3) . " autres\n";
                    }
                } else {
                    echo "✅ 0 résultats\n";
                }
            } else {
                // Requête INSERT/UPDATE/DELETE
                $affectedRows = $pdo->exec($query);
                echo "✅ Exécutée (affecté: $affectedRows lignes)\n";
            }
            
            $successCount++;
            
        } catch (PDOException $e) {
            echo "❌ Erreur: " . $e->getMessage() . "\n";
            $errorCount++;
        }
    }
    
    echo "\n=== RÉSUMÉ ===\n";
    echo "✅ Requêtes réussies: $successCount\n";
    echo "❌ Requêtes échouées: $errorCount\n";
    
    if ($errorCount === 0) {
        echo "\n🎉 TOUS LES SEEDERS EXÉCUTÉS AVEC SUCCÈS !\n";
    } else {
        echo "\n⚠️  Certaines requêtes ont échoué, mais le processus continue.\n";
    }
    
} catch (PDOException $e) {
    echo "❌ ERREUR DE CONNEXION:\n";
    echo "Message: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ ERREUR GÉNÉRALE:\n";
    echo "Message: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\n=== FIN DU SEEDER ===\n";
?>
