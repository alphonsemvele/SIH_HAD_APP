import 'package:flutter/material.dart';
import '../services/tournee_service.dart';
import 'patient_detail_screen.dart';
import 'qr_scan_screen.dart';

class TourneeDetailScreen extends StatefulWidget {
  final int? tourneeId;
  final Map<String, dynamic>? tourneeInfo;

  const TourneeDetailScreen({super.key, this.tourneeId, this.tourneeInfo});

  @override
  State<TourneeDetailScreen> createState() => _TourneeDetailScreenState();
}

class _TourneeDetailScreenState extends State<TourneeDetailScreen> {
  final TourneeService _tourneeService = TourneeService();
  List<Map<String, dynamic>> _visites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisites();
  }

  Future<void> _loadVisites() async {
    if (widget.tourneeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    final res = await _tourneeService.getTourneeVisites(widget.tourneeId!);
    if (!mounted) return;

    if (res['success'] == true) {
      final data = res['data'];
      List<dynamic> raw = [];
      if (data is Map && data['visites'] != null) {
        raw = data['visites'] as List;
      } else if (data is List) {
        raw = data;
      }
      setState(() {
        _visites = raw.map((v) => Map<String, dynamic>.from(v)).toList();
        _visites.sort((a, b) => ((a['ordre'] ?? 0) as num).compareTo((b['ordre'] ?? 0) as num));
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _formatHeure(String? iso) {
    if (iso == null || iso.isEmpty) return '--:--';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.length >= 5 ? iso.substring(0, 5) : iso;
    }
  }

  String _libellePriorite(String? p) {
    switch (p?.toLowerCase()) {
      case 'critique': return 'Critique';
      case 'surveillance': return 'Surveillance';
      case 'normal': return 'Normal';
      default: return (p ?? 'Normal');
    }
  }

  Color _couleurPriorite(String? p) {
    switch (p?.toLowerCase()) {
      case 'critique': return const Color(0xFFFF4433);
      case 'surveillance': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.tourneeInfo ?? {};
    final titre = info['titre']?.toString() ?? 'Tournée du jour';
    final secteur = info['secteur']?.toString() ?? '';
    final heure = info['heure']?.toString() ?? '';
    final id = info['id']?.toString() ?? widget.tourneeId?.toString() ?? '';
    final isActive = (info['statut'] == 'En cours' || info['statut'] == 'en_cours');

    final visitesRealisees = _visites.where((v) => v['visite_at'] != null).length;
    final total = _visites.length;
    final progress = total > 0 ? visitesRealisees / total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          titre,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: 'Scanner QR',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScanScreen())),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
          : RefreshIndicator(
              color: const Color(0xFFFF4433),
              onRefresh: _loadVisites,
              child: Column(
                children: [
                  // Header info
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E1E2A)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.play_circle_filled : Icons.schedule,
                                    color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    info['statut']?.toString() ?? '—',
                                    style: TextStyle(
                                      color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text('TR-$id', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(Icons.access_time, heure.isNotEmpty ? heure : '--'),
                            _buildInfoItem(Icons.location_on, secteur.isNotEmpty ? secteur : '—'),
                            _buildInfoItem(Icons.people, '$visitesRealisees/$total visités'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0xFF1E1E2A),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4433)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Header liste
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Patients à visiter',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E1E2A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort, color: Color(0xFF6B6B7B), size: 16),
                              const SizedBox(width: 6),
                              Text('Par ordre', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _visites.isEmpty
                        ? Center(
                            child: Text(
                              'Aucune visite dans cette tournée',
                              style: TextStyle(color: Colors.white.withOpacity(0.5)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _visites.length,
                            itemBuilder: (context, index) => _buildVisiteItem(_visites[index]),
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loadVisites,
                  icon: const Icon(Icons.refresh, color: Color(0xFFFF4433)),
                  label: const Text('Rafraîchir', style: TextStyle(color: Color(0xFFFF4433))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF4433)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScanScreen())),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text('Scanner QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4433),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B6B7B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVisiteItem(Map<String, dynamic> v) {
    final patient = v['patient'] as Map<String, dynamic>? ?? {};
    final nom = '${patient['nom'] ?? ''} ${patient['prenom'] ?? ''}'.trim();
    final diagnostic = (v['diagnostic']?.toString() ?? '—').trim();
    final quartier = patient['ville']?.toString() ?? patient['adresse']?.toString().split(',').first ?? '—';
    final priorite = _libellePriorite(v['priorite']?.toString());
    final prioriteColor = _couleurPriorite(v['priorite']?.toString());
    final heure = _formatHeure(v['heure_prevue']?.toString());
    final isVisite = v['visite_at'] != null;
    final ordre = v['ordre'] as int? ?? 0;
    final actesCount = v['actes_count'] as int? ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PatientDetailScreen(nom: nom)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isVisite ? const Color(0xFF12121A).withOpacity(0.5) : const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isVisite ? const Color(0xFF4CAF50).withOpacity(0.3) : const Color(0xFF1E1E2A),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isVisite ? const Color(0xFF4CAF50) : const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isVisite
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text('$ordre', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          nom.isNotEmpty ? nom : 'Patient #${patient['id'] ?? '?'}',
                          style: TextStyle(
                            color: isVisite ? Colors.white.withOpacity(0.5) : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: isVisite ? TextDecoration.lineThrough : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: prioriteColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          priorite,
                          style: TextStyle(color: prioriteColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diagnostic,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 4),
                      Text(quartier, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                      if (actesCount > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.healing, size: 12, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 4),
                        Text('$actesCount actes', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  heure,
                  style: TextStyle(
                    color: isVisite ? Colors.white.withOpacity(0.4) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
