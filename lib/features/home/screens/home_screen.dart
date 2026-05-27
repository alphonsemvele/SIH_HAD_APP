import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../visits/screens/visits_list_screen.dart';
import '../../demandes/screens/demandes_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? user;
  const HomeScreen({super.key, this.user});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prenom = user?['prenom']?.toString() ?? '';
    final nom    = user?['nom']?.toString() ?? '';
    final dossier = user?['numero_dossier']?.toString() ?? '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prenom.isEmpty ? 'Bonjour' : 'Bonjour $prenom',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text('Dossier $dossier',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.accent),
                  onPressed: () => _logout(context),
                  tooltip: 'Déconnexion',
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mon espace patient',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                    nom.isNotEmpty
                        ? 'Bienvenue $prenom $nom. Consultez vos visites HAD ou demandez une nouvelle visite.'
                        : 'Consultez vos visites HAD ou demandez une nouvelle visite.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _tile(
              context,
              icon: Icons.calendar_today,
              title: 'Mes visites à domicile',
              subtitle: 'Voir mes prochains rendez-vous',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VisitsListScreen()),
              ),
            ),
            _tile(
              context,
              icon: Icons.medical_services,
              title: 'Demander une visite',
              subtitle: 'Solliciter un soignant à domicile',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DemandesListScreen()),
              ),
            ),
            _tileDisabled(Icons.medication,  'Mes ordonnances'),
            _tileDisabled(Icons.description, 'Mon dossier médical'),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _tileDisabled(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 22),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.2), size: 16),
        ],
      ),
    );
  }
}
