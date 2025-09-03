import { useState } from 'react'
import { Plane, Calendar, ArrowLeftRight } from 'lucide-react'
import type { FlightSearchParams } from '../hooks'
import { useFlightSearchValidation } from '../hooks'
import { ValidationError } from './ValidationError'
import { ValidationSummary } from './ValidationSummary'
import { AirportSelect } from './AirportSelect'
import { AirlineSelect } from './AirlineSelect'

interface FlightSearchFormProps {
  onSubmit: (data: FlightSearchParams) => void
  onClear?: () => void
  showClearButton?: boolean
}

export const FlightSearchForm: React.FC<FlightSearchFormProps> = ({ onSubmit, onClear, showClearButton = false }) => {
  const [tripType, setTripType] = useState<'one-way' | 'round-trip' | 'multi-city'>('one-way')
  const [formData, setFormData] = useState<FlightSearchParams>({
    tripType: 'one-way',
    departureAirport: '',
    arrivalAirport: '',
    departureDate: '',
    returnDate: '',
    airline: '',
    passengers: 1
  })

  // Hook de validation
  const {
    errors,
    validateField,
    validateForm,
    hasError,
    getErrorMessage,
    clearErrors,
    clearFieldError
  } = useFlightSearchValidation()

  // Validation spéciale pour la date de retour
  const validateReturnDate = (returnDate: string): string => {
    if (tripType === 'round-trip' && returnDate && formData.departureDate) {
      const returnDateObj = new Date(returnDate)
      const departureDateObj = new Date(formData.departureDate)
      
      if (returnDateObj <= departureDateObj) {
        return 'La date de retour doit être après la date de départ'
      }
    }
    return ''
  }

  // Fonction helper pour obtenir le message d'erreur de la date de retour
  const getReturnDateErrorMessage = (): string => {
    const hookError = getErrorMessage('returnDate')
    if (hookError) return hookError
    
    const customError = validateReturnDate(formData.returnDate ?? '')
    return customError
  }

  const handleInputChange = (field: keyof FlightSearchParams, value: string | number) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }))
    
    // Validation en temps réel
    if (value) {
      clearFieldError(field)
      const error = validateField(field, value, tripType)
      if (error) {
        // L'erreur sera gérée par le hook de validation
      }
    }
  }

  const handleTripTypeChange = (type: 'one-way' | 'round-trip' | 'multi-city') => {
    setTripType(type)
    setFormData(prev => ({
      ...prev,
      tripType: type,
      returnDate: type === 'one-way' ? undefined : prev.returnDate
    }))
    
    // Effacer les erreurs liées au type de voyage
    clearErrors()
  }

  const handleSwapAirports = () => {
    setFormData(prev => ({
      ...prev,
      departureAirport: prev.arrivalAirport,
      arrivalAirport: prev.departureAirport
    }))
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    
    // Validation complète du formulaire
    const validationErrors = validateForm(formData, tripType)
    
    if (validationErrors.length === 0) {
      onSubmit(formData)
    }
  }

  return (
    <div className="bg-white rounded-2xl shadow-2xl p-8">
      <div className="flex items-center gap-3 mb-6">
        <Plane className="w-6 h-6 text-blue-600" />
        <h2 className="text-2xl font-bold text-gray-800">Search Flights</h2>
      </div>

      {/* Résumé des erreurs de validation */}
      <ValidationSummary errors={errors} onClear={clearErrors} />

      {/* Trip Type Selection */}
      <div className="flex gap-2 mb-6">
        <button
          type="button"
          onClick={() => handleTripTypeChange('one-way')}
          className={`px-6 py-3 rounded-full font-medium transition-all ${
            tripType === 'one-way'
              ? 'bg-blue-600 text-white shadow-lg'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Aller simple
        </button>
        <button
          type="button"
          onClick={() => handleTripTypeChange('round-trip')}
          className={`px-6 py-3 rounded-full font-medium transition-all ${
            tripType === 'round-trip'
              ? 'bg-blue-600 text-white shadow-lg'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Aller-retour
        </button>
        <button
          type="button"
          onClick={() => handleTripTypeChange('multi-city')}
          className={`px-6 py-3 rounded-full font-medium transition-all ${
            tripType === 'multi-city'
              ? 'bg-blue-600 text-white shadow-lg'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Multi-villes
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* From Airport */}
          <AirportSelect
            value={formData.departureAirport}
            onChange={(value) => handleInputChange('departureAirport', value)}
            placeholder="Sélectionner un aéroport de départ"
            label="Départ"
            error={hasError('departureAirport')}
            required={true}
          />
          <ValidationError message={getErrorMessage('departureAirport')} />

          {/* To Airport */}
          <div className="space-y-2">
            <div className="flex gap-2">
              <div className="flex-1">
                <AirportSelect
                  value={formData.arrivalAirport}
                  onChange={(value) => handleInputChange('arrivalAirport', value)}
                  placeholder="Sélectionner un aéroport d'arrivée"
                  label="Arrivée"
                  error={hasError('arrivalAirport')}
                  required={true}
                />
              </div>
              <button
                type="button"
                onClick={handleSwapAirports}
                className="px-3 py-3 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors self-end"
                title="Échanger les aéroports"
              >
                <ArrowLeftRight className="w-4 h-4" />
              </button>
            </div>
            <ValidationError message={getErrorMessage('arrivalAirport')} />
          </div>

          {/* Departure Date */}
          <div className="space-y-2">
            <label className="flex items-center gap-2 text-sm font-medium text-gray-700">
              <Calendar className="w-4 h-4 text-blue-600" />
              Departure Date
            </label>
            <div className="relative">
              <input
                type="date"
                value={formData.departureDate}
                onChange={(e) => handleInputChange('departureDate', e.target.value)}
                min={new Date().toISOString().split('T')[0]}
                max={new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}
                className={`form-input pr-12 ${hasError('departureDate') ? 'border-red-500 focus:border-red-500' : ''}`}
                required
              />
              <Calendar className="absolute right-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            </div>
            <ValidationError message={getErrorMessage('departureDate')} />
          </div>

          {/* Return Date */}
          <div className="space-y-2">
            <label className="flex items-center gap-2 text-sm font-medium text-gray-700">
              <Calendar className="w-4 h-4 text-blue-600" />
              Date de retour
            </label>
            <div className="relative">
              <input
                type="date"
                value={formData.returnDate || ''}
                onChange={(e) => handleInputChange('returnDate', e.target.value)}
                disabled={tripType === 'one-way'}
                min={formData.departureDate || new Date().toISOString().split('T')[0]}
                max={new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}
                className={`form-input pr-12 ${
                  tripType === 'one-way' ? 'bg-gray-100 cursor-not-allowed' : ''
                } ${hasError('returnDate') ? 'border-red-500 focus:border-red-500' : ''}`}
                required={tripType === 'round-trip'}
              />
              <Calendar className="absolute right-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-500" />
            </div>
            <ValidationError message={getReturnDateErrorMessage()} />
          </div>

          {/* Airline Filter */}
          <AirlineSelect
            value={formData.airline || ''}
            onChange={(value) => handleInputChange('airline', value)}
            placeholder="Sélectionner une compagnie (optionnel)"
            label="Compagnie aérienne (optionnel)"
            error={hasError('airline')}
            required={false}
          />
          <ValidationError message={getErrorMessage('airline')} />

          {/* Passengers */}
          <div className="space-y-2">
            <label className="flex items-center gap-2 text-sm font-medium text-gray-700">
              <Plane className="w-4 h-4 text-blue-600" />
              Passagers
            </label>
            <input
              type="number"
              min="1"
              max="9"
              value={formData.passengers}
              onChange={(e) => handleInputChange('passengers', parseInt(e.target.value))}
              className={`form-input ${hasError('passengers') ? 'border-red-500 focus:border-red-500' : ''}`}
              required
            />
            <ValidationError message={getErrorMessage('passengers')} />
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex gap-4">
          <button
            type="submit"
            className="btn-primary flex-1"
          >
            Rechercher des vols
            {errors.length > 0 && (
              <span className="ml-2 bg-red-100 text-red-700 px-2 py-1 rounded-full text-xs font-medium">
                {errors.length} erreur{errors.length > 1 ? 's' : ''}
              </span>
            )}
          </button>
          
          {showClearButton && onClear && (
            <button
              type="button"
              onClick={onClear}
              className="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
            >
              Réinitialiser
            </button>
          )}
        </div>
      </form>
    </div>
  )
}
