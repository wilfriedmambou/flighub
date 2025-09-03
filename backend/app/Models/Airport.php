<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="Airport",
 *     title="Aéroport",
 *     description="Modèle représentant un aéroport",
 *     @OA\Property(property="id", type="integer", example=1, description="ID unique de l'aéroport"),
 *     @OA\Property(property="name", type="string", example="Montréal-Trudeau International Airport", description="Nom de l'aéroport"),
 *     @OA\Property(property="iata_code", type="string", example="YUL", description="Code IATA de l'aéroport"),
 *     @OA\Property(property="city", type="string", example="Montréal", description="Ville de l'aéroport"),
 *     @OA\Property(property="latitude", type="number", format="float", example=45.4706, description="Latitude de l'aéroport"),
 *     @OA\Property(property="longitude", type="number", format="float", example=-73.7408, description="Longitude de l'aéroport"),
 *     @OA\Property(property="timezone", type="string", example="America/Montreal", description="Fuseau horaire de l'aéroport"),
 *     @OA\Property(property="city_code", type="string", example="YMQ", description="Code de la ville"),
 *     @OA\Property(property="created_at", type="string", format="date-time", description="Date de création"),
 *     @OA\Property(property="updated_at", type="string", format="date-time", description="Date de mise à jour")
 * )
 */
class Airport extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'iata_code',
        'city',
        'latitude',
        'longitude',
        'timezone',
        'city_code',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    /**
     * Get the flights departing from this airport.
     */
    public function departureFlights()
    {
        return $this->hasMany(Flight::class, 'departure_airport_id');
    }

    /**
     * Get the flights arriving at this airport.
     */
    public function arrivalFlights()
    {
        return $this->hasMany(Flight::class, 'arrival_airport_id');
    }
}
