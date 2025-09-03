import React from 'react';
import { ArrowUpDown, Clock, DollarSign, Plane } from 'lucide-react';

interface FlightSortingProps {
  sortBy: string;
  sortOrder: 'asc' | 'desc';
  onSortChange: (sortBy: string, sortOrder: 'asc' | 'desc') => void;
}

export const FlightSorting: React.FC<FlightSortingProps> = ({
  sortBy,
  sortOrder,
  onSortChange,
}) => {
  const sortOptions = [
    {
      value: 'departure_time',
      label: 'Heure de départ',
      icon: Clock,
    },
    {
      value: 'arrival_time',
      label: 'Heure d\'arrivée',
      icon: Clock,
    },
    {
      value: 'price',
      label: 'Prix',
      icon: DollarSign,
    },
    {
      value: 'flight_number',
      label: 'Numéro de vol',
      icon: Plane,
    },
  ];

  const handleSortChange = (newSortBy: string) => {
    const newSortOrder = sortBy === newSortBy && sortOrder === 'asc' ? 'desc' : 'asc';
    onSortChange(newSortBy, newSortOrder);
  };

  const getSortIcon = (optionValue: string) => {
    if (sortBy !== optionValue) {
      return <ArrowUpDown className="w-4 h-4 text-gray-400" />;
    }
    
    return sortOrder === 'asc' ? (
      <ArrowUpDown className="w-4 h-4 text-blue-600" />
    ) : (
      <ArrowUpDown className="w-4 h-4 text-blue-600 rotate-180" />
    );
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border">
      <h3 className="text-sm font-medium text-gray-900 mb-3">Trier par :</h3>
      <div className="flex flex-wrap gap-2">
        {sortOptions.map((option) => {
          const Icon = option.icon;
          const isActive = sortBy === option.value;
          
          return (
            <button
              key={option.value}
              onClick={() => handleSortChange(option.value)}
              className={`flex items-center gap-2 px-3 py-2 text-sm font-medium rounded-md border transition-colors ${
                isActive
                  ? 'bg-blue-50 border-blue-200 text-blue-700'
                  : 'bg-white border-gray-300 text-gray-700 hover:bg-gray-50 hover:border-gray-400'
              }`}
            >
              <Icon className="w-4 h-4" />
              {option.label}
              {getSortIcon(option.value)}
            </button>
          );
        })}
      </div>
      
      {sortBy && (
        <div className="mt-3 text-xs text-gray-500">
          Trié par : <span className="font-medium">{sortOptions.find(opt => opt.value === sortBy)?.label}</span>
          {' '}({sortOrder === 'asc' ? 'croissant' : 'décroissant'})
        </div>
      )}
    </div>
  );
};
