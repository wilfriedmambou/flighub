<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Airport;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

/**
 * @OA\Tag(
 *     name="Airports",
 *     description="Gestion des aéroports"
 * )
 */
class AirportController extends Controller
{
    /**
     * @OA\Get(
     *     path="/airports",
     *     operationId="getAirports",
     *     tags={"Airports"},
     *     summary="Récupérer la liste des aéroports",
     *     description="Retourne la liste des aéroports avec filtres optionnels",
     *     @OA\Parameter(
     *         name="city",
     *         in="query",
     *         description="Filtrer par ville",
     *         required=false,
     *         @OA\Schema(type="string")
     *     ),
     *     @OA\Parameter(
     *         name="city_code",
     *         in="query",
     *         description="Filtrer par code de ville",
     *         required=false,
     *         @OA\Schema(type="string")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Liste des aéroports récupérée avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Airport")),
     *             @OA\Property(property="message", type="string", example="Airports retrieved successfully")
     *         )
     *     )
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $query = Airport::query();

        // Filter by city
        if ($request->has('city')) {
            $query->where('city', 'like', '%' . $request->city . '%');
        }

        // Filter by city_code
        if ($request->has('city_code')) {
            $query->where('city_code', $request->city_code);
        }

        $airports = $query->get();

        $response = response()->json([
            'success' => true,
            'data' => $airports,
            'message' => 'Airports retrieved successfully'
        ]);

        // Add CORS headers
        $response->headers->set('Access-Control-Allow-Origin', '*');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');

        return $response;
    }

    /**
     * @OA\Get(
     *     path="/airports/{airport}",
     *     operationId="getAirport",
     *     tags={"Airports"},
     *     summary="Récupérer un aéroport spécifique",
     *     description="Retourne les détails d'un aéroport par son ID",
     *     @OA\Parameter(
     *         name="airport",
     *         in="path",
     *         description="ID de l'aéroport",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Aéroport récupéré avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Airport"),
     *             @OA\Property(property="message", type="string", example="Airport retrieved successfully")
     *         )
     *     )
     * )
     */
    public function show(Airport $airport): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $airport,
            'message' => 'Airport retrieved successfully'
        ]);
    }

    /**
     * @OA\Get(
     *     path="/airports/search",
     *     operationId="searchAirports",
     *     tags={"Airports"},
     *     summary="Rechercher des aéroports",
     *     description="Recherche des aéroports par nom, code IATA ou ville",
     *     @OA\Parameter(
     *         name="q",
     *         in="query",
     *         description="Terme de recherche",
     *         required=true,
     *         @OA\Schema(type="string")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Aéroports trouvés avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Airport")),
     *             @OA\Property(property="message", type="string", example="Airports found successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Requête invalide",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Search query is required")
     *         )
     *     )
     * )
     */
    public function search(Request $request): JsonResponse
    {
        $query = $request->get('q');
        
        if (!$query) {
            return response()->json([
                'success' => false,
                'message' => 'Search query is required'
            ], 400);
        }

        $airports = Airport::where('name', 'like', '%' . $query . '%')
            ->orWhere('iata_code', 'like', '%' . $query . '%')
            ->orWhere('city', 'like', '%' . $query . '%')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $airports,
            'message' => 'Airports found successfully'
        ]);
    }
}
