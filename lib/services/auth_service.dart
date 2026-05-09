import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  final ApiService _apiService = ApiService();

  /// POST /api/login → { success, token, user }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/api/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Extraire token (peut être à la racine ou dans data)
        String? token = data['token']?.toString()
            ?? data['data']?['token']?.toString();
        Map<String, dynamic>? user;
        if (data['user'] != null) {
          user = Map<String, dynamic>.from(data['user']);
        } else if (data['data']?['user'] != null) {
          user = Map<String, dynamic>.from(data['data']['user']);
        }

        if (token != null) {
          await _apiService.setAuthToken(token);
        }

        return {
          'success': true,
          'token': token,
          'user': user,
          'message': 'Connexion réussie',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']
          ?? e.response?.data?['error']
          ?? 'Identifiants incorrects';
      return {'success': false, 'message': msg.toString()};
    } catch (e) {
      return {'success': false, 'message': 'Erreur : $e'};
    }
  }

  /// POST /api/logout
  Future<bool> logout() async {
    try {
      await _apiService.post('/api/logout');
      await _apiService.setAuthToken(null);
      return true;
    } catch (_) {
      try { await _apiService.setAuthToken(null); } catch (_) {}
      return false;
    }
  }

  /// GET /api/me → user complet
  Future<Map<String, dynamic>?> getMe() async {
    try {
      final res = await _apiService.get('/api/me');
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(res.data['data']?['user'] ?? {});
      }
    } catch (_) {}
    return null;
  }

  /// GET /api/me/stats → stats personnelles
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final res = await _apiService.get('/api/me/stats');
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(res.data['data'] ?? {});
      }
    } catch (_) {}
    return null;
  }
}
