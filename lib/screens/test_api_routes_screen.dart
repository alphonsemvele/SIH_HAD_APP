import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../config/api_config.dart';

class TestApiRoutesScreen extends StatefulWidget {
  const TestApiRoutesScreen({super.key});

  @override
  State<TestApiRoutesScreen> createState() => _TestApiRoutesScreenState();
}

class _TestApiRoutesScreenState extends State<TestApiRoutesScreen> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  String _result = '';
  bool _isLoading = false;

  void _updateResult(String message) {
    setState(() {
      _result += '\n$message';
    });
  }

  Future<void> _testApiRoutes() async {
    setState(() {
      _result = '=== Test Routes API (/api) ===\n';
      _isLoading = true;
    });

    _updateResult('URL Base: ${ApiConfig.apiBaseUrl}');
    _updateResult('');

    // Test 1: Login API
    _updateResult('1. Test POST /api/login...');
    try {
      final result = await _authService.login('anne.ngo@had.com', 'password');
      if (result['success']) {
        _updateResult('✅ Login API réussi');
        _updateResult('   -> ${result['message']}');
      } else {
        _updateResult('❌ Login API échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur login API: $e');
    }

    // Test 2: Patients API
    _updateResult('\n2. Test GET /api/patients...');
    try {
      final result = await _patientService.getPatients();
      if (result['success']) {
        _updateResult('✅ Patients API réussi');
        final data = result['data'];
        if (data is Map && data['data'] != null) {
          final patients = data['data'];
          if (patients is List) {
            _updateResult('   -> ${patients.length} patient(s) trouvé(s)');
          }
        }
      } else {
        _updateResult('❌ Patients API échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur patients API: $e');
    }

    // Test 3: Création Patient API
    _updateResult('\n3. Test POST /api/patients...');
    try {
      final patientData = {
        'nom': 'Test',
        'prenom': 'API',
        'date_naissance': '1990-01-01',
        'sexe': 'M',
        'telephone': '+237 123456789',
        'adresse': 'Test API Address',
        'quartier': 'Bastos',
        'ville': 'Yaoundé',
        'antecedents_medicaux': ['Test API'],
        'allergies': 'Aucune',
        'notes': 'Patient test via API',
        'statut': 'consultation',
      };

      final result = await _patientService.createPatient(patientData);
      if (result['success']) {
        _updateResult('✅ Création patient API réussie');
        _updateResult('   -> ${result['message']}');
      } else {
        _updateResult('❌ Création patient API échouée: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur création patient API: $e');
    }

    // Test 4: Logout API
    _updateResult('\n4. Test POST /api/logout...');
    try {
      final result = await _authService.logout();
      if (result['success']) {
        _updateResult('✅ Logout API réussi');
        _updateResult('   -> ${result['message']}');
      } else {
        _updateResult('❌ Logout API échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur logout API: $e');
    }

    // Test 5: Vérification URLs
    _updateResult('\n5. Vérification URLs...');
    _updateResult('   -> Auth: ${ApiConfig.auth}');
    _updateResult('   -> Patients: ${ApiConfig.patients}');
    _updateResult('   -> Tournees: ${ApiConfig.tournees}');
    _updateResult('   -> Lits: ${ApiConfig.lits}');
    _updateResult('   -> Medicaments: ${ApiConfig.medicaments}');

    _updateResult('\n=== Test terminé ===');
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Routes API'),
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
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔄 Migration vers API Routes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tous les endpoints déplacés vers /api/*\nRoutes web.php → routes/api.php',
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
              onPressed: _isLoading ? null : _testApiRoutes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tester les routes API'),
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
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'API Base URL: ${ApiConfig.apiBaseUrl}',
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
