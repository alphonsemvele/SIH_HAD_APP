import 'package:dio/dio.dart';
import 'api_service.dart';

class VisiteService {
  static final VisiteService _instance = VisiteService._internal();
  factory VisiteService() => _instance;
  VisiteService._internal();

  final ApiService _apiService = ApiService();

  /// Envoyer la réalisation d'une visite avec les données multipart
  Future<Map<String, dynamic>> envoyerRealisationVisite(int visiteId, FormData data) async {
    try {
      final response = await _apiService.dio.post(
        '/api/had/visites/$visiteId/realisation',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de l\'envoi de la réalisation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Tenter d'envoyer les données avec retry et backoff
  Future<Map<String, dynamic>> envoyerRealisationVisiteAvecRetry(
    int visiteId, 
    FormData data, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxRetries) {
      try {
        return await envoyerRealisationVisite(visiteId, data);
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Attendre avec backoff exponentiel
        await Future.delayed(delay);
        delay = delay * 2; // Backoff exponentiel
      }
    }
    
    throw Exception('Échec après $maxRetries tentatives');
  }
}
