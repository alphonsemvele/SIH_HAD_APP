/// Configuration de l'API patient
class ApiConfig {
  // Sur émulateur Android, localhost = 10.0.2.2 (loopback de l'hôte)
  // Sur device physique, mets l'IP de ta machine (ex: http://192.168.1.42:8000)
  // Sur iOS simulator, localhost fonctionne directement
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api/patient';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Endpoints
  static const String login   = '$apiPrefix/login';
  static const String logout  = '$apiPrefix/logout';
  static const String me      = '$apiPrefix/me';
  static const String visites = '$apiPrefix/visites';
}
