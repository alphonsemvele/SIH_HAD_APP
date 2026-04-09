import 'package:flutter/material.dart';
import 'saisie_constantes_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final String nom;

  const PatientDetailScreen({super.key, required this.nom});

  @override
  Widget build(BuildContext context) {
    final constantes = {
      'temperature': '36.8°C',
      'tension': '145/92 mmHg',
      'pouls': '78 bpm',
      'saturation': '96%',
      'glycemie': '1.12 g/L',
      'date': 'Aujourd\'hui, 08:30',
    };

    final traitements = [
      {'nom': 'Furosémide 40mg', 'posologie': '1 comprimé le matin', 'duree': 'Continu'},
      {'nom': 'Ramipril 5mg', 'posologie': '1 comprimé le matin', 'duree': 'Continu'},
      {'nom': 'Bisoprolol 2.5mg', 'posologie': '1 comprimé le matin', 'duree': 'Continu'},
    ];

    final historique = [
      {'date': '27/01/2025', 'type': 'Visite', 'note': 'Tension stable. Patient en bonne forme.'},
      {'date': '25/01/2025', 'type': 'Visite', 'note': 'Légère dyspnée à l\'effort.'},
      {'date': '22/01/2025', 'type': 'Urgence', 'note': 'Œdèmes importants. Ajustement diurétiques.'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0F),
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 20),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF4433).withOpacity(0.3),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          nom.split(' ').map((e) => e[0]).take(2).join(),
                          style: const TextStyle(
                            color: Color(0xFFFF9800),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Surveillance',
                        style: TextStyle(color: Color(0xFFFF9800), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E1E2A)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildInfoChip(Icons.cake, '67 ans'),
                            const SizedBox(width: 10),
                            _buildInfoChip(Icons.person, 'Masculin'),
                            const SizedBox(width: 10),
                            _buildInfoChip(Icons.location_on, 'Bastos'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: const Color(0xFF1E1E2A)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.medical_services, color: Color(0xFFFF4433), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Insuffisance cardiaque - Suivi post-hospitalisation',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Constantes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dernières constantes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(constantes['date']!, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: [
                      _buildConstanteCard('Température', constantes['temperature']!, Icons.thermostat, const Color(0xFFFF9800)),
                      _buildConstanteCard('Tension', constantes['tension']!, Icons.favorite, const Color(0xFFFF4433)),
                      _buildConstanteCard('Pouls', constantes['pouls']!, Icons.monitor_heart, const Color(0xFF4CAF50)),
                      _buildConstanteCard('SpO2', constantes['saturation']!, Icons.air, const Color(0xFF2196F3)),
                      _buildConstanteCard('Glycémie', constantes['glycemie']!, Icons.water_drop, const Color(0xFF9C27B0)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SaisieConstantesScreen(patientNom: nom))),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4433).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF4433).withOpacity(0.3)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle, color: Color(0xFFFF4433), size: 28),
                              SizedBox(height: 6),
                              Text('Saisir', style: TextStyle(color: Color(0xFFFF4433), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Traitements
                  const Text('Traitements en cours', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...traitements.map((t) => _buildTraitementItem(t)),
                  const SizedBox(height: 24),

                  // Historique
                  const Text('Historique des visites', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...historique.map((h) => _buildHistoriqueItem(h)),
                  const SizedBox(height: 100),
                ],
              ),
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
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SaisieConstantesScreen(patientNom: nom))),
            icon: const Icon(Icons.edit_note, color: Colors.white),
            label: const Text('Saisir les constantes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4433),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B6B7B)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConstanteCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTraitementItem(Map<String, String> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.medication, color: Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['nom']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(t['posologie']!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueItem(Map<String, String> h) {
    final isUrgence = h['type'] == 'Urgence';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUrgence ? const Color(0xFFFF4433).withOpacity(0.3) : const Color(0xFF1E1E2A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUrgence ? const Color(0xFFFF4433).withOpacity(0.15) : const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(isUrgence ? Icons.warning : Icons.calendar_today, color: isUrgence ? const Color(0xFFFF4433) : const Color(0xFF6B6B7B), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(h['date']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUrgence ? const Color(0xFFFF4433).withOpacity(0.2) : const Color(0xFF1E1E2A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(h['type']!, style: TextStyle(color: isUrgence ? const Color(0xFFFF4433) : Colors.white.withOpacity(0.5), fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(h['note']!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}