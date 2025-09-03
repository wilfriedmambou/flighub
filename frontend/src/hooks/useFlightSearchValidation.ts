import { useState, useCallback } from 'react'
import type { FlightSegment } from './useFlightSearch'

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

    // Pour les voyages multi-villes, on ne valide que les champs communs (airline, passengers)
    if (tripType === 'multi-city') {
      // Validation uniquement des champs communs
      const commonFields = ['airline', 'passengers']
      commonFields.forEach(field => {
        const value = formData[field]
        const error = validateField(field, value, tripType)
        if (error) {
          newErrors.push(error)
        }
      })
    } else {
      // Validation de tous les champs pour one-way et round-trip
      Object.keys(validationRules).forEach(field => {
        const value = formData[field]
        const error = validateField(field, value, tripType)
        if (error) {
          newErrors.push(error)
        }
      })
    }

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

    // Validation aéroports différents (seulement pour one-way et round-trip)
    if (tripType !== 'multi-city' && formData.departureAirport && formData.arrivalAirport) {
      if (formData.departureAirport === formData.arrivalAirport) {
        newErrors.push({
          field: 'arrivalAirport',
          message: 'L\'aéroport d\'arrivée doit être différent de l\'aéroport de départ'
        })
      }
    }

    // Validation multi-city sera gérée par validateMultiCitySegments

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

  // Validation spécifique pour les voyages multi-villes
  const validateMultiCitySegments = useCallback((segments: FlightSegment[]): ValidationError[] => {
    const errors: ValidationError[] = []

    if (!segments || segments.length < 2) {
      errors.push({
        field: 'segments',
        message: 'Un voyage multi-villes doit avoir au moins 2 segments'
      })
      return errors
    }

    if (segments.length > 5) {
      errors.push({
        field: 'segments',
        message: 'Un voyage multi-villes ne peut pas avoir plus de 5 segments'
      })
    }

    segments.forEach((segment, index) => {
      // Validation aéroport de départ
      if (!segment.departureAirport) {
        errors.push({
          field: `segment_${index}_departure`,
          message: `L'aéroport de départ du segment ${index + 1} est requis`
        })
      } else if (!/^[A-Z]{3}$/.test(segment.departureAirport)) {
        errors.push({
          field: `segment_${index}_departure`,
          message: `L'aéroport de départ du segment ${index + 1} doit être un code IATA valide`
        })
      }

      // Validation aéroport d'arrivée
      if (!segment.arrivalAirport) {
        errors.push({
          field: `segment_${index}_arrival`,
          message: `L'aéroport d'arrivée du segment ${index + 1} est requis`
        })
      } else if (!/^[A-Z]{3}$/.test(segment.arrivalAirport)) {
        errors.push({
          field: `segment_${index}_arrival`,
          message: `L'aéroport d'arrivée du segment ${index + 1} doit être un code IATA valide`
        })
      }

      // Validation que départ ≠ arrivée
      if (segment.departureAirport && segment.arrivalAirport && 
          segment.departureAirport === segment.arrivalAirport) {
        errors.push({
          field: `segment_${index}_airports`,
          message: `L'aéroport de départ et d'arrivée du segment ${index + 1} ne peuvent pas être identiques`
        })
      }

      // Validation date
      if (!segment.departureDate) {
        errors.push({
          field: `segment_${index}_date`,
          message: `La date de départ du segment ${index + 1} est requise`
        })
      } else {
        const segmentDate = new Date(segment.departureDate)
        const today = new Date()
        today.setHours(0, 0, 0, 0)

        if (segmentDate < today) {
          errors.push({
            field: `segment_${index}_date`,
            message: `La date de départ du segment ${index + 1} doit être dans le futur`
          })
        }

        // Validation que la date est après le segment précédent
        if (index > 0) {
          const prevSegmentDate = new Date(segments[index - 1].departureDate)
          if (segmentDate <= prevSegmentDate) {
            errors.push({
              field: `segment_${index}_date`,
              message: `La date du segment ${index + 1} doit être après celle du segment ${index}`
            })
          }
        }
      }
    })

    // Validation de la continuité des aéroports (plus permissive avec auto-remplissage)
    for (let i = 1; i < segments.length; i++) {
      // Seulement si l'utilisateur a manuellement modifié l'aéroport de départ
      // et qu'il ne correspond pas à l'arrivée du segment précédent
      if (segments[i].departureAirport && segments[i-1].arrivalAirport &&
          segments[i].departureAirport !== segments[i-1].arrivalAirport) {
        // Avertissement plutôt qu'erreur bloquante
        console.warn(`Segment ${i + 1}: L'aéroport de départ (${segments[i].departureAirport}) ne correspond pas à l'arrivée du segment précédent (${segments[i-1].arrivalAirport})`);
      }
    }

    return errors
  }, [])

  return {
    errors,
    validateField,
    validateForm,
    hasError,
    getErrorMessage,
    clearErrors,
    clearFieldError,
    validateMultiCitySegments,
    validationRules
  }
}
