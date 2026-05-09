import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final results = await Future.wait([
      _authService.getMe(),
      _authService.getStats(),
    ]);
    if (mounted) {
      setState(() {
        _user = results[0];
        _stats = results[1];
        _isLoading = false;
      });
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      const mois = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return '${d.day} ${mois[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4433))),
      );
    }

    final name = _user?['name']?.toString() ?? 'Utilisateur';
    final fonctionRaw = _user?['fonction']?.toString() ?? '';
    final fonction = switch (fonctionRaw) {
      'medecin' => 'Médecin',
      'infirmier' => 'Infirmier(ère)',
      'sage_femme' => 'Sage-femme',
      'pharmacien' => 'Pharmacien(ne)',
      'technicien' => 'Technicien(ne)',
      'laborantin' => 'Laborantin(e)',
      'administratif' => 'Administratif',
      'receptionniste' => 'Réceptionniste',
      'comptable' => 'Comptable',
      _ => fonctionRaw.isNotEmpty ? fonctionRaw : 'Soignant(e) HAD',
    };
    final email = _user?['email']?.toString() ?? '—';
    final matricule = _user?['matricule']?.toString() ?? '—';
    final telephone = _user?['telephone']?.toString() ?? '—';
    final service = _user?['service']?.toString() ?? '—';
    final dateEmbauche = _formatDate(_user?['date_embauche']?.toString());

    final visites = _stats?['visites_total']?.toString() ?? '0';
    final patients = _stats?['patients_uniques']?.toString() ?? '0';
    final note = _stats?['note_moyenne']?.toString() ?? '—';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: RefreshIndicator(
        color: const Color(0xFFFF4433),
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF4433).withOpacity(0.2),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF4433), Color(0xFFFF6B5B)]),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF4433).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: Center(
                        child: Text(
                          _initials(name),
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(fonction, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatBadge(visites, 'Visites'),
                        const SizedBox(width: 16),
                        _buildStatBadge(patients, 'Patients'),
                        const SizedBox(width: 16),
                        _buildStatBadge(note, 'Note'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informations', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow(Icons.badge, 'Matricule', matricule),
                      _buildInfoRow(Icons.email, 'Email', email),
                      _buildInfoRow(Icons.phone, 'Téléphone', telephone),
                      _buildInfoRow(Icons.apartment, 'Service', service),
                      _buildInfoRow(Icons.calendar_today, 'Depuis', dateEmbauche),
                    ]),
                    const SizedBox(height: 24),
                    const Text('Paramètres', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _buildSettingRow(Icons.notifications, 'Notifications', trailing: _buildSwitch(true)),
                      _buildSettingRow(Icons.location_on, 'Localisation', trailing: _buildSwitch(true)),
                      _buildSettingRow(Icons.dark_mode, 'Mode sombre', trailing: _buildSwitch(true)),
                      _buildSettingRow(Icons.language, 'Langue', trailing: Text('Français', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
                    ]),
                    const SizedBox(height: 24),
                    const Text('Application', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _buildSettingRow(Icons.help_outline, 'Aide & Support', hasArrow: true),
                      _buildSettingRow(Icons.info_outline, 'À propos', trailing: Text('v1.0.0', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
                    ]),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4433).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFF4433).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Color(0xFFFF4433)),
                            SizedBox(width: 10),
                            Text('Se déconnecter', style: TextStyle(color: Color(0xFFFF4433), fontWeight: FontWeight.w600, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF12121A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E1E2A))),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: const Color(0xFF12121A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E1E2A))),
    child: Column(children: children),
  );

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF6B6B7B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF12121A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E1E2A))),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(children: [e.value, if (!isLast) const Divider(color: Color(0xFF1E1E2A), height: 1)]);
        }).toList(),
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, {Widget? trailing, bool hasArrow = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF6B6B7B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
          if (trailing != null) trailing,
          if (hasArrow) Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value) => Switch(
    value: value, onChanged: (v) {},
    activeColor: const Color(0xFFFF4433),
    activeTrackColor: const Color(0xFFFF4433).withOpacity(0.3),
    inactiveThumbColor: const Color(0xFF6B6B7B),
    inactiveTrackColor: const Color(0xFF1E1E2A),
  );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?', style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4433), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
