import { useState, useCallback } from 'react'

export interface ValidationError {
  field: string
  message: string
}

export interface ValidationRules {
  departureAirport: {
    required: boolean
    pattern: RegExp
    minLength: number
    maxLength: number
  }
  arrivalAirport: {
    required: boolean
    pattern: RegExp
    minLength: number
    maxLength: number
  }
  departureDate: {
    required: boolean
    minDate: string
    maxDate: string
  }
  returnDate: {
    required: boolean
    minDate: string
    dependsOn: string
  }
  passengers: {
    required: boolean
    min: number
    max: number
  }
  airline: {
    required: boolean
    pattern: RegExp
    maxLength: number
  }
}

export const useFlightSearchValidation = () => {
  const [errors, setErrors] = useState<ValidationError[]>([])

  // Règles de validation selon les contraintes du projet
  const validationRules: ValidationRules = {
    departureAirport: {
      required: true,
      pattern: /^[A-Z]{3}$/,
      minLength: 3,
      maxLength: 3
    },
    arrivalAirport: {
      required: true,
      pattern: /^[A-Z]{3}$/,
      minLength: 3,
      maxLength: 3
    },
    departureDate: {
      required: true,
      minDate: new Date().toISOString().split('T')[0], // Aujourd'hui
      maxDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0] // +1 an
    },
    returnDate: {
      required: false,
      minDate: new Date().toISOString().split('T')[0],
      dependsOn: 'departureDate'
    },
    passengers: {
      required: true,
      min: 1,
      max: 9
    },
    airline: {
      required: false,
      pattern: /^[A-Z]{2}$/,
      maxLength: 2
    }
  }

  // Validation d'un champ spécifique
  const validateField = useCallback((field: string, value: any, tripType: string): ValidationError | null => {
    const rules = validationRules[field as keyof ValidationRules]
    if (!rules) return null

    // Validation required
    if (rules.required && (!value || value.toString().trim() === '')) {
      return {
        field,
        message: `Le champ ${field === 'departureAirport' ? 'départ' : field === 'arrivalAirport' ? 'arrivée' : field} est requis`
      }
    }

    // Validation pattern (only for fields that have pattern)
    if ('pattern' in rules && rules.pattern && value && !rules.pattern.test(value.toString())) {
      if (field.includes('Airport')) {
        return {
          field,
          message: 'Le code aéroport doit être au format IATA (3 lettres majuscules, ex: YUL)'
        }
      }
      if (field === 'airline') {
        return {
          field,
          message: 'Le code compagnie doit être au format IATA (2 lettres majuscules, ex: AC)'
        }
      }
    }

    // Validation longueur (only for fields that have minLength/maxLength)
    if ('minLength' in rules && value && rules.minLength && value.toString().length < rules.minLength) {
      return {
        field,
        message: `Le champ ${field} doit contenir au moins ${rules.minLength} caractères`
      }
    }

    if ('maxLength' in rules && value && rules.maxLength && value.toString().length > rules.maxLength) {
      return {
        field,
        message: `Le champ ${field} doit contenir au maximum ${rules.maxLength} caractères`
      }
    }

    // Validation dates
    if (field === 'departureDate' && value) {
      const selectedDate = new Date(value)
      const today = new Date()
      today.setHours(0, 0, 0, 0)

      if (selectedDate < today) {
        return {
          field,
          message: 'La date de départ ne peut pas être dans le passé'
        }
      }

      const maxDate = new Date()
      maxDate.setFullYear(maxDate.getFullYear() + 1)
      if (selectedDate > maxDate) {
        return {
          field,
          message: 'La date de départ ne peut pas être plus de 1 an dans le futur'
        }
      }
    }

    if (field === 'returnDate' && value && tripType === 'round-trip') {
      const returnDate = new Date(value)
      const departureDate = new Date() // Sera remplacé par la vraie valeur

      if (returnDate <= departureDate) {
        return {
          field,
          message: 'La date de retour doit être après la date de départ'
        }
      }
    }

    // Validation nombre de passagers (only for fields that have min/max)
    if (field === 'passengers' && value && 'min' in rules && 'max' in rules) {
      const passengers = parseInt(value)
      if (passengers < rules.min || passengers > rules.max) {
        return {
          field,
          message: `Le nombre de passagers doit être entre ${rules.min} et ${rules.max}`
        }
      }
    }

    // Validation aéroports différents
    if (field === 'arrivalAirport' && value) {
      // Cette validation sera faite dans validateForm
    }

    return null
  }, [validationRules])

  // Validation complète du formulaire
  const validateForm = useCallback((formData: any, tripType: string): ValidationError[] => {
    const newErrors: ValidationError[] = []

    // Validation de chaque champ
    Object.keys(validationRules).forEach(field => {
      const value = formData[field]
      const error = validateField(field, value, tripType)
      if (error) {
        newErrors.push(error)
      }
    })

    // Validation spécifique au type de voyage
    if (tripType === 'round-trip' && formData.returnDate) {
      const departureDate = new Date(formData.departureDate)
      const returnDate = new Date(formData.returnDate)
      
      if (returnDate <= departureDate) {
        newErrors.push({
          field: 'returnDate',
          message: 'La date de retour doit être après la date de départ'
        })
      }
    }

    // Validation aéroports différents
    if (formData.departureAirport && formData.arrivalAirport) {
      if (formData.departureAirport === formData.arrivalAirport) {
        newErrors.push({
          field: 'arrivalAirport',
          message: 'L\'aéroport d\'arrivée doit être différent de l\'aéroport de départ'
        })
      }
    }

    // Validation multi-city (si implémenté)
    if (tripType === 'multi-city') {
      // Logique spécifique pour multi-city
      if (!formData.returnDate) {
        newErrors.push({
          field: 'returnDate',
          message: 'La date de retour est requise pour les voyages multi-villes'
        })
      }
    }

    setErrors(newErrors)
    return newErrors
  }, [validationRules, validateField])

  // Vérifier si un champ a une erreur
  const hasError = useCallback((field: string): boolean => {
    return errors.some(error => error.field === field)
  }, [errors])

  // Obtenir le message d'erreur d'un champ
  const getErrorMessage = useCallback((field: string): string => {
    const error = errors.find(error => error.field === field)
    return error ? error.message : ''
  }, [errors])

  // Effacer les erreurs
  const clearErrors = useCallback(() => {
    setErrors([])
  }, [])

  // Effacer l'erreur d'un champ spécifique
  const clearFieldError = useCallback((field: string) => {
    setErrors(prev => prev.filter(error => error.field !== field))
  }, [])

  return {
    errors,
    validateField,
    validateForm,
    hasError,
    getErrorMessage,
    clearErrors,
    clearFieldError,
    validationRules
  }
}
