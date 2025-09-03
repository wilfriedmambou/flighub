import React from 'react';
import { Plane, Clock, MapPin, Building2, CheckCircle } from 'lucide-react';
import { Pagination } from './Pagination';
import { FlightSorting } from './FlightSorting';
import type { Flight } from '../hooks';

interface FlightSearchResultsProps {
  flights: Flight[];
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
  selectedFlights: Flight[];
  searchParams: {
    departureAirport: string;
    arrivalAirport: string;
    date: string;
    airline?: string;
  };
  onFlightSelect: (flight: Flight) => void;
  onSortChange: (sortBy: string, sortOrder: 'asc' | 'desc') => void;
  onPageChange: (page: number) => void;
  onPerPageChange: (perPage: number) => void;
  onContinueToConfirmation: () => void;
}

export const FlightSearchResults: React.FC<FlightSearchResultsProps> = ({
  flights,
  loading,
  error,
  pagination,
  sortBy,
  sortOrder,
  selectedFlights,
  searchParams,
  onFlightSelect,
  onSortChange,
  onPageChange,
  onPerPageChange,
  onContinueToConfirmation,
}) => {
  const formatTime = (timeString: string) => {
    return new Date(timeString).toLocaleTimeString('fr-FR', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
    });
  };

  const calculateDuration = (departureTime: string, arrivalTime: string): string => {
    const departure = new Date(departureTime);
    const arrival = new Date(arrivalTime);
    const diffMs = arrival.getTime() - departure.getTime();
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
    
    if (diffHours > 0) {
      return `${diffHours}h ${diffMinutes}m`;
    }
    return `${diffMinutes}m`;
  };

  const isFlightSelected = (flight: Flight) => {
    return selectedFlights.some(f => f.id === flight.id);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-red-700">{error}</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* En-tête des résultats */}
      <div className="bg-white p-6 rounded-lg shadow-sm border">
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          Résultats de recherche
        </h2>
        <p className="text-gray-600">
          {searchParams.departureAirport} → {searchParams.arrivalAirport} • {formatDate(searchParams.date)}
        </p>
        {pagination.total > 0 && (
          <p className="text-sm text-gray-500 mt-1">
            {pagination.total} vol{pagination.total > 1 ? 's' : ''} trouvé{pagination.total > 1 ? 's' : ''}
          </p>
        )}
        
        {/* Résumé de la sélection */}
        {selectedFlights.length > 0 && (
          <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-800">
                  {selectedFlights.length} vol{selectedFlights.length > 1 ? 's' : ''} sélectionné{selectedFlights.length > 1 ? 's' : ''}
                </p>
                <p className="text-sm text-blue-600">
                  Total: {selectedFlights.reduce((total, flight) => total + parseFloat(flight.price), 0).toFixed(2)} €
                </p>
              </div>
              <button
                onClick={onContinueToConfirmation}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Continuer vers la confirmation
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Composant de tri */}
      <FlightSorting
        sortBy={sortBy}
        sortOrder={sortOrder}
        onSortChange={onSortChange}
      />

      {/* Liste des vols */}
      {flights.length > 0 ? (
        <div className="space-y-4">
          {flights.map((flight) => (
            <div
              key={flight.id}
              className={`bg-white p-6 rounded-lg shadow-sm border transition-all ${
                isFlightSelected(flight)
                  ? 'ring-2 ring-blue-500 border-blue-300'
                  : 'hover:shadow-md'
              }`}
            >
              <div className="flex items-center justify-between">
                {/* Informations principales */}
                <div className="flex-1">
                  <div className="flex items-center gap-4 mb-3">
                    <div className="flex items-center gap-2">
                      <Building2 className="w-5 h-5 text-blue-600" />
                      <span className="font-semibold text-lg">{flight.airline.name}</span>
                      <span className="text-gray-500">({flight.airline.iata_code})</span>
                    </div>
                    <div className="text-gray-400">•</div>
                    <span className="font-mono text-lg font-semibold">{flight.flight_number}</span>
                  </div>

                  {/* Itinéraire */}
                  <div className="flex items-center gap-6">
                    <div className="text-center">
                      <div className="text-2xl font-bold text-gray-900">
                        {formatTime(flight.departure_time)}
                      </div>
                      <div className="text-sm text-gray-600">{flight.departure_airport.city}</div>
                      <div className="text-xs text-gray-500">{flight.departure_airport.iata_code}</div>
                    </div>

                    <div className="flex-1 flex items-center justify-center">
                      <div className="flex items-center gap-2">
                        <div className="w-16 h-px bg-gray-300"></div>
                        <Plane className="w-4 h-4 text-blue-600" />
                        <div className="w-16 h-px bg-gray-300"></div>
                      </div>
                    </div>

                    <div className="text-center">
                      <div className="text-2xl font-bold text-gray-900">
                        {formatTime(flight.arrival_time)}
                      </div>
                      <div className="text-sm text-gray-600">{flight.arrival_airport.city}</div>
                      <div className="text-xs text-gray-500">{flight.arrival_airport.iata_code}</div>
                    </div>
                  </div>
                </div>

                {/* Prix et actions */}
                <div className="text-right ml-6">
                  <div className="text-3xl font-bold text-blue-600 mb-2">
                    {parseFloat(flight.price).toFixed(2)} €
                  </div>
                  <button
                    onClick={() => onFlightSelect(flight)}
                    className={`px-6 py-2 rounded-lg font-medium transition-colors ${
                      isFlightSelected(flight)
                        ? 'bg-green-600 text-white hover:bg-green-700'
                        : 'bg-blue-600 text-white hover:bg-blue-700'
                    }`}
                  >
                    {isFlightSelected(flight) ? (
                      <div className="flex items-center gap-2">
                        <CheckCircle className="w-4 h-4" />
                        Sélectionné
                      </div>
                    ) : (
                      'Sélectionner'
                    )}
                  </button>
                </div>
              </div>

              {/* Détails supplémentaires */}
              <div className="mt-4 pt-4 border-t border-gray-100">
                <div className="flex items-center gap-6 text-sm text-gray-600">
                  <div className="flex items-center gap-2">
                    <Clock className="w-4 h-4" />
                    <span>Durée: {calculateDuration(flight.departure_time, flight.arrival_time)}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4" />
                    <span>{flight.departure_airport.name}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4" />
                    <span>{flight.arrival_airport.name}</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="bg-white p-12 rounded-lg shadow-sm border text-center">
          <Plane className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun vol trouvé</h3>
          <p className="text-gray-600">
            Aucun vol ne correspond à vos critères de recherche.
          </p>
        </div>
      )}

      {/* Pagination */}
      {pagination.total > 0 && (
        <Pagination
          currentPage={pagination.currentPage}
          lastPage={pagination.lastPage}
          total={pagination.total}
          perPage={pagination.perPage}
          onPageChange={onPageChange}
          onPerPageChange={onPerPageChange}
          showPerPageSelector={true}
        />
      )}
    </div>
  );
};
