import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _api = ApiClient();

  /// POST /api/patient/login
  /// Retourne { success: bool, message?: String, user?: Map, token?: String }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.dio.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        final token = res.data['data']?['token']?.toString();
        final user  = res.data['data']?['user'] as Map<String, dynamic>?;

        if (token != null) {
          await _api.setToken(token);
        }
        return {'success': true, 'user': user, 'token': token};
      }

      return {
        'success': false,
        'message': res.data['message'] ?? 'Connexion échouée',
      };
    } on DioException catch (e) {
      final msg = e.response?.data?['message']
          ?? e.response?.data?['error']
          ?? 'Email ou mot de passe incorrect';
      return {'success': false, 'message': msg.toString()};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// GET /api/patient/me — vérifie que le token est encore valide
  /// Retourne le user ou null si non authentifié.
  Future<Map<String, dynamic>?> me() async {
    try {
      final res = await _api.dio.get(ApiConfig.me);
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data']?['user'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// POST /api/patient/logout
  Future<void> logout() async {
    try {
      await _api.dio.post(ApiConfig.logout);
    } catch (_) {
      // peu importe si l'appel échoue, on supprime le token local
    }
    await _api.setToken(null);
  }

  Future<bool> hasToken() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }
}
