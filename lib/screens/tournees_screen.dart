import 'package:flutter/material.dart';
import 'tournee_detail_screen.dart';
import 'add_tournee_screen.dart';
import '../services/tournee_service.dart';

class TourneesScreen extends StatefulWidget {
  const TourneesScreen({super.key});

  @override
  State<TourneesScreen> createState() => _TourneesScreenState();
}

class _TourneesScreenState extends State<TourneesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TourneeService _tourneeService = TourneeService();
  List<Map<String, dynamic>> _tournees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTournees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTournees() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _tourneeService.getTournees();
      
      if (result['success']) {
        final data = result['data'];
        List<dynamic> rawList = [];
        
        // Structure: { "tournees": [...], "stats": {...}, ... }
        if (data is Map && data['tournees'] != null) {
          rawList = data['tournees'] as List;
        } else if (data is List) {
          rawList = data;
        }
        
        setState(() {
          _tournees = rawList
              .map((item) => _mapTourneeFromApi(Map<String, dynamic>.from(item)))
              .toList();
        });
        
        print('✅ ${_tournees.length} tournées chargées');
      } else {
        setState(() {
          _tournees = _mockTournees;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement tournées: $e');
      setState(() {
        _tournees = _mockTournees;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshTournees() async {
    await _loadTournees();
  }

  Map<String, dynamic> _mapTourneeFromApi(Map<String, dynamic> t) {
    // Mapper le statut Laravel vers le statut de l'UI
    String statut;
    switch (t['statut']) {
      case 'en_cours':
        statut = 'En cours';
        break;
      case 'terminee':
        statut = 'Terminée';
        break;
      case 'planifiee':
        statut = 'Planifiée';
        break;
      default:
        statut = 'Planifiée';
    }

    return {
      'id': t['id'],
      'titre': t['titre'] ?? 'Tournée sans titre',
      'secteur': t['secteur'] ?? 'Secteur non défini',
      'heure': '${t['heure_debut_prevue'] ?? '08:00'} - ${t['heure_fin_prevue'] ?? '12:00'}',
      'statut': statut,
      'patients': t['patients_total'] ?? 0,
      'visites': t['patients_vus'] ?? 0,
      'soignant': t['soignant']?['name'] ?? 'Non assigné',
      'service': t['service']?['nom'] ?? 'Non défini',
      'date': t['date'] ?? DateTime.now().toIso8601String().split('T')[0],
    };
  }

  
  // Données de test pour le développement
  final List<Map<String, dynamic>> _mockTournees = [
    {
      'id': 1,
      'titre': 'Tournée du Matin',
      'secteur': 'Bastos - Nlongkak - Messa',
      'heure': '08:00 - 12:00',
      'statut': 'En cours',
      'patients': 6,
      'visites': 3,
      'soignant': 'Dr. Martin',
      'service': 'Urgences',
      'date': DateTime.now().toIso8601String().split('T')[0],
    },
    {
      'id': 2,
      'titre': 'Tournée de l\'Après-midi',
      'secteur': 'Omnisport - Essos',
      'heure': '14:00 - 17:00',
      'statut': 'Planifiée',
      'patients': 4,
      'visites': 0,
      'soignant': 'Dr. Sophie',
      'service': 'Pédiatrie',
      'date': DateTime.now().toIso8601String().split('T')[0],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text(
          'Mes Tournées',
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
            child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFFF4433),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF6B6B7B),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Aujourd\'hui'),
                Tab(text: 'À venir'),
                Tab(text: 'Historique'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildUpcomingTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTourneeScreen()),
          );
          if (result == true) {
            _refreshTournees();
          }
        },
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle tournée', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: _refreshTournees,
      color: const Color(0xFFFF4433),
      child: Column(
        children: [
          // Liste des tournées
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF4433),
                    ),
                  )
                : _tournees.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const SizedBox(height: 80),
                          Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.3), size: 48),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Aucune tournée aujourd\'hui',
                              style: TextStyle(color: Colors.white.withOpacity(0.5)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tournees.length,
                        itemBuilder: (context, index) {
                          final tournee = _tournees[index];
                          return _buildTourneeCard(
                            id: tournee['id'].toString(),
                            titre: tournee['titre'],
                            secteur: tournee['secteur'],
                            heure: tournee['heure'],
                            status: tournee['statut'],
                            patients: tournee['patients'],
                            visites: tournee['visites'],
                            isActive: tournee['statut'] == 'En cours',
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mardi, 28 Janvier',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildTourneeCard(
            id: 'TR-2025-003',
            titre: 'Tournée du Matin',
            secteur: 'Messa - Mokolo',
            heure: '08:00 - 12:00',
            status: 'Planifiée',
            patients: 5,
            visites: 0,
            isActive: false,
          ),
          const SizedBox(height: 24),
          const Text(
            'Mercredi, 29 Janvier',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildTourneeCard(
            id: 'TR-2025-004',
            titre: 'Tournée Complète',
            secteur: 'Bastos - Nlongkak - Omnisport',
            heure: '08:00 - 16:00',
            status: 'Planifiée',
            patients: 8,
            visites: 0,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dimanche, 26 Janvier',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildTourneeCard(
            id: 'TR-2025-000',
            titre: 'Tournée du Matin',
            secteur: 'Bastos - Messa',
            heure: '08:00 - 11:30',
            status: 'Terminée',
            patients: 5,
            visites: 5,
            isActive: false,
          ),
          const SizedBox(height: 24),
          const Text(
            'Samedi, 25 Janvier',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildTourneeCard(
            id: 'TR-2024-099',
            titre: 'Tournée d\'urgence',
            secteur: 'Nlongkak',
            heure: '14:00 - 15:30',
            status: 'Terminée',
            patients: 2,
            visites: 2,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF4433), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTourneeCard({
    required String id,
    required String titre,
    required String secteur,
    required String heure,
    required String status,
    required int patients,
    required int visites,
    required bool isActive,
  }) {
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'En cours':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.play_circle_filled;
        break;
      case 'Terminée':
        statusColor = const Color(0xFF6B6B7B);
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.schedule;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TourneeDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFFFF4433).withOpacity(0.5) : const Color(0xFF1E1E2A),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
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
                  id,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              titre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  secteur,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      heure,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      '$visites/$patients patients',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: visites / patients,
                  backgroundColor: const Color(0xFF1E1E2A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4433)),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}