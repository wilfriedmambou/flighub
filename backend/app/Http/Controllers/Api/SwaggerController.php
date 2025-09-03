<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SwaggerController extends Controller
{
    /**
     * Serve the Swagger JSON documentation
     */
    public function json()
    {
        $jsonPath = storage_path('api-docs/api-docs.json');
        
        if (!file_exists($jsonPath)) {
            return response()->json(['error' => 'Documentation not found'], 404);
        }
        
        $content = file_get_contents($jsonPath);
        $data = json_decode($content, true);
        
        return response()->json($data);
    }
}



