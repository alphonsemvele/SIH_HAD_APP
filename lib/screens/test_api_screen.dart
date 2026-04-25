import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../services/tournee_service.dart';
import '../config/api_config.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final ApiService _apiService = ApiService();
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

  Future<void> _testConnection() async {
    setState(() {
      _result = '=== Test de Connexion API ===\n';
      _isLoading = true;
    });

    try {
      // Test 1: Connexion simple au serveur
      _updateResult('1. Test connexion serveur...');
      final response = await _apiService.get('/');
      if (response.statusCode == 200) {
        _updateResult('✅ Connexion réussie');
      } else {
        _updateResult('❌ Erreur: ${response.statusCode}');
      }
    } catch (e) {
      _updateResult('❌ Erreur connexion: $e');
    }

    try {
      // Test 2: Login (avec des identifiants de test)
      _updateResult('\n2. Test login...');
      final loginResult = await _authService.login('test@example.com', 'password');
      if (loginResult['success']) {
        _updateResult('✅ Login réussi');
      } else {
        _updateResult('❌ Login échoué: ${loginResult['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur login: $e');
    }

    try {
      // Test 3: Récupération patients
      _updateResult('\n3. Test récupération patients...');
      final patientsResult = await _patientService.getPatients();
      if (patientsResult['success']) {
        _updateResult('✅ Patients récupérés avec succès');
        final data = patientsResult['data'];
        if (data is Map && data['data'] != null) {
          final patients = data['data'];
          if (patients is List) {
            _updateResult('   -> ${patients.length} patient(s) trouvé(s)');
          }
        }
      } else {
        _updateResult('❌ Erreur patients: ${patientsResult['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur patients: $e');
    }

    try {
      // Test 4: Récupération tournées
      _updateResult('\n4. Test récupération tournées...');
      final tourneesResult = await _tourneeService.getTournees();
      if (tourneesResult['success']) {
        _updateResult('✅ Tournées récupérées avec succès');
      } else {
        _updateResult('❌ Erreur tournées: ${tourneesResult['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur tournées: $e');
    }

    try {
      // Test 5: Vérification statut auth
      _updateResult('\n5. Test statut authentification...');
      final isLoggedIn = await _authService.isLoggedIn();
      _updateResult(isLoggedIn ? '✅ Utilisateur connecté' : '❌ Utilisateur non connecté');
    } catch (e) {
      _updateResult('❌ Erreur statut: $e');
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
        title: const Text('Test API'),
        backgroundColor: const Color(0xFFFF4433),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Lancer les tests API'),
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
              'Backend URL: ${ApiConfig.baseUrl}',
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
