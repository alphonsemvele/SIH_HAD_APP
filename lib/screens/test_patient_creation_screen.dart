import 'package:flutter/material.dart';
import '../services/patient_service.dart';
import '../config/api_config.dart';

class TestPatientCreationScreen extends StatefulWidget {
  const TestPatientCreationScreen({super.key});

  @override
  State<TestPatientCreationScreen> createState() => _TestPatientCreationScreenState();
}

class _TestPatientCreationScreenState extends State<TestPatientCreationScreen> {
  final PatientService _patientService = PatientService();
  String _result = '';
  bool _isLoading = false;

  void _updateResult(String message) {
    setState(() {
      _result += '\n$message';
    });
  }

  Future<void> _testPatientCreation() async {
    setState(() {
      _result = '=== Test Création Patient ===\n';
      _isLoading = true;
    });

    // Test 1: Création patient avec données valides
    _updateResult('1. Test création patient valide...');
    try {
      final patientData = {
        'nom': 'Test',
        'prenom': 'Patient',
        'date_naissance': '1990-01-01',
        'sexe': 'M',
        'telephone': '+237 123456789',
        'adresse': 'Adresse de test',
        'quartier': 'Bastos',
        'ville': 'Yaoundé',
        'antecedents_medicaux': ['Antécédent de test'],
        'allergies': 'Aucune',
        'notes': 'Patient de test créé via API',
        'statut': 'consultation',
      };

      final result = await _patientService.createPatient(patientData);
      if (result['success']) {
        _updateResult('✅ Patient créé avec succès');
        _updateResult('   -> Message: ${result['message']}');
      } else {
        _updateResult('❌ Échec création: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur création: $e');
    }

    // Test 2: Test avec données invalides (champs manquants)
    _updateResult('\n2. Test création patient invalide...');
    try {
      final invalidData = {
        'nom': 'Test',
        //prenom manquant
        'date_naissance': '1990-01-01',
        'sexe': 'M',
      };

      final result = await _patientService.createPatient(invalidData);
      if (result['success']) {
        _updateResult('❌ Création réussie (inattendu)');
      } else {
        _updateResult('✅ Erreur validation détectée: ${result['message']}');
      }
    } catch (e) {
      _updateResult('✅ Erreur validation: $e');
    }

    // Test 3: Récupération de la liste des patients
    _updateResult('\n3. Test récupération patients...');
    try {
      final result = await _patientService.getPatients();
      if (result['success']) {
        _updateResult('✅ Patients récupérés avec succès');
        final data = result['data'];
        if (data is Map && data['data'] != null) {
          final patients = data['data'];
          if (patients is List) {
            _updateResult('   -> ${patients.length} patient(s) trouvé(s)');
          }
        }
      } else {
        _updateResult('❌ Erreur récupération: ${result['message']}');
      }
    } catch (e) {
      _updateResult('❌ Erreur récupération: $e');
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
        title: const Text('Test Création Patient'),
        backgroundColor: const Color(0xFFFF4433),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testPatientCreation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4433),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tester la création de patient'),
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
