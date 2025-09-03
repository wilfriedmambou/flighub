import React from 'react';
import { Plus, Minus, MapPin, Calendar } from 'lucide-react';
import { AirportSelect } from './AirportSelect';

import type { FlightSegment } from '../hooks';

interface MultiCityFormProps {
  segments: FlightSegment[];
  onSegmentsChange: (segments: FlightSegment[]) => void;
  errors: string[];
  onClearErrors: () => void;
}

export const MultiCityForm: React.FC<MultiCityFormProps> = ({
  segments,
  onSegmentsChange,
  errors,
  onClearErrors
}) => {
  const maxSegments = 5;
  const minSegments = 2;

  const addSegment = () => {
    if (segments.length < maxSegments) {
      const lastSegment = segments[segments.length - 1];
      const newSegment: FlightSegment = {
        departureAirport: lastSegment?.arrivalAirport || '',
        arrivalAirport: '',
        departureDate: lastSegment?.departureDate || ''
      };
      onSegmentsChange([...segments, newSegment]);
      onClearErrors();
    }
  };

  const removeSegment = (index: number) => {
    if (segments.length > minSegments) {
      const newSegments = segments.filter((_, i) => i !== index);
      onSegmentsChange(newSegments);
      onClearErrors();
    }
  };

  const updateSegment = (index: number, field: keyof FlightSegment, value: string) => {
    const newSegments = segments.map((segment, i) => 
      i === index ? { ...segment, [field]: value } : segment
    );
    
    // Auto-remplissage : si on change l'aéroport d'arrivée, mettre à jour l'aéroport de départ du segment suivant
    if (field === 'arrivalAirport' && index < segments.length - 1) {
      const nextSegmentIndex = index + 1;
      newSegments[nextSegmentIndex] = {
        ...newSegments[nextSegmentIndex],
        departureAirport: value
      };
    }
    
    onSegmentsChange(newSegments);
    onClearErrors();
  };

  const swapAirports = (index: number) => {
    const segment = segments[index];
    updateSegment(index, 'departureAirport', segment.arrivalAirport);
    updateSegment(index, 'arrivalAirport', segment.departureAirport);
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-medium text-gray-900">
          Itinéraire multi-villes ({segments.length} segment{segments.length > 1 ? 's' : ''})
        </h3>
        <div className="flex gap-2">
          {segments.length < maxSegments && (
            <button
              type="button"
              onClick={addSegment}
              className="flex items-center gap-2 px-3 py-2 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
            >
              <Plus className="w-4 h-4" />
              Ajouter un segment
            </button>
          )}
        </div>
      </div>

      {errors.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3">
          <ul className="list-disc list-inside text-sm text-red-700 space-y-1">
            {errors.map((error, index) => (
              <li key={index}>{error}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="space-y-4">
        {segments.map((segment, index) => (
          <div key={index} className="bg-gray-50 p-4 rounded-lg border">
            <div className="flex items-center justify-between mb-3">
              <h4 className="font-medium text-gray-900">
                Segment {index + 1}
              </h4>
              {segments.length > minSegments && (
                <button
                  type="button"
                  onClick={() => removeSegment(index)}
                  className="flex items-center gap-1 px-2 py-1 text-sm text-red-600 hover:bg-red-50 rounded transition-colors"
                >
                  <Minus className="w-4 h-4" />
                  Supprimer
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
              {/* Départ */}
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <label className="text-sm font-medium text-gray-700">Départ</label>
                  {index > 0 && segment.departureAirport && (
                    <span className="text-xs text-green-600 bg-green-50 px-2 py-1 rounded">
                      Auto-rempli
                    </span>
                  )}
                </div>
                <AirportSelect
                  value={segment.departureAirport}
                  onChange={(value) => updateSegment(index, 'departureAirport', value)}
                  placeholder="Aéroport de départ"
                  label=""
                  required={true}
                />
              </div>

              {/* Arrivée */}
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <label className="text-sm font-medium text-gray-700">Arrivée</label>
                  {index < segments.length - 1 && (
                    <span className="text-xs text-blue-600 bg-blue-50 px-2 py-1 rounded">
                      Départ suivant
                    </span>
                  )}
                </div>
                <div className="flex gap-2">
                  <div className="flex-1">
                    <AirportSelect
                      value={segment.arrivalAirport}
                      onChange={(value) => updateSegment(index, 'arrivalAirport', value)}
                      placeholder="Aéroport d'arrivée"
                      label=""
                      required={true}
                    />
                  </div>
                  <button
                    type="button"
                    onClick={() => swapAirports(index)}
                    className="px-3 py-3 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors self-end"
                    title="Échanger les aéroports"
                  >
                    <MapPin className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Date */}
              <div className="space-y-2">
                <label className="flex items-center gap-2 text-sm font-medium text-gray-700">
                  <Calendar className="w-4 h-4 text-blue-600" />
                  Date de départ
                </label>
                <input
                  type="date"
                  value={segment.departureDate}
                  onChange={(e) => updateSegment(index, 'departureDate', e.target.value)}
                  min={index === 0 ? new Date().toISOString().split('T')[0] : segments[index - 1]?.departureDate}
                  max={new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}
                  className="form-input"
                  required
                />
              </div>
            </div>

            {/* Indication de connexion */}
            {index < segments.length - 1 && (
              <div className="mt-3 text-center">
                <div className="inline-flex items-center gap-2 text-sm text-gray-500">
                  <div className="w-4 h-4 border-2 border-gray-300 rounded-full"></div>
                  <span>Connexion à {segment.arrivalAirport || 'l\'aéroport suivant'}</span>
                  <div className="w-4 h-4 border-2 border-gray-300 rounded-full"></div>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Résumé de l'itinéraire */}
      <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
        <h4 className="font-medium text-blue-900 mb-2">Résumé de l'itinéraire :</h4>
        <div className="text-sm text-blue-800">
          {segments.map((segment, index) => (
            <span key={index}>
              {segment.departureAirport || '?'} → {segment.arrivalAirport || '?'}
              {index < segments.length - 1 && ' → '}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
};
