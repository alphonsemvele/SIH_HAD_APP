import 'package:dio/dio.dart';
import 'api_service.dart';

class MapService {
  final ApiService _apiService = ApiService();

  // Obtenir les patients pour la carte
  Future<Map<String, dynamic>> getPatientsMap() async {
    try {
      final response = await _apiService.get('/api/patients/map');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients pour la carte',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les patients géolocalisés
  Future<Map<String, dynamic>> getPatientsGeolocalises() async {
    try {
      final response = await _apiService.get('/api/patients/geolocalises');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients géolocalisés',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir la géolocalisation d'un patient spécifique
  Future<Map<String, dynamic>> getPatientGeolocalisation(int patientId) async {
    try {
      final response = await _apiService.get('/api/patients/$patientId/geolocalisation');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération de la géolocalisation du patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Mettre à jour la géolocalisation d'un patient
  Future<Map<String, dynamic>> updatePatientGeolocalisation(int patientId, Map<String, dynamic> geoData) async {
    try {
      final response = await _apiService.put('/api/patients/$patientId/geolocalisation', data: geoData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Géolocalisation mise à jour avec succès',
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

  // Obtenir les zones de visites
  Future<Map<String, dynamic>> getZonesVisites() async {
    try {
      final response = await _apiService.get('/api/zones-visites');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des zones de visites',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir l'itinéraire optimisé
  Future<Map<String, dynamic>> getItineraireOptimise(Map<String, dynamic> params) async {
    try {
      final response = await _apiService.post('/api/itineraire/optimiser', data: params);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
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

  // Obtenir les statistiques des zones
  Future<Map<String, dynamic>> getStatistiquesZones() async {
    try {
      final response = await _apiService.get('/api/zones/statistiques');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des statistiques des zones',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Filtrer les patients par quartier
  Future<Map<String, dynamic>> getPatientsByQuartier(String quartier) async {
    try {
      final response = await _apiService.get('/api/patients/map?quartier=$quartier');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients du quartier',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Filtrer les patients par priorité
  Future<Map<String, dynamic>> getPatientsByPriorite(String priorite) async {
    try {
      final response = await _apiService.get('/api/patients/map?priorite=$priorite');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients par priorité',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les patients à visiter aujourd'hui
  Future<Map<String, dynamic>> getPatientsAVisiterAujourdhui() async {
    try {
      final response = await _apiService.get('/api/patients/map?a_visiter_aujourdhui=true');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients à visiter aujourd\'hui',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les patients en retard de visite
  Future<Map<String, dynamic>> getPatientsRetardVisite() async {
    try {
      final response = await _apiService.get('/api/patients/map?retard_visite=true');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients en retard de visite',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Calculer la distance entre deux points
  Future<Map<String, dynamic>> calculerDistance(Map<String, dynamic> params) async {
    try {
      final response = await _apiService.post('/api/calculer-distance', data: params);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du calcul de la distance',
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
