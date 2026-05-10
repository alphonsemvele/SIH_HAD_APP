import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';
import '../services/patient_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';
  String _searchQuery = '';
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

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
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);

    try {
      final result = await _patientService.getPatients();

      if (result['success']) {
        final data = result['data'];
        List<dynamic> rawList = [];

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
        setState(() {
          _patients = _mockPatients;
        });
        _showErrorSnackBar('Utilisation des données de test: ${result['message']}');
      }
    } catch (e) {
      print('❌ $e');
      setState(() {
        _patients = _mockPatients;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPatients() async {
    await _loadPatients();
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

    final nomComplet = '${p['prenom'] ?? ''} ${p['nom'] ?? ''}'.trim();

    String diagnostic = 'Pas de diagnostic';
    final notes = p['notes']?.toString() ?? '';
    if (notes.contains('Diagnostic:')) {
      final match = RegExp(r'Diagnostic:\s*([^|\n]+)').firstMatch(notes);
      if (match != null) diagnostic = match.group(1)!.trim();
    } else if (notes.isNotEmpty) {
      diagnostic = notes;
    }

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
    List<Map<String, dynamic>> filtered = _patients;

    if (_selectedFilter != 'Tous') {
      filtered = filtered.where((p) => p['priorite'] == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((p) {
        final nom = (p['nom'] ?? '').toString().toLowerCase();
        final diagnostic = (p['diagnostic'] ?? '').toString().toLowerCase();
        final quartier = (p['quartier'] ?? '').toString().toLowerCase();
        final telephone = (p['telephone'] ?? '').toString().toLowerCase();

        return nom.contains(query) ||
            diagnostic.contains(query) ||
            quartier.contains(query) ||
            telephone.contains(query);
      }).toList();
    }

    return filtered;
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B6B7B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6B6B7B)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
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
                    child: _filteredPatients.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              const SizedBox(height: 80),
                              Icon(Icons.search_off, color: Colors.white.withOpacity(0.3), size: 48),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Aucun patient ne correspond à "$_searchQuery"'
                                      : 'Aucun patient',
                                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
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

    final nomString = (patient['nom'] ?? '').toString();
    final initiales = nomString.isEmpty
        ? '?'
        : nomString
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0].toUpperCase())
            .take(2)
            .join();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(nom: patient['nom']?.toString(), patient: Map<String, dynamic>.from(patient)),
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
                  initiales,
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
                      Flexible(
                        child: Text(
                          patient['nom'] ?? 'Sans nom',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                    patient['diagnostic'] ?? '',
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
                        patient['quartier'] ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 4),
                      Text(
                        patient['derniereVisite'] ?? '',
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
                    patient['priorite'] ?? '',
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
                      onTap: () => _callPatient(patient),
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

  Future<void> _callPatient(Map<String, dynamic> patient) async {
    final tel = (patient['telephone']?.toString() ?? '').replaceAll(' ', '');
    if (tel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun numéro renseigné'),
          backgroundColor: Color(0xFFFF4433),
        ),
      );
      return;
    }
    final uri = Uri.parse('tel:$tel');
    try {
      await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur appel: $e'), backgroundColor: const Color(0xFFFF4433)),
        );
      }
    }
  }

}