import 'package:dio/dio.dart';
import 'api_service.dart';

class AlerteService {
  final ApiService _apiService = ApiService();

  // Obtenir toutes les alertes
  Future<Map<String, dynamic>> getAlertes() async {
    try {
      final response = await _apiService.get('/api/alertes');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des alertes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir une alerte spécifique
  Future<Map<String, dynamic>> getAlerte(int id) async {
    try {
      final response = await _apiService.get('/api/alertes/$id');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération de l\'alerte',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Créer une nouvelle alerte
  Future<Map<String, dynamic>> createAlerte(Map<String, dynamic> alerteData) async {
    try {
      final response = await _apiService.post('/api/alertes', data: alerteData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Alerte créée avec succès',
        };
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

  // Mettre à jour une alerte
  Future<Map<String, dynamic>> updateAlerte(int id, Map<String, dynamic> alerteData) async {
    try {
      final response = await _apiService.put('/api/alertes/$id', data: alerteData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Alerte mise à jour avec succès',
        };
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

  // Supprimer une alerte
  Future<Map<String, dynamic>> deleteAlerte(int id) async {
    try {
      final response = await _apiService.delete('/api/alertes/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Alerte supprimée avec succès',
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

  // Rechercher des alertes
  Future<Map<String, dynamic>> searchAlertes(String query) async {
    try {
      final response = await _apiService.get('/api/alertes?search=$query');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la recherche des alertes',
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
