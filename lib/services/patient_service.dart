import 'api_service.dart';
import '../config/api_config.dart';

class PatientService {
  final ApiService _apiService = ApiService();

  // Obtenir tous les patients
  Future<Map<String, dynamic>> getPatients({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _apiService.get(ApiConfig.patients, queryParameters: queryParameters);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des patients',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir un patient spécifique
  Future<Map<String, dynamic>> getPatient(int id) async {
    try {
      final response = await _apiService.get(ApiConfig.patient(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Créer un nouveau patient
  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await _apiService.post(ApiConfig.patients, data: patientData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // API retourne 201 (créé) ou 200 (OK) après création réussie
        return {
          'success': true,
          'data': response.data,
          'message': 'Patient créé avec succès',
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

  // Mettre à jour un patient
  Future<Map<String, dynamic>> updatePatient(int id, Map<String, dynamic> patientData) async {
    try {
      final response = await _apiService.put(ApiConfig.patient(id), data: patientData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Patient mis à jour avec succès',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la mise à jour du patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Supprimer un patient
  Future<Map<String, dynamic>> deletePatient(int id) async {
    try {
      final response = await _apiService.delete(ApiConfig.patient(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Patient supprimé avec succès',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la suppression du patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir le dossier médical d'un patient
  Future<Map<String, dynamic>> getPatientDossier(int id) async {
    try {
      final response = await _apiService.get(ApiConfig.patientDossier(id));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du dossier médical',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Rechercher des patients
  Future<Map<String, dynamic>> searchPatients(String query) async {
    try {
      final response = await _apiService.get(ApiConfig.patients, queryParameters: {
        'search': query,
      });
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la recherche des patients',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Filtrer les patients par critères
  Future<Map<String, dynamic>> filterPatients({
    String? quartier,
    String? diagnostic,
    String? priorite,
    int? ageMin,
    int? ageMax,
  }) async {
    Map<String, dynamic> queryParams = {};
    
    if (quartier != null) queryParams['quartier'] = quartier;
    if (diagnostic != null) queryParams['diagnostic'] = diagnostic;
    if (priorite != null) queryParams['priorite'] = priorite;
    if (ageMin != null) queryParams['age_min'] = ageMin;
    if (ageMax != null) queryParams['age_max'] = ageMax;

    try {
      final response = await _apiService.get(ApiConfig.patients, queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du filtrage des patients',
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
