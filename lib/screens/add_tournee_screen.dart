import 'package:flutter/material.dart';
import '../services/tournee_service.dart';
import '../services/api_service.dart';

class AddTourneeScreen extends StatefulWidget {
  const AddTourneeScreen({super.key});

  @override
  State<AddTourneeScreen> createState() => _AddTourneeScreenState();
}

class _AddTourneeScreenState extends State<AddTourneeScreen> {
  final TourneeService _tourneeService = TourneeService();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _secteurController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  final _patientsController = TextEditingController();

  // Listes dynamiques chargées depuis Laravel
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _soignants = [];
  
  Map<String, dynamic>? _selectedService;
  Map<String, dynamic>? _selectedSoignant;
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _secteurController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    _patientsController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final servicesResp = await _apiService.get('/api/services');
      final soignantsResp = await _apiService.get('/api/soignants');
      
      setState(() {
        // Si la réponse est paginée par apiResource, ajuste :
        final servicesData = servicesResp.data is List 
            ? servicesResp.data 
            : (servicesResp.data['data'] ?? servicesResp.data);
        _services = List<Map<String, dynamic>>.from(servicesData);
        _soignants = List<Map<String, dynamic>>.from(soignantsResp.data);
        
        if (_services.isNotEmpty) _selectedService = _services.first;
        if (_soignants.isNotEmpty) _selectedSoignant = _soignants.first;
        
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      _showErrorSnackBar('Erreur de chargement: $e');
    }
  }

  Future<void> _createTournee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null || _selectedSoignant == null) {
      _showErrorSnackBar('Veuillez sélectionner un service et un soignant');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tourneeData = {
        'titre': _titreController.text,
        'secteur': _secteurController.text,
        'heure_debut_prevue': _heureDebutController.text,
        'heure_fin_prevue': _heureFinController.text,
        'patients_total': int.parse(_patientsController.text),
        'service_id': _selectedService!['id'],
        'soignant_id': _selectedSoignant!['id'],
        'type': 'complete',
        'date': DateTime.now().toIso8601String().split('T')[0],
      };

      final result = await _tourneeService.createTournee(tourneeData);

      if (result['success']) {
        _showSuccessSnackBar('Tournée créée avec succès');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la création');
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
        backgroundColor: const Color(0xFF0A0A0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouvelle Tournée',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createTournee,
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
                      color: Color(0xFFFF4433),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoadingData
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF4433),
            ),
          )
        : SingleChildScrollView(
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
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E1E2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations générales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _titreController,
                      label: 'Titre de la tournée',
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
                      controller: _secteurController,
                      label: 'Secteur',
                      hint: 'Ex: Bastos - Nlongkak - Messa',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un secteur';
                        }
                        return null;
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
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E1E2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Planning',
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _patientsController,
                      label: 'Nombre de patients',
                      hint: '6',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nombre requis';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Nombre invalide';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Assignation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E1E2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assignation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildServiceDropdown(),
                    const SizedBox(height: 16),
                    _buildSoignantDropdown(),
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFF1E1E2A),
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
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service',
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
            border: Border.all(color: const Color(0xFF1E1E2A)),
          ),
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedService,
            dropdownColor: const Color(0xFF1E1E2A),
            style: const TextStyle(color: Colors.white),
            isExpanded: true,
            underline: Container(),
            items: _services.map((service) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: service,
                child: Text('${service['nom']} (Étage ${service['etage'] ?? '?'})'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedService = value),
          ),
        ),
      ],
    );
  }

  Widget _buildSoignantDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soignant',
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
            border: Border.all(color: const Color(0xFF1E1E2A)),
          ),
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedSoignant,
            dropdownColor: const Color(0xFF1E1E2A),
            style: const TextStyle(color: Colors.white),
            isExpanded: true,
            underline: Container(),
            items: _soignants.map((soignant) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: soignant,
                child: Text(soignant['name']),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedSoignant = value),
          ),
        ),
      ],
    );
  }
}
