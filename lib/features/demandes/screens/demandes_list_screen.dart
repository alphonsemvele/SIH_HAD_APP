import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/demandes_service.dart';
import '../models/demande_visite.dart';
import 'nouvelle_demande_screen.dart';

class DemandesListScreen extends StatefulWidget {
  const DemandesListScreen({super.key});

  @override
  State<DemandesListScreen> createState() => _DemandesListScreenState();
}

class _DemandesListScreenState extends State<DemandesListScreen> {
  final _service = DemandesService();
  List<DemandeVisite> _demandes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.list();
      if (!mounted) return;
      setState(() {
        _demandes = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _nouvelleDemande() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NouvelleDemandeScreen()),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mes demandes de visite',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: _nouvelleDemande,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle demande',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.error_outline, color: AppColors.accent, size: 56),
          const SizedBox(height: 16),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Réessayer'),
          ),
        ],
      );
    }
    if (_demandes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.assignment_outlined, color: Colors.white.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 20),
          const Text('Aucune demande pour l\'instant',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur "Nouvelle demande" pour solliciter une visite à domicile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: _demandes.length,
      itemBuilder: (_, i) => _card(_demandes[i]),
    );
  }

  Widget _card(DemandeVisite d) {
    final (icon, color) = _statutBadge(d.statut);
    final urgenceColor = _urgenceColor(d.urgence);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(d.statutLibelle,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgenceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(d.urgenceLibelle,
                    style: TextStyle(color: urgenceColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(d.symptomes,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          if (d.dateSouhaitee != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white.withValues(alpha: 0.5), size: 14),
                const SizedBox(width: 6),
                Text(
                  d.heureSouhaitee != null
                      ? '${d.dateSouhaitee} à ${d.heureSouhaitee}'
                      : d.dateSouhaitee!,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ],
          if (d.soignantName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.5), size: 14),
                const SizedBox(width: 6),
                Text('Pris en charge par ${d.soignantName}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              ],
            ),
          ],
          if (d.statut == 'refusee' && d.raisonRefus != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Motif du refus : ${d.raisonRefus}',
                  style: const TextStyle(color: AppColors.accent, fontSize: 13)),
            ),
          ],
          if (d.notesInfirmier != null && d.notesInfirmier!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(d.notesInfirmier!,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  (IconData, Color) _statutBadge(String statut) {
    switch (statut) {
      case 'en_attente': return (Icons.schedule, Colors.amber);
      case 'acceptee':   return (Icons.check_circle, AppColors.success);
      case 'en_cours':   return (Icons.directions_run, Colors.blueAccent);
      case 'terminee':   return (Icons.task_alt, AppColors.success);
      case 'refusee':    return (Icons.cancel, AppColors.accent);
      default:           return (Icons.help_outline, AppColors.textTertiary);
    }
  }

  Color _urgenceColor(String urgence) {
    switch (urgence) {
      case 'faible':   return Colors.greenAccent;
      case 'moyenne':  return Colors.amber;
      case 'urgente':  return Colors.orangeAccent;
      case 'critique': return AppColors.accent;
      default:         return AppColors.textTertiary;
    }
  }
}
