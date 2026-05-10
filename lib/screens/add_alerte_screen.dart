import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddAlerteScreen extends StatefulWidget {
  const AddAlerteScreen({super.key});

  @override
  State<AddAlerteScreen> createState() => _AddAlerteScreenState();
}

class _AddAlerteScreenState extends State<AddAlerteScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _diagnosticController = TextEditingController();
  final _alerteController = TextEditingController();
  final _quartierController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _selectedNiveau = 'Urgent';
  bool _isLoading = false;

  final List<String> _niveaux = [
    'Critique',
    'Urgent',
    'Moyen',
    'Faible',
  ];

  @override
  void dispose() {
    _patientController.dispose();
    _diagnosticController.dispose();
    _alerteController.dispose();
    _quartierController.dispose();
    _telephoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _createAlerte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final alerteData = {
        'patient_nom': _patientController.text,
        'diagnostic': _diagnosticController.text,
        'alerte': _alerteController.text,
        'quartier': _quartierController.text,
        'telephone': _telephoneController.text,
        'age': int.parse(_ageController.text),
        'niveau': _selectedNiveau,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'heure': DateTime.now().toIso8601String().split('T')[1].substring(0, 5),
      };

      final response = await _apiService.post('/api/alertes', data: alerteData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccessSnackBar('Alerte créée avec succès');
        Navigator.pop(context, true);
      } else if (response.statusCode == 422) {
        // Erreur de validation
        String errorMessage = 'Erreur de validation:';
        final errors = response.data['errors'] ?? {};
        errors.forEach((field, messages) {
          errorMessage += '\n• ${messages.join(', ')}';
        });
        _showErrorSnackBar(errorMessage);
      } else {
        _showErrorSnackBar('Erreur HTTP ${response.statusCode}: ${response.data['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4433),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4433),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouvelle Alerte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createAlerte,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Créer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations patient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations Patient',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _patientController,
                            label: 'Nom du patient',
                            hint: 'Ex: Jean Dupont',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du patient';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Âge',
                            hint: '45',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Âge requis';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age <= 0) {
                                return 'Âge invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _diagnosticController,
                      label: 'Diagnostic',
                      hint: 'Ex: Diabète type 2',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un diagnostic';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Alerte
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alerte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _alerteController,
                      label: 'Description de l\'alerte',
                      hint: 'Ex: Glycémie critique: 2.8 g/L',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez décrire l\'alerte';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Niveau d\'urgence',
                      value: _selectedNiveau,
                      items: _niveaux,
                      onChanged: (value) {
                        setState(() {
                          _selectedNiveau = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Localisation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Localisation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _quartierController,
                      label: 'Quartier',
                      hint: 'Ex: Bastos',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le quartier';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      hint: 'Ex: +237 690 123 456',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le téléphone';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white60),
            filled: true,
            fillColor: const Color(0xFF1E1E2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1E1E2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1E1E2A)),
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
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF1E1E2A)),
          ),
          child: DropdownButton<String>(
            value: value,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            isExpanded: true,
            underline: Container(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
