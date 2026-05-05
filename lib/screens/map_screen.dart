import 'package:flutter/material.dart';
import '../services/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientsMap();
  }

  Future<void> _loadPatientsMap() async {
    setState(() => _isLoading = true);

    try {
      final result = await _mapService.getPatientsMap();

      if (result['success']) {
        final List<dynamic> raw = result['data'] ?? [];
        setState(() {
          _patients = raw
              .map((p) => _mapPatientFromApi(Map<String, dynamic>.from(p)))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar(result['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur: ${e.toString()}');
    }
  }

  Future<void> _refreshPatients() async {
    await _loadPatientsMap();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4433),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Map<String, dynamic> _mapPatientFromApi(Map<String, dynamic> patient) {
    return {
      'id': patient['id'],
      'nom': patient['nom'] ?? 'Sans nom',
      'quartier': patient['quartier'] ?? 'Non spécifié',
      'priorite': patient['priorite'] ?? 'Normal',
      'distance': '${patient['distance'] ?? '0.0'} km',
      'visite': patient['a_visiter_aujourdhui'] ?? false,
      'latitude': patient['latitude'],
      'longitude': patient['longitude'],
      'derniere_visite': patient['derniere_visite'],
      'prochaine_visite': patient['prochaine_visite'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4433)),
            )
          : Stack(
              children: [
                _buildFakeMapBackground(),
                ..._buildMarkers(_patients),
                _buildTopBar(),
                _buildSideButtons(),
                _buildBottomSheet(),
              ],
            ),
    );
  }

  Widget _buildFakeMapBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: CustomPaint(
        painter: MapGridPainter(),
        size: Size.infinite,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E1E2A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF6B6B7B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rechercher une adresse...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF12121A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E2A)),
              ),
              child: const Icon(Icons.layers, color: Colors.white, size: 22),
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
          _sideButton(Icons.my_location, color: const Color(0xFFFF4433), withShadow: true),
          const SizedBox(height: 10),
          _sideButton(Icons.add),
          const SizedBox(height: 4),
          _sideButton(Icons.remove),
        ],
      ),
    );
  }

  Widget _sideButton(IconData icon, {Color color = Colors.white, bool withShadow = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E2A)),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12121A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
          ),
          child: RefreshIndicator(
            onRefresh: _refreshPatients,
            color: const Color(0xFFFF4433),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A4A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Patients à proximité',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4433).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.navigation,
                              color: Color(0xFFFF4433),
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Itinéraire',
                              style: TextStyle(
                                color: Color(0xFFFF4433),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _patients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun patient à proximité',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            return _buildPatientItem(_patients[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMarkers(List<Map<String, dynamic>> patients) {
    final positions = [
      const Offset(80, 200),
      const Offset(200, 280),
      const Offset(280, 180),
      const Offset(150, 400),
      const Offset(100, 320),
      const Offset(250, 350),
    ];

    return List.generate(patients.length.clamp(0, positions.length), (index) {
      final patient = patients[index];
      final pos = positions[index];

      Color color;
      switch (patient['priorite']) {
        case 'Critique':
          color = const Color(0xFFFF4433);
          break;
        case 'Surveillance':
          color = const Color(0xFFFF9800);
          break;
        default:
          color = const Color(0xFF4CAF50);
      }

      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                patient['visite'] == true ? Icons.check : Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            Container(width: 3, height: 10, color: color),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPatientItem(Map<String, dynamic> patient) {
    Color prioriteColor;
    switch (patient['priorite']) {
      case 'Critique':
        prioriteColor = const Color(0xFFFF4433);
        break;
      case 'Surveillance':
        prioriteColor = const Color(0xFFFF9800);
        break;
      default:
        prioriteColor = const Color(0xFF4CAF50);
    }

    final isVisited = patient['visite'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVisited
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : const Color(0xFF1E1E2A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: prioriteColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isVisited
                  ? const Icon(Icons.check, color: Color(0xFF4CAF50), size: 22)
                  : Text(
                      _getInitials(patient['nom'] as String? ?? ''),
                      style: TextStyle(
                        color: prioriteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient['nom'] as String? ?? '',
                  style: TextStyle(
                    color: isVisited
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: isVisited ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient['quartier'] as String? ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: prioriteColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  patient['priorite'] as String? ?? '',
                  style: TextStyle(
                    color: prioriteColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    patient['distance'] as String? ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String nom) {
    if (nom.isEmpty) return '?';
    final parts = nom.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((e) => e[0]).take(2).join().toUpperCase();
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A3A).withOpacity(0.3)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF3A3A4A).withOpacity(0.5)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 300), Offset(size.width, 300), roadPaint);
    canvas.drawLine(const Offset(150, 0), Offset(150, size.height), roadPaint);
    canvas.drawLine(const Offset(50, 200), const Offset(300, 400), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}