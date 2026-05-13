import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/demande_service.dart';
import 'demande_detail_screen.dart';

class DemandesVisiteScreen extends StatefulWidget {
  const DemandesVisiteScreen({super.key});

  @override
  State<DemandesVisiteScreen> createState() => _DemandesVisiteScreenState();
}

class _DemandesVisiteScreenState extends State<DemandesVisiteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DemandeService _demandeService = DemandeService();

  List<Map<String, dynamic>> _demandes = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemandes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDemandes() async {
    setState(() => _isLoading = true);
    final result = await _demandeService.getDemandes();
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> raw = data is Map ? (data['demandes'] ?? []) : [];
      setState(() {
        _demandes = raw.map((d) => Map<String, dynamic>.from(d)).toList();
        _stats = data is Map ? Map<String, dynamic>.from(data['stats'] ?? {}) : {};
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Erreur chargement'),
          backgroundColor: const Color(0xFFFF4433),
        ),
      );
    }
  }

  Color _urgenceColor(String urgence) {
    return switch (urgence) {
      'critique' => const Color(0xFFFF4433),
      'urgente' => const Color(0xFFFF9800),
      'moyenne' => const Color(0xFF2196F3),
      'faible' => const Color(0xFF4CAF50),
      _ => Colors.grey,
    };
  }

  IconData _urgenceIcon(String urgence) {
    return switch (urgence) {
      'critique' => Icons.emergency,
      'urgente' => Icons.warning_amber,
      _ => Icons.info_outline,
    };
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 1) return 'À l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
      return '${d.day}/${d.month}/${d.year.toString().substring(2)}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _callPatient(String telephone) async {
    if (telephone.isEmpty) return;
    final uri = Uri.parse('tel:${telephone.replaceAll(' ', '')}');
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

  @override
  Widget build(BuildContext context) {
    final enAttente = _demandes.where((d) => d['statut'] == 'en_attente').toList();
    final acceptees = _demandes.where((d) => d['statut'] == 'acceptee' || d['statut'] == 'en_cours').toList();
    final historique = _demandes.where((d) => d['statut'] == 'terminee' || d['statut'] == 'refusee').toList();

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
          'Demandes de visite',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDemandes,
          ),
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
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              tabs: [
                Tab(text: 'Attente (${enAttente.length})'),
                Tab(text: 'Acceptées (${acceptees.length})'),
                Tab(text: 'Historique (${historique.length})'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
          : Column(
              children: [
                if (_stats.isNotEmpty) _buildStatsBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(enAttente, showActions: true),
                      _buildList(acceptees, showActions: false),
                      _buildList(historique, showActions: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsBar() {
    final critiques = (_stats['critiques'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: critiques > 0
            ? const Color(0xFFFF4433).withOpacity(0.1)
            : const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: critiques > 0
              ? const Color(0xFFFF4433).withOpacity(0.4)
              : const Color(0xFF1E1E2A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            critiques > 0 ? Icons.emergency : Icons.notifications_active,
            color: critiques > 0 ? const Color(0xFFFF4433) : const Color(0xFF4CAF50),
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  critiques > 0
                      ? '⚠️ $critiques demande(s) critique(s)'
                      : 'Toutes les demandes sont sous contrôle',
                  style: TextStyle(
                    color: critiques > 0 ? const Color(0xFFFF4433) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_stats['en_attente'] ?? 0} en attente • ${_stats['acceptees'] ?? 0} acceptées',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list, {required bool showActions}) {
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.inbox, color: Colors.white.withOpacity(0.3), size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Aucune demande',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDemandes,
      color: const Color(0xFFFF4433),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i], showActions: showActions),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> d, {required bool showActions}) {
    final urgence = d['urgence']?.toString() ?? 'moyenne';
    final color = _urgenceColor(urgence);
    final patient = d['patient_nom']?.toString() ?? '—';
    final telephone = d['patient_telephone']?.toString() ?? '';
    final age = d['patient_age'];
    final quartier = d['quartier']?.toString() ?? d['ville']?.toString() ?? '';
    final symptomes = d['symptomes']?.toString() ?? '';
    final demandeur = d['demandeur_nom']?.toString();
    final relation = d['demandeur_relation']?.toString();
    final time = _formatTime(d['created_at']?.toString());
    final statut = d['statut']?.toString() ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DemandeDetailScreen(demande: d),
        ),
      ).then((_) => _loadDemandes()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: urgence == 'critique' ? color.withOpacity(0.5) : const Color(0xFF1E1E2A),
            width: urgence == 'critique' ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_urgenceIcon(urgence), color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    d['urgence_libelle']?.toString() ?? '—',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            patient.split(' ').where((p) => p.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                              patient,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              age != null ? '$age ans • $quartier' : quartier,
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (telephone.isNotEmpty)
                        GestureDetector(
                          onTap: () => _callPatient(telephone),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Symptômes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      symptomes,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (demandeur != null && demandeur.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.white.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        Text(
                          'Demandé par $demandeur${relation != null ? " ($relation)" : ""}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],

                  // Statut badge si pas en attente
                  if (statut != 'en_attente') ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statutColor(statut).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        d['statut_libelle']?.toString() ?? '—',
                        style: TextStyle(
                          color: _statutColor(statut),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statutColor(String statut) {
    return switch (statut) {
      'acceptee' || 'en_cours' => const Color(0xFF2196F3),
      'terminee' => const Color(0xFF4CAF50),
      'refusee' => Colors.grey,
      _ => const Color(0xFFFF9800),
    };
  }
}
