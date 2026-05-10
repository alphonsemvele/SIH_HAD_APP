import 'package:flutter/material.dart';
import 'tournee_detail_screen.dart';
import 'tournees_screen.dart';
import 'qr_scan_screen.dart';
import '../services/tournee_service.dart';
import '../services/auth_service.dart';
import '../services/alerte_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TourneeService _tourneeService = TourneeService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _tourneeJour;
  Map<String, dynamic>? _userStats;
  List<Map<String, dynamic>> _prochainsPatients = [];
  List<Map<String, dynamic>> _alertes = [];
  bool _isLoading = true;
  final AlerteService _alerteService = AlerteService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _tourneeService.getTournees(),
      _authService.getStats(),
      _alerteService.getAlertes(),
    ]);

    final tourneesRes = results[0] as Map<String, dynamic>;
    final stats = results[1] as Map<String, dynamic>?;
    final alertesRes = results[2] as Map<String, dynamic>;

    List<Map<String, dynamic>> alertes = [];
    if (alertesRes['success'] == true) {
      final raw = alertesRes['data'];
      final List<dynamic> rawList = raw is List ? raw : (raw is Map && raw['data'] is List ? raw['data'] : []);
      alertes = rawList.map((a) => Map<String, dynamic>.from(a)).toList();
    }

    Map<String, dynamic>? tourneeEnCours;
    List<Map<String, dynamic>> prochains = [];

    if (tourneesRes['success'] == true) {
      final data = tourneesRes['data'];
      final List<dynamic> raw = data is Map && data['tournees'] != null
          ? data['tournees']
          : (data is List ? data : []);
      final tournees = raw.map((t) => Map<String, dynamic>.from(t)).toList();

      // Tournée en cours en priorité
      tourneeEnCours = tournees.firstWhere(
        (t) => t['statut'] == 'en_cours',
        orElse: () => tournees.isNotEmpty ? tournees.first : <String, dynamic>{},
      );

      if (tourneeEnCours.isEmpty) tourneeEnCours = null;

      // Charger les visites de cette tournée
      if (tourneeEnCours != null && tourneeEnCours['id'] != null) {
        final visitesRes = await _tourneeService.getTourneeVisites(tourneeEnCours['id'] as int);
        if (visitesRes['success'] == true) {
          final vData = visitesRes['data'];
          final List<dynamic> rawVisites = vData is Map && vData['visites'] != null
              ? vData['visites']
              : (vData is List ? vData : []);
          // Garder seulement les non-faites, triées par ordre
          prochains = rawVisites
              .map((v) => Map<String, dynamic>.from(v))
              .where((v) => v['visite_at'] == null)
              .toList()
            ..sort((a, b) => ((a['ordre'] ?? 0) as num).compareTo((b['ordre'] ?? 0) as num));
          prochains = prochains.take(3).toList();
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _tourneeJour = tourneeEnCours;
      _userStats = stats;
      _prochainsPatients = prochains;
      _alertes = alertes;
      _isLoading = false;
    });
  }

  String _formatHeureRange(Map<String, dynamic>? t) {
    if (t == null) return '';
    String fmt(dynamic iso) {
      if (iso == null) return '--:--';
      final s = iso.toString();
      if (s.contains('T')) {
        try {
          final d = DateTime.parse(s).toLocal();
          return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        } catch (_) {}
      }
      return s.length >= 5 ? s.substring(0, 5) : s;
    }
    return '${fmt(t['heure_debut_prevue'])} - ${fmt(t['heure_fin_prevue'])}';
  }

  Color _prioriteColor(String? p) {
    switch (p?.toLowerCase()) {
      case 'critique': return const Color(0xFFFF4433);
      case 'surveillance': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFFF4433),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tourneeJour != null) _buildTourneeCard() else _buildNoTourneeCard(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    if (_alertes.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Alertes récentes',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4433).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_alertes.length}',
                                style: const TextStyle(color: Color(0xFFFF4433), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._alertes.take(3).map(_buildAlerteCard),
                      const SizedBox(height: 24),
                    ],
                    if (_prochainsPatients.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Prochains patients',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TourneesScreen()),
                            ),
                            child: const Text('Voir tout', style: TextStyle(color: Color(0xFFFF4433))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._prochainsPatients.map(_buildPatientCard),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QrScanScreen()),
        ),
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scanner QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTourneeCard() {
    final t = _tourneeJour!;
    final patientsTotal = (t['patients_total'] ?? 0) as int;
    final patientsVus = (t['patients_vus'] ?? 0) as int;
    final progress = patientsTotal > 0 ? patientsVus / patientsTotal : 0.0;
    final percentage = (progress * 100).round();
    final titre = t['notes']?.toString().split('—').first.trim() ?? 'Tournée du jour';
    final secteur = t['service']?['nom']?.toString() ?? 'HAD';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TourneeDetailScreen(
            tourneeId: t['id'] as int,
            tourneeInfo: t,
          ),
        ),
      ).then((_) => _loadData()),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF4433), Color(0xFFFF6B5B)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4433).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_filled, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('EN COURS',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text(_formatHeureRange(t),
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            Text(titre,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(secteur,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$patientsVus/$patientsTotal patients',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text('$percentage%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTourneeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.3), size: 48),
          const SizedBox(height: 12),
          Text(
            'Aucune tournée en cours',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final visites = _userStats?['visites_total']?.toString() ?? '0';
    final patients = _userStats?['patients_uniques']?.toString() ?? '0';
    final actes = _userStats?['actes_realises']?.toString() ?? '0';

    return Row(
      children: [
        _buildStatCard('Visites', visites, Icons.calendar_today, const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        _buildStatCard('Patients', patients, Icons.people, const Color(0xFF2196F3)),
        const SizedBox(width: 12),
        _buildStatCard('Actes', actes, Icons.healing, const Color(0xFFFF9800)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> v) {
    final patient = v['patient'] as Map<String, dynamic>? ?? {};
    final nom = '${patient['nom'] ?? ''} ${patient['prenom'] ?? ''}'.trim();
    final diagnostic = v['diagnostic']?.toString() ?? '';
    final quartier = patient['ville']?.toString() ?? '';
    final priorite = (v['priorite']?.toString() ?? 'normal').replaceFirstMapped(
        RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
    final pColor = _prioriteColor(v['priorite']?.toString());
    String heure = '';
    if (v['heure_prevue'] != null) {
      try {
        final d = DateTime.parse(v['heure_prevue'].toString()).toLocal();
        heure = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: pColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                nom.split(' ').where((p) => p.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase(),
                style: TextStyle(color: pColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(diagnostic,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (quartier.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(quartier, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(priorite,
                    style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Text(heure,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlerteCard(Map<String, dynamic> a) {
    final niveau = a['niveau']?.toString() ?? 'Moyen';
    final color = niveau == 'Critique'
        ? const Color(0xFFFF4433)
        : niveau == 'Urgent'
            ? const Color(0xFFFF9800)
            : const Color(0xFF4CAF50);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              niveau == 'Critique' ? Icons.emergency : Icons.warning_amber,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['patient_nom']?.toString() ?? '—',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  a['alerte']?.toString() ?? '—',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            a['heure']?.toString() ?? '',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

}
