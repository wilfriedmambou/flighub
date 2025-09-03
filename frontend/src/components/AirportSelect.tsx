import { useState, useRef, useEffect } from 'react'
import { MapPin, ChevronDown, Search, X } from 'lucide-react'

interface Airport {
  iata_code: string
  name: string
  city: string
}

interface AirportSelectProps {
  value: string
  onChange: (value: string) => void
  placeholder: string
  label: string
  error?: boolean
  required?: boolean
}

// Données des aéroports basées sur les vrais codes IATA de la base de données
const AIRPORTS: Airport[] = [
  { iata_code: 'YUL', name: 'Montréal-Trudeau International Airport', city: 'Montreal' },
  { iata_code: 'SSR', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'CAJ', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'ADG', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'XRE', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'YXZ', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'XXK', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'USU', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'VIR', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'PSE', name: 'Toronto International Airport', city: 'Toronto' },
  { iata_code: 'IVR', name: 'Ottawa International Airport', city: 'Ottawa' },
  { iata_code: 'XQE', name: 'Ottawa International Airport', city: 'Ottawa' },
  { iata_code: 'BUW', name: 'Ottawa International Airport', city: 'Ottawa' },
  { iata_code: 'TAO', name: 'Ottawa International Airport', city: 'Ottawa' },
]

export const AirportSelect: React.FC<AirportSelectProps> = ({
  value,
  onChange,
  placeholder,
  label,
  error = false,
  required = false
}) => {
  const [isOpen, setIsOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedAirport, setSelectedAirport] = useState<Airport | null>(null)
  const dropdownRef = useRef<HTMLDivElement>(null)

  // Trouver l'aéroport sélectionné
  useEffect(() => {
    if (value) {
      const airport = AIRPORTS.find(a => a.iata_code === value)
      setSelectedAirport(airport || null)
    } else {
      setSelectedAirport(null)
    }
  }, [value])

  // Fermer le dropdown si on clique ailleurs
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false)
        setSearchTerm('')
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // Filtrer les aéroports selon la recherche
  const filteredAirports = AIRPORTS.filter(airport =>
    airport.iata_code.toLowerCase().includes(searchTerm.toLowerCase()) ||
    airport.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
    airport.name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const handleSelect = (airport: Airport) => {
    onChange(airport.iata_code)
    setSelectedAirport(airport)
    setIsOpen(false)
    setSearchTerm('')
  }

  const handleClear = () => {
    onChange('')
    setSelectedAirport(null)
    setSearchTerm('')
  }

  return (
    <div className="space-y-2">
      <label className="flex items-center gap-2 text-sm font-medium text-gray-700">
        <MapPin className="w-4 h-4 text-blue-600" />
        {label}
        {required && <span className="text-red-500">*</span>}
      </label>
      
      <div className="relative" ref={dropdownRef}>
        <div
          className={`form-input cursor-pointer flex items-center justify-between ${
            error ? 'border-red-500 focus:border-red-500' : ''
          }`}
          onClick={() => setIsOpen(!isOpen)}
        >
          {selectedAirport ? (
            <div className="flex items-center gap-2">
              <span className="font-semibold text-blue-600">{selectedAirport.iata_code}</span>
              <span className="text-gray-600">- {selectedAirport.city}</span>
            </div>
          ) : (
            <span className="text-gray-400">{placeholder}</span>
          )}
          
          <div className="flex items-center gap-2">
            {selectedAirport && (
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  handleClear()
                }}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            )}
            <ChevronDown className={`w-4 h-4 text-gray-400 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
          </div>
        </div>

        {isOpen && (
          <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-50 max-h-64 overflow-hidden">
            {/* Barre de recherche */}
            <div className="p-3 border-b border-gray-100">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Rechercher un aéroport..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  onClick={(e) => e.stopPropagation()}
                />
              </div>
            </div>

            {/* Liste des aéroports */}
            <div className="max-h-48 overflow-y-auto">
              {filteredAirports.length > 0 ? (
                filteredAirports.map((airport) => (
                  <div
                    key={airport.iata_code}
                    className="px-3 py-2 hover:bg-blue-50 cursor-pointer transition-colors"
                    onClick={() => handleSelect(airport)}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-semibold text-blue-600">{airport.iata_code}</div>
                        <div className="text-sm text-gray-600">{airport.city}</div>
                      </div>
                      <div className="text-xs text-gray-400 text-right max-w-[200px] truncate">
                        {airport.name}
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="px-3 py-4 text-center text-gray-500">
                  Aucun aéroport trouvé
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

