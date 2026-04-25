import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class TestLoginFixedScreen extends StatefulWidget {
  const TestLoginFixedScreen({super.key});

  @override
  State<TestLoginFixedScreen> createState() => _TestLoginFixedScreenState();
}

class _TestLoginFixedScreenState extends State<TestLoginFixedScreen> {
  final AuthService _authService = AuthService();
  String _result = '';
  bool _isLoading = false;

  void _updateResult(String message) {
    setState(() {
      _result += '\n$message';
    });
  }

  Future<void> _testLoginFixed() async {
    setState(() {
      _result = '=== Test Login après correction CSRF ===\n';
      _isLoading = true;
    });

    // Test 1: Login avec identifiants de test
    _updateResult('1. Test login avec identifiants de test...');
    try {
      final result = await _authService.login('anne.ngo@had.com', 'password');
      if (result['success']) {
        _updateResult('✅ Login réussi');
        _updateResult('   -> Message: ${result['message']}');
        _updateResult('   -> Utilisateur: ${result['data']['name']}');
        _updateResult('   -> Email: ${result['data']['email']}');
      } else {
        _updateResult('❌ Login échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur login: $e');
    }

    // Test 2: Login avec email test@example.com
    _updateResult('\n2. Test login avec test@example.com...');
    try {
      final result = await _authService.login('test@example.com', 'password');
      if (result['success']) {
        _updateResult('✅ Login réussi');
        _updateResult('   -> Message: ${result['message']}');
      } else {
        _updateResult('❌ Login échoué: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur login: $e');
    }

    // Test 3: Vérification statut après login
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

    // Test 5: Test logout
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
        title: const Text('Test Login (CSRF Fixed)'),
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
                color: const Color(0xFFFF4433).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF4433).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔧 Correction CSRF appliquée',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4433),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Middleware ExcludeCsrfForApi ajouté pour exclure les routes mobiles de la protection CSRF',
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
              onPressed: _isLoading ? null : _testLoginFixed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tester le login (CSRF Fixed)'),
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
              'Identifiants: anne.ngo@had.com / password',
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
