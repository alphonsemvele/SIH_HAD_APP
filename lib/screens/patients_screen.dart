import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _selectedFilter = 'Tous';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _patients = [
    {
      'nom': 'Jean-Pierre Nguemo',
      'age': 67,
      'sexe': 'M',
      'quartier': 'Bastos',
      'diagnostic': 'Insuffisance cardiaque',
      'priorite': 'Surveillance',
      'telephone': '+237 677 234 567',
      'derniereVisite': 'Aujourd\'hui, 08:30',
    },
    {
      'nom': 'Marie-Claire Bella',
      'age': 45,
      'sexe': 'F',
      'quartier': 'Nlongkak',
      'diagnostic': 'Diabète type 2 - Plaie pied gauche',
      'priorite': 'Critique',
      'telephone': '+237 690 345 678',
      'derniereVisite': 'Aujourd\'hui, 09:30',
    },
    {
      'nom': 'Robert Tagne',
      'age': 72,
      'sexe': 'M',
      'quartier': 'Messa',
      'diagnostic': 'BPCO stade III - Oxygénothérapie',
      'priorite': 'Surveillance',
      'telephone': '+237 655 456 789',
      'derniereVisite': 'Hier, 10:15',
    },
    {
      'nom': 'Pauline Essomba',
      'age': 58,
      'sexe': 'F',
      'quartier': 'Omnisport',
      'diagnostic': 'AVC ischémique - Rééducation',
      'priorite': 'Normal',
      'telephone': '+237 678 567 890',
      'derniereVisite': 'Hier, 14:00',
    },
    {
      'nom': 'François Mbede',
      'age': 78,
      'sexe': 'M',
      'quartier': 'Bastos',
      'diagnostic': 'Cancer poumon - Soins palliatifs',
      'priorite': 'Critique',
      'telephone': '+237 699 678 901',
      'derniereVisite': 'Il y a 2 jours',
    },
    {
      'nom': 'Jeanne Ateba',
      'age': 63,
      'sexe': 'F',
      'quartier': 'Nlongkak',
      'diagnostic': 'Post-chirurgie prothèse hanche',
      'priorite': 'Normal',
      'telephone': '+237 677 789 012',
      'derniereVisite': 'Il y a 3 jours',
    },
    {
      'nom': 'Michel Onana',
      'age': 55,
      'sexe': 'M',
      'quartier': 'Essos',
      'diagnostic': 'Insuffisance rénale - Dialyse',
      'priorite': 'Surveillance',
      'telephone': '+237 690 890 123',
      'derniereVisite': 'Aujourd\'hui, 07:00',
    },
    {
      'nom': 'Christiane Mvondo',
      'age': 48,
      'sexe': 'F',
      'quartier': 'Mokolo',
      'diagnostic': 'Sclérose en plaques',
      'priorite': 'Surveillance',
      'telephone': '+237 655 901 234',
      'derniereVisite': 'Hier, 16:30',
    },
  ];

  List<Map<String, dynamic>> get _filteredPatients {
    if (_selectedFilter == 'Tous') return _patients;
    return _patients.where((p) => p['priorite'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text(
          'Mes Patients',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E1E2A)),
            ),
            child: const Icon(Icons.person_add, color: Colors.white, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B6B7B)),
                filled: true,
                fillColor: const Color(0xFF12121A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF4433)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tous', _patients.length),
                const SizedBox(width: 8),
                _buildFilterChip('Critique', _patients.where((p) => p['priorite'] == 'Critique').length),
                const SizedBox(width: 8),
                _buildFilterChip('Surveillance', _patients.where((p) => p['priorite'] == 'Surveillance').length),
                const SizedBox(width: 8),
                _buildFilterChip('Normal', _patients.where((p) => p['priorite'] == 'Normal').length),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12121A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E1E2A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', '${_patients.length}', Icons.people),
                  Container(width: 1, height: 35, color: const Color(0xFF1E1E2A)),
                  _buildStatItem('Critiques', '${_patients.where((p) => p['priorite'] == 'Critique').length}', Icons.warning_amber),
                  Container(width: 1, height: 35, color: const Color(0xFF1E1E2A)),
                  _buildStatItem('À voir', '4', Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Liste des patients
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return _buildPatientCard(context, patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4433) : const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4433) : const Color(0xFF1E1E2A),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B6B7B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF4433), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context, Map<String, dynamic> patient) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(nom: patient['nom']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E1E2A)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: prioriteColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  patient['nom'].split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(
                    color: prioriteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        patient['nom'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${patient['age']} ans',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient['diagnostic'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 4),
                      Text(
                        patient['quartier'],
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 4),
                      Text(
                        patient['derniereVisite'],
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Priorité et actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: prioriteColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    patient['priorite'],
                    style: TextStyle(
                      color: prioriteColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}