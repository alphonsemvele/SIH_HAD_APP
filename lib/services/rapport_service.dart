import 'package:dio/dio.dart';
import 'api_service.dart';

class RapportService {
  final ApiService _apiService = ApiService();

  // Obtenir tous les rapports
  Future<Map<String, dynamic>> getRapports() async {
    try {
      final response = await _apiService.get('/api/rapports');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des rapports',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir un rapport spécifique
  Future<Map<String, dynamic>> getRapport(int id) async {
    try {
      final response = await _apiService.get('/api/rapports/$id');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du rapport',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Créer un nouveau rapport
  Future<Map<String, dynamic>> createRapport(Map<String, dynamic> rapportData) async {
    try {
      final response = await _apiService.post('/api/rapports', data: rapportData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Rapport créé avec succès',
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

  // Mettre à jour un rapport
  Future<Map<String, dynamic>> updateRapport(int id, Map<String, dynamic> rapportData) async {
    try {
      final response = await _apiService.put('/api/rapports/$id', data: rapportData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Rapport mis à jour avec succès',
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

  // Supprimer un rapport
  Future<Map<String, dynamic>> deleteRapport(int id) async {
    try {
      final response = await _apiService.delete('/api/rapports/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Rapport supprimé avec succès',
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

  // Télécharger un rapport
  Future<Map<String, dynamic>> telechargerRapport(int id) async {
    try {
      final response = await _apiService.get('/api/rapports/$id/telecharger');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du téléchargement du rapport',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Générer un rapport automatiquement
  Future<Map<String, dynamic>> genererRapport(Map<String, dynamic> generationData) async {
    try {
      final response = await _apiService.post('/api/rapports/generer', data: generationData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Rapport généré avec succès',
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

  // Obtenir les types de rapports disponibles
  Future<Map<String, dynamic>> getTypesRapports() async {
    try {
      final response = await _apiService.get('/api/rapports/types');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des types de rapports',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les statistiques des rapports
  Future<Map<String, dynamic>> getRapportsStats() async {
    try {
      final response = await _apiService.get('/api/rapports/stats');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des statistiques',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Filtrer les rapports par type
  Future<Map<String, dynamic>> getRapportsByType(String type) async {
    try {
      final response = await _apiService.get('/api/rapports?type=$type');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des rapports',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Filtrer les rapports par période
  Future<Map<String, dynamic>> getRapportsByPeriod(String debut, String fin) async {
    try {
      final response = await _apiService.get('/api/rapports?debut=$debut&fin=$fin');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des rapports',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Filtrer les rapports par statut
  Future<Map<String, dynamic>> getRapportsByStatus(String status) async {
    try {
      final response = await _apiService.get('/api/rapports?status=$status');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des rapports',
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
