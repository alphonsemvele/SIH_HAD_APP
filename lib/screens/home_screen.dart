import 'package:flutter/material.dart';
import 'tournee_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournée en cours
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TourneeDetailScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF4433), Color(0xFFFF6B5B)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF4433).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Row(children: [Icon(Icons.play_circle_filled, color: Colors.white, size: 16), SizedBox(width: 6), Text('EN COURS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]),
                        ),
                        const Text('08:00 - 12:00', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Tournée du Matin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Secteur Bastos - Nlongkak', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('3/6 patients', style: TextStyle(color: Colors.white, fontSize: 13)), const Text('50%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(value: 0.5, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _buildStatCard('Visites', '6', Icons.calendar_today, const Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                _buildStatCard('Critiques', '2', Icons.warning_amber, const Color(0xFFFF9800)),
                const SizedBox(width: 12),
                _buildStatCard('Alertes', '3', Icons.notifications, const Color(0xFFFF4433)),
              ],
            ),
            const SizedBox(height: 24),

            // Prochains patients
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prochains patients', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Voir tout', style: TextStyle(color: Color(0xFFFF4433)))),
              ],
            ),
            const SizedBox(height: 12),
            _buildPatientCard('Marie-Claire Bella', 'Diabète - Plaie pied', 'Nlongkak', 'Critique', '09:30'),
            _buildPatientCard('Robert Tagne', 'BPCO - Oxygénothérapie', 'Messa', 'Surveillance', '10:15'),
            _buildPatientCard('Pauline Essomba', 'AVC - Rééducation', 'Omnisport', 'Normal', '11:00'),
            const SizedBox(height: 24),

            // Alertes
            const Text('Alertes récentes', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAlertCard('Tension élevée', 'Jean-Pierre Nguemo - 160/100 mmHg', '08:45', Icons.favorite, const Color(0xFFFF4433)),
            _buildAlertCard('Glycémie haute', 'Marie-Claire Bella - 2.1 g/L', '07:30', Icons.water_drop, const Color(0xFFFF9800)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(String nom, String diagnostic, String quartier, String priorite, String heure) {
    Color pColor = priorite == 'Critique' ? const Color(0xFFFF4433) : priorite == 'Surveillance' ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(nom.split(' ').map((e) => e[0]).take(2).join(), style: TextStyle(color: pColor, fontWeight: FontWeight.bold, fontSize: 16)))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nom, style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text(diagnostic, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey.shade400), const SizedBox(width: 4), Text(quartier, style: TextStyle(color: Colors.grey.shade400, fontSize: 11))]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(priorite, style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            Text(heure, style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)), Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))])),
          Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}