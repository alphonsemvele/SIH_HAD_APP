import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../config/api_config.dart';

/// Client OSRM — calcule un itinéraire entre 2 ou plusieurs points.
class RoutingService {
  static final RoutingService _instance = RoutingService._internal();
  factory RoutingService() => _instance;
  RoutingService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.osrmUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Calcule l'itinéraire (driving) entre [from] et [to].
  /// Retourne { points: List<LatLng>, distance_m, duration_s } ou null.
  Future<Map<String, dynamic>?> getRoute(LatLng from, LatLng to) async {
    final coords = '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
    final url = '/route/v1/driving/$coords?overview=full&geometries=geojson';

    try {
      final response = await _dio.get(url);
      if (response.statusCode != 200) return null;

      final data = response.data;
      if (data['code'] != 'Ok') return null;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes[0];
      final geometry = route['geometry'];
      final coordinates = (geometry['coordinates'] as List?) ?? [];

      // OSRM renvoie [lng, lat] - on inverse pour LatLng
      final points = coordinates
          .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      return {
        'points': points,
        'distance_m': (route['distance'] ?? 0).toDouble(),
        'duration_s': (route['duration'] ?? 0).toDouble(),
      };
    } catch (e) {
      return null;
    }
  }

  /// Multi-stops : calcule l'itinéraire optimisé entre tous les points.
  Future<Map<String, dynamic>?> getOptimizedRoute(List<LatLng> stops) async {
    if (stops.length < 2) return null;

    final coords = stops.map((p) => '${p.longitude},${p.latitude}').join(';');
    final url = '/trip/v1/driving/$coords?overview=full&geometries=geojson&source=first&roundtrip=false';

    try {
      final response = await _dio.get(url);
      if (response.statusCode != 200) return null;
      final data = response.data;
      if (data['code'] != 'Ok') return null;

      final trips = data['trips'] as List?;
      if (trips == null || trips.isEmpty) return null;

      final trip = trips[0];
      final coordinates = (trip['geometry']['coordinates'] as List?) ?? [];
      final points = coordinates
          .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      // Ordre optimisé des waypoints
      final waypoints = (data['waypoints'] as List?) ?? [];
      final orderedIndices = waypoints
          .map<int>((w) => (w['waypoint_index'] ?? 0) as int)
          .toList();

      return {
        'points': points,
        'distance_m': (trip['distance'] ?? 0).toDouble(),
        'duration_s': (trip['duration'] ?? 0).toDouble(),
        'order': orderedIndices,
      };
    } catch (e) {
      return null;
    }
  }
}
