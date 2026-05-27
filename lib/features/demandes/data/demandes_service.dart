import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/demande_visite.dart';

class DemandesService {
  final ApiClient _api = ApiClient();
  static const String _base = '/api/patient/demandes-visite';

  Future<List<DemandeVisite>> list() async {
    try {
      final res = await _api.dio.get(_base);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as List? ?? [];
        return data
            .whereType<Map>()
            .map((m) => DemandeVisite.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'Erreur lors du chargement des demandes',
      );
    }
  }

  /// Renvoie {success, demande?, message?, errors?}
  Future<Map<String, dynamic>> create({
    required String symptomes,
    required String urgence,
    String? dureeSymptomes,
    String? dateSouhaitee,   // YYYY-MM-DD
    String? heureSouhaitee,  // HH:mm
  }) async {
    try {
      final body = <String, dynamic>{
        'symptomes': symptomes,
        'urgence':   urgence,
      };
      if (dureeSymptomes != null && dureeSymptomes.isNotEmpty) {
        body['duree_symptomes'] = dureeSymptomes;
      }
      if (dateSouhaitee != null && dateSouhaitee.isNotEmpty) {
        body['date_souhaitee'] = dateSouhaitee;
      }
      if (heureSouhaitee != null && heureSouhaitee.isNotEmpty) {
        body['heure_souhaitee'] = heureSouhaitee;
      }

      final res = await _api.dio.post(_base, data: body);
      if (res.statusCode == 201 && res.data['success'] == true) {
        return {
          'success': true,
          'demande': DemandeVisite.fromJson(
            Map<String, dynamic>.from(res.data['data'] ?? {}),
          ),
          'message': res.data['message'] ?? 'Demande envoyée',
        };
      }
      return {'success': false, 'message': res.data['message'] ?? 'Échec'};
    } on DioException catch (e) {
      final data = e.response?.data;
      return {
        'success': false,
        'message': data?['message']?.toString() ?? 'Erreur réseau',
        'errors':  data?['errors'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
