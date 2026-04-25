import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _currentToken;
  
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ));

    // Interceptor pour ajouter le token d'authentification
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_currentToken != null) {
          options.headers['Authorization'] = 'Bearer $_currentToken';
        } else {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            _currentToken = token;
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Si erreur 401 (non autorisé), on déconnecte l'utilisateur
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          await prefs.remove('user');
          // Ici vous pouvez ajouter une redirection vers la page de login
        }
        handler.next(error);
      },
    ));

    // Interceptor pour le logging (en développement uniquement)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));
  }

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String endpoint, {dynamic data}) async {
    try {
      return await _dio.patch(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<Response> upload(String endpoint, String filePath, {Map<String, dynamic>? data}) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });
      return await _dio.post(endpoint, data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gestion des erreurs
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Délai de connexion dépassé';
        case DioExceptionType.sendTimeout:
          return 'Délai d\'envoi dépassé';
        case DioExceptionType.receiveTimeout:
          return 'Délai de réception dépassé';
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return 'Non autorisé - Veuillez vous reconnecter';
          } else if (error.response?.statusCode == 404) {
            return 'Ressource non trouvée';
          } else if (error.response?.statusCode == 500) {
            return 'Erreur serveur interne';
          } else {
            return 'Erreur HTTP: ${error.response?.statusCode}';
          }
        case DioExceptionType.cancel:
          return 'Requête annulée';
        case DioExceptionType.connectionError:
          return 'Erreur de connexion au serveur';
        case DioExceptionType.badCertificate:
          return 'Erreur de certificat SSL';
        case DioExceptionType.unknown:
          return 'Erreur inconnue: ${error.message}';
      }
    }
    return 'Erreur inconnue: $error';
  }

  // Pour accéder directement à Dio si nécessaire
  Dio get dio => _dio;

  // Mettre à jour le token d'authentification
  Future<void> setAuthToken(String? token) async {
    _currentToken = token;
    
    // Sauvegarder dans SharedPreferences pour la persistance
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }
}
