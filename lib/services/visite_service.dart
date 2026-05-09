import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
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

  Future<Map<String, dynamic>> envoyerRealisationVisiteAvecRetry(
    int visiteId,
    FormData data, {
    int maxRetries = 1,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    return envoyerRealisationVisite(visiteId, data);
  }

  /// Télécharge la preuve PDF d'une visite et l'ouvre dans un viewer natif.
  /// Retourne le chemin local du fichier ou throw en cas d'erreur.
  Future<String> telechargerEtOuvrirPreuve(int visiteId) async {
    try {
      // 1. Téléchargement en bytes
      final response = await _apiService.dio.get(
        '/api/had/visites/$visiteId/preuve',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/pdf'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur téléchargement PDF (HTTP ${response.statusCode})');
      }

      // 2. Sauvegarde dans le dossier temp
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/preuve_visite_$visiteId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.data as List<int>);

      // 3. Ouvrir avec un viewer natif
      final result = await OpenFilex.open(filePath, type: 'application/pdf');
      if (result.type != ResultType.done) {
        throw Exception('Impossible d\'ouvrir le PDF : ${result.message}');
      }

      return filePath;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erreur réseau : ${e.message ?? "inconnue"}';
      throw Exception(msg);
    }
  }
}
