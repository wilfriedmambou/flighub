<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Flight;
use App\Models\Airline;
use App\Models\Airport;
use Carbon\Carbon;

class ExtendedFlightSeeder extends Seeder
{
    public function run()
    {
        $airlines = Airline::all();
        $airports = Airport::all();

        // Dates de test (du 1er septembre 2025 au 31 décembre 2025)
        $startDate = Carbon::create(2025, 9, 1);
        $endDate = Carbon::create(2025, 12, 31);
        $testDates = [];
        
        // Générer des dates de test (tous les 2-3 jours pour éviter trop de données)
        $currentDate = $startDate->copy();
        while ($currentDate <= $endDate) {
            $testDates[] = $currentDate->copy();
            $currentDate->addDays(rand(2, 4)); // Intervalle aléatoire entre 2 et 4 jours
        }

        // Routes populaires avec plus de vols
        $routes = [
            ['YUL', 'YYZ'], // Montréal → Toronto
            ['YYZ', 'YUL'], // Toronto → Montréal
            ['YUL', 'YVR'], // Montréal → Vancouver
            ['YVR', 'YUL'], // Vancouver → Montréal
            ['YYZ', 'YVR'], // Toronto → Vancouver
            ['YVR', 'YYZ'], // Vancouver → Toronto
            ['YUL', 'YYC'], // Montréal → Calgary
            ['YYC', 'YUL'], // Calgary → Montréal
            ['YYZ', 'YYC'], // Toronto → Calgary
            ['YYC', 'YYZ'], // Calgary → Toronto
            ['YUL', 'YOW'], // Montréal → Ottawa
            ['YOW', 'YUL'], // Ottawa → Montréal
            ['YYZ', 'YOW'], // Toronto → Ottawa
            ['YOW', 'YYZ'], // Ottawa → Toronto
        ];

        // Horaires diversifiés (6h00 à 23h00)
        $departureTimes = [
            '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
            '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
            '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
            '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30',
            '22:00', '22:30', '23:00'
        ];

        // Durées de vol par route (en minutes)
        $flightDurations = [
            'YUL-YYZ' => 75,   // Montréal → Toronto
            'YYZ-YUL' => 75,   // Toronto → Montréal
            'YUL-YVR' => 330,  // Montréal → Vancouver
            'YVR-YUL' => 330,  // Vancouver → Montréal
            'YYZ-YVR' => 270,  // Toronto → Vancouver
            'YVR-YYZ' => 270,  // Vancouver → Toronto
            'YUL-YYC' => 240,  // Montréal → Calgary
            'YYC-YUL' => 240,  // Calgary → Montréal
            'YYZ-YYC' => 210,  // Toronto → Calgary
            'YYC-YYZ' => 210,  // Calgary → Toronto
            'YUL-YOW' => 45,   // Montréal → Ottawa
            'YOW-YUL' => 45,   // Ottawa → Montréal
            'YYZ-YOW' => 60,   // Toronto → Ottawa
            'YOW-YYZ' => 60,   // Ottawa → Toronto
        ];

        // Prix de base par route (en euros)
        $basePrices = [
            'YUL-YYZ' => 120,
            'YYZ-YUL' => 120,
            'YUL-YVR' => 380,
            'YVR-YUL' => 380,
            'YYZ-YVR' => 320,
            'YVR-YYZ' => 320,
            'YUL-YYC' => 280,
            'YYC-YUL' => 280,
            'YYZ-YYC' => 250,
            'YYC-YYZ' => 250,
            'YUL-YOW' => 80,
            'YOW-YUL' => 80,
            'YYZ-YOW' => 100,
            'YOW-YYZ' => 100,
        ];

        $flightNumber = 1000;

        foreach ($routes as $route) {
            $departureAirport = $airports->where('iata_code', $route[0])->first();
            $arrivalAirport = $airports->where('iata_code', $route[1])->first();
            
            if (!$departureAirport || !$arrivalAirport) continue;

            $routeKey = $route[0] . '-' . $route[1];
            $duration = $flightDurations[$routeKey] ?? 120;
            $basePrice = $basePrices[$routeKey] ?? 200;

            // Créer des vols sur différentes dates
            foreach ($testDates as $testDate) {
                // Créer plusieurs vols par route avec des horaires différents
                foreach ($departureTimes as $departureTime) {
                // Calculer l'heure d'arrivée
                $departureDateTime = Carbon::createFromFormat('H:i', $departureTime);
                $arrivalDateTime = $departureDateTime->copy()->addMinutes($duration);
                
                // Ajuster pour les vols qui passent minuit
                if ($arrivalDateTime->hour < $departureDateTime->hour) {
                    $arrivalDateTime->addDay();
                }

                // Créer 3 vols par horaire (matin, après-midi, soir)
                $timeSlots = ['morning', 'afternoon', 'evening'];
                
                foreach ($timeSlots as $slot) {
                    // Ajuster l'heure selon le créneau
                    $adjustedDepartureTime = $this->adjustTimeForSlot($departureTime, $slot);
                    $adjustedDepartureDateTime = Carbon::createFromFormat('H:i', $adjustedDepartureTime);
                    
                    // Combiner la date de test avec l'heure ajustée
                    $departureDateTime = $testDate->copy()->setTimeFrom($adjustedDepartureDateTime);
                    $arrivalDateTime = $departureDateTime->copy()->addMinutes($duration);
                    
                    // Ajuster pour les vols qui passent minuit
                    if ($arrivalDateTime->hour < $departureDateTime->hour) {
                        $arrivalDateTime->addDay();
                    }

                    // Prix variable selon l'heure et la saison
                    $timeMultiplier = $this->getPriceMultiplier($slot);
                    $seasonalMultiplier = $this->getSeasonalPriceMultiplier($testDate);
                    $price = round($basePrice * $timeMultiplier * $seasonalMultiplier);

                    // Compagnie aléatoire
                    $airline = $airlines->random();

                    Flight::create([
                        'flight_number' => $airline->iata_code . $flightNumber,
                        'airline_id' => $airline->id,
                        'departure_airport_id' => $departureAirport->id,
                        'arrival_airport_id' => $arrivalAirport->id,
                        'departure_time' => $departureDateTime->format('Y-m-d H:i:s'),
                        'arrival_time' => $arrivalDateTime->format('Y-m-d H:i:s'),
                        'price' => $price,
                    ]);

                    $flightNumber++;
                }
            }
        }
    }

        $this->command->info('Extended flights seeded successfully!');
    }

