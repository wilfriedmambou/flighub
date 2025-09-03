<?php

return [

    /*
    |--------------------------------------------------------------------------
    | API Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration générale pour l'API FlightHub
    |
    */

    'pagination' => [
        'default_per_page' => 10,
        'max_per_page' => 100,
    ],

    'rate_limiting' => [
        'requests_per_minute' => 60,
        'burst_limit' => 100,
    ],

    'search' => [
        'max_results' => 50,
        'default_sort' => 'created_at',
        'default_order' => 'desc',
    ],

    'validation' => [
        'max_flights_per_trip' => 5,
        'max_days_ahead' => 365,
        'min_days_ahead' => 1,
    ],

    'response' => [
        'include_metadata' => true,
        'include_pagination' => true,
        'include_timestamps' => true,
    ],

];
