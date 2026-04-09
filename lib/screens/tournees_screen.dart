import 'package:flutter/material.dart';
import 'tournee_detail_screen.dart';

class TourneesScreen extends StatefulWidget {
  const TourneesScreen({super.key});

  @override
  State<TourneesScreen> createState() => _TourneesScreenState();
}

class _TourneesScreenState extends State<TourneesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        onPressed: () {},
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle tournée', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé du jour
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF12121A),
                  const Color(0xFF1E1E2A).withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E1E2A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total', '2', Icons.list_alt),
                Container(width: 1, height: 40, color: const Color(0xFF1E1E2A)),
                _buildSummaryItem('En cours', '1', Icons.play_arrow),
                Container(width: 1, height: 40, color: const Color(0xFF1E1E2A)),
                _buildSummaryItem('Terminées', '0', Icons.check_circle),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tournée en cours
          _buildTourneeCard(
            id: 'TR-2025-001',
            titre: 'Tournée du Matin',
            secteur: 'Bastos - Nlongkak - Messa',
            heure: '08:00 - 12:00',
            status: 'En cours',
            patients: 6,
            visites: 3,
            isActive: true,
          ),
          const SizedBox(height: 16),

          // Tournée planifiée
          _buildTourneeCard(
            id: 'TR-2025-002',
            titre: 'Tournée de l\'Après-midi',
            secteur: 'Omnisport - Essos',
            heure: '14:00 - 17:00',
            status: 'Planifiée',
            patients: 4,
            visites: 0,
            isActive: false,
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