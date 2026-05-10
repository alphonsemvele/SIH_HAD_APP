import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'saisie_constantes_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  /// Compatibilité ancienne signature : on peut passer juste le nom
  final String? nom;
  /// Nouvelle signature : passer le Map patient complet (recommandé)
  final Map<String, dynamic>? patient;

  const PatientDetailScreen({super.key, this.nom, this.patient});

  // ────────────── Helpers extraction patient ──────────────

  String _nomComplet() {
    if (patient != null) {
      final n = patient!['nom']?.toString() ?? '';
      final p = patient!['prenom']?.toString() ?? '';
      return '$n $p'.trim().isEmpty ? (nom ?? 'Patient') : '$n $p'.trim();
    }
    return nom ?? 'Patient';
  }

  String _initiales() {
    final parts = _nomComplet().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((e) => e[0]).take(2).join().toUpperCase();
  }

  int _age() {
    // Fallback: si l'age est deja calcule cote liste (patients_screen)
    final ageDirect = patient?['age'];
    if (ageDirect is int && ageDirect > 0) return ageDirect;
    if (ageDirect is String) {
      final n = int.tryParse(ageDirect.replaceAll(RegExp(r'[^0-9]'), ''));
      if (n != null && n > 0) return n;
    }

    if (patient?['date_naissance'] == null) return 0;
    try {
      final dob = DateTime.parse(patient!['date_naissance'].toString());
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      return age;
    } catch (_) {
      return 0;
    }
  }

  String _sexe() {
    final s = patient?['sexe']?.toString().toUpperCase() ?? '';
    return s == 'F' ? 'Féminin' : (s == 'M' ? 'Masculin' : '—');
  }

  String _quartier() {
    return patient?['quartier']?.toString() ?? patient?['ville']?.toString() ?? '—';
  }

  String _diagnostic() {
    // Priorité: diagnostic direct (mappe par patients_screen) -> antecedents -> default
    final diag = patient?['diagnostic']?.toString();
    if (diag != null && diag.isNotEmpty && diag != 'Pas de diagnostic') return diag;

    final antc = patient?['antecedents_medicaux'];
    if (antc is List && antc.isNotEmpty) {
      return antc.take(2).join(' • ');
    }
    return 'Suivi médical';
  }

  String _priorite() {
    final p = patient?['priorite']?.toString().toLowerCase() ?? '';
    return switch (p) {
      'critique' => 'Critique',
      'surveillance' => 'Surveillance',
      _ => 'Standard',
    };
  }

  Color _prioriteColor() {
    final p = patient?['priorite']?.toString().toLowerCase() ?? '';
    return switch (p) {
      'critique' => const Color(0xFFFF4433),
      'surveillance' => const Color(0xFFFF9800),
      _ => const Color(0xFF4CAF50),
    };
  }

  String _telephone() {
    return patient?['telephone']?.toString() ?? patient?['telephone_urgence']?.toString() ?? '';
  }

  List<String> _allergies() {
    final a = patient?['allergies'];
    if (a is List) return a.map((e) => e.toString()).toList();
    return [];
  }

  // ────────────── Build ──────────────

  @override
  Widget build(BuildContext context) {
    final pColor = _prioriteColor();
    final allergies = _allergies();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0F),
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_telephone().isNotEmpty)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 20),
                  ),
                  onPressed: () => _appelerPatient(context),
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [pColor.withOpacity(0.3), const Color(0xFF0A0A0F)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _initiales(),
                          style: TextStyle(color: pColor, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nomComplet(),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _priorite(),
                        style: TextStyle(color: pColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E1E2A)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildInfoChip(Icons.cake, _age() > 0 ? '${_age()} ans' : '— ans'),
                            const SizedBox(width: 10),
                            _buildInfoChip(Icons.person, _sexe()),
                            const SizedBox(width: 10),
                            Expanded(child: _buildInfoChip(Icons.location_on, _quartier())),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFF1E1E2A)),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.medical_services, color: Color(0xFFFF4433), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _diagnostic(),
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        if (allergies.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning, color: Color(0xFFFF9800), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Allergies : ${allergies.join(", ")}',
                                  style: const TextStyle(color: Color(0xFFFF9800), fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Constantes (placeholder - pas encore branché vrai backend)
                  const Row(
                    children: [
                      Text(
                        'Dernières constantes',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E1E2A)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.monitor_heart, size: 40, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune constante saisie',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SaisieConstantesScreen(patientNom: _nomComplet()),
                            ),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white, size: 16),
                          label: const Text('Saisir des constantes', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4433),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Antécédents (depuis patient.antecedents_medicaux)
                  if (patient?['antecedents_medicaux'] is List &&
                      (patient!['antecedents_medicaux'] as List).isNotEmpty) ...[
                    const Text(
                      'Antécédents médicaux',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...(patient!['antecedents_medicaux'] as List).map((a) => _buildAntecedentItem(a.toString())),
                    const SizedBox(height: 24),
                  ],

                  // Coordonnées
                  const Text(
                    'Coordonnées',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E1E2A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_telephone().isNotEmpty) _kvRow(Icons.phone, 'Téléphone', _telephone()),
                        if (patient?['adresse'] != null) _kvRow(Icons.home, 'Adresse', patient!['adresse'].toString()),
                        if (patient?['email'] != null && patient!['email'].toString().isNotEmpty)
                          _kvRow(Icons.email, 'Email', patient!['email'].toString()),
                        if (patient?['nationalite'] != null)
                          _kvRow(Icons.flag, 'Nationalité', patient!['nationalite'].toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SaisieConstantesScreen(patientNom: _nomComplet())),
            ),
            icon: const Icon(Icons.edit_note, color: Colors.white),
            label: const Text(
              'Saisir les constantes',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4433),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntecedentItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4433).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.history, color: Color(0xFFFF4433), size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _kvRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _appelerPatient(BuildContext context) async {
    final tel = _telephone().replaceAll(' ', '');
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
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appel impossible: $tel'),
            backgroundColor: const Color(0xFFFF4433),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur appel: $e'),
            backgroundColor: const Color(0xFFFF4433),
          ),
        );
      }
    }
  }

}
