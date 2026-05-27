import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../models/visit.dart';

class VisitsService {
  final ApiClient _api = ApiClient();

  Future<List<Visit>> getVisites() async {
    try {
      final res = await _api.dio.get(ApiConfig.visites);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as List? ?? [];
        return data
            .whereType<Map>()
            .map((m) => Visit.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'Erreur lors du chargement des visites',
      );
    }
  }
}
