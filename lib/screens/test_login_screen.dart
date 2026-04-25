import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class TestLoginScreen extends StatefulWidget {
  const TestLoginScreen({super.key});

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  final AuthService _authService = AuthService();
  String _result = '';
  bool _isLoading = false;

  void _updateResult(String message) {
    setState(() {
      _result += '\n$message';
    });
  }

  Future<void> _testLogin() async {
    setState(() {
      _result = '=== Test Connexion Login ===\n';
      _isLoading = true;
    });

    // Test 1: Login avec identifiants valides
    _updateResult('1. Test login valide...');
    try {
      final result = await _authService.login('anne.ngo@had.com', 'password');
      if (result['success']) {
        _updateResult('✅ Login réussi');
        _updateResult('   -> Message: ${result['message']}');
        _updateResult('   -> Utilisateur: ${result['data']['name']}');
      } else {
        _updateResult('❌ Login échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur login: $e');
    }

    // Test 2: Login avec identifiants invalides
    _updateResult('\n2. Test login invalide...');
    try {
      final result = await _authService.login('wrong@email.com', 'wrongpassword');
      if (result['success']) {
        _updateResult('❌ Login réussi (inattendu)');
      } else {
        _updateResult('✅ Erreur détectée: ${result['message']}');
      }
    } catch (e) {
      _updateResult('✅ Erreur détectée: $e');
    }

    // Test 3: Vérification statut connexion
    _updateResult('\n3. Test statut connexion...');
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      _updateResult(isLoggedIn ? '✅ Utilisateur connecté' : '❌ Utilisateur non connecté');
    } catch (e) {
      _updateResult('❌ Erreur statut: $e');
    }

    // Test 4: Récupération infos utilisateur
    _updateResult('\n4. Test infos utilisateur...');
    try {
      final user = await _authService.getUser();
      if (user != null) {
        _updateResult('✅ Infos utilisateur récupérées');
        _updateResult('   -> Email: ${user['email']}');
        _updateResult('   -> Nom: ${user['name']}');
        _updateResult('   -> Rôle: ${user['role']}');
      } else {
        _updateResult('❌ Aucune info utilisateur');
      }
    } catch (e) {
      _updateResult('❌ Erreur infos: $e');
    }

    // Test 5: Logout
    _updateResult('\n5. Test logout...');
    try {
      final result = await _authService.logout();
      if (result['success']) {
        _updateResult('✅ Logout réussi');
      } else {
        _updateResult('❌ Logout échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur logout: $e');
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
        title: const Text('Test Login'),
        backgroundColor: const Color(0xFFFF4433),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tester la connexion login'),
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
            const SizedBox(height: 5),
            Text(
              'Identifiants de test: anne.ngo@had.com / password',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
