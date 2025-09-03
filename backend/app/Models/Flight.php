<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="Flight",
 *     title="Vol",
 *     description="Modèle représentant un vol",
 *     @OA\Property(property="id", type="integer", example=1, description="ID unique du vol"),
 *     @OA\Property(property="flight_number", type="string", example="AC123", description="Numéro de vol"),
 *     @OA\Property(property="airline_id", type="integer", example=1, description="ID de la compagnie aérienne"),
 *     @OA\Property(property="departure_airport_id", type="integer", example=1, description="ID de l'aéroport de départ"),
 *     @OA\Property(property="arrival_airport_id", type="integer", example=2, description="ID de l'aéroport d'arrivée"),
 *     @OA\Property(property="price", type="number", format="float", example=299.99, description="Prix du vol"),
 *     @OA\Property(property="departure_time", type="string", format="date-time", example="2024-01-15T10:30:00Z", description="Heure de départ"),
 *     @OA\Property(property="arrival_time", type="string", format="date-time", example="2024-01-15T12:45:00Z", description="Heure d'arrivée"),
 *     @OA\Property(property="airline", ref="#/components/schemas/Airline", description="Compagnie aérienne"),
 *     @OA\Property(property="departure_airport", ref="#/components/schemas/Airport", description="Aéroport de départ"),
 *     @OA\Property(property="arrival_airport", ref="#/components/schemas/Airport", description="Aéroport d'arrivée"),
 *     @OA\Property(property="created_at", type="string", format="date-time", description="Date de création"),
 *     @OA\Property(property="updated_at", type="string", format="date-time", description="Date de mise à jour")
 * )
 */
class Flight extends Model
{
    use HasFactory;

    protected $fillable = [
        'flight_number',
        'airline_id',
        'departure_airport_id',
        'arrival_airport_id',
        'price',
        'departure_time',
        'arrival_time',
    ];

    protected $casts = [
        'departure_time' => 'datetime',
        'arrival_time' => 'datetime',
        'price' => 'decimal:2',
    ];

    /**
     * Get the airline that operates the flight.
     */
    public function airline()
    {
        return $this->belongsTo(Airline::class);
    }

    /**
     * Get the departure airport.
     */
    public function departureAirport()
    {
        return $this->belongsTo(Airport::class, 'departure_airport_id');
    }

    /**
     * Get the arrival airport.
     */
    public function arrivalAirport()
    {
        return $this->belongsTo(Airport::class, 'arrival_airport_id');
    }

    /**
     * Get the trips that include this flight.
     */
    public function trips()
    {
        return $this->belongsToMany(Trip::class, 'flight_trip')->withPivot('order')->withTimestamps();
    }
}
