import 'package:flutter/material.dart';
import 'add_alerte_screen.dart';
import '../services/alerte_service.dart';

class UrgencesScreen extends StatefulWidget {
  const UrgencesScreen({super.key});

  @override
  State<UrgencesScreen> createState() => _UrgencesScreenState();
}

class _UrgencesScreenState extends State<UrgencesScreen> {
  final AlerteService _alerteService = AlerteService();
  List<Map<String, dynamic>> _alertes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlertes();
  }

  Future<void> _loadAlertes() async {
    setState(() => _isLoading = true);

    try {
      final result = await _alerteService.getAlertes();

      if (result['success']) {
        setState(() {
          _alertes = List<Map<String, dynamic>>.from(result['data']);
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

  Future<void> _refreshAlertes() async {
    await _loadAlertes();
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

  Map<String, dynamic> _mapAlerteFromApi(Map<String, dynamic> alerte) {
    return {
      'id': alerte['id'],
      'nom': alerte['patient_nom'] ?? 'Non spécifié',
      'age': alerte['age'] ?? 0,
      'diagnostic': alerte['diagnostic'] ?? 'Non spécifié',
      'alerte': alerte['alerte'] ?? 'Non spécifié',
      'heure': alerte['heure'] ?? '00:00',
      'quartier': alerte['quartier'] ?? 'Non spécifié',
      'telephone': alerte['telephone'] ?? 'Non spécifié',
      'niveau': alerte['niveau'] ?? 'Moyen',
    };
  }

  @override
  Widget build(BuildContext context) {
    final urgences = _alertes.map((alerte) => _mapAlerteFromApi(alerte)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4433),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Urgences',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${urgences.length} alertes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4433)),
            )
          : RefreshIndicator(
              onRefresh: _refreshAlertes,
              color: const Color(0xFFFF4433),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4433),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildUrgenceStat(
                              'Critiques',
                              '${urgences.where((u) => u['niveau'] == 'Critique').length}',
                              Colors.white,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _buildUrgenceStat(
                              'Urgents',
                              '${urgences.where((u) => u['niveau'] == 'Urgent').length}',
                              Colors.white,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _buildUrgenceStat(
                              'Total',
                              '${urgences.length}',
                              Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'SAMU: 119 | Urgences: 112',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: urgences.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aucune alerte pour le moment',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: urgences.length,
                            itemBuilder: (context, index) {
                              final urgence = urgences[index];
                              return _buildUrgenceCard(context, urgence);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAlertDialog(context),
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text(
          'Nouvelle alerte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildUrgenceStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUrgenceCard(BuildContext context, Map<String, dynamic> urgence) {
    final isCritique = urgence['niveau'] == 'Critique';
    final cardColor = isCritique ? const Color(0xFFFF4433) : const Color(0xFFFF9800);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCritique ? Icons.emergency : Icons.warning_amber,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  urgence['niveau'],
                  style: TextStyle(
                    color: cardColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  urgence['heure'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(urgence['nom'] as String),
                          style: TextStyle(
                            color: cardColor,
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
                            urgence['nom'],
                            style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${urgence['age']} ans • ${urgence['quartier']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: cardColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          urgence['alerte'],
                          style: TextStyle(
                            color: cardColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  urgence['diagnostic'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.phone, color: cardColor, size: 18),
                        label: Text(
                          'Appeler',
                          style: TextStyle(color: cardColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cardColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Y aller',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String nom) {
    if (nom.isEmpty) return '?';
    final parts = nom.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((e) => e[0]).take(2).join().toUpperCase();
  }

  void _showNewAlertDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAlerteScreen()),
    );

    if (result == true) {
      _refreshAlertes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerte créée avec succès'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}