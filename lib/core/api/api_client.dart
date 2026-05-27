import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// Client HTTP unique pour l'app patient.
/// Gère token Bearer + injection automatique dans les requêtes.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String _tokenKey = 'patient_token';

  late final Dio _dio;
  String? _currentToken;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: Map.from(ApiConfig.defaultHeaders),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_currentToken == null) {
          final prefs = await SharedPreferences.getInstance();
          _currentToken = prefs.getString(_tokenKey);
        }
        if (_currentToken != null) {
          options.headers['Authorization'] = 'Bearer $_currentToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 -> token invalide ou expiré, on le supprime
        if (error.response?.statusCode == 401) {
          await setToken(null);
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> setToken(String? token) async {
    _currentToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(_tokenKey);
    return _currentToken;
  }
}
