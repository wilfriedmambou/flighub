// FlightHub Frontend Environment Configuration
// Ce fichier gère automatiquement les URLs selon l'environnement

interface EnvironmentConfig {
  API_BASE_URL: string;
  ENVIRONMENT: string;
  APP_NAME: string;
  APP_VERSION: string;
  DEBUG: boolean;
  LOG_LEVEL: string;
}

const getEnvironmentConfig = (): EnvironmentConfig => {
  const env = import.meta.env.MODE || 'development';
  
  // Vérifier si on a une URL spécifique dans les variables d'environnement
  const customApiUrl = import.meta.env.VITE_API_BASE_URL;
  
  if (customApiUrl) {
    return {
      API_BASE_URL: customApiUrl,
      ENVIRONMENT: env,
      APP_NAME: import.meta.env.VITE_APP_NAME || 'FlightHub',
      APP_VERSION: import.meta.env.VITE_APP_VERSION || '1.0.0',
      DEBUG: import.meta.env.VITE_DEBUG === 'true',
      LOG_LEVEL: import.meta.env.VITE_LOG_LEVEL || 'info'
    };
  }
  
  // Fallback selon l'environnement
  switch (env) {
    case 'production':
      return {
        API_BASE_URL: 'https://api.flighthub.yourdomain.com', // Sera remplacé automatiquement
        ENVIRONMENT: 'production',
        APP_NAME: 'FlightHub',
        APP_VERSION: '1.0.0',
        DEBUG: false,
        LOG_LEVEL: 'info'
      };
    case 'staging':
      return {
        API_BASE_URL: 'https://api-staging.flighthub.yourdomain.com',
        ENVIRONMENT: 'staging',
        APP_NAME: 'FlightHub',
        APP_VERSION: '1.0.0',
        DEBUG: false,
        LOG_LEVEL: 'info'
      };
    default: // development
      return {
        API_BASE_URL: 'http://localhost:8000',
        ENVIRONMENT: 'development',
        APP_NAME: 'FlightHub',
        APP_VERSION: '1.0.0',
        DEBUG: true,
        LOG_LEVEL: 'debug'
      };
  }
};

export const config = getEnvironmentConfig();

// Fonction utilitaire pour logger selon l'environnement
export const logger = {
  debug: (message: string, ...args: any[]) => {
    if (config.DEBUG) {
      console.log(`[DEBUG] ${message}`, ...args);
    }
  },
  info: (message: string, ...args: any[]) => {
    if (config.LOG_LEVEL === 'debug' || config.LOG_LEVEL === 'info') {
      console.log(`[INFO] ${message}`, ...args);
    }
  },
  warn: (message: string, ...args: any[]) => {
    console.warn(`[WARN] ${message}`, ...args);
  },
  error: (message: string, ...args: any[]) => {
    console.error(`[ERROR] ${message}`, ...args);
  }
};

// Fonction pour construire les URLs de l'API
export const buildApiUrl = (endpoint: string): string => {
  const baseUrl = config.API_BASE_URL.replace(/\/$/, ''); // Enlever le slash final
  const cleanEndpoint = endpoint.replace(/^\//, ''); // Enlever le slash initial
  return `${baseUrl}/${cleanEndpoint}`;
};

// Fonction pour vérifier si l'API est accessible
export const checkApiHealth = async (): Promise<boolean> => {
  try {
    const response = await fetch(buildApiUrl('/health'), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return response.ok;
  } catch (error) {
    logger.error('API health check failed:', error);
    return false;
  }
};

// Export par défaut pour compatibilité
export default config;