    private function adjustTimeForSlot($baseTime, $slot)
    {
        $time = Carbon::createFromFormat('H:i', $baseTime);
        
        switch ($slot) {
            case 'morning':
                return $time->copy()->subHours(rand(1, 2))->format('H:i');
            case 'afternoon':
                return $time->copy()->addHours(rand(0, 1))->format('H:i');
            case 'evening':
                return $time->copy()->addHours(rand(2, 3))->format('H:i');
            default:
                return $baseTime;
        }
    }

    private function getPriceMultiplier($slot)
    {
        switch ($slot) {
            case 'morning':
                return 1.2; // 20% plus cher (vols d'affaires)
            case 'afternoon':
                return 1.0; // Prix normal
            case 'evening':
                return 1.15; // 15% plus cher (vols de fin de journée)
            default:
                return 1.0;
        }
    }

    private function getSeasonalPriceMultiplier($date)
    {
        $month = $date->month;
        
        // Haute saison (été et vacances)
        if (in_array($month, [6, 7, 8, 12])) {
            return 1.3; // 30% plus cher
        }
        // Saison moyenne (printemps et automne)
        elseif (in_array($month, [4, 5, 9, 10])) {
            return 1.1; // 10% plus cher
        }
        // Basse saison (hiver hors vacances)
        else {
            return 0.9; // 10% moins cher
        }
    }
}
