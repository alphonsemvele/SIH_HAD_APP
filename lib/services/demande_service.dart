import 'api_service.dart';

class DemandeService {
  final ApiService _apiService = ApiService();

  /// GET /api/demandes-visite?statut=en_attente|acceptees|terminees
  Future<Map<String, dynamic>> getDemandes({String? statut, bool mesDemandes = false}) async {
    try {
      final Map<String, dynamic> query = {};
      if (statut != null) query['statut'] = statut;
      if (mesDemandes) query['mes_demandes'] = true;

      final response = await _apiService.get(
        '/api/demandes-visite',
        queryParameters: query.isEmpty ? null : query,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/demandes-visite/{id}
  Future<Map<String, dynamic>> getDemande(int id) async {
    try {
      final response = await _apiService.get('/api/demandes-visite/$id');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/demandes-visite (public, pas d'auth)
  Future<Map<String, dynamic>> creerDemande(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/api/demandes-visite', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Demande créée avec succès',
        };
      } else if (response.statusCode == 422) {
        String errorMessage = 'Erreur de validation:';
        final errors = response.data['errors'] ?? {};
        errors.forEach((field, messages) {
          errorMessage += '\n• ${messages.join(', ')}';
        });
        return {'success': false, 'message': errorMessage};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/demandes-visite/{id}/accepter
  Future<Map<String, dynamic>> accepterDemande(
    int id, {
    String? dateVisite,
    String? heureVisite,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (dateVisite != null) body['date_visite'] = dateVisite;
      if (heureVisite != null) body['heure_visite'] = heureVisite;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;

      final response = await _apiService.post(
        '/api/demandes-visite/$id/accepter',
        data: body,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/demandes-visite/{id}/refuser
  Future<Map<String, dynamic>> refuserDemande(int id, String raison) async {
    try {
      final response = await _apiService.post(
        '/api/demandes-visite/$id/refuser',
        data: {'raison': raison},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /api/demandes-visite/{id}/terminer
  Future<Map<String, dynamic>> terminerDemande(int id, {String? notes}) async {
    try {
      final response = await _apiService.post(
        '/api/demandes-visite/$id/terminer',
        data: notes != null ? {'notes': notes} : {},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Erreur HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
