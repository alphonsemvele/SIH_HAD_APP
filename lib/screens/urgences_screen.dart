import 'package:flutter/material.dart';

class UrgencesScreen extends StatelessWidget {
  const UrgencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final urgences = [
      {
        'nom': 'Marie-Claire Bella',
        'age': 45,
        'diagnostic': 'Diabète type 2 - Plaie infectée',
        'alerte': 'Glycémie critique: 2.8 g/L',
        'heure': '08:45',
        'quartier': 'Nlongkak',
        'telephone': '+237 690 345 678',
        'niveau': 'Critique',
      },
      {
        'nom': 'François Mbede',
        'age': 78,
        'diagnostic': 'Cancer poumon - Soins palliatifs',
        'alerte': 'Détresse respiratoire signalée',
        'heure': '09:12',
        'quartier': 'Bastos',
        'telephone': '+237 699 678 901',
        'niveau': 'Critique',
      },
      {
        'nom': 'Jean-Pierre Nguemo',
        'age': 67,
        'diagnostic': 'Insuffisance cardiaque',
        'alerte': 'Tension élevée: 180/110 mmHg',
        'heure': '10:30',
        'quartier': 'Bastos',
        'telephone': '+237 677 234 567',
        'niveau': 'Urgent',
      },
      {
        'nom': 'Robert Tagne',
        'age': 72,
        'diagnostic': 'BPCO - Oxygénothérapie',
        'alerte': 'Saturation basse: 88%',
        'heure': '11:15',
        'quartier': 'Messa',
        'telephone': '+237 655 456 789',
        'niveau': 'Urgent',
      },
    ];

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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header d'urgence
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
                    _buildUrgenceStat('Critiques', '2', Colors.white),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                    _buildUrgenceStat('Urgents', '2', Colors.white),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                    _buildUrgenceStat('En attente', '4', Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_in_talk, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'SAMU: 119 | Urgences: 112',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des urgences
          Expanded(
            child: ListView.builder(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAlertDialog(context),
        backgroundColor: const Color(0xFFFF4433),
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('Nouvelle alerte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
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
          // Header avec niveau
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

          // Contenu
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
                          (urgence['nom'] as String).split(' ').map((e) => e[0]).take(2).join(),
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
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Alerte
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

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.phone, color: cardColor, size: 18),
                        label: Text('Appeler', style: TextStyle(color: cardColor)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cardColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.navigation, color: Colors.white, size: 18),
                        label: const Text('Y aller', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  void _showNewAlertDialog(BuildContext context) {
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
                'Nouvelle alerte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Formulaire de nouvelle alerte...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}