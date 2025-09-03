import { useState, useRef, useEffect } from 'react'
import { Building2, ChevronDown, Search, X } from 'lucide-react'

interface Airline {
  iata_code: string
  name: string
}

interface AirlineSelectProps {
  value: string
  onChange: (value: string) => void
  placeholder: string
  label: string
  error?: boolean
  required?: boolean
}

// Données des compagnies aériennes basées sur les seeders
const AIRLINES: Airline[] = [
  { iata_code: 'AC', name: 'Air Canada' },
  { iata_code: 'WS', name: 'WestJet' },
  { iata_code: 'TS', name: 'Air Transat' },
  { iata_code: 'PD', name: 'Porter Airlines' },
  { iata_code: 'WG', name: 'Sunwing Airlines' },
  { iata_code: 'F8', name: 'Flair Airlines' },
  { iata_code: 'Y9', name: 'Lynx Air' },
]

export const AirlineSelect: React.FC<AirlineSelectProps> = ({
  value,
  onChange,
  placeholder,
  label,
  error = false,
  required = false
}) => {
  const [isOpen, setIsOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedAirline, setSelectedAirline] = useState<Airline | null>(null)
  const dropdownRef = useRef<HTMLDivElement>(null)

  // Trouver la compagnie sélectionnée
  useEffect(() => {
    if (value) {
      const airline = AIRLINES.find(a => a.iata_code === value)
      setSelectedAirline(airline || null)
    } else {
      setSelectedAirline(null)
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

  // Filtrer les compagnies selon la recherche
  const filteredAirlines = AIRLINES.filter(airline =>
    airline.iata_code.toLowerCase().includes(searchTerm.toLowerCase()) ||
    airline.name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const handleSelect = (airline: Airline) => {
    onChange(airline.iata_code)
    setSelectedAirline(airline)
    setIsOpen(false)
    setSearchTerm('')
  }

  const handleClear = () => {
    onChange('')
    setSelectedAirline(null)
    setSearchTerm('')
  }

  return (
    <div className="space-y-2">
      <label className="flex items-center gap-2 text-sm font-medium text-gray-700">
        <Building2 className="w-4 h-4 text-blue-600" />
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
          {selectedAirline ? (
            <div className="flex items-center gap-2">
              <span className="font-semibold text-blue-600">{selectedAirline.iata_code}</span>
              <span className="text-gray-600">- {selectedAirline.name}</span>
            </div>
          ) : (
            <span className="text-gray-400">{placeholder}</span>
          )}
          
          <div className="flex items-center gap-2">
            {selectedAirline && (
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
                  placeholder="Rechercher une compagnie..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  onClick={(e) => e.stopPropagation()}
                />
              </div>
            </div>

            {/* Liste des compagnies */}
            <div className="max-h-48 overflow-y-auto">
              {filteredAirlines.length > 0 ? (
                filteredAirlines.map((airline) => (
                  <div
                    key={airline.iata_code}
                    className="px-3 py-2 hover:bg-blue-50 cursor-pointer transition-colors"
                    onClick={() => handleSelect(airline)}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-semibold text-blue-600">{airline.iata_code}</div>
                        <div className="text-sm text-gray-600">{airline.name}</div>
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="px-3 py-4 text-center text-gray-500">
                  Aucune compagnie trouvée
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

