import 'package:dio/dio.dart';
import 'api_service.dart';

class VisiteService {
  static final VisiteService _instance = VisiteService._internal();
  factory VisiteService() => _instance;
  VisiteService._internal();
  final ApiService _apiService = ApiService();

  /// Envoyer la réalisation d'une visite avec multipart.
  Future<Map<String, dynamic>> envoyerRealisationVisite(int visiteId, FormData data) async {
    try {
      final response = await _apiService.dio.post(
        '/api/had/visites/$visiteId/realisation',
        data: data,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          // Augmente les timeouts pour les uploads multipart avec photos
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data ?? {});
      }
      throw Exception('Erreur HTTP ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erreur réseau : ${e.message ?? "inconnue"}';
      throw Exception(msg);
    }
  }

  /// Pas de retry pour le moment (FormData ne peut pas être réutilisé).
  /// Si retry nécessaire, le caller doit reconstruire le FormData.
  Future<Map<String, dynamic>> envoyerRealisationVisiteAvecRetry(
    int visiteId,
    FormData data, {
    int maxRetries = 1,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    return envoyerRealisationVisite(visiteId, data);
  }
}
