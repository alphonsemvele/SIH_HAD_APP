import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/demande_service.dart';

class DemandeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> demande;
  const DemandeDetailScreen({super.key, required this.demande});

  @override
  State<DemandeDetailScreen> createState() => _DemandeDetailScreenState();
}

class _DemandeDetailScreenState extends State<DemandeDetailScreen> {
  final DemandeService _demandeService = DemandeService();
  late Map<String, dynamic> _demande;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _demande = Map<String, dynamic>.from(widget.demande);
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

  Color _statutColor(String s) => switch (s) {
        'acceptee' || 'en_cours' => const Color(0xFF2196F3),
        'terminee' => const Color(0xFF4CAF50),
        'refusee' => Colors.grey,
        _ => const Color(0xFFFF9800),
      };

  Future<void> _callPatient() async {
    final tel = (_demande['patient_telephone']?.toString() ?? '').replaceAll(' ', '');
    if (tel.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$tel'));
    } catch (_) {}
  }

  Future<void> _openMap() async {
    final lat = _demande['latitude'];
    final lng = _demande['longitude'];
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pas de coordonnées GPS'), backgroundColor: Color(0xFFFF9800)),
      );
      return;
    }
    final uri = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _accepter() async {
    final notesCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('Accepter la demande', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notes (optionnel) :',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: const Color(0xFF0A0A0F),
                filled: true,
                hintText: 'Ex: passe après tournée matinée',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accepter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      final res = await _demandeService.accepterDemande(
        _demande['id'] as int,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        final newData = res['data']?['data'];
        if (newData is Map) {
          setState(() => _demande = Map<String, dynamic>.from(newData));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande acceptée'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Erreur'),
            backgroundColor: const Color(0xFFFF4433),
          ),
        );
      }
    }
  }

  Future<void> _refuser() async {
    final raisonCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('Refuser la demande', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Raison du refus (obligatoire) :',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: raisonCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: const Color(0xFF0A0A0F),
                filled: true,
                hintText: 'Ex: hors zone, équipe complète, etc.',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4433)),
            onPressed: () {
              if (raisonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Raison obligatoire')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Refuser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      final res = await _demandeService.refuserDemande(
        _demande['id'] as int,
        raisonCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        final newData = res['data']?['data'];
        if (newData is Map) {
          setState(() => _demande = Map<String, dynamic>.from(newData));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande refusée'), backgroundColor: Color(0xFFFF9800)),
        );
      }
    }
  }

  Future<void> _terminer() async {
    final notesCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('Terminer la demande', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notes finales (optionnel) :',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: const Color(0xFF0A0A0F),
                filled: true,
                hintText: 'Ex: visite effectuée, patient stable',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Terminer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      final res = await _demandeService.terminerDemande(
        _demande['id'] as int,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        final newData = res['data']?['data'];
        if (newData is Map) {
          setState(() => _demande = Map<String, dynamic>.from(newData));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Demande terminée'), backgroundColor: Color(0xFF4CAF50)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgence = _demande['urgence']?.toString() ?? 'moyenne';
    final color = _urgenceColor(urgence);
    final statut = _demande['statut']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Détail demande',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête urgence + statut
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _demande['type_libelle']?.toString() ?? '—',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _demande['urgence_libelle']?.toString() ?? '—',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _demande['patient_nom']?.toString() ?? '—',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        if (_demande['patient_age'] != null)
                          Text(
                            '${_demande['patient_age']} ans',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (statut != 'en_attente') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statutColor(statut).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _statutColor(statut).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: _statutColor(statut), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Statut: ${_demande['statut_libelle']}',
                            style: TextStyle(color: _statutColor(statut), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _section('Symptômes', _demande['symptomes']?.toString() ?? '—',
                      icon: Icons.healing),
                  if (_demande['duree_symptomes'] != null)
                    _section('Durée', _demande['duree_symptomes'].toString(),
                        icon: Icons.access_time),

                  _section(
                    'Adresse',
                    '${_demande['adresse']}\n${_demande['quartier'] ?? ""} - ${_demande['ville'] ?? "Yaoundé"}',
                    icon: Icons.location_on,
                  ),

                  if (_demande['demandeur_nom'] != null)
                    _section(
                      'Demande faite par',
                      '${_demande['demandeur_nom']} (${_demande['demandeur_relation'] ?? "proche"})',
                      icon: Icons.person,
                    ),

                  if (_demande['notes_infirmier'] != null)
                    _section('Notes infirmier', _demande['notes_infirmier'].toString(),
                        icon: Icons.note),

                  if (_demande['raison_refus'] != null)
                    _section('Raison du refus', _demande['raison_refus'].toString(),
                        icon: Icons.cancel_outlined),

                  const SizedBox(height: 16),

                  // Actions secondaires
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _callPatient,
                          icon: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                          label: const Text('Appeler', style: TextStyle(color: Color(0xFF4CAF50))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openMap,
                          icon: const Icon(Icons.map, color: Color(0xFF2196F3)),
                          label: const Text('Carte', style: TextStyle(color: Color(0xFF2196F3))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2196F3)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions principales selon statut
                  if (statut == 'en_attente') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _accepter,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('Accepter la demande',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _refuser,
                        icon: const Icon(Icons.cancel, color: Color(0xFFFF4433)),
                        label: const Text('Refuser', style: TextStyle(color: Color(0xFFFF4433))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF4433)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ] else if (statut == 'acceptee' || statut == 'en_cours') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _terminer,
                        icon: const Icon(Icons.task_alt, color: Colors.white),
                        label: const Text('Marquer comme terminée',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _section(String label, String value, {required IconData icon}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
