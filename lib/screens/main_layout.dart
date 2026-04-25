import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tournees_screen.dart';
import 'patients_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'urgences_screen.dart';
import 'planning_screen.dart';
import 'messagerie_screen.dart';
import 'rapports_screen.dart';
import 'test_api_screen.dart';
import 'test_patient_creation_screen.dart';
import 'test_login_screen.dart';
import 'test_login_fixed_screen.dart';
import 'test_api_routes_screen.dart';
import 'test_sanctum_auth_screen.dart';
import 'test_all_endpoints_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const TourneesScreen(),
    const PatientsScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu, color: Color(0xFF1A1A2E), size: 20),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.network(
          'https://via.placeholder.com/120x40/FF4433/FFFFFF?text=HAD',
          height: 32,
          errorBuilder: (_, __, ___) => const Text(
            'HAD Mobile',
            style: TextStyle(
              color: Color(0xFFFF4433),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A2E), size: 20),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4433),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Accueil'),
                _buildNavItem(1, Icons.calendar_month_rounded, 'Tournées'),
                _buildNavItem(2, Icons.people_rounded, 'Patients'),
                _buildNavItem(3, Icons.map_rounded, 'Carte'),
                _buildNavItem(4, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header du drawer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4433).withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4433), Color(0xFFFF6B5B)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'AN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Anne Ngo Likeng',
                          style: TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Infirmière HAD',
                          style: TextStyle(
                            color: const Color(0xFF1A1A2E).withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF1A1A2E)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerSection('PRINCIPAL'),
                  _buildDrawerItem(Icons.home_rounded, 'Accueil', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 0);
                  }),
                  _buildDrawerItem(Icons.calendar_month_rounded, 'Tournées', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  }),
                  _buildDrawerItem(Icons.people_rounded, 'Patients', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  }),
                  
                  const SizedBox(height: 10),
                  _buildDrawerSection('OUTILS'),
                  _buildDrawerItem(Icons.warning_amber_rounded, 'Urgences', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UrgencesScreen()));
                  }, badge: '2', badgeColor: const Color(0xFFFF4433)),
                  _buildDrawerItem(Icons.calendar_today_rounded, 'Planning', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanningScreen()));
                  }),
                  _buildDrawerItem(Icons.chat_bubble_outline_rounded, 'Messagerie', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagerieScreen()));
                  }, badge: '3', badgeColor: const Color(0xFF4CAF50)),
                  _buildDrawerItem(Icons.description_outlined, 'Rapports', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RapportsScreen()));
                  }),
                  
                  const SizedBox(height: 10),
                  _buildDrawerSection('AUTRES'),
                  _buildDrawerItem(Icons.map_rounded, 'Carte', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 3);
                  }),
                  _buildDrawerItem(Icons.settings_outlined, 'Paramètres', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 4);
                  }),
                  _buildDrawerItem(Icons.help_outline_rounded, 'Aide', () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.bug_report_rounded, 'Test API', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestApiScreen()));
                  }),
                  _buildDrawerItem(Icons.person_add_rounded, 'Test Patient', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestPatientCreationScreen()));
                  }),
                  _buildDrawerItem(Icons.login_rounded, 'Test Login', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestLoginScreen()));
                  }),
                  _buildDrawerItem(Icons.security_rounded, 'Test Login Fixed', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestLoginFixedScreen()));
                  }),
                  _buildDrawerItem(Icons.api_rounded, 'Test API Routes', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestApiRoutesScreen()));
                  }),
                  _buildDrawerItem(Icons.security_rounded, 'Test Sanctum Auth', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestSanctumAuthScreen()));
                  }),
                  _buildDrawerItem(Icons.checklist_rounded, 'Test Tous Endpoints', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestAllEndpointsScreen()));
                  }),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital, color: Color(0xFFFF4433), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Hôpital Central de Yaoundé',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {String? badge, Color? badgeColor}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor?.withOpacity(0.15) ?? Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor ?? Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4433).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF4433) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF4433) : Colors.grey.shade400,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}