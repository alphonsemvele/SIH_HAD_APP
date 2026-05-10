import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/rapport_service.dart';

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RapportService _rapportService = RapportService();
  List<Map<String, dynamic>> _rapports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRapports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRapports() async {
    setState(() => _isLoading = true);

    try {
      final result = await _rapportService.getRapports();

      if (result['success']) {
        final List<dynamic> raw = result['data'] ?? [];
        setState(() {
          _rapports = raw
              .map((r) => _mapRapportFromApi(Map<String, dynamic>.from(r)))
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

  Future<void> _refreshRapports() async {
    await _loadRapports();
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

  Map<String, dynamic> _mapRapportFromApi(Map<String, dynamic> rapport) {
    final createdAt = rapport['created_at']?.toString() ?? '';
    return {
      'id': rapport['id'],
      'titre': rapport['titre'] ?? 'Sans titre',
      'date': rapport['date_formatee'] ?? '00/00/0000',
      'heure': createdAt.length >= 16 ? createdAt.substring(11, 16) : '00:00',
      'type': rapport['type'] ?? 'autre',
      'status': rapport['status_libelle'] ?? 'Inconnu',
      'patient': rapport['patient']?['nom'] ?? 'Non spécifié',
    };
  }

  // Compteurs dynamiques pour les stats
  int get _totalCount => _rapports.length;
  int get _completedCount =>
      _rapports.where((r) => r['status'] == 'Complété').length;
  int get _pendingCount =>
      _rapports.where((r) => r['status'] != 'Complété').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rapports',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 20,
              ),
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
              color: const Color(0xFF1E1E2A),
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
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Tous'),
                Tab(text: 'Visites'),
                Tab(text: 'Tournées'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4433)),
            )
          : RefreshIndicator(
              onRefresh: _refreshRapports,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          '$_totalCount',
                          Icons.description,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Color(0xFF1E1E2A),
                        ),
                        _buildStatItem(
                          'Complétés',
                          '$_completedCount',
                          Icons.check_circle,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Color(0xFF1E1E2A),
                        ),
                        _buildStatItem(
                          'En cours',
                          '$_pendingCount',
                          Icons.pending,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRapportsList(_rapports),
                        _buildRapportsList(
                          _rapports.where((r) => r['type'] == 'visite').toList(),
                        ),
                        _buildRapportsList(
                          _rapports.where((r) => r['type'] == 'tournee').toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewRapportSheet(context),
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouveau rapport',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRapportsList(List<Map<String, dynamic>> rapports) {
    if (rapports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 60, color: Color(0xFF1E1E2A)),
            const SizedBox(height: 16),
            Text(
              'Aucun rapport',
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rapports.length,
      itemBuilder: (context, index) {
        return _buildRapportCard(rapports[index]);
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
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E1E2A)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3),
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
                    rapport['titre'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rapport['date']} à ${rapport['heure']}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rapport['status'] ?? '',
                      style: TextStyle(
                        color: isComplete
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF9800),
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
                  icon: const Icon(
                    Icons.download,
                    color: Color(0xFFFF4433),
                    size: 22,
                  ),
                  onPressed: () => _telechargerRapport(rapport),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Télécharger',
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.white.withOpacity(0.7),
                    size: 22,
                  ),
                  onPressed: () => _partagerRapport(rapport),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Partager',
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
          color: const Color(0xFF12121A),
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
                color: Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rapport['titre'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    _buildDetailRow(
                      'Date',
                      '${rapport['date']} à ${rapport['heure']}',
                    ),
                    _buildDetailRow(
                      'Type',
                      rapport['type'] == 'visite'
                          ? 'Rapport de visite'
                          : 'Rapport de tournée',
                    ),
                    _buildDetailRow('Statut', rapport['status'] ?? ''),
                    if (rapport['patient'] != null)
                      _buildDetailRow('Patient', '${rapport['patient']}'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12121A),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3),
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
                        label: const Text(
                          'Modifier',
                          style: TextStyle(color: Color(0xFFFF4433)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF4433)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          'Télécharger PDF',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4433),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
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
          color: const Color(0xFF12121A),
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
                color: Color(0xFF1E1E2A),
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
                  color: Colors.white,
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
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E1E2A)),
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
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white60),
          ],
        ),
      ),
    );
  }

  Future<void> _telechargerRapport(Map<String, dynamic> rapport) async {
    final id = rapport['id'];
    if (id == null) return;

    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433))),
    );

    final res = await _rapportService.telechargerRapport(id is int ? id : int.parse(id.toString()));

    if (!mounted) return;
    Navigator.of(context).pop(); // Fermer loading

    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      _showRapportContenu(data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Erreur téléchargement'),
          backgroundColor: const Color(0xFFFF4433),
        ),
      );
    }
  }

  void _showRapportContenu(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
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
                color: const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Color(0xFFFF4433)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data['titre']?.toString() ?? 'Rapport',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E1E2A), height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kvRow('Type', data['type']?.toString() ?? '—'),
                    _kvRow('Statut', data['status']?.toString() ?? '—'),
                    _kvRow('Auteur', data['creator_nom']?.toString() ?? '—'),
                    if (data['patient_nom'] != null && data['patient_nom'].toString().isNotEmpty)
                      _kvRow('Patient', data['patient_nom'].toString()),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E2A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONTENU',
                            style: TextStyle(
                              color: Color(0xFFFF4433),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data['contenu']?.toString() ?? 'Aucun contenu',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data['notes'] != null && data['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Notes : ${data['notes']}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF12121A),
                border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rapport sauvegardé localement'),
                        backgroundColor: Color(0xFF4CAF50),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Confirmer le téléchargement', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4433),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(k, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _partagerRapport(Map<String, dynamic> rapport) {
    final titre = rapport['titre']?.toString() ?? 'Rapport';
    final type = rapport['type']?.toString() ?? '';
    final patient = rapport['patient']?.toString() ?? '';
    final date = rapport['date']?.toString() ?? '';

    final body = Uri.encodeComponent(
      'Bonjour,\n\nVeuillez trouver ci-dessous le rapport HAD :\n\n'
      '— Titre : $titre\n'
      '— Type : $type\n'
      '— Date : $date\n'
      '${patient.isNotEmpty ? "— Patient : $patient\n" : ""}'
      '\nCordialement,\nÉquipe HAD - HCY'
    );
    final subject = Uri.encodeComponent('[HAD] $titre');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Partager le rapport',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.email, color: Color(0xFF2196F3)),
                ),
                title: const Text('Email', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Ouvre votre client mail',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('mailto:?subject=$subject&body=$body');
                  try {
                    await launchUrl(uri);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFFF4433)),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.message, color: Color(0xFF4CAF50)),
                ),
                title: const Text('SMS', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Envoyer par message',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('sms:?body=$body');
                  try {
                    await launchUrl(uri);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFFF4433)),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4433).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services, color: Color(0xFFFF4433)),
                ),
                title: const Text('MSSanté', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Messagerie sécurisée santé (à venir)',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('MSSanté - Configuration ANS requise (Phase 4)'),
                      backgroundColor: Color(0xFFFF4433),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

}