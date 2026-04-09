import 'package:flutter/material.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  int _selectedDay = 27; // Jour sélectionné (aujourd'hui)
  
  final List<Map<String, dynamic>> _jours = [
    {'jour': 'Lun', 'date': 27, 'actif': true},
    {'jour': 'Mar', 'date': 28, 'actif': true},
    {'jour': 'Mer', 'date': 29, 'actif': true},
    {'jour': 'Jeu', 'date': 30, 'actif': true},
    {'jour': 'Ven', 'date': 31, 'actif': true},
    {'jour': 'Sam', 'date': 1, 'actif': false},
    {'jour': 'Dim', 'date': 2, 'actif': false},
  ];

  final Map<int, List<Map<String, dynamic>>> _planning = {
    27: [
      {'heure': '08:00', 'fin': '12:00', 'titre': 'Tournée Matin', 'type': 'tournee', 'patients': 6, 'secteur': 'Bastos - Nlongkak'},
      {'heure': '14:00', 'fin': '17:00', 'titre': 'Tournée Après-midi', 'type': 'tournee', 'patients': 4, 'secteur': 'Omnisport - Essos'},
    ],
    28: [
      {'heure': '08:00', 'fin': '12:00', 'titre': 'Tournée Matin', 'type': 'tournee', 'patients': 5, 'secteur': 'Messa - Mokolo'},
      {'heure': '13:00', 'fin': '14:00', 'titre': 'Réunion équipe HAD', 'type': 'reunion', 'lieu': 'Salle 204'},
      {'heure': '15:00', 'fin': '17:00', 'titre': 'Formation soins palliatifs', 'type': 'formation', 'lieu': 'Amphi B'},
    ],
    29: [
      {'heure': '08:00', 'fin': '16:00', 'titre': 'Tournée Complète', 'type': 'tournee', 'patients': 8, 'secteur': 'Bastos - Nlongkak - Omnisport'},
    ],
    30: [
      {'heure': '08:00', 'fin': '12:00', 'titre': 'Tournée Matin', 'type': 'tournee', 'patients': 6, 'secteur': 'Bastos'},
      {'heure': '14:00', 'fin': '15:00', 'titre': 'Visite urgence - M. Mbede', 'type': 'urgence', 'quartier': 'Bastos'},
    ],
    31: [
      {'heure': '08:00', 'fin': '12:00', 'titre': 'Tournée Matin', 'type': 'tournee', 'patients': 5, 'secteur': 'Nlongkak - Messa'},
      {'heure': '14:00', 'fin': '17:00', 'titre': 'Tournée Après-midi', 'type': 'tournee', 'patients': 4, 'secteur': 'Essos'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final events = _planning[_selectedDay] ?? [];

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
          'Planning',
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
              child: const Icon(Icons.today, color: Color(0xFF1A1A2E), size: 20),
            ),
            onPressed: () => setState(() => _selectedDay = 27),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Mois et année
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF1A1A2E)),
                  onPressed: () {},
                ),
                const Text(
                  'Janvier 2025',
                  style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF1A1A2E)),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Jours de la semaine
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _jours.map((jour) {
                final isSelected = jour['date'] == _selectedDay;
                final isToday = jour['date'] == 27;
                final isActif = jour['actif'] as bool;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = jour['date'] as int),
                  child: Container(
                    width: 45,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF4433) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          jour['jour'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isActif
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isToday && !isSelected
                                ? const Color(0xFFFF4433).withOpacity(0.1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${jour['date']}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFFFF4433)
                                        : isActif
                                            ? const Color(0xFF1A1A2E)
                                            : Colors.grey.shade400,
                                fontSize: 16,
                                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_planning.containsKey(jour['date']))
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : const Color(0xFFFF4433),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Événements du jour
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun événement ce jour',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventCard(event);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF4433),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    Color typeColor;
    IconData typeIcon;

    switch (event['type']) {
      case 'tournee':
        typeColor = const Color(0xFFFF4433);
        typeIcon = Icons.route;
        break;
      case 'reunion':
        typeColor = const Color(0xFF2196F3);
        typeIcon = Icons.groups;
        break;
      case 'formation':
        typeColor = const Color(0xFF9C27B0);
        typeIcon = Icons.school;
        break;
      case 'urgence':
        typeColor = const Color(0xFFFF9800);
        typeIcon = Icons.emergency;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.event;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Text(
                event['heure'],
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event['fin'],
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Ligne verticale
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 80,
                color: typeColor.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Card de l'événement
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: typeColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event['titre'],
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (event['type'] == 'tournee') ...[
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          event['secteur'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          '${event['patients']} patients',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ] else if (event['lieu'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.room, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          event['lieu'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ] else if (event['quartier'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          event['quartier'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}