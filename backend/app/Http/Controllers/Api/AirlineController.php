<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Airline;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

/**
 * @OA\Tag(
 *     name="Airlines",
 *     description="Gestion des compagnies aériennes"
 * )
 */
class AirlineController extends Controller
{
    /**
     * @OA\Get(
     *     path="/airlines",
     *     operationId="getAirlines",
     *     tags={"Airlines"},
     *     summary="Récupérer la liste des compagnies aériennes",
     *     description="Retourne la liste complète des compagnies aériennes disponibles",
     *     @OA\Response(
     *         response=200,
     *         description="Liste des compagnies aériennes récupérée avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Airline")),
     *             @OA\Property(property="message", type="string", example="Airlines retrieved successfully")
     *         )
     *     )
     * )
     */
    public function index(): JsonResponse
    {
        $airlines = Airline::all();
        
        return response()->json([
            'success' => true,
            'data' => $airlines,
            'message' => 'Airlines retrieved successfully'
        ]);
    }

    /**
     * @OA\Get(
     *     path="/airlines/{airline}",
     *     operationId="getAirline",
     *     tags={"Airlines"},
     *     summary="Récupérer une compagnie aérienne spécifique",
     *     description="Retourne les détails d'une compagnie aérienne par son ID",
     *     @OA\Parameter(
     *         name="airline",
     *         in="path",
     *         description="ID de la compagnie aérienne",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Compagnie aérienne récupérée avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", ref="#/components/schemas/Airline"),
     *             @OA\Property(property="message", type="string", example="Airline retrieved successfully")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Compagnie aérienne non trouvée"
     *     )
     * )
     */
    public function show(Airline $airline): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $airline,
            'message' => 'Airline retrieved successfully'
        ]);
    }
}
