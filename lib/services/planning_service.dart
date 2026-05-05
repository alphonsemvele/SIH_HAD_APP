import 'package:dio/dio.dart';
import 'api_service.dart';

class PlanningService {
  final ApiService _apiService = ApiService();

  // Obtenir tous les événements de planning
  Future<Map<String, dynamic>> getPlanning() async {
    try {
      final response = await _apiService.get('/api/planning');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du planning',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir un événement spécifique
  Future<Map<String, dynamic>> getEvenement(int id) async {
    try {
      final response = await _apiService.get('/api/planning/$id');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération de l\'événement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Créer un nouvel événement de planning
  Future<Map<String, dynamic>> createEvenement(Map<String, dynamic> planningData) async {
    try {
      final response = await _apiService.post('/api/planning', data: planningData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Événement créé avec succès',
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

  // Mettre à jour un événement
  Future<Map<String, dynamic>> updateEvenement(int id, Map<String, dynamic> planningData) async {
    try {
      final response = await _apiService.put('/api/planning/$id', data: planningData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Événement mis à jour avec succès',
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

  // Supprimer un événement
  Future<Map<String, dynamic>> deleteEvenement(int id) async {
    try {
      final response = await _apiService.delete('/api/planning/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Événement supprimé avec succès',
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

  // Obtenir le planning pour une date spécifique
  Future<Map<String, dynamic>> getPlanningByDate(String date) async {
    try {
      final response = await _apiService.get('/api/planning?date=$date');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du planning',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir le planning pour une période
  Future<Map<String, dynamic>> getPlanningByPeriod(String debut, String fin) async {
    try {
      final response = await _apiService.get('/api/planning?debut=$debut&fin=$fin');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du planning',
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
