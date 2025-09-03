import { AlertTriangle, X } from 'lucide-react'
import type { ValidationError } from '../hooks'

interface ValidationSummaryProps {
  errors: ValidationError[]
  onClear: () => void
}

export const ValidationSummary: React.FC<ValidationSummaryProps> = ({ errors, onClear }) => {
  if (errors.length === 0) return null

  return (
    <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          <AlertTriangle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
          <div>
            <h3 className="text-sm font-medium text-red-800">
              {errors.length} erreur{errors.length > 1 ? 's' : ''} à corriger
            </h3>
            <p className="text-sm text-red-700 mt-1">
              Veuillez corriger les erreurs ci-dessous avant de continuer.
            </p>
          </div>
        </div>
        <button
          onClick={onClear}
          className="text-red-400 hover:text-red-600 transition-colors"
          title="Fermer"
        >
          <X className="w-4 h-4" />
        </button>
      </div>
      
      <ul className="mt-3 space-y-1">
        {errors.map((error, index) => (
          <li key={index} className="text-sm text-red-700 flex items-center gap-2">
            <span className="w-2 h-2 bg-red-400 rounded-full"></span>
            <span className="capitalize">
              {error.field === 'departureAirport' ? 'Départ' :
               error.field === 'arrivalAirport' ? 'Arrivée' :
               error.field === 'departureDate' ? 'Date de départ' :
               error.field === 'returnDate' ? 'Date de retour' :
               error.field === 'airline' ? 'Compagnie' :
               error.field === 'passengers' ? 'Passagers' : error.field}
            </span>
            : {error.message}
          </li>
        ))}
      </ul>
    </div>
  )
}

