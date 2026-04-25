import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.auth,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true) {
          final token = data['data']['token'];
          final userData = data['data']['user'];
          
          // Sauvegarder le token Sanctum et les infos utilisateur
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_email', userData['email']);
          await prefs.setString('user_name', userData['name']);
          await prefs.setString('user_role', userData['role']);
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('user', userData.toString());
          
          // Mettre à jour le token dans ApiService pour les futures requêtes
          await _apiService.setAuthToken(token);
          
          return {
            'success': true,
            'data': userData,
            'message': data['message'] ?? 'Connexion réussie',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur lors de la connexion',
          };
        }
      } else if (response.statusCode == 422) {
        // Erreur de validation
        String errorMessage = 'Erreur de validation:';
        final errors = response.data['errors'] ?? {};
        errors.forEach((field, messages) {
          errorMessage += '\n• ${messages.join(', ')}';
        });
        return {
          'success': false,
          'message': errorMessage,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}: ${response.data['message'] ?? 'Erreur inconnue'}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(ApiConfig.logout);
      
      // Nettoyer le stockage local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user');
      
      // Nettoyer le token dans ApiService
      await _apiService.setAuthToken(null);
      
      return {
        'success': true,
        'message': 'Déconnexion réussie',
      };
    } catch (e) {
      // Même si l'API échoue, on nettoie le stockage local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user');
      
      // Nettoyer le token dans ApiService
      await _apiService.setAuthToken(null);
      
      return {
        'success': true,
        'message': 'Déconnexion locale réussie',
      };
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final email = prefs.getString('user_email');
    return isLoggedIn && email != null && email.isNotEmpty;
  }

  // Obtenir le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Obtenir les infos utilisateur
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn && email != null) {
      return {
        'email': email,
        'name': 'Anne Ngo Likeng', // À adapter dynamiquement
        'role': 'infirmiere',
      };
    }
    return null;
  }

  // Rafraîchir le token (si votre backend le supporte)
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post('${ApiConfig.baseUrl}/refresh-token');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        
        if (data['token'] != null) {
          await prefs.setString('auth_token', data['token']);
        }
        
        return {
          'success': true,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': 'Impossible de rafraîchir le token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
