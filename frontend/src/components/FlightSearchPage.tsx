import React, { useState } from 'react';
import { FlightSearchForm } from './FlightSearchForm';
import { FlightSearchResults } from './FlightSearchResults';
import { TripConfirmation } from './TripConfirmation';
import { useFlightSearch } from '../hooks';
import type { FlightSearchParams, Flight } from '../hooks';

type SearchStep = 'search' | 'results' | 'confirmation';

export const FlightSearchPage: React.FC = () => {
  const [currentStep, setCurrentStep] = useState<SearchStep>('search');
  const {
    searchParams,
    searchResults,
    selectedFlights,
    loading,
    error,
    pagination,
    sortBy,
    sortOrder,
    searchFlights,
    setSorting,
    changePage,
    changePerPage,
    selectFlight,
    clearSearch,
    getTotalPrice,
  } = useFlightSearch();

  const handleSearch = (params: FlightSearchParams) => {
    searchFlights(params);
    setCurrentStep('results');
  };

  const handleFlightSelect = (flight: Flight) => {
    selectFlight(flight);
  };

  const handleContinueToConfirmation = () => {
    setCurrentStep('confirmation');
  };

  const handleBackToSearch = () => {
    setCurrentStep('search');
    clearSearch();
  };

  const handleBackToResults = () => {
    setCurrentStep('results');
  };

  const handleModifySelection = () => {
    setCurrentStep('results');
  };

  const handleConfirmTrip = () => {
    // Ici, vous pouvez implémenter la logique de confirmation
    // Par exemple, envoyer les données au backend pour créer le voyage
    alert('Voyage confirmé ! Redirection vers la page de paiement...');
    // Vous pouvez rediriger vers une page de paiement ou de confirmation finale
  };

  const renderCurrentStep = () => {
    switch (currentStep) {
      case 'search':
        return (
          <FlightSearchForm
            onSubmit={handleSearch}
            onClear={clearSearch}
            showClearButton={false}
          />
        );

      case 'results':
        return (
          <div className="space-y-6">
            {/* Bouton retour */}
            <div className="flex justify-between items-center">
              <button
                onClick={handleBackToSearch}
                className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
              >
                ← Retour à la recherche
              </button>
              
              {selectedFlights.length > 0 && (
                <div className="text-sm text-gray-600">
                  {selectedFlights.length} vol{selectedFlights.length > 1 ? 's' : ''} sélectionné{selectedFlights.length > 1 ? 's' : ''} • 
                  Total: {getTotalPrice().toFixed(2)} €
                </div>
              )}
            </div>

            {/* Résultats de recherche */}
            <FlightSearchResults
              flights={searchResults}
              loading={loading}
              error={error}
              pagination={pagination}
              sortBy={sortBy}
              sortOrder={sortOrder}
              selectedFlights={selectedFlights}
              searchParams={{
                departureAirport: searchParams?.departureAirport || '',
                arrivalAirport: searchParams?.arrivalAirport || '',
                date: searchParams?.departureDate || '',
                airline: searchParams?.airline,
              }}
              onFlightSelect={handleFlightSelect}
              onSortChange={setSorting}
              onPageChange={changePage}
              onPerPageChange={changePerPage}
              onContinueToConfirmation={handleContinueToConfirmation}
            />
          </div>
        );

      case 'confirmation':
        return (
          <div className="space-y-6">
            {/* Bouton retour */}
            <button
              onClick={handleBackToResults}
              className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
            >
              ← Retour aux résultats
            </button>

            {/* Page de confirmation */}
            {searchParams && (
              <TripConfirmation
                searchParams={searchParams}
                selectedFlights={selectedFlights}
                onConfirm={handleConfirmTrip}
                onBack={handleBackToSearch}
                onModify={handleModifySelection}
              />
            )}
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* En-tête de la page */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Recherche de Vols
          </h1>
          <p className="text-gray-600">
            Trouvez et réservez vos vols en quelques clics
          </p>
        </div>

        {/* Indicateur de progression */}
        <div className="mb-8">
          <div className="flex items-center justify-center">
            <div className="flex items-center space-x-4">
              <div className={`flex items-center ${currentStep === 'search' ? 'text-blue-600' : 'text-gray-400'}`}>
                <div className={`w-8 h-8 rounded-full flex items-center justify-center border-2 ${
                  currentStep === 'search' ? 'border-blue-600 bg-blue-600 text-white' : 'border-gray-300'
                }`}>
                  1
                </div>
                <span className="ml-2 font-medium">Recherche</span>
              </div>

              <div className={`w-16 h-1 ${currentStep === 'results' || currentStep === 'confirmation' ? 'bg-blue-600' : 'bg-gray-300'}`}></div>

              <div className={`flex items-center ${currentStep === 'results' ? 'text-blue-600' : currentStep === 'confirmation' ? 'text-blue-600' : 'text-gray-400'}`}>
                <div className={`w-8 h-8 rounded-full flex items-center justify-center border-2 ${
                  currentStep === 'results' ? 'border-blue-600 bg-blue-600 text-white' : 
                  currentStep === 'confirmation' ? 'border-blue-600 bg-blue-600 text-white' : 'border-gray-300'
                }`}>
                  2
                </div>
                <span className="ml-2 font-medium">Sélection</span>
              </div>

              <div className={`w-16 h-1 ${currentStep === 'confirmation' ? 'bg-blue-600' : 'bg-gray-300'}`}></div>

              <div className={`flex items-center ${currentStep === 'confirmation' ? 'text-blue-600' : 'text-gray-400'}`}>
                <div className={`w-8 h-8 rounded-full flex items-center justify-center border-2 ${
                  currentStep === 'confirmation' ? 'border-blue-600 bg-blue-600 text-white' : 'border-gray-300'
                }`}>
                  3
                </div>
                <span className="ml-2 font-medium">Confirmation</span>
              </div>
            </div>
          </div>
        </div>

        {/* Contenu principal */}
        {renderCurrentStep()}
      </div>
    </div>
  );
};
