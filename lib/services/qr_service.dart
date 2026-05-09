import 'package:dio/dio.dart';
import 'api_service.dart';

class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> scanQrCode(
    String scannedText, {
    double? lat,
    double? lng,
    int? precisionM,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      String uuid = scannedText.trim();
      if (uuid.contains('/qr/')) {
        uuid = uuid.substring(uuid.lastIndexOf('/qr/') + 4);
      }
      if (uuid.contains('?')) {
        uuid = uuid.substring(0, uuid.indexOf('?'));
      }

      final body = <String, dynamic>{
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (precisionM != null) 'precision_m': precisionM,
        if (deviceInfo != null) 'device_info': deviceInfo,
      };

      final response = await _apiService.post(
        '/api/had/qr-codes/$uuid/scan',
        data: body,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Scan échoué : HTTP ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erreur réseau : ${e.message}';
      throw Exception(msg);
    }
  }
}
