enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get apiUrl {
    switch (_environment) {
      case Environment.development:
        return "http://localhost:3000/api/v1";
      case Environment.staging:
        return "https://staging-api.starlist.com/api/v1";
      case Environment.production:
        return "https://api.starlist.com/api/v1";
    }
  }

  static Map<String, dynamic> get firebaseConfig {
    switch (_environment) {
      case Environment.development:
        return {
          "apiKey": "your-dev-api-key",
          "authDomain": "starlist-dev.firebaseapp.com",
          "projectId": "starlist-dev",
          "storageBucket": "starlist-dev.appspot.com",
          "messagingSenderId": "your-dev-sender-id",
          "appId": "your-dev-app-id",
        };
      case Environment.staging:
        return {
          "apiKey": "your-staging-api-key",
          "authDomain": "starlist-staging.firebaseapp.com",
          "projectId": "starlist-staging",
          "storageBucket": "starlist-staging.appspot.com",
          "messagingSenderId": "your-staging-sender-id",
          "appId": "your-staging-app-id",
        };
      case Environment.production:
        return {
          "apiKey": "your-prod-api-key",
          "authDomain": "starlist-prod.firebaseapp.com",
          "projectId": "starlist-prod",
          "storageBucket": "starlist-prod.appspot.com",
          "messagingSenderId": "your-prod-sender-id",
          "appId": "your-prod-app-id",
        };
    }
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}
