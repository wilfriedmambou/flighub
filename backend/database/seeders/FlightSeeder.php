<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Flight;
use App\Models\Airline;
use App\Models\Airport;
use Carbon\Carbon;

class FlightSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $airlines = Airline::all();
        $airports = Airport::all();

        // Create sample flights for the next 30 days
        for ($i = 0; $i < 100; $i++) {
            $departureAirport = $airports->random();
            $arrivalAirport = $airports->where('id', '!=', $departureAirport->id)->random();
            $airline = $airlines->random();
            
            // Random departure time in the next 30 days
            $departureTime = Carbon::now()->addDays(rand(1, 30))->addHours(rand(6, 22));
            $flightDuration = rand(1, 6); // 1-6 hours
            $arrivalTime = $departureTime->copy()->addHours($flightDuration);
            
            // Random price between $100 and $800
            $price = rand(100, 800);

            Flight::create([
                'flight_number' => $airline->iata_code . rand(100, 9999),
                'airline_id' => $airline->id,
                'departure_airport_id' => $departureAirport->id,
                'arrival_airport_id' => $arrivalAirport->id,
                'price' => $price,
                'departure_time' => $departureTime,
                'arrival_time' => $arrivalTime,
            ]);
        }

        // Create some specific popular routes with multiple flights
        $popularRoutes = [
            ['YUL', 'YVR'], // Montreal to Vancouver
            ['YYZ', 'YVR'], // Toronto to Vancouver
            ['YUL', 'YYZ'], // Montreal to Toronto
            ['YYC', 'YVR'], // Calgary to Vancouver
            ['YOW', 'YYZ'], // Ottawa to Toronto
        ];

        foreach ($popularRoutes as $route) {
            $departureAirport = Airport::where('iata_code', $route[0])->first();
            $arrivalAirport = Airport::where('iata_code', $route[1])->first();
            
            if ($departureAirport && $arrivalAirport) {
                // Create 3 flights per day for popular routes
                for ($day = 1; $day <= 30; $day++) {
                    for ($time = 0; $time < 3; $time++) {
                        $departureTime = Carbon::now()->addDays($day)->addHours(8 + ($time * 4));
                        $flightDuration = rand(3, 5);
                        $arrivalTime = $departureTime->copy()->addHours($flightDuration);
                        
                        $airline = $airlines->random();
                        $price = rand(150, 600);

                        Flight::create([
                            'flight_number' => $airline->iata_code . rand(100, 9999),
                            'airline_id' => $airline->id,
                            'departure_airport_id' => $departureAirport->id,
                            'arrival_airport_id' => $arrivalAirport->id,
                            'price' => $price,
                            'departure_time' => $departureTime,
                            'arrival_time' => $arrivalTime,
                        ]);
                    }
                }
            }
        }
    }
}
