import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../services/tournee_service.dart';
import '../config/api_config.dart';

class TestAllEndpointsScreen extends StatefulWidget {
  const TestAllEndpointsScreen({super.key});

  @override
  State<TestAllEndpointsScreen> createState() => _TestAllEndpointsScreenState();
}

class _TestAllEndpointsScreenState extends State<TestAllEndpointsScreen> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  final TourneeService _tourneeService = TourneeService();
  String _result = '';
  bool _isLoading = false;

  void _updateResult(String message) {
    setState(() {
      _result += '\n$message';
    });
  }

  Future<void> _testAllEndpoints() async {
    setState(() {
      _result = '=== Test Complet des Endpoints ===\n';
      _isLoading = true;
    });

    // Test 1: Authentification
    _updateResult('🔐 1. AUTHENTIFICATION');
    _updateResult('   Test login...');
    try {
      final loginResult = await _authService.login('anne.ngo@had.com', 'password');
      if (loginResult['success']) {
        _updateResult('   ✅ Login réussi: ${loginResult['data']['name']}');
      } else {
        _updateResult('   ❌ Login échoué: ${loginResult['message']}');
        return;
      }
    } catch (e) {
      _updateResult('   ❌ Erreur login: $e');
      return;
    }

    // Test 2: Patients
    _updateResult('\n👥 2. PATIENTS');
    _updateResult('   Test GET /api/patients...');
    try {
      final patientsResult = await _patientService.getPatients();
      if (patientsResult['success']) {
        final data = patientsResult['data'];
        if (data is Map && data['data'] != null) {
          final patients = data['data'];
          if (patients is List) {
            _updateResult('   ✅ ${patients.length} patient(s) trouvé(s)');
          }
        }
      } else {
        _updateResult('   ❌ Erreur patients: ${patientsResult['message']}');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur patients: $e');
    }

    // Test 3: Création Patient
    _updateResult('   Test POST /api/patients...');
    try {
      final patientData = {
        'nom': 'Test',
        'prenom': 'Flutter',
        'date_naissance': '1990-01-01',
        'sexe': 'M',
        'telephone': '+237 123456789',
        'adresse': 'Test Address',
        'quartier': 'Bastos',
        'ville': 'Yaoundé',
        'antecedents_medicaux': ['Test'],
        'allergies': 'Aucune',
        'notes': 'Patient test Flutter',
        'statut': 'Consultation',
      };
      final createResult = await _patientService.createPatient(patientData);
      if (createResult['success']) {
        _updateResult('   ✅ Patient créé avec succès');
      } else {
        _updateResult('   ❌ Erreur création: ${createResult['message']}');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur création: $e');
    }

    // Test 4: Tournées
    _updateResult('\n🚗 3. TOURNÉES');
    _updateResult('   Test GET /api/tournees...');
    try {
      final tourneesResult = await _tourneeService.getTournees();
      if (tourneesResult['success']) {
        final data = tourneesResult['data'];
        if (data is Map && data['data'] != null) {
          final tournees = data['data'];
          if (tournees is List) {
            _updateResult('   ✅ ${tournees.length} tournée(s) trouvée(s)');
          }
        }
      } else {
        _updateResult('   ❌ Erreur tournées: ${tourneesResult['message']}');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur tournées: $e');
    }

    // Test 5: Création Tournée
    _updateResult('   Test POST /api/tournees...');
    try {
      final tourneeData = {
        'nom': 'Tournée Test Flutter',
        'description': 'Tournée créée via Flutter API',
        'date_debut': DateTime.now().toIso8601String().split('T')[0],
        'secteur': 'Bastos',
        'infirmiere_id': 1,
        'statut': 'planifie',
      };
      final createTourneeResult = await _tourneeService.createTournee(tourneeData);
      if (createTourneeResult['success']) {
        _updateResult('   ✅ Tournée créée avec succès');
      } else {
        _updateResult('   ❌ Erreur création tournée: ${createTourneeResult['message']}');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur création tournée: $e');
    }

    // Test 6: Vérification Token
    _updateResult('\n🔑 4. VÉRIFICATION TOKEN');
    try {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        _updateResult('   ✅ Token actif: ${token.substring(0, 20)}...');
      } else {
        _updateResult('   ❌ Aucun token');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur token: $e');
    }

    // Test 7: Utilisateur connecté
    _updateResult('\n👤 5. UTILISATEUR CONNECTÉ');
    try {
      final user = await _authService.getUser();
      if (user != null) {
        _updateResult('   ✅ Utilisateur: ${user['name']} (${user['email']})');
      } else {
        _updateResult('   ❌ Aucun utilisateur');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur utilisateur: $e');
    }

    // Test 8: Logout
    _updateResult('\n🚪 6. LOGOUT');
    try {
      final logoutResult = await _authService.logout();
      if (logoutResult['success']) {
        _updateResult('   ✅ Logout réussi');
      } else {
        _updateResult('   ❌ Erreur logout: ${logoutResult['message']}');
      }
    } catch (e) {
      _updateResult('   ❌ Erreur logout: $e');
    }

    // Résumé des URLs
    _updateResult('\n📡 7. URLs CONFIGURATION');
    _updateResult('   Auth: ${ApiConfig.auth}');
    _updateResult('   Patients: ${ApiConfig.patients}');
    _updateResult('   Tournees: ${ApiConfig.tournees}');
    _updateResult('   Base API: ${ApiConfig.apiBaseUrl}');

    _updateResult('\n=== Test terminé ===');
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Tous Endpoints'),
        backgroundColor: const Color(0xFFFF4433),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧪 Test Complet Laravel-Flutter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auth • Patients • Tournées • Tokens • Logout',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllEndpoints,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Lancer Test Complet'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Les résultats apparaîtront ici...' : _result,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'API: ${ApiConfig.apiBaseUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
