export interface EnvironmentConfig {
  API_BASE_URL: string;
  ENVIRONMENT: string;
  APP_NAME: string;
  VERSION: string;
}

export const getEnvironmentConfig = (): EnvironmentConfig => {
  const environment = process.env.NODE_ENV || 'development';

  switch (environment) {
    case 'production':
      return {
        API_BASE_URL: 'http://52.90.108.95',
        ENVIRONMENT: 'production',
        APP_NAME: 'FlightHub',
        VERSION: '1.0.0',
      };
    case 'staging':
      return {
        API_BASE_URL: 'http://52.90.108.95',
        ENVIRONMENT: 'staging',
        APP_NAME: 'FlightHub',
        VERSION: '1.0.0',
      };
    default: // development
      return {
        API_BASE_URL: 'http://52.90.108.95',
        ENVIRONMENT: 'development',
        APP_NAME: 'FlightHub',
        VERSION: '1.0.0',
      };
  }
};

export const config = getEnvironmentConfig();