import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = [
      {'nom': 'Jean-Pierre Nguemo', 'quartier': 'Bastos', 'priorite': 'Surveillance', 'distance': '1.2 km', 'visite': true},
      {'nom': 'Marie-Claire Bella', 'quartier': 'Nlongkak', 'priorite': 'Critique', 'distance': '2.5 km', 'visite': true},
      {'nom': 'Robert Tagne', 'quartier': 'Messa', 'priorite': 'Surveillance', 'distance': '3.1 km', 'visite': true},
      {'nom': 'Pauline Essomba', 'quartier': 'Omnisport', 'priorite': 'Normal', 'distance': '4.8 km', 'visite': false},
      {'nom': 'François Mbede', 'quartier': 'Bastos', 'priorite': 'Critique', 'distance': '1.5 km', 'visite': false},
      {'nom': 'Jeanne Ateba', 'quartier': 'Nlongkak', 'priorite': 'Normal', 'distance': '2.8 km', 'visite': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Fake Map Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  const Color(0xFF0f3460),
                ],
              ),
            ),
            child: CustomPaint(
              painter: MapGridPainter(),
              size: Size.infinite,
            ),
          ),

          // Map markers
          ..._buildMarkers(context, patients),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E2A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF6B6B7B), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Rechercher une adresse...',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
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
          ),

          // Current location button
          Positioned(
            right: 16,
            bottom: 280,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E2A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.my_location, color: Color(0xFFFF4433), size: 22),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E2A)),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E2A)),
                  ),
                  child: const Icon(Icons.remove, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
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
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A4A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4433).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.navigation, color: Color(0xFFFF4433), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Itinéraire',
                                  style: TextStyle(
                                    color: const Color(0xFFFF4433),
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
                    // Liste
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return _buildPatientItem(patient);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMarkers(BuildContext context, List<Map<String, dynamic>> patients) {
    final positions = [
      const Offset(80, 200),
      const Offset(200, 280),
      const Offset(280, 180),
      const Offset(150, 400),
      const Offset(100, 320),
      const Offset(250, 350),
    ];

    return List.generate(patients.length, (index) {
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
            Container(
              width: 3,
              height: 10,
              color: color,
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: patient['visite'] == true
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
              child: patient['visite'] == true
                  ? const Icon(Icons.check, color: Color(0xFF4CAF50), size: 22)
                  : Text(
                      (patient['nom'] as String).split(' ').map((e) => e[0]).take(2).join(),
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
                  patient['nom'] as String,
                  style: TextStyle(
                    color: patient['visite'] == true ? Colors.white.withOpacity(0.5) : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: patient['visite'] == true ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      patient['quartier'] as String,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: prioriteColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  patient['priorite'] as String,
                  style: TextStyle(color: prioriteColor, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.directions_walk, size: 12, color: Colors.white.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text(
                    patient['distance'] as String,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for grid background
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A3A).withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw grid
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw some "roads"
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