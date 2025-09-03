<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Airport;

class AirportSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $airports = [
            [
                'name' => 'Montréal-Trudeau International Airport',
                'iata_code' => 'YUL',
                'city' => 'Montreal',
                'latitude' => 45.4706,
                'longitude' => -73.7408,
                'timezone' => 'America/Montreal',
                'city_code' => 'YMQ',
            ],
            [
                'name' => 'Vancouver International Airport',
                'iata_code' => 'YVR',
                'city' => 'Vancouver',
                'latitude' => 49.1967,
                'longitude' => -123.1815,
                'timezone' => 'America/Vancouver',
                'city_code' => 'YVR',
            ],
            [
                'name' => 'Toronto Pearson International Airport',
                'iata_code' => 'YYZ',
                'city' => 'Toronto',
                'latitude' => 43.6777,
                'longitude' => -79.6248,
                'timezone' => 'America/Toronto',
                'city_code' => 'YYZ',
            ],
            [
                'name' => 'Calgary International Airport',
                'iata_code' => 'YYC',
                'city' => 'Calgary',
                'latitude' => 51.1314,
                'longitude' => -114.0103,
                'timezone' => 'America/Edmonton',
                'city_code' => 'YYC',
            ],
            [
                'name' => 'Edmonton International Airport',
                'iata_code' => 'YEG',
                'city' => 'Edmonton',
                'latitude' => 53.3097,
                'longitude' => -113.5792,
                'timezone' => 'America/Edmonton',
                'city_code' => 'YEG',
            ],
            [
                'name' => 'Ottawa Macdonald-Cartier International Airport',
                'iata_code' => 'YOW',
                'city' => 'Ottawa',
                'latitude' => 45.3225,
                'longitude' => -75.6692,
                'timezone' => 'America/Toronto',
                'city_code' => 'YOW',
            ],
            [
                'name' => 'Halifax Stanfield International Airport',
                'iata_code' => 'YHZ',
                'city' => 'Halifax',
                'latitude' => 44.8808,
                'longitude' => -63.5086,
                'timezone' => 'America/Halifax',
                'city_code' => 'YHZ',
            ],
            [
                'name' => 'Winnipeg James Armstrong Richardson International Airport',
                'iata_code' => 'YWG',
                'city' => 'Winnipeg',
                'latitude' => 49.9100,
                'longitude' => -97.2399,
                'timezone' => 'America/Winnipeg',
                'city_code' => 'YWG',
            ],
        ];

        foreach ($airports as $airport) {
            Airport::create($airport);
        }
    }
}
