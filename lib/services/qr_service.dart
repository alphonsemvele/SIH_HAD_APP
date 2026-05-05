import 'package:dio/dio.dart';
import 'api_service.dart';

class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();

  final ApiService _apiService = ApiService();

  /// Scanner un QR code et récupérer les informations de la visite
  Future<Map<String, dynamic>> scanQrCode(String payload, {double? lat, double? lng}) async {
    try {
      final Map<String, dynamic> data = {
        'payload': payload,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
      };

      // Pour l'instant, on utilise le payload directement
      // TODO: Adapter l'endpoint backend quand il sera prêt
      final response = await _apiService.post('/api/had/qr-codes/scan-from-payload', data: data);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors du scan du QR code: ${response.statusCode}');
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
}
