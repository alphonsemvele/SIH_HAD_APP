import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';
import '../services/patient_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _selectedFilter = 'Tous';
  final _searchController = TextEditingController();
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;

  // Données de test pour le développement
  final List<Map<String, dynamic>> _mockPatients = [
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

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _patientService.getPatients();
      
      if (result['success']) {
        final data = result['data'];
        List<dynamic> rawList = [];
        
        // Structure: { "patients": { "data": [...], "current_page": 1, ... }, "stats": {...} }
        if (data is Map && data['patients'] != null && data['patients']['data'] != null) {
          rawList = data['patients']['data'] as List;
        } else if (data is Map && data['data'] != null) {
          rawList = data['data'] as List;
        } else if (data is List) {
          rawList = data;
        }
        
        setState(() {
          _patients = rawList
              .map((item) => _mapPatientFromApi(Map<String, dynamic>.from(item)))
              .toList();
        });
        
        print('✅ ${_patients.length} patients chargés');
      } else {
        // En cas d'erreur, utiliser les données mock pour le développement
        setState(() {
          _patients = _mockPatients;
        });
        _showErrorSnackBar('Utilisation des données de test: ${result['message']}');
      }
    } catch (e) {
      print('❌ $e');
      // En cas d'erreur, utiliser les données mock pour le développement
      setState(() {
        _patients = _mockPatients;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPatients() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _patientService.getPatients();
      
      if (result['success']) {
        final data = result['data'];
        List<dynamic> rawList = [];
        
        // Structure: { "patients": { "data": [...], "current_page": 1, ... }, "stats": {...} }
        if (data is Map && data['patients'] != null && data['patients']['data'] != null) {
          rawList = data['patients']['data'] as List;
        } else if (data is Map && data['data'] != null) {
          rawList = data['data'] as List;
        } else if (data is List) {
          rawList = data;
        }
        
        setState(() {
          _patients = rawList
              .map((item) => _mapPatientFromApi(Map<String, dynamic>.from(item)))
              .toList();
        });
        
        print('✅ ${_patients.length} patients rechargés');
      } else {
        // En cas d'erreur, utiliser les données mock pour le développement
        setState(() {
          _patients = _mockPatients;
        });
      }
    } catch (e) {
      print('❌ Erreur refresh: $e');
      // En cas d'erreur, utiliser les données mock pour le développement
      setState(() {
        _patients = _mockPatients;
      });
    } finally {
      setState(() => _isLoading = false);
    }
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

  Map<String, dynamic> _mapPatientFromApi(Map<String, dynamic> p) {
  // Calculer l'âge depuis date_naissance (format ISO)
  int age = 0;
  if (p['date_naissance'] != null) {
    try {
      final dob = DateTime.parse(p['date_naissance']);
      final now = DateTime.now();
      age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
    } catch (_) {}
  }

  // Nom complet : prénom + nom
  final nomComplet = '${p['prenom'] ?? ''} ${p['nom'] ?? ''}'.trim();

  // Extraire le diagnostic depuis le champ notes (format "Diagnostic: X | Traitement: Y")
  String diagnostic = 'Pas de diagnostic';
  final notes = p['notes']?.toString() ?? '';
  if (notes.contains('Diagnostic:')) {
    final match = RegExp(r'Diagnostic:\s*([^|\n]+)').firstMatch(notes);
    if (match != null) diagnostic = match.group(1)!.trim();
  } else if (notes.isNotEmpty) {
    diagnostic = notes;
  }

  // Mapper le statut Laravel vers la priorité de l'UI
  String priorite;
  switch (p['statut']) {
    case 'Urgence':
      priorite = 'Critique';
      break;
    case 'Hospitalisé':
      priorite = 'Surveillance';
      break;
    default:
      priorite = 'Normal';
  }

  return {
    'id': p['id'],
    'nom': nomComplet.isEmpty ? 'Sans nom' : nomComplet,
    'age': age,
    'sexe': p['sexe'] ?? 'M',
    'quartier': p['quartier'] ?? 'Non renseigné',
    'diagnostic': diagnostic,
    'priorite': priorite,
    'telephone': p['telephone'] ?? '',
    'derniereVisite': _formatDate(p['updated_at']),
  };
}

String _formatDate(String? isoDate) {
  if (isoDate == null) return 'Jamais';
  try {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return '${date.day}/${date.month}/${date.year}';
  } catch (_) {
    return 'Date inconnue';
  }
}

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
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPatientScreen()),
              );
              if (result == true) {
                _refreshPatients();
              }
            },
            icon: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF12121A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E1E2A)),
              ),
              child: const Icon(Icons.person_add, color: Colors.white, size: 20),
            ),
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF4433),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshPatients,
                    color: const Color(0xFFFF4433),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = _filteredPatients[index];
                        return _buildPatientCard(context, patient);
                      },
                    ),
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