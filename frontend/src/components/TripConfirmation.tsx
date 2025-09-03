import React from 'react';
import { Plane, Clock, MapPin, Building2, CheckCircle, AlertCircle } from 'lucide-react';
import type { Flight, FlightSearchParams } from '../hooks';

interface TripConfirmationProps {
  searchParams: FlightSearchParams;
  selectedFlights: Flight[];
  onConfirm: () => void;
  onBack: () => void;
  onModify: () => void;
}

export const TripConfirmation: React.FC<TripConfirmationProps> = ({
  searchParams,
  selectedFlights,
  onConfirm,
  onBack,
  onModify,
}) => {
  const totalPrice = selectedFlights.reduce((total, flight) => total + parseFloat(flight.price), 0);
  const totalPriceWithPassengers = totalPrice * (searchParams.passengers || 1);

  const formatTime = (timeString: string) => {
    return new Date(timeString).toLocaleTimeString('fr-FR', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
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

  const validateTrip = (): { isValid: boolean; errors: string[] } => {
    const errors: string[] = [];

    // Vérifier le type de voyage
    if (searchParams.tripType === 'one-way' && selectedFlights.length !== 1) {
      errors.push('Un voyage aller simple doit avoir exactement 1 vol');
    }

    if (searchParams.tripType === 'round-trip' && selectedFlights.length !== 2) {
      errors.push('Un voyage aller-retour doit avoir exactement 2 vols');
    }

    if (searchParams.tripType === 'multi-city' && (selectedFlights.length < 2 || selectedFlights.length > 5)) {
      errors.push('Un voyage multi-villes doit avoir entre 2 et 5 vols');
    }

    // Vérifier les dates
    const departureDate = new Date(searchParams.departureDate);
    const now = new Date();
    const oneYearFromNow = new Date();
    oneYearFromNow.setFullYear(now.getFullYear() + 1);

    if (departureDate <= now) {
      errors.push('La date de départ doit être dans le futur');
    }

    if (departureDate > oneYearFromNow) {
      errors.push('La date de départ ne peut pas être plus de 365 jours dans le futur');
    }

    if (searchParams.returnDate) {
      const returnDate = new Date(searchParams.returnDate);
      if (returnDate <= departureDate) {
        errors.push('La date de retour doit être après la date de départ');
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  };

  const validation = validateTrip();

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* En-tête de confirmation */}
      <div className="bg-white p-6 rounded-lg shadow-sm border">
        <div className="flex items-center gap-3 mb-4">
          <CheckCircle className="w-8 h-8 text-green-600" />
          <h1 className="text-2xl font-bold text-gray-900">Confirmation de votre voyage</h1>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
          <div>
            <span className="font-medium">Type de voyage:</span> {searchParams.tripType === 'one-way' ? 'Aller simple' : searchParams.tripType === 'round-trip' ? 'Aller-retour' : 'Multi-villes'}
          </div>
          <div>
            <span className="font-medium">Passagers:</span> {searchParams.passengers}
          </div>
          <div>
            <span className="font-medium">Date de départ:</span> {formatDate(searchParams.departureDate)}
          </div>
          {searchParams.returnDate && (
            <div>
              <span className="font-medium">Date de retour:</span> {formatDate(searchParams.returnDate)}
          </div>
          )}
        </div>
      </div>

      {/* Validation du voyage */}
      {!validation.isValid && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-2">
            <AlertCircle className="w-5 h-5 text-red-600" />
            <h3 className="font-medium text-red-800">Problèmes détectés avec votre voyage</h3>
          </div>
          <ul className="list-disc list-inside text-sm text-red-700 space-y-1">
            {validation.errors.map((error, index) => (
              <li key={index}>{error}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Détails des vols sélectionnés */}
      <div className="bg-white rounded-lg shadow-sm border">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">Vols sélectionnés</h2>
          <p className="text-sm text-gray-600 mt-1">
            {selectedFlights.length} vol{selectedFlights.length > 1 ? 's' : ''} • {searchParams.departureAirport} → {searchParams.arrivalAirport}
          </p>
        </div>

        <div className="divide-y divide-gray-200">
          {selectedFlights.map((flight, index) => (
            <div key={flight.id} className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-4">
                  <div className="text-center">
                    <div className="text-lg font-semibold text-gray-900">
                      Vol {index + 1}
                    </div>
                    <div className="text-xs text-gray-500">
                      {searchParams.tripType === 'round-trip' && index === 0 ? 'Aller' : searchParams.tripType === 'round-trip' && index === 1 ? 'Retour' : `Étape ${index + 1}`}
                    </div>
                  </div>
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

                <div className="text-right">
                  <div className="text-2xl font-bold text-blue-600">
                    {parseFloat(flight.price).toFixed(2)} €
                  </div>
                  <div className="text-sm text-gray-500">par passager</div>
                </div>
              </div>

              {/* Détails du vol */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-gray-600">
                <div className="flex items-center gap-2">
                  <Building2 className="w-4 h-4 text-blue-600" />
                  <span>{flight.airline.name} ({flight.airline.iata_code})</span>
                </div>
                <div className="flex items-center gap-2">
                  <Clock className="w-4 h-4 text-blue-600" />
                  <span>Durée: {calculateDuration(flight.departure_time, flight.arrival_time)}</span>
                </div>
                <div className="flex items-center gap-2">
                  <MapPin className="w-4 h-4 text-blue-600" />
                  <span>{flight.flight_number}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Résumé des prix */}
      <div className="bg-white p-6 rounded-lg shadow-sm border">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Résumé des prix</h3>
        
        <div className="space-y-3">
          <div className="flex justify-between text-sm">
            <span>Prix des vols ({selectedFlights.length} vol{selectedFlights.length > 1 ? 's' : ''})</span>
            <span>{totalPrice.toFixed(2)} €</span>
          </div>
          
          <div className="flex justify-between text-sm">
            <span>Nombre de passagers</span>
            <span>× {searchParams.passengers}</span>
          </div>
          
          <div className="border-t border-gray-200 pt-3">
            <div className="flex justify-between text-lg font-semibold">
              <span>Total</span>
              <span className="text-blue-600">{totalPriceWithPassengers.toFixed(2)} €</span>
            </div>
          </div>
        </div>
      </div>

      {/* Informations importantes */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h3 className="font-medium text-blue-800 mb-2">Informations importantes</h3>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Votre voyage respecte les contraintes de temps (départ après création, maximum 365 jours)</li>
          <li>• Les prix sont en euros et incluent tous les frais</li>
          <li>• Les vols sont disponibles selon les conditions de la compagnie aérienne</li>
          <li>• Veuillez vérifier les documents de voyage requis pour votre destination</li>
        </ul>
      </div>

      {/* Boutons d'action */}
      <div className="flex gap-4">
        <button
          onClick={onBack}
          className="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
        >
          Retour à la recherche
        </button>
        
        <button
          onClick={onModify}
          className="px-6 py-3 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
        >
          Modifier la sélection
        </button>
        
        <button
          onClick={onConfirm}
          disabled={!validation.isValid}
          className={`px-8 py-3 rounded-lg font-medium transition-colors ${
            validation.isValid
              ? 'bg-green-600 text-white hover:bg-green-700'
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
          }`}
        >
          Confirmer le voyage
        </button>
      </div>
    </div>
  );
};
