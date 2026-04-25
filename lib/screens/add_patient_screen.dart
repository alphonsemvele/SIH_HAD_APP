import 'package:flutter/material.dart';
import '../services/patient_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();
  
  // Controllers pour les champs
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _ageController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _quartierController = TextEditingController();
  final _diagnosticController = TextEditingController();
  final _antecedentsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _traitementController = TextEditingController();
  
  String _sexe = 'M';
  String _priorite = 'Normal';
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _quartierController.dispose();
    _diagnosticController.dispose();
    _antecedentsController.dispose();
    _allergiesController.dispose();
    _traitementController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Calculer la date de naissance à partir de l'âge
    final now = DateTime.now();
    final birthYear = now.year - int.parse(_ageController.text);
    final birthDate = DateTime(birthYear, now.month, now.day);

    final patientData = {
      'nom': _nomController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'date_naissance': birthDate.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'sexe': _sexe,
      'telephone': _telephoneController.text.trim(),
      'adresse': _adresseController.text.trim(),
      'quartier': _quartierController.text.trim(),
      'ville': 'Yaoundé', // Par défaut
      'antecedents_medicaux': _antecedentsController.text.trim().isNotEmpty 
          ? [_antecedentsController.text.trim()] 
          : [],
      'allergies': _allergiesController.text.trim().isNotEmpty 
          ? [_allergiesController.text.trim()] 
          : [],
      'notes': 'Diagnostic: ${_diagnosticController.text.trim()} | Traitement: ${_traitementController.text.trim()}',
      'statut': 'Consultation', // Statut par défaut selon le backend
    };

    try {
      final result = await _patientService.createPatient(patientData);
      
      if (result['success']) {
        _showSuccessSnackBar('Patient créé avec succès');
        Navigator.pop(context, true); // Retourner true pour indiquer le succès
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la création');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFFF4433),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text(
          'Nouveau Patient',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePatient,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4433)),
                    ),
                  )
                : const Text(
                    'ENREGISTRER',
                    style: TextStyle(
                      color: Color(0xFFFF4433),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations Personnelles
              _buildSectionTitle('Informations Personnelles'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildTextField('Nom', _nomController, 'Nom du patient')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Prénom', _prenomController, 'Prénom du patient')),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Âge',
                      _ageController,
                      'Âge du patient',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Champ obligatoire';
                        final age = int.tryParse(value);
                        if (age == null || age < 0 || age > 150) return 'Âge invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSexeSelector()),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField('Téléphone', _telephoneController, '+237 XXX XXX XXX', 
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ obligatoire';
                  return null;
                }),
              const SizedBox(height: 16),
              
              _buildTextField('Adresse', _adresseController, 'Adresse complète'),
              const SizedBox(height: 16),
              
              _buildTextField('Quartier', _quartierController, 'Quartier de résidence'),
              const SizedBox(height: 24),

              // Section Médicale
              _buildSectionTitle('Informations Médicales'),
              const SizedBox(height: 16),
              
              _buildTextField('Diagnostic', _diagnosticController, 'Diagnostic principal'),
              const SizedBox(height: 16),
              
              _buildTextField('Antécédents', _antecedentsController, 'Antécédents médicaux', maxLines: 3),
              const SizedBox(height: 16),
              
              _buildTextField('Allergies', _allergiesController, 'Allergies connues'),
              const SizedBox(height: 16),
              
              _buildTextField('Traitement en cours', _traitementController, 'Médicaments actuels'),
              const SizedBox(height: 16),
              
              _buildPrioriteSelector(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFF12121A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4433)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4433)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator ?? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Champ obligatoire';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSexeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexe',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E2A)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sexe = 'M'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _sexe == 'M' ? const Color(0xFFFF4433).withOpacity(0.2) : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Masculin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _sexe == 'M' ? const Color(0xFFFF4433) : Colors.white.withOpacity(0.6),
                        fontWeight: _sexe == 'M' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sexe = 'F'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _sexe == 'F' ? const Color(0xFFFF4433).withOpacity(0.2) : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Féminin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _sexe == 'F' ? const Color(0xFFFF4433) : Colors.white.withOpacity(0.6),
                        fontWeight: _sexe == 'F' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrioriteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priorité',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E2A)),
          ),
          child: Column(
            children: ['Normal', 'Surveillance', 'Critique'].map((priorite) {
              Color color;
              switch (priorite) {
                case 'Critique':
                  color = const Color(0xFFFF4433);
                  break;
                case 'Surveillance':
                  color = const Color(0xFFFF9800);
                  break;
                default:
                  color = const Color(0xFF4CAF50);
              }
              
              return GestureDetector(
                onTap: () => setState(() => _priorite = priorite),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _priorite == priorite ? color.withOpacity(0.2) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF1E1E2A).withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _priorite == priorite ? color : Colors.transparent,
                          border: Border.all(
                            color: _priorite == priorite ? color : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _priorite == priorite
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        priorite,
                        style: TextStyle(
                          color: _priorite == priorite ? color : Colors.white.withOpacity(0.7),
                          fontWeight: _priorite == priorite ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
