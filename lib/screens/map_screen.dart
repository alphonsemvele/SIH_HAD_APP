import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/map_service.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();
  final MapController _mapController = MapController();

  List<Map<String, dynamic>> _patients = [];
  Position? _currentPosition;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  bool _isRouting = false;
  Map<String, dynamic>? _selectedPatient;

  // Centre par défaut : Yaoundé
  static const LatLng _yaoundeCentre = LatLng(3.8480, 11.5021);

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    setState(() => _isLoading = true);
    // En parallèle : position GPS + patients
    final results = await Future.wait([
      _locationService.getCurrentPosition(),
      _mapService.getPatientsMap(),
    ]);

    final position = results[0] as Position?;
    final patientsRes = results[1] as Map<String, dynamic>;

    final List<dynamic> rawPatients = (patientsRes['success'] == true)
        ? (patientsRes['data'] ?? [])
        : [];

    setState(() {
      _currentPosition = position;
      _patients = rawPatients
          .map((p) => Map<String, dynamic>.from(p))
          .where((p) => p['latitude'] != null && p['longitude'] != null)
          .toList();
      _computeDistances();
      _isLoading = false;
    });

    // Centrer la carte sur la position infirmier si dispo
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14.0,
      );
    } else if (_patients.isNotEmpty) {
      // Sinon centrer sur le 1er patient
      _mapController.move(
        LatLng(_patientLat(_patients.first), _patientLng(_patients.first)),
        13.0,
      );
    }
  }

  double _patientLat(Map<String, dynamic> p) {
    final v = p['latitude'];
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double _patientLng(Map<String, dynamic> p) {
    final v = p['longitude'];
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  void _computeDistances() {
    if (_currentPosition == null) return;
    for (var p in _patients) {
      final d = _locationService.distanceKm(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _patientLat(p),
        _patientLng(p),
      );
      p['_distance_km'] = d;
      p['distance'] = '${d.toStringAsFixed(1)} km';
    }
    _patients.sort((a, b) {
      final da = (a['_distance_km'] as double?) ?? 999.0;
      final db = (b['_distance_km'] as double?) ?? 999.0;
      return da.compareTo(db);
    });
  }

  Future<void> _onPatientTap(Map<String, dynamic> patient) async {
    setState(() {
      _selectedPatient = patient;
      _routePoints = [];
      _isRouting = true;
    });

    if (_currentPosition == null) {
      _showSnackBar('GPS désactivé. Activez la position pour calculer l\'itinéraire.', isError: true);
      setState(() => _isRouting = false);
      return;
    }

    final from = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final to = LatLng(_patientLat(patient), _patientLng(patient));

    final route = await _routingService.getRoute(from, to);
    if (route != null) {
      setState(() {
        _routePoints = route['points'] as List<LatLng>;
        _isRouting = false;
      });

      // Recadrer la carte sur la route
      if (_routePoints.isNotEmpty) {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: [from, to, ..._routePoints],
            padding: const EdgeInsets.all(60),
          ),
        );
      }

      final distance = ((route['distance_m'] as double) / 1000).toStringAsFixed(1);
      final duration = ((route['duration_s'] as double) / 60).toStringAsFixed(0);
      _showSnackBar('🗺️ ${patient['nom']} : $distance km, ~$duration min');
    } else {
      setState(() => _isRouting = false);
      _showSnackBar('Itinéraire impossible (hors zone OSRM)', isError: true);
    }
  }

  Future<void> _refreshLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      setState(() {
        _currentPosition = pos;
        _computeDistances();
      });
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
      _showSnackBar('📍 Position : ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
    } else {
      _showSnackBar('GPS désactivé ou permission refusée', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF4433) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _prioriteColor(String? p) {
    switch (p?.toLowerCase()) {
      case 'critique':
        return const Color(0xFFFF4433);
      case 'surveillance':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
          : Stack(
              children: [
                // Vraie carte OSM
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : _yaoundeCentre,
                    initialZoom: 13.0,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sih_had',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5,
                            color: const Color(0xFFFF4433),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            width: 36,
                            height: 36,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12, spreadRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                            ),
                          ),
                        ..._patients.map((patient) {
                          final color = _prioriteColor(patient['priorite'] as String?);
                          final isSelected = _selectedPatient?['id'] == patient['id'];
                          return Marker(
                            point: LatLng(_patientLat(patient), _patientLng(patient)),
                            width: isSelected ? 56 : 44,
                            height: isSelected ? 56 : 44,
                            child: GestureDetector(
                              onTap: () => _onPatientTap(patient),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                                  ],
                                ),
                                child: Icon(
                                  patient['a_visiter_aujourdhui'] == true ? Icons.access_time : Icons.person,
                                  color: Colors.white,
                                  size: isSelected ? 26 : 20,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                _buildTopBar(),
                _buildSideButtons(),
                _buildBottomSheet(),
                if (_isRouting)
                  const Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Card(
                        color: Color(0xFF12121A),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF4433))),
                              SizedBox(width: 12),
                              Text('Calcul itinéraire...', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E1E2A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFF4433), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentPosition != null
                            ? 'Position : ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                            : 'Position GPS non disponible',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideButtons() {
    return Positioned(
      right: 16,
      bottom: 280,
      child: Column(
        children: [
          GestureDetector(
            onTap: _refreshLocation,
            child: _sideButton(Icons.my_location, color: const Color(0xFFFF4433), withShadow: true),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
            child: _sideButton(Icons.add),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
            child: _sideButton(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _sideButton(IconData icon, {Color color = Colors.white, bool withShadow = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E2A)),
        boxShadow: withShadow
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.12,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12121A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
          ),
          child: RefreshIndicator(
            onRefresh: _initMap,
            color: const Color(0xFFFF4433),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFF3A3A4A), borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Patients (${_patients.length})',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_currentPosition != null)
                        const Text('Triés par distance', style: TextStyle(color: Color(0xFFFF4433), fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _patients.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun patient à afficher',
                            style: TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _patients.length,
                          itemBuilder: (context, index) => _buildPatientItem(_patients[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientItem(Map<String, dynamic> patient) {
    final color = _prioriteColor(patient['priorite'] as String?);
    final isSelected = _selectedPatient?['id'] == patient['id'];
    final isVisited = patient['a_visiter_aujourdhui'] == false;

    return GestureDetector(
      onTap: () => _onPatientTap(patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4433) : const Color(0xFF1E1E2A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.person, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${patient['nom'] ?? ''} ${patient['prenom'] ?? ''}'.trim(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    patient['quartier'] ?? patient['adresse'] ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    patient['priorite'] ?? 'Normal',
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient['distance'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
