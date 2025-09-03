<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Flight;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

/**
 * @OA\Tag(
 *     name="Flights",
 *     description="Recherche et gestion des vols"
 * )
 */
class FlightController extends Controller
{
    /**
     * @OA\Get(
     *     path="/flights",
     *     operationId="getFlights",
     *     tags={"Flights"},
     *     summary="Récupérer la liste des vols",
     *     description="Retourne la liste des vols avec filtres et pagination",
     *     @OA\Parameter(
     *         name="departure_airport",
     *         in="query",
     *         description="Filtrer par aéroport de départ (code IATA)",
     *         required=false,
     *         @OA\Schema(type="string", maxLength=3)
     *     ),
     *     @OA\Parameter(
     *         name="arrival_airport",
     *         in="query",
     *         description="Filtrer par aéroport d'arrivée (code IATA)",
     *         required=false,
     *         @OA\Schema(type="string", maxLength=3)
     *     ),
     *     @OA\Parameter(
     *         name="date",
     *         in="query",
     *         description="Filtrer par date de départ",
     *         required=false,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="airline",
     *         in="query",
     *         description="Filtrer par compagnie aérienne (code IATA)",
     *         required=false,
     *         @OA\Schema(type="string", maxLength=3)
     *     ),
     *     @OA\Parameter(
     *         name="sort",
     *         in="query",
     *         description="Champ de tri",
     *         required=false,
     *         @OA\Schema(type="string", default="departure_time")
     *     ),
     *     @OA\Parameter(
     *         name="order",
     *         in="query",
     *         description="Ordre de tri",
     *         required=false,
     *         @OA\Schema(type="string", enum={"asc", "desc"}, default="asc")
     *     ),
     *     @OA\Parameter(
     *         name="limit",
     *         in="query",
     *         description="Nombre d'éléments par page",
     *         required=false,
     *         @OA\Schema(type="integer", default=10)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Liste des vols récupérée avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object", ref="#/components/schemas/PaginatedResponse"),
     *             @OA\Property(property="message", type="string", example="Flights retrieved successfully")
     *         )
     *     )
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $query = Flight::with(['airline', 'departureAirport', 'arrivalAirport']);

        // Filter by departure airport
        if ($request->has('departure_airport')) {
            $query->whereHas('departureAirport', function ($q) use ($request) {
                $q->where('iata_code', $request->departure_airport);
            });
        }

        // Filter by arrival airport
        if ($request->has('arrival_airport')) {
            $query->whereHas('arrivalAirport', function ($q) use ($request) {
                $q->where('iata_code', $request->arrival_airport);
            });
        }

        // Filter by date
        if ($request->has('date')) {
            $query->whereDate('departure_time', $request->date);
        }

        // Filter by airline
        if ($request->has('airline')) {
            $query->whereHas('airline', function ($q) use ($request) {
                $q->where('iata_code', $request->airline);
            });
        }

        // Sorting
        $sort = $request->get('sort', 'departure_time');
        $order = $request->get('order', 'asc');
        $query->orderBy($sort, $order);

        // Pagination
        $perPage = $request->get('limit', 10);
        $flights = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $flights,
            'message' => 'Flights retrieved successfully'
        ]);
    }

    /**
     * @OA\Get(
     *     path="/flights/{flight}",
     *     operationId="getFlight",
     *     tags={"Flights"},
     *     summary="Récupérer un vol spécifique",
     *     description="Retourne les détails d'un vol par son ID",
     *     @OA\Parameter(
     *         name="flight",
     *         in="path",
     *         description="ID du vol",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Vol récupéré avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Flight"),
     *             @OA\Property(property="message", type="string", example="Flight retrieved successfully")
     *         )
     *     )
     * )
     */
    public function show(Flight $flight): JsonResponse
    {
        $flight->load(['airline', 'departureAirport', 'arrivalAirport']);

        return response()->json([
            'success' => true,
            'data' => $flight,
            'message' => 'Flight retrieved successfully'
        ]);
    }

    /**
     * @OA\Get(
     *     path="/flights/search",
     *     operationId="searchFlights",
     *     tags={"Flights"},
     *     summary="Rechercher des vols",
     *     description="Recherche avancée de vols avec validation et pagination",
     *     @OA\Parameter(
     *         name="departure_airport",
     *         in="query",
     *         description="Aéroport de départ (code IATA)",
     *         required=true,
     *         @OA\Schema(type="string", maxLength=3)
     *     ),
     *     @OA\Parameter(
     *         name="arrival_airport",
     *         in="query",
     *         description="Aéroport d'arrivée (code IATA)",
     *         required=true,
     *         @OA\Schema(type="string", maxLength=3)
     *     ),
     *     @OA\Parameter(
     *         name="date",
     *         in="query",
     *         description="Date de départ",
     *         required=true,
     *         @OA\Schema(type="string", format="date")
     *     ),
     *     @OA\Parameter(
     *         name="airline",
     *         in="query",
     *         description="Compagnie aérienne (code IATA)",
     *         required=false,
     *         @OA\Schema(type="string", maxLength=3)
     *     ),
     *     @OA\Parameter(
     *         name="sort",
     *         in="query",
     *         description="Champ de tri",
     *         required=false,
     *         @OA\Schema(type="string", default="departure_time")
     *     ),
     *     @OA\Parameter(
     *         name="order",
     *         in="query",
     *         description="Ordre de tri",
     *         required=false,
     *         @OA\Schema(type="string", enum={"asc", "desc"}, default="asc")
     *     ),
     *     @OA\Parameter(
     *         name="page",
     *         in="query",
     *         description="Numéro de page",
     *         required=false,
     *         @OA\Schema(type="integer", default=1)
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         description="Nombre d'éléments par page",
     *         required=false,
     *         @OA\Schema(type="integer", default=10)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Vols trouvés avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object", ref="#/components/schemas/PaginatedResponse"),
     *             @OA\Property(property="message", type="string", example="Flights found successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Données de validation invalides",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validation failed"),
     *             @OA\Property(property="errors", type="object")
     *         )
     *     )
     * )
     */
    public function search(Request $request): JsonResponse
    {
        $request->validate([
            'departure_airport' => 'required|string|max:3',
            'arrival_airport' => 'required|string|max:3',
            'date' => 'required|date|after:today',
            'airline' => 'nullable|string|max:3',
            'sort' => 'nullable|string|in:departure_time,arrival_time,price,flight_number',
            'order' => 'nullable|string|in:asc,desc',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        $query = Flight::with(['airline', 'departureAirport', 'arrivalAirport'])
            ->whereHas('departureAirport', function ($q) use ($request) {
                $q->where('iata_code', $request->departure_airport);
            })
            ->whereHas('arrivalAirport', function ($q) use ($request) {
                $q->where('iata_code', $request->arrival_airport);
            })
            ->whereDate('departure_time', $request->date);

        if ($request->has('airline')) {
            $query->whereHas('airline', function ($q) use ($request) {
                $q->where('iata_code', $request->airline);
            });
        }

        // Tri
        $sort = $request->get('sort', 'departure_time');
        $order = $request->get('order', 'asc');
        $query->orderBy($sort, $order);

        // Pagination
        $perPage = $request->get('per_page', 10);
        $flights = $query->paginate($perPage);

        $response = response()->json([
            'success' => true,
            'data' => $flights,
            'message' => 'Flights found successfully'
        ]);

        // Add CORS headers
        $response->headers->set('Access-Control-Allow-Origin', '*');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');

        return $response;
    }
}
