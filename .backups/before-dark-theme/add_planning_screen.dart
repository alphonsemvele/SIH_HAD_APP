import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPlanningScreen extends StatefulWidget {
  const AddPlanningScreen({super.key});

  @override
  State<AddPlanningScreen> createState() => _AddPlanningScreenState();
}

class _AddPlanningScreenState extends State<AddPlanningScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  final _dateController = TextEditingController();
  
  String _selectedType = 'tournee';
  String _selectedSecteur = 'Bastos';
  bool _isLoading = false;

  final List<String> _types = [
    'tournee',
    'reunion',
    'formation',
    'urgence',
    'consultation',
    'autre',
  ];

  final List<String> _secteurs = [
    'Bastos',
    'Nlongkak',
    'Messa',
    'Mokolo',
    'Omnisport',
    'Essos',
    'Ngousso',
    'Tsinga',
  ];

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _createPlanning() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final planningData = {
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'type': _selectedType,
        'date': _dateController.text,
        'heure_debut': _heureDebutController.text,
        'heure_fin': _heureFinController.text,
      };

      // Ajouter les champs spécifiques selon le type
      if (_selectedType == 'tournee') {
        planningData['secteur'] = _selectedSecteur;
      } else if (_selectedType == 'reunion' || _selectedType == 'formation') {
        planningData['lieu'] = _lieuController.text;
      }

      final response = await _apiService.post('/api/planning', data: planningData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccessSnackBar('Événement créé avec succès');
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4433),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouveau Planning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPlanning,
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
              // Informations générales
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations générales',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _titreController,
                      label: 'Titre de l\'événement',
                      hint: 'Ex: Tournée du Matin',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Ex: Visite des patients du secteur...',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Type d\'événement',
                      value: _selectedType,
                      items: _types,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Planning
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Planning',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _dateController,
                      label: 'Date',
                      hint: '2026-04-27',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heureDebutController,
                            label: 'Heure de début',
                            hint: '08:00',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Heure requise';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _heureFinController,
                            label: 'Heure de fin',
                            hint: '12:00',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Heure requise';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Champs spécifiques selon le type
              if (_selectedType == 'tournee') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détails de la tournée',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        label: 'Secteur',
                        value: _selectedSecteur,
                        items: _secteurs,
                        onChanged: (value) {
                          setState(() {
                            _selectedSecteur = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_selectedType == 'reunion' || _selectedType == 'formation') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lieu',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _lieuController,
                        label: 'Lieu',
                        hint: 'Ex: Salle 204, Amphi B',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un lieu';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
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
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Color(0xFF1A1A2E)),
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
