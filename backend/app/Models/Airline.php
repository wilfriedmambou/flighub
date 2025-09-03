<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="Airline",
 *     title="Compagnie Aérienne",
 *     description="Modèle représentant une compagnie aérienne",
 *     @OA\Property(property="id", type="integer", example=1, description="ID unique de la compagnie"),
 *     @OA\Property(property="name", type="string", example="Air Canada", description="Nom de la compagnie"),
 *     @OA\Property(property="iata_code", type="string", example="AC", description="Code IATA de la compagnie"),
 *     @OA\Property(property="created_at", type="string", format="date-time", description="Date de création"),
 *     @OA\Property(property="updated_at", type="string", format="date-time", description="Date de mise à jour")
 * )
 */
class Airline extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'iata_code',
    ];

    /**
     * Get the flights for the airline.
     */
    public function flights()
    {
        return $this->hasMany(Flight::class);
    }
}
