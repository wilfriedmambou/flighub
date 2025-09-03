// Configuration de l'API
import { config } from '../config/environment';

const API_BASE_URL = `${config.API_BASE_URL}/api`;

// Types pour les réponses API
interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
}

interface PaginatedResponse<T> extends ApiResponse<T> {
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
}

// Types pour les entités
export interface Airline {
  id: number;
  name: string;
  iata_code: string;
  created_at: string;
  updated_at: string;
}

export interface Airport {
  id: number;
  name: string;
  iata_code: string;
  city: string;
  latitude: number;
  longitude: number;
  timezone: string;
  city_code: string;
  created_at: string;
  updated_at: string;
}

export interface Flight {
  id: number;
  flight_number: string;
  airline_id: number;
  departure_airport_id: number;
  arrival_airport_id: number;
  price: number;
  departure_time: string;
  arrival_time: string;
  airline?: Airline;
  departure_airport?: Airport;
  arrival_airport?: Airport;
  created_at: string;
  updated_at: string;
}

export interface Trip {
  id: number;
  trip_type: 'one-way' | 'round-trip' | 'multi-city';
  total_price: number;
  departure_date: string;
  return_date?: string;
  flights?: Flight[];
  created_at: string;
  updated_at: string;
}

// Classe principale de l'API
class ApiService {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  // Méthode générique pour les requêtes HTTP
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    const defaultOptions: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      ...options,
    };

    try {
      const response = await fetch(url, defaultOptions);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Compagnies aériennes
  async getAirlines(): Promise<ApiResponse<Airline[]>> {
    return this.request<ApiResponse<Airline[]>>('/airlines');
  }

  async getAirline(id: number): Promise<ApiResponse<Airline>> {
    return this.request<ApiResponse<Airline>>(`/airlines/${id}`);
  }

  // Aéroports
  async getAirports(params?: {
    city?: string;
    city_code?: string;
  }): Promise<ApiResponse<Airport[]>> {
    const queryParams = params ? new URLSearchParams(params).toString() : '';
    const endpoint = queryParams ? `/airports?${queryParams}` : '/airports';
    return this.request<ApiResponse<Airport[]>>(endpoint);
  }

  async searchAirports(query: string): Promise<ApiResponse<Airport[]>> {
    return this.request<ApiResponse<Airport[]>>(`/airports/search?q=${encodeURIComponent(query)}`);
  }

  async getAirport(id: number): Promise<ApiResponse<Airport>> {
    return this.request<ApiResponse<Airport>>(`/airports/${id}`);
  }

  // Vols
  async getFlights(params?: {
    departure_airport?: string;
    arrival_airport?: string;
    date?: string;
    airline?: string;
    sort?: string;
    order?: 'asc' | 'desc';
    limit?: number;
  }): Promise<PaginatedResponse<Flight[]>> {
    const queryParams = params ? new URLSearchParams(params as Record<string, string>).toString() : '';
    const endpoint = queryParams ? `/flights?${queryParams}` : '/flights';
    return this.request<PaginatedResponse<Flight[]>>(endpoint);
  }

  async searchFlights(params: {
    departure_airport: string;
    arrival_airport: string;
    date: string;
    airline?: string;
    sort?: string;
    order?: 'asc' | 'desc';
    page?: number;
    per_page?: number;
  }): Promise<ApiResponse<Flight[]>> {
    const queryParams = new URLSearchParams(
      Object.entries(params).reduce((acc, [key, value]) => {
        if (value !== undefined) {
          acc[key] = String(value);
        }
        return acc;
      }, {} as Record<string, string>)
    ).toString();
    const endpoint = `/flights/search?${queryParams}`;
    return this.request<ApiResponse<Flight[]>>(endpoint);
  }

  async getFlight(id: number): Promise<ApiResponse<Flight>> {
    return this.request<ApiResponse<Flight>>(`/flights/${id}`);
  }

  // Voyages
  async getTrips(params?: {
    sort?: string;
    order?: 'asc' | 'desc';
    limit?: number;
  }): Promise<PaginatedResponse<Trip[]>> {
    const queryParams = params ? new URLSearchParams(params as Record<string, string>).toString() : '';
    const endpoint = queryParams ? `/trips?${queryParams}` : '/trips';
    return this.request<PaginatedResponse<Trip[]>>(endpoint);
  }

  async createTrip(tripData: {
    trip_type: 'one-way' | 'round-trip' | 'multi-city';
    flights: number[];
    departure_date: string;
    return_date?: string;
  }): Promise<ApiResponse<Trip>> {
    return this.request<ApiResponse<Trip>>('/trips', {
      method: 'POST',
      body: JSON.stringify(tripData),
    });
  }

  async validateTrip(tripData: {
    trip_type: 'one-way' | 'round-trip' | 'multi-city';
    flights: number[];
    departure_date: string;
    return_date?: string;
  }): Promise<ApiResponse<{
    total_price: number;
    flights_count: number;
  }>> {
    return this.request<ApiResponse<{
      total_price: number;
      flights_count: number;
    }>>('/trips/validate', {
      method: 'POST',
      body: JSON.stringify(tripData),
    });
  }

  async getTrip(id: number): Promise<ApiResponse<Trip>> {
    return this.request<ApiResponse<Trip>>(`/trips/${id}`);
  }
}

// Instance exportée du service API
export const apiService = new ApiService();

// Export des types
export type { ApiResponse, PaginatedResponse };
