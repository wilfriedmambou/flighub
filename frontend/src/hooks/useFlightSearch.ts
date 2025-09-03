import { useState, useCallback } from 'react';

const API_BASE_URL = 'http://localhost:8000';

// FlightSearchParams interface for flight search parameters
export interface FlightSearchParams {
  tripType: 'one-way' | 'round-trip' | 'multi-city';
  departureAirport: string;
  arrivalAirport: string;
  departureDate: string;
  returnDate?: string;
  airline?: string;
  passengers?: number;
}

export interface Flight {
  id: number;
  flight_number: string;
  airline: {
    name: string;
    iata_code: string;
  };
  departure_airport: {
    name: string;
    iata_code: string;
    city: string;
    timezone: string;
  };
  arrival_airport: {
    name: string;
    iata_code: string;
    city: string;
    timezone: string;
  };
  price: string;
  departure_time: string;
  arrival_time: string;
}

export interface FlightSearchState {
  searchParams: FlightSearchParams | null;
  searchResults: Flight[];
  selectedFlights: Flight[];
  loading: boolean;
  error: string | null;
  pagination: {
    currentPage: number;
    lastPage: number;
    total: number;
    perPage: number;
  };
  sortBy: string;
  sortOrder: 'asc' | 'desc';
}

export const useFlightSearch = () => {
  const [state, setState] = useState<FlightSearchState>({
    searchParams: null,
    searchResults: [],
    selectedFlights: [],
    loading: false,
    error: null,
    pagination: {
      currentPage: 1,
      lastPage: 1,
      total: 0,
      perPage: 10,
    },
    sortBy: 'departure_time',
    sortOrder: 'asc',
  });

  const searchFlights = useCallback(async (params: FlightSearchParams, page = 1, perPage = state.pagination.perPage) => {
    setState(prev => ({ ...prev, loading: true, error: null, searchParams: params }));

    try {
      const searchParams = new URLSearchParams({
        departure_airport: params.departureAirport,
        arrival_airport: params.arrivalAirport,
        date: params.departureDate,
        sort: state.sortBy,
        order: state.sortOrder,
        page: page.toString(),
        per_page: perPage.toString(),
      });

      if (params.airline) {
        searchParams.append('airline', params.airline);
      }

      const response = await fetch(`${API_BASE_URL}/api/flights/search?${searchParams}`);
      
      if (!response.ok) {
        throw new Error('Erreur lors de la recherche de vols');
      }

      const data = await response.json();
      
      if (data.success) {
        setState(prev => ({
          ...prev,
          searchResults: data.data.data,
          pagination: {
            currentPage: data.data.current_page,
            lastPage: data.data.last_page,
            total: data.data.total,
            perPage: data.data.per_page,
          },
          loading: false,
        }));
      } else {
        setState(prev => ({
          ...prev,
          error: data.message || 'Erreur lors de la recherche',
          loading: false,
        }));
      }
    } catch (err) {
      setState(prev => ({
        ...prev,
        error: err instanceof Error ? err.message : 'Erreur inconnue',
        loading: false,
      }));
    }
  }, [state.sortBy, state.sortOrder, state.pagination.perPage]);

  const setSorting = useCallback((sortBy: string, sortOrder: 'asc' | 'desc') => {
    setState(prev => ({ ...prev, sortBy, sortOrder }));
    if (state.searchParams) {
      searchFlights(state.searchParams, 1, state.pagination.perPage);
    }
  }, [state.searchParams, state.pagination.perPage, searchFlights]);

  const changePage = useCallback((page: number) => {
    if (state.searchParams) {
      searchFlights(state.searchParams, page, state.pagination.perPage);
    }
  }, [state.searchParams, state.pagination.perPage, searchFlights]);

  const changePerPage = useCallback((perPage: number) => {
    setState(prev => ({
      ...prev,
      pagination: { ...prev.pagination, perPage }
    }));
    if (state.searchParams) {
      searchFlights(state.searchParams, 1, perPage);
    }
  }, [state.searchParams, searchFlights]);

  const selectFlight = useCallback((flight: Flight) => {
    setState(prev => {
      const isSelected = prev.selectedFlights.some(f => f.id === flight.id);
      if (isSelected) {
        return {
          ...prev,
          selectedFlights: prev.selectedFlights.filter(f => f.id !== flight.id)
        };
      } else {
        return {
          ...prev,
          selectedFlights: [...prev.selectedFlights, flight]
        };
      }
    });
  }, []);

  const clearSearch = useCallback(() => {
    setState(prev => ({
      ...prev,
      searchParams: null,
      searchResults: [],
      selectedFlights: [],
      error: null,
      pagination: {
        currentPage: 1,
        lastPage: 1,
        total: 0,
        perPage: 10,
      },
    }));
  }, []);

  const getTotalPrice = useCallback(() => {
    return state.selectedFlights.reduce((total, flight) => total + parseFloat(flight.price), 0);
  }, [state.selectedFlights]);

  return {
    ...state,
    searchFlights,
    setSorting,
    changePage,
    changePerPage,
    selectFlight,
    clearSearch,
    getTotalPrice,
  };
};
