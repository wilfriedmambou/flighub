<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="Trip",
 *     title="Voyage",
 *     description="Modèle représentant un voyage",
 *     @OA\Property(property="id", type="integer", example=1, description="ID unique du voyage"),
 *     @OA\Property(property="trip_type", type="string", enum={"one-way", "round-trip", "multi-city"}, example="one-way", description="Type de voyage"),
 *     @OA\Property(property="total_price", type="number", format="float", example=599.98, description="Prix total du voyage"),
 *     @OA\Property(property="departure_date", type="string", format="date", example="2024-01-15", description="Date de départ"),
 *     @OA\Property(property="return_date", type="string", format="date", example="2024-01-20", description="Date de retour (optionnel)"),
 *     @OA\Property(property="flights", type="array", @OA\Items(ref="#/components/schemas/Flight"), description="Vols du voyage"),
 *     @OA\Property(property="created_at", type="string", format="date-time", description="Date de création"),
 *     @OA\Property(property="updated_at", type="string", format="date-time", description="Date de mise à jour")
 * )
 */
class Trip extends Model
{
    use HasFactory;

    protected $fillable = [
        'trip_type',
        'total_price',
        'departure_date',
        'return_date',
    ];

    protected $casts = [
        'departure_date' => 'date',
        'return_date' => 'date',
        'total_price' => 'decimal:2',
    ];

    /**
     * Get the flights for the trip.
     */
    public function flights()
    {
        return $this->belongsToMany(Flight::class, 'flight_trip')->withPivot('order')->withTimestamps()->orderBy('order');
    }

    /**
     * Calculate the total price of the trip.
     */
    public function calculateTotalPrice()
    {
        return $this->flights->sum('price');
    }

    /**
     * Check if the trip is valid (departure after creation, within 365 days).
     */
    public function isValid()
    {
        $now = now();
        $maxDate = $now->addDays(365);
        
        return $this->departure_date >= $now->toDateString() && 
               $this->departure_date <= $maxDate->toDateString();
    }
}
