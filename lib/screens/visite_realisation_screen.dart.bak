import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../services/visite_service.dart';
import 'dart:io';

class VisiteRealisationScreen extends StatefulWidget {
  final Map<String, dynamic> visite;

  const VisiteRealisationScreen({
    super.key,
    required this.visite,
  });

  @override
  State<VisiteRealisationScreen> createState() => _VisiteRealisationScreenState();
}

class _VisiteRealisationScreenState extends State<VisiteRealisationScreen> {
  final ScrollController _scrollController = ScrollController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Section 1 - Actes réalisés
  List<Map<String, dynamic>> _actes = [];
  List<Map<String, dynamic>> _actesRealises = [];

  // Section 2 - Constantes vitales
  final TextEditingController _taSystoliqueController = TextEditingController();
  final TextEditingController _taDiastoliqueController = TextEditingController();
  final TextEditingController _fcController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _glycemieController = TextEditingController();
  final TextEditingController _evaController = TextEditingController();

  // Section 3 - Photos
  final List<File> _photos = [];

  // Section 4 - Signature
  String _signatureType = 'patient'; // patient, aidant, refus
  final TextEditingController _refusMotifController = TextEditingController();
  File? _signatureFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeActes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _signatureController.dispose();
    _taSystoliqueController.dispose();
    _taDiastoliqueController.dispose();
    _fcController.dispose();
    _temperatureController.dispose();
    _spo2Controller.dispose();
    _glycemieController.dispose();
    _evaController.dispose();
    _refusMotifController.dispose();
    super.dispose();
  }

  void _initializeActes() {
    // Initialiser les actes prévus depuis la visite
    final actesPrevus = widget.visite['actes_prevus'] as List? ?? [];
    _actes = actesPrevus.map((acte) => Map<String, dynamic>.from(acte)).toList();
    
    // Initialiser la liste des actes réalisés
    _actesRealises = _actes.map((acte) => {
      'id': acte['id'],
      'libelle': acte['libelle'],
      'realise': false,
      'observations': '',
    }).toList();
  }

  Future<void> _ajouterActeNonPrevu() async {
    final libelleController = TextEditingController();
    final observationsController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un acte non prévu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: libelleController,
                decoration: const InputDecoration(
                  labelText: 'Libellé de l\'acte',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observations',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (libelleController.text.isNotEmpty) {
                  setState(() {
                    _actesRealises.add({
                      'id': 'non_prevu_${DateTime.now().millisecondsSinceEpoch}',
                      'libelle': libelleController.text,
                      'realise': true,
                      'observations': observationsController.text,
                      'non_prevu': true,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _prendrePhoto() async {
    if (_photos.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 photos autorisées'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
    );

    if (photo != null) {
      setState(() {
        _photos.add(File(photo.path));
      });
    }
  }

  void _supprimerPhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _signer() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      width: double.infinity,
                      height: double.infinity,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      child: const Text('Effacer'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final signatureBytes = await _signatureController.toPngBytes();
                        if (signatureBytes != null) {
                          final directory = await getApplicationDocumentsDirectory();
                          final signaturePath = '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
                          final file = File(signaturePath);
                          await file.writeAsBytes(signatureBytes);
                          
                          setState(() {
                            _signatureFile = file;
                          });
                          
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Valider'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _terminerVisite() async {
    // Validation
    final actesRealisesList = _actesRealises.where((acte) => acte['realise'] == true).toList();
    if (actesRealisesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez cocher au moins un acte réalisé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_signatureType != 'refus' && _signatureFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez fournir une signature'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_signatureType == 'refus' && _refusMotifController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez préciser le motif de refus de signature'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Préparer les données multipart
      final formData = FormData.fromMap({
        // Actes réalisés
        'actes': actesRealisesList.map((acte) => {
          'id': acte['id'],
          'libelle': acte['libelle'],
          'observations': acte['observations'],
          'non_prevu': acte['non_prevu'] ?? false,
        }),

        // Constantes vitales
        'ta_systolique': _taSystoliqueController.text.isNotEmpty ? _taSystoliqueController.text : null,
        'ta_diastolique': _taDiastoliqueController.text.isNotEmpty ? _taDiastoliqueController.text : null,
        'fc': _fcController.text.isNotEmpty ? _fcController.text : null,
        't': _temperatureController.text.isNotEmpty ? _temperatureController.text : null,
        'spo2': _spo2Controller.text.isNotEmpty ? _spo2Controller.text : null,
        'glycemie': _glycemieController.text.isNotEmpty ? _glycemieController.text : null,
        'eva_douleur': _evaController.text.isNotEmpty ? _evaController.text : null,

        // Signature
        'signature_type': _signatureType,
        'refus_motif': _signatureType == 'refus' ? _refusMotifController.text : null,

        // Photos
        for (int i = 0; i < _photos.length; i++)
          'photos[$i]': await MultipartFile.fromFile(_photos[i].path, filename: 'photo_$i.jpg'),

        // Signature file
        if (_signatureFile != null)
          'signature': await MultipartFile.fromFile(_signatureFile!.path, filename: 'signature.png'),
      });

      final visiteService = VisiteService();
      await visiteService.envoyerRealisationVisiteAvecRetry(
        widget.visite['id'],
        formData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visite enregistrée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retour à l'écran des tournées
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/tournees',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4433),
        title: Text('Visite - ${widget.visite['patient_nom'] ?? 'Patient'}'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('1. Actes réalisés'),
                _buildActesSection(),
                const SizedBox(height: 24),

                _buildSectionHeader('2. Constantes vitales'),
                _buildConstantesSection(),
                const SizedBox(height: 24),

                _buildSectionHeader('3. Photos (max 10)'),
                _buildPhotosSection(),
                const SizedBox(height: 24),

                _buildSectionHeader('4. Signature'),
                _buildSignatureSection(),
                const SizedBox(height: 100), // Espace pour le bouton flottant
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Envoi en cours...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _terminerVisite,
        backgroundColor: const Color(0xFFFF4433),
        icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.check),
        label: Text(_isLoading ? 'Envoi...' : 'Terminer la visite'),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _buildActesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ..._actesRealises.asMap().entries.map((entry) {
            final index = entry.key;
            final acte = entry.value;
            return _buildActeItem(acte, index);
          }).toList(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _ajouterActeNonPrevu,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un acte non prévu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActeItem(Map<String, dynamic> acte, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: acte['realise'] ?? false,
                onChanged: (value) {
                  setState(() {
                    _actesRealises[index]['realise'] = value ?? false;
                  });
                },
                activeColor: const Color(0xFFFF4433),
              ),
              Expanded(
                child: Text(
                  acte['libelle'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (acte['non_prevu'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Non prévu',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if ((acte['realise'] ?? false))
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: TextField(
                onChanged: (value) {
                  _actesRealises[index]['observations'] = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Observations',
                  border: OutlineInputBorder(),
                  hintText: 'Max 500 caractères',
                ),
                maxLines: 2,
                maxLength: 500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConstantesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taSystoliqueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TA Systolique (mmHg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _taDiastoliqueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TA Diastolique (mmHg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fcController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'FC (bpm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'T° (°C)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _spo2Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'SpO2 (%)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _glycemieController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Glycémie (g/L)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _evaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'EVA Douleur (0-10)',
              border: OutlineInputBorder(),
              helperText: 'Échelle Visuelle Analogique',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_photos.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucune photo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _photos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(photo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => _supprimerPhoto(index),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _prendrePhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text('${_photos.length}/10 photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type de signature :',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Patient'),
                  value: 'patient',
                  groupValue: _signatureType,
                  onChanged: (value) {
                    setState(() {
                      _signatureType = value!;
                    });
                  },
                  activeColor: const Color(0xFFFF4433),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Aidant'),
                  value: 'aidant',
                  groupValue: _signatureType,
                  onChanged: (value) {
                    setState(() {
                      _signatureType = value!;
                    });
                  },
                  activeColor: const Color(0xFFFF4433),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Refus'),
                  value: 'refus',
                  groupValue: _signatureType,
                  onChanged: (value) {
                    setState(() {
                      _signatureType = value!;
                    });
                  },
                  activeColor: const Color(0xFFFF4433),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_signatureType == 'refus')
            TextField(
              controller: _refusMotifController,
              decoration: const InputDecoration(
                labelText: 'Motif du refus',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_signatureFile != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Signature enregistrée'),
                        const Spacer(),
                        TextButton(
                          onPressed: _signer,
                          child: const Text('Modifier'),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _signer,
                    icon: const Icon(Icons.draw),
                    label: const Text('Signer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4433),
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
