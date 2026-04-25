import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../config/api_config.dart';

class TestSanctumAuthScreen extends StatefulWidget {
  const TestSanctumAuthScreen({super.key});

  @override
  State<TestSanctumAuthScreen> createState() => _TestSanctumAuthScreenState();
}

class _TestSanctumAuthScreenState extends State<TestSanctumAuthScreen> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  String _result = '';
  bool _isLoading = false;

  void _updateResult(String message) {
    setState(() {
      _result += '\n$message';
    });
  }

  Future<void> _testSanctumAuth() async {
    setState(() {
      _result = '=== Test Authentification Sanctum ===\n';
      _isLoading = true;
    });

    // Test 1: Login avec Sanctum
    _updateResult('1. Test login Sanctum...');
    try {
      final result = await _authService.login('anne.ngo@had.com', 'password');
      if (result['success']) {
        _updateResult('✅ Login Sanctum réussi');
        _updateResult('   -> ${result['message']}');
        _updateResult('   -> Token: ${result['data']['email']}');
      } else {
        _updateResult('❌ Login Sanctum échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur login Sanctum: $e');
    }

    // Test 2: Vérification du token
    _updateResult('\n2. Test vérification token...');
    try {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        _updateResult('✅ Token présent: ${token.substring(0, 20)}...');
      } else {
        _updateResult('❌ Aucun token trouvé');
      }
    } catch (e) {
      _updateResult('❌ Erreur token: $e');
    }

    // Test 3: Appel API protégé (patients)
    _updateResult('\n3. Test API protégée (patients)...');
    try {
      final result = await _patientService.getPatients();
      if (result['success']) {
        _updateResult('✅ API protégée fonctionnelle');
        final data = result['data'];
        if (data is Map && data['data'] != null) {
          final patients = data['data'];
          if (patients is List) {
            _updateResult('   -> ${patients.length} patient(s) trouvé(s)');
          }
        }
      } else {
        _updateResult('❌ API protégée échouée: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur API protégée: $e');
    }

    // Test 4: Logout Sanctum
    _updateResult('\n4. Test logout Sanctum...');
    try {
      final result = await _authService.logout();
      if (result['success']) {
        _updateResult('✅ Logout Sanctum réussi');
        _updateResult('   -> ${result['message']}');
      } else {
        _updateResult('❌ Logout Sanctum échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur logout Sanctum: $e');
    }

    // Test 5: Vérification après logout
    _updateResult('\n5. Test token après logout...');
    try {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        _updateResult('❌ Token toujours présent');
      } else {
        _updateResult('✅ Token bien supprimé');
      }
    } catch (e) {
      _updateResult('❌ Erreur vérification token: $e');
    }

    _updateResult('\n=== Test terminé ===');
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sanctum Auth'),
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
                    '🔐 Authentification Sanctum',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tokens JWT | API Stateless | Pas de sessions web',
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
              onPressed: _isLoading ? null : _testSanctumAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tester Sanctum Auth'),
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
