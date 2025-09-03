<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Airline;

class AirlineSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $airlines = [
            [
                'name' => 'Air Canada',
                'iata_code' => 'AC',
            ],
            [
                'name' => 'WestJet',
                'iata_code' => 'WS',
            ],
            [
                'name' => 'Air Transat',
                'iata_code' => 'TS',
            ],
            [
                'name' => 'Porter Airlines',
                'iata_code' => 'PD',
            ],
            [
                'name' => 'Sunwing Airlines',
                'iata_code' => 'WG',
            ],
            [
                'name' => 'Flair Airlines',
                'iata_code' => 'F8',
            ],
            [
                'name' => 'Lynx Air',
                'iata_code' => 'Y9',
            ],
        ];

        foreach ($airlines as $airline) {
            Airline::create($airline);
        }
    }
}
