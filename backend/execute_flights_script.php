<?php

require_once 'vendor/autoload.php';

use Illuminate\Support\Facades\DB;

// Charger la configuration Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

try {
    echo "🔄 Exécution du script de génération de vols...\n";
    
    // Lire le fichier SQL
    $sqlFile = 'database/seeders/Flights2025-2026.sql';
    $sql = file_get_contents($sqlFile);
    
    if (!$sql) {
        throw new Exception("Impossible de lire le fichier SQL: $sqlFile");
    }
    
    // Diviser le script en requêtes individuelles
    $queries = array_filter(array_map('trim', explode(';', $sql)));
    
    $totalQueries = count($queries);
    $executedQueries = 0;
    
    echo "📊 Nombre de requêtes à exécuter: $totalQueries\n";
    
    foreach ($queries as $index => $query) {
        if (empty($query) || strpos($query, '--') === 0) {
            continue; // Ignorer les commentaires et lignes vides
        }
        
        try {
            echo "⚡ Exécution de la requête " . ($index + 1) . "/$totalQueries...\n";
            
            if (stripos($query, 'INSERT INTO flights') !== false) {
                // Pour les INSERT, on peut afficher plus d'infos
                echo "   📝 Insertion de vols...\n";
            }
            
            DB::statement($query);
            $executedQueries++;
            
        } catch (Exception $e) {
            echo "❌ Erreur lors de l'exécution de la requête " . ($index + 1) . ":\n";
            echo "   " . $e->getMessage() . "\n";
            echo "   Requête: " . substr($query, 0, 100) . "...\n";
        }
    }
    
    echo "\n✅ Script terminé!\n";
    echo "📊 Requêtes exécutées: $executedQueries/$totalQueries\n";
    
    // Vérifier le nombre de vols créés
    $flightCount = DB::table('flights')->count();
    echo "✈️ Nombre total de vols dans la base: $flightCount\n";
    
    // Statistiques par aéroport
    $airportStats = DB::table('flights')
        ->join('airports as dep', 'flights.departure_airport_id', '=', 'dep.id')
        ->join('airports as arr', 'flights.arrival_airport_id', '=', 'arr.id')
        ->select(
            'dep.iata_code as departure',
            'arr.iata_code as arrival',
            DB::raw('COUNT(*) as flight_count')
        )
        ->groupBy('dep.iata_code', 'arr.iata_code')
        ->orderBy('flight_count', 'desc')
        ->get();
    
    echo "\n📈 Top 10 des routes les plus fréquentées:\n";
    foreach ($airportStats->take(10) as $stat) {
        echo "   {$stat->departure} → {$stat->arrival}: {$stat->flight_count} vols\n";
    }
    
} catch (Exception $e) {
    echo "❌ Erreur fatale: " . $e->getMessage() . "\n";
    exit(1);
}
