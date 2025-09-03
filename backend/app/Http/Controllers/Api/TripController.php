<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trip;
use App\Models\Flight;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

/**
 * @OA\Tag(
 *     name="Trips",
 *     description="Gestion des voyages"
 * )
 */
class TripController extends Controller
{
    /**
     * @OA\Get(
     *     path="/trips",
     *     operationId="getTrips",
     *     tags={"Trips"},
     *     summary="Récupérer la liste des voyages",
     *     description="Retourne la liste des voyages avec tri et pagination",
     *     @OA\Parameter(
     *         name="sort",
     *         in="query",
     *         description="Champ de tri",
     *         required=false,
     *         @OA\Schema(type="string", default="created_at")
     *     ),
     *     @OA\Parameter(
     *         name="order",
     *         in="query",
     *         description="Ordre de tri",
     *         required=false,
     *         @OA\Schema(type="string", enum={"asc", "desc"}, default="desc")
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
     *         description="Liste des voyages récupérée avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object", ref="#/components/schemas/PaginatedResponse"),
     *             @OA\Property(property="message", type="string", example="Trips retrieved successfully")
     *         )
     *     )
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $query = Trip::with(['flights.airline', 'flights.departureAirport', 'flights.arrivalAirport']);

        // Sorting
        $sort = $request->get('sort', 'created_at');
        $order = $request->get('order', 'desc');
        $query->orderBy($sort, $order);

        // Pagination
        $perPage = $request->get('limit', 10);
        $trips = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $trips,
            'message' => 'Trips retrieved successfully'
        ]);
    }

    /**
     * @OA\Get(
     *     path="/trips/{trip}",
     *     operationId="getTrip",
     *     tags={"Trips"},
     *     summary="Récupérer un voyage spécifique",
     *     description="Retourne les détails d'un voyage par son ID",
     *     @OA\Parameter(
     *         name="trip",
     *         in="path",
     *         description="ID du voyage",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Voyage récupéré avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Trip"),
     *             @OA\Property(property="message", type="string", example="Trip retrieved successfully")
     *         )
     *     )
     * )
     */
    public function show(Trip $trip): JsonResponse
    {
        $trip->load(['flights.airline', 'flights.departureAirport', 'flights.arrivalAirport']);

        return response()->json([
            'success' => true,
            'data' => $trip,
            'message' => 'Trip retrieved successfully'
        ]);
    }

    /**
     * @OA\Post(
     *     path="/trips",
     *     operationId="createTrip",
     *     tags={"Trips"},
     *     summary="Créer un nouveau voyage",
     *     description="Crée un nouveau voyage avec les vols sélectionnés",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="trip_type", type="string", enum={"one-way", "round-trip", "multi-city"}, example="one-way", description="Type de voyage"),
     *             @OA\Property(property="flights", type="array", @OA\Items(type="integer"), example={1, 2}, description="IDs des vols"),
     *             @OA\Property(property="departure_date", type="string", format="date", example="2024-01-15", description="Date de départ"),
     *             @OA\Property(property="return_date", type="string", format="date", example="2024-01-20", description="Date de retour (optionnel)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Voyage créé avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Trip"),
     *             @OA\Property(property="message", type="string", example="Trip created successfully")
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
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'trip_type' => 'required|in:one-way,round-trip,multi-city',
            'flights' => 'required|array|min:1',
            'flights.*' => 'exists:flights,id',
            'departure_date' => 'required|date|after:today',
            'return_date' => 'nullable|date|after:departure_date',
        ]);

        try {
            DB::beginTransaction();

            // Calculate total price
            $totalPrice = Flight::whereIn('id', $request->flights)->sum('price');

            // Create trip
            $trip = Trip::create([
                'trip_type' => $request->trip_type,
                'total_price' => $totalPrice,
                'departure_date' => $request->departure_date,
                'return_date' => $request->return_date,
            ]);

            // Attach flights with order
            $flightOrder = [];
            foreach ($request->flights as $index => $flightId) {
                $flightOrder[$flightId] = ['order' => $index];
            }
            $trip->flights()->attach($flightOrder);

            DB::commit();

            $trip->load(['flights.airline', 'flights.departureAirport', 'flights.arrivalAirport']);

            return response()->json([
                'success' => true,
                'data' => $trip,
                'message' => 'Trip created successfully'
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to create trip: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * @OA\Post(
     *     path="/trips/validate",
     *     operationId="validateTrip",
     *     tags={"Trips"},
     *     summary="Valider un voyage",
     *     description="Valide les contraintes d'un voyage avant création",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="trip_type", type="string", enum={"one-way", "round-trip", "multi-city"}, example="one-way", description="Type de voyage"),
     *             @OA\Property(property="flights", type="array", @OA\Items(type="integer"), example={1, 2}, description="IDs des vols"),
     *             @OA\Property(property="departure_date", type="string", format="date", example="2024-01-15", description="Date de départ"),
     *             @OA\Property(property="return_date", type="string", format="date", example="2024-01-20", description="Date de retour (optionnel)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Voyage validé avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="valid", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Trip is valid"),
     *             @OA\Property(property="total_price", type="number", format="float", example=599.98, description="Prix total du voyage")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Voyage invalide",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="valid", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Trip validation failed"),
     *             @OA\Property(property="errors", type="array", @OA\Items(type="string"))
     *         )
     *     )
     * )
     */
    public function validateTrip(Request $request): JsonResponse
    {
        $request->validate([
            'trip_type' => 'required|in:one-way,round-trip,multi-city',
            'flights' => 'required|array|min:1',
            'flights.*' => 'exists:flights,id',
            'departure_date' => 'required|date|after:today',
            'return_date' => 'nullable|date|after:departure_date',
        ]);

        $errors = [];
        $totalPrice = 0;

        // Get flights
        $flights = Flight::whereIn('id', $request->flights)->get();
        
        if ($flights->count() !== count($request->flights)) {
            $errors[] = 'Some flights do not exist';
        }

        // Calculate total price
        $totalPrice = $flights->sum('price');

        // Validate trip constraints
        if ($request->trip_type === 'one-way' && count($request->flights) !== 1) {
            $errors[] = 'One-way trips must have exactly one flight';
        }

        if ($request->trip_type === 'round-trip' && count($request->flights) !== 2) {
            $errors[] = 'Round-trip must have exactly two flights';
        }

        if ($request->trip_type === 'multi-city' && count($request->flights) > 5) {
            $errors[] = 'Multi-city trips cannot have more than 5 flights';
        }

        // Check departure date constraints
        $departureDate = \Carbon\Carbon::parse($request->departure_date);
        $maxDate = now()->addDays(365);
        
        if ($departureDate->gt($maxDate)) {
            $errors[] = 'Departure date cannot be more than 365 days from now';
        }

        if (empty($errors)) {
            return response()->json([
                'success' => true,
                'valid' => true,
                'message' => 'Trip is valid',
                'total_price' => $totalPrice
            ]);
        } else {
            return response()->json([
                'success' => false,
                'valid' => false,
                'message' => 'Trip validation failed',
                'errors' => $errors
            ], 422);
        }
    }
}
