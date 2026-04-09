import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';

class TourneeDetailScreen extends StatelessWidget {
  const TourneeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = [
      {'nom': 'Jean-Pierre Nguemo', 'diagnostic': 'Insuffisance cardiaque', 'quartier': 'Bastos', 'priorite': 'Surveillance', 'heure': '08:30', 'visite': true},
      {'nom': 'Marie-Claire Bella', 'diagnostic': 'Diabète type 2 - Plaie pied', 'quartier': 'Nlongkak', 'priorite': 'Critique', 'heure': '09:30', 'visite': true},
      {'nom': 'Robert Tagne', 'diagnostic': 'BPCO - Oxygénothérapie', 'quartier': 'Messa', 'priorite': 'Surveillance', 'heure': '10:15', 'visite': true},
      {'nom': 'Pauline Essomba', 'diagnostic': 'AVC - Rééducation', 'quartier': 'Omnisport', 'priorite': 'Normal', 'heure': '11:00', 'visite': false},
      {'nom': 'François Mbede', 'diagnostic': 'Cancer - Soins palliatifs', 'quartier': 'Bastos', 'priorite': 'Critique', 'heure': '11:45', 'visite': false},
      {'nom': 'Jeanne Ateba', 'diagnostic': 'Post-chirurgie hanche', 'quartier': 'Nlongkak', 'priorite': 'Normal', 'heure': '12:30', 'visite': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tournée du Matin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E1E2A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.play_circle_filled, color: Color(0xFF4CAF50), size: 14),
                              SizedBox(width: 6),
                              Text(
                                'En cours',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'TR-2025-001',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(Icons.access_time, '08:00 - 12:00'),
                    _buildInfoItem(Icons.location_on, 'Bastos - Nlongkak'),
                    _buildInfoItem(Icons.people, '3/6 visités'),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: const Color(0xFF1E1E2A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4433)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Liste des patients
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Patients à visiter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E1E2A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sort, color: Color(0xFF6B6B7B), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Par heure',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _buildPatientItem(
                  context,
                  nom: patient['nom'] as String,
                  diagnostic: patient['diagnostic'] as String,
                  quartier: patient['quartier'] as String,
                  priorite: patient['priorite'] as String,
                  heure: patient['heure'] as String,
                  visite: patient['visite'] as bool,
                  index: index + 1,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.pause, color: Color(0xFFFF4433)),
                  label: const Text('Pause', style: TextStyle(color: Color(0xFFFF4433))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF4433)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation, color: Colors.white),
                  label: const Text('Prochain patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4433),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B6B7B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPatientItem(
    BuildContext context, {
    required String nom,
    required String diagnostic,
    required String quartier,
    required String priorite,
    required String heure,
    required bool visite,
    required int index,
  }) {
    Color prioriteColor;
    switch (priorite) {
      case 'Critique':
        prioriteColor = const Color(0xFFFF4433);
        break;
      case 'Surveillance':
        prioriteColor = const Color(0xFFFF9800);
        break;
      default:
        prioriteColor = const Color(0xFF4CAF50);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PatientDetailScreen(nom: nom)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: visite ? const Color(0xFF12121A).withOpacity(0.5) : const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: visite ? const Color(0xFF4CAF50).withOpacity(0.3) : const Color(0xFF1E1E2A),
          ),
        ),
        child: Row(
          children: [
            // Numéro d'ordre
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: visite ? const Color(0xFF4CAF50) : const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: visite
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Infos patient
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        nom,
                        style: TextStyle(
                          color: visite ? Colors.white.withOpacity(0.5) : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: visite ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: prioriteColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          priorite,
                          style: TextStyle(
                            color: prioriteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diagnostic,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 4),
                      Text(
                        quartier,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Heure
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  heure,
                  style: TextStyle(
                    color: visite ? Colors.white.withOpacity(0.4) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}