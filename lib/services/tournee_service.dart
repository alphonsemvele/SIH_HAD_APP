import 'api_service.dart';
import '../config/api_config.dart';

class TourneeService {
  final ApiService _apiService = ApiService();

  // Obtenir toutes les tournées
  Future<Map<String, dynamic>> getTournees() async {
    try {
      final response = await _apiService.get(ApiConfig.tournees);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
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

  // Obtenir une tournée spécifique
  Future<Map<String, dynamic>> getTournee(int id) async {
    try {
      final response = await _apiService.get(ApiConfig.tournee(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération de la tournée',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Créer une nouvelle tournée
  Future<Map<String, dynamic>> createTournee(Map<String, dynamic> tourneeData) async {
    try {
      final response = await _apiService.post(ApiConfig.tournees, data: tourneeData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Tournée créée avec succès',
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

  // Démarrer une tournée
  Future<Map<String, dynamic>> demarrerTournee(int id) async {
    try {
      final response = await _apiService.post(ApiConfig.tourneeDemarrer(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Tournée démarrée avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du démarrage de la tournée',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Terminer une tournée
  Future<Map<String, dynamic>> terminerTournee(int id) async {
    try {
      final response = await _apiService.post(ApiConfig.tourneeTerminer(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Tournée terminée avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la terminaison de la tournée',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Suspendre une tournée
  Future<Map<String, dynamic>> suspendreTournee(int id) async {
    try {
      final response = await _apiService.post(ApiConfig.tourneeSuspendre(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Tournée suspendue avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la suspension de la tournée',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Annuler une tournée
  Future<Map<String, dynamic>> annulerTournee(int id) async {
    try {
      final response = await _apiService.post(ApiConfig.tourneeAnnuler(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Tournée annulée avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de l\'annulation de la tournée',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Valider une visite dans une tournée
  Future<Map<String, dynamic>> validerVisite(int tourneeId, int visiteId) async {
    try {
      final response = await _apiService.post(ApiConfig.tourneeValiderVisite(tourneeId, visiteId));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Visite validée avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la validation de la visite',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }


  /// GET /api/tournees/{id}/visites
  Future<Map<String, dynamic>> getTourneeVisites(int tourneeId) async {
    try {
      final response = await _apiService.get('/api/tournees/$tourneeId/visites');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }


  /// GET /api/tournees?date_filter=upcoming|past|today
  Future<Map<String, dynamic>> getTourneesParFiltre(String dateFilter) async {
    try {
      final response = await _apiService.get('/api/tournees', queryParameters: {'date_filter': dateFilter});
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}