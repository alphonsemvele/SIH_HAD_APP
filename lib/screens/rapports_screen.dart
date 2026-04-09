import 'package:flutter/material.dart';

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _rapports = [
    {
      'titre': 'Rapport de visite - Jean-Pierre Nguemo',
      'date': '27/01/2025',
      'heure': '08:45',
      'type': 'visite',
      'status': 'Complété',
      'patient': 'Jean-Pierre Nguemo',
    },
    {
      'titre': 'Rapport de visite - Marie-Claire Bella',
      'date': '27/01/2025',
      'heure': '09:50',
      'type': 'visite',
      'status': 'Complété',
      'patient': 'Marie-Claire Bella',
    },
    {
      'titre': 'Rapport de visite - Robert Tagne',
      'date': '27/01/2025',
      'heure': '10:30',
      'type': 'visite',
      'status': 'En cours',
      'patient': 'Robert Tagne',
    },
    {
      'titre': 'Rapport tournée matin',
      'date': '26/01/2025',
      'heure': '12:15',
      'type': 'tournee',
      'status': 'Complété',
      'patients': 5,
    },
    {
      'titre': 'Rapport d\'incident - Chute patient',
      'date': '25/01/2025',
      'heure': '14:20',
      'type': 'incident',
      'status': 'Complété',
      'patient': 'Pauline Essomba',
    },
    {
      'titre': 'Rapport tournée après-midi',
      'date': '25/01/2025',
      'heure': '17:30',
      'type': 'tournee',
      'status': 'Complété',
      'patients': 4,
    },
  ];

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rapports',
          style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_list, color: Color(0xFF1A1A2E), size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
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
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Tous'),
                Tab(text: 'Visites'),
                Tab(text: 'Tournées'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Ce mois', '24', Icons.description),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _buildStatItem('Complétés', '22', Icons.check_circle),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _buildStatItem('En cours', '2', Icons.pending),
              ],
            ),
          ),

          // Liste des rapports
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRapportsList(_rapports),
                _buildRapportsList(_rapports.where((r) => r['type'] == 'visite').toList()),
                _buildRapportsList(_rapports.where((r) => r['type'] == 'tournee').toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewRapportSheet(context),
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau rapport', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF4433), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRapportsList(List<Map<String, dynamic>> rapports) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rapports.length,
      itemBuilder: (context, index) {
        final rapport = rapports[index];
        return _buildRapportCard(rapport);
      },
    );
  }

  Widget _buildRapportCard(Map<String, dynamic> rapport) {
    Color typeColor;
    IconData typeIcon;

    switch (rapport['type']) {
      case 'visite':
        typeColor = const Color(0xFF4CAF50);
        typeIcon = Icons.person;
        break;
      case 'tournee':
        typeColor = const Color(0xFF2196F3);
        typeIcon = Icons.route;
        break;
      case 'incident':
        typeColor = const Color(0xFFFF9800);
        typeIcon = Icons.warning;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.description;
    }

    final isComplete = rapport['status'] == 'Complété';

    return GestureDetector(
      onTap: () => _showRapportDetail(context, rapport),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rapport['titre'],
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${rapport['date']} à ${rapport['heure']}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rapport['status'],
                      style: TextStyle(
                        color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.download, color: Colors.grey.shade400, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey.shade400, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRapportDetail(BuildContext context, Map<String, dynamic> rapport) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rapport['titre'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Date', '${rapport['date']} à ${rapport['heure']}'),
                    _buildDetailRow('Type', rapport['type'] == 'visite' ? 'Rapport de visite' : 'Rapport de tournée'),
                    _buildDetailRow('Statut', rapport['status']),
                    if (rapport['patient'] != null)
                      _buildDetailRow('Patient', rapport['patient']),
                    if (rapport['patients'] != null)
                      _buildDetailRow('Patients visités', '${rapport['patients']}'),
                    const SizedBox(height: 20),
                    const Text(
                      'Contenu du rapport',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Visite effectuée à domicile. Patient stable.\n\nConstantes relevées :\n- Température : 36.8°C\n- Tension : 145/92 mmHg\n- Pouls : 78 bpm\n- Saturation : 96%\n\nObservations :\nÉtat général satisfaisant. Pas de signes d\'aggravation. Traitement bien suivi. Prochain RDV prévu dans 48h.\n\nRecommandations :\n- Continuer le traitement actuel\n- Surveiller la tension\n- Appeler en cas de dyspnée',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, color: Color(0xFFFF4433)),
                        label: const Text('Modifier', style: TextStyle(color: Color(0xFFFF4433))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF4433)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text('Télécharger PDF', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4433),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewRapportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Nouveau rapport',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildRapportTypeOption(
                    icon: Icons.person,
                    title: 'Rapport de visite',
                    subtitle: 'Compte rendu d\'une visite patient',
                    color: const Color(0xFF4CAF50),
                  ),
                  _buildRapportTypeOption(
                    icon: Icons.route,
                    title: 'Rapport de tournée',
                    subtitle: 'Bilan d\'une tournée complète',
                    color: const Color(0xFF2196F3),
                  ),
                  _buildRapportTypeOption(
                    icon: Icons.warning,
                    title: 'Rapport d\'incident',
                    subtitle: 'Signalement d\'un événement',
                    color: const Color(0xFFFF9800),
                  ),
                  _buildRapportTypeOption(
                    icon: Icons.medical_services,
                    title: 'Rapport médical',
                    subtitle: 'Observations médicales détaillées',
                    color: const Color(0xFFFF4433),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRapportTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}