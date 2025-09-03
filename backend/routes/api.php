<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AirlineController;
use App\Http\Controllers\Api\AirportController;
use App\Http\Controllers\Api\FlightController;
use App\Http\Controllers\Api\TripController;
use App\Http\Controllers\Api\SwaggerController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'environment' => config('app.env'),
        'version' => '1.0.0',
        'service' => 'FlightHub API'
    ]);
});

// Handle preflight OPTIONS requests
Route::options('/{any}', function () {
    return response('', 200);
})->where('any', '.*');

// API routes
// Airlines
Route::get('/airlines', [AirlineController::class, 'index']);
Route::get('/airlines/{airline}', [AirlineController::class, 'show']);

// Airports
Route::get('/airports', [AirportController::class, 'index']);
Route::get('/airports/search', [AirportController::class, 'search']);
Route::get('/airports/{airport}', [AirportController::class, 'show']);

// Flights
Route::get('/flights', [FlightController::class, 'index']);
Route::get('/flights/search', [FlightController::class, 'search']);
Route::get('/flights/{flight}', [FlightController::class, 'show']);

// Trips
Route::get('/trips', [TripController::class, 'index']);
Route::get('/trips/{trip}', [TripController::class, 'show']);
Route::post('/trips', [TripController::class, 'store']);
Route::put('/trips/{trip}', [TripController::class, 'update']);
Route::delete('/trips/{trip}', [TripController::class, 'destroy']);

// Swagger documentation JSON
Route::get('/api-docs.json', [SwaggerController::class, 'json']);

// Route de documentation Swagger (redirection vers /docs)
Route::get('/documentation', function() {
    return redirect('/api/docs');
});

// Interface Swagger UI en HTML
Route::get('/docs', function() {
    $html = '
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FlightHub API Documentation</title>
        <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui.css" />
        <style>
            body { margin: 0; padding: 0; }
            .swagger-ui .topbar { display: none; }
            .swagger-ui .info { margin: 20px; }
            .swagger-ui .info .title { color: #3b4151; font-size: 36px; }
            .swagger-ui .info .description { font-size: 16px; line-height: 1.5; }
        </style>
    </head>
    <body>
        <div id="swagger-ui"></div>
        <script src="https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui-bundle.js"></script>
        <script src="https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui-standalone-preset.js"></script>
        <script>
            window.onload = function() {
                SwaggerUIBundle({
                    url: "/api/api-docs.json",
                    dom_id: "#swagger-ui",
                    deepLinking: true,
                    presets: [
                        SwaggerUIBundle.presets.apis,
                        SwaggerUIStandalonePreset
                    ],
                    plugins: [
                        SwaggerUIBundle.plugins.DownloadUrl
                    ],
                    layout: "StandaloneLayout",
                    defaultModelsExpandDepth: 1,
                    defaultModelExpandDepth: 1,
                    docExpansion: "list",
                    filter: true,
                    showExtensions: true,
                    showCommonExtensions: true
                });
            };
        </script>
    </body>
    </html>';
    
    return response($html)->header('Content-Type', 'text/html');
})->name('l5-swagger.default.docs');
