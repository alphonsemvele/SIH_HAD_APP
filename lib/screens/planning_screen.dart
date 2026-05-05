import 'package:flutter/material.dart';
import 'add_planning_screen.dart';
import '../services/planning_service.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final PlanningService _planningService = PlanningService();
  int _selectedDay = DateTime.now().day;
  List<Map<String, dynamic>> _planning = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _jours = [
    {'jour': 'Lun', 'date': 27, 'actif': true},
    {'jour': 'Mar', 'date': 28, 'actif': true},
    {'jour': 'Mer', 'date': 29, 'actif': true},
    {'jour': 'Jeu', 'date': 30, 'actif': true},
    {'jour': 'Ven', 'date': 31, 'actif': true},
    {'jour': 'Sam', 'date': 1, 'actif': false},
    {'jour': 'Dim', 'date': 2, 'actif': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadPlanning();
  }

  Future<void> _loadPlanning() async {
    setState(() => _isLoading = true);

    try {
      final result = await _planningService.getPlanning();

      if (result['success']) {
        setState(() {
          _planning = List<Map<String, dynamic>>.from(result['data']);
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

  Future<void> _refreshPlanning() async {
    await _loadPlanning();
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

  // Filtre les événements pour le jour sélectionné
  List<Map<String, dynamic>> _eventsForDay(int day) {
    return _planning.where((event) {
      final dateStr = event['date']?.toString();
      if (dateStr == null) return false;
      try {
        final date = DateTime.parse(dateStr);
        return date.day == day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Indique si un jour a au moins un événement
  bool _hasEventsOnDay(int day) {
    return _eventsForDay(day).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventsForDay(_selectedDay);

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
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
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
            onPressed: () => setState(() => _selectedDay = DateTime.now().day),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4433)),
            )
          : RefreshIndicator(
              onRefresh: _refreshPlanning,
              color: const Color(0xFFFF4433),
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF1A1A2E),
                          ),
                          onPressed: () {},
                        ),
                        Text(
                          _formatMonthYear(),
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF1A1A2E),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _jours.map((jour) {
                        final dayInt = jour['date'] as int;
                        final isSelected = dayInt == _selectedDay;
                        final isToday = dayInt == DateTime.now().day;
                        final isActif = jour['actif'] as bool;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = dayInt),
                          child: Container(
                            width: 45,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF4433)
                                  : Colors.transparent,
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
                                      '$dayInt',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                                ? const Color(0xFFFF4433)
                                                : isActif
                                                    ? const Color(0xFF1A1A2E)
                                                    : Colors.grey.shade400,
                                        fontSize: 16,
                                        fontWeight: isToday || isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (_hasEventsOnDay(dayInt))
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFFF4433),
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
                  Expanded(
                    child: events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun événement ce jour',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return _buildEventCard(events[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlanningScreen()),
          );

          if (result == true) {
            _refreshPlanning();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Événement créé avec succès'),
                backgroundColor: Color(0xFF4CAF50),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFFFF4433),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatMonthYear() {
    const mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    final now = DateTime.now();
    return '${mois[now.month - 1]} ${now.year}';
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
          Column(
            children: [
              Text(
                event['heure']?.toString() ?? '--:--',
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event['fin']?.toString() ?? '--:--',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
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
                          event['titre']?.toString() ?? 'Sans titre',
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
                    if (event['secteur'] != null)
                      _buildEventInfoRow(
                        Icons.location_on,
                        event['secteur'].toString(),
                      ),
                    const SizedBox(height: 6),
                    if (event['patients'] != null)
                      _buildEventInfoRow(
                        Icons.people,
                        '${event['patients']} patients',
                      ),
                  ] else if (event['lieu'] != null)
                    _buildEventInfoRow(Icons.room, event['lieu'].toString())
                  else if (event['quartier'] != null)
                    _buildEventInfoRow(
                      Icons.location_on,
                      event['quartier'].toString(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }
}