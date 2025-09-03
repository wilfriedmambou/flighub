<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

/**
 * @OA\Info(
 *     version="1.0.0",
 *     title="FlightHub API Documentation",
 *     description="API pour la recherche et la réservation de vols",
 *     @OA\Contact(
 *         email="support@flighthub.com",
 *         name="FlightHub Support"
 *     ),
 *     @OA\License(
 *         name="MIT",
 *         url="https://opensource.org/licenses/MIT"
 *     )
 * )
 * 
 * @OA\Server(
 *     url="http://localhost:8000/api",
 *     description="Serveur de développement local"
 * )
 * 
 * @OA\Schema(
 *     schema="PaginatedResponse",
 *     title="Réponse Paginée",
 *     description="Structure de réponse paginée",
 *     @OA\Property(property="current_page", type="integer", example=1, description="Page actuelle"),
 *     @OA\Property(property="data", type="array", @OA\Items(type="object"), description="Données de la page"),
 *     @OA\Property(property="first_page_url", type="string", example="http://localhost:8000/api/flights?page=1", description="URL de la première page"),
 *     @OA\Property(property="from", type="integer", example=1, description="Premier élément de la page"),
 *     @OA\Property(property="last_page", type="integer", example=5, description="Dernière page"),
 *     @OA\Property(property="last_page_url", type="string", example="http://localhost:8000/api/flights?page=5", description="URL de la dernière page"),
 *     @OA\Property(property="next_page_url", type="string", example="http://localhost:8000/api/flights?page=2", description="URL de la page suivante"),
 *     @OA\Property(property="path", type="string", example="http://localhost:8000/api/flights", description="URL de base"),
 *     @OA\Property(property="per_page", type="integer", example=10, description="Éléments par page"),
 *     @OA\Property(property="prev_page_url", type="string", example=null, description="URL de la page précédente"),
 *     @OA\Property(property="to", type="integer", example=10, description="Dernier élément de la page"),
 *     @OA\Property(property="total", type="integer", example=50, description="Nombre total d'éléments")
 * )
 * 
 * @OA\Tag(
 *     name="Airlines",
 *     description="Gestion des compagnies aériennes"
 * )
 * @OA\Tag(
 *     name="Airports",
 *     description="Gestion des aéroports"
 * )
 * @OA\Tag(
 *     name="Flights",
 *     description="Recherche et gestion des vols"
 * )
 * @OA\Tag(
 *     name="Trips",
 *     description="Gestion des voyages"
 * )
 */
class Controller extends BaseController
{
    use AuthorizesRequests, ValidatesRequests;
}
