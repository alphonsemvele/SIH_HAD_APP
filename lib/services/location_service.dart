import 'package:geolocator/geolocator.dart';

/// Service GPS — gère les permissions et la position courante du device.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastPosition;

  /// Demande la permission + retourne la position courante.
  /// Retourne null si refusé ou si GPS désactivé.
  Future<Position?> getCurrentPosition({bool useCache = false}) async {
    if (useCache && _lastPosition != null) return _lastPosition;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastPosition = pos;
      return pos;
    } catch (e) {
      // Fallback : dernière position connue
      try {
        final last = await Geolocator.getLastKnownPosition();
        return last;
      } catch (_) {
        return null;
      }
    }
  }

  /// Distance en km entre 2 points GPS (Haversine via Geolocator).
  double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
  }

  Position? get lastKnownPosition => _lastPosition;
}
