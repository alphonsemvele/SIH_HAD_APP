import 'package:flutter/material.dart';
import '../services/demande_service.dart';

class NouvelleDemandeScreen extends StatefulWidget {
  const NouvelleDemandeScreen({super.key});

  @override
  State<NouvelleDemandeScreen> createState() => _NouvelleDemandeScreenState();
}

class _NouvelleDemandeScreenState extends State<NouvelleDemandeScreen> {
  final _formKey = GlobalKey<FormState>();
  final DemandeService _demandeService = DemandeService();

  // Patient
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // Adresse
  final _adresseCtrl = TextEditingController();
  String _quartier = 'Bastos';

  // Médical
  final _symptomesCtrl = TextEditingController();
  final _dureeCtrl = TextEditingController();
  String _urgence = 'moyenne';
  String _type = 'visite';

  // Demandeur
  final _demandeurNomCtrl = TextEditingController();
  final _demandeurRelationCtrl = TextEditingController();
  bool _estProche = false;

  bool _isSubmitting = false;

  static const List<String> _quartiers = [
    'Bastos', 'Nlongkak', 'Messa', 'Mvog-Ada', 'Mvog-Mbi',
    'Etoa-Meki', 'Nkolbisson', 'Tsinga', 'Mokolo', 'Briqueterie',
    'Essos', 'Mendong', 'Ngoa-Ekellé', 'Autre',
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _ageCtrl.dispose();
    _adresseCtrl.dispose();
    _symptomesCtrl.dispose();
    _dureeCtrl.dispose();
    _demandeurNomCtrl.dispose();
    _demandeurRelationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'patient_nom': _nomCtrl.text.trim(),
      'patient_telephone': _telCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim(),
      'quartier': _quartier,
      'symptomes': _symptomesCtrl.text.trim(),
      'urgence': _urgence,
      'type': _type,
    };

    if (_ageCtrl.text.trim().isNotEmpty) {
      data['patient_age'] = int.tryParse(_ageCtrl.text.trim());
    }
    if (_dureeCtrl.text.trim().isNotEmpty) {
      data['duree_symptomes'] = _dureeCtrl.text.trim();
    }
    if (_estProche) {
      if (_demandeurNomCtrl.text.trim().isNotEmpty) {
        data['demandeur_nom'] = _demandeurNomCtrl.text.trim();
      }
      if (_demandeurRelationCtrl.text.trim().isNotEmpty) {
        data['demandeur_relation'] = _demandeurRelationCtrl.text.trim();
      }
    }

    final result = await _demandeService.creerDemande(data);
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      final id = result['data']?['data']?['id'];
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF12121A),
          icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 56),
          title: const Text(
            'Demande envoyée',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Votre demande #$id a été enregistrée.\n\nUn soignant vous contactera très bientôt au ${_telCtrl.text}.',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Erreur'),
          backgroundColor: const Color(0xFFFF4433),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  InputDecoration _inputDeco(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      prefixIcon: icon != null ? Icon(icon, color: Colors.white.withOpacity(0.5)) : null,
      filled: true,
      fillColor: const Color(0xFF12121A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E1E2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF4433)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF4433)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Nouvelle demande',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bandeau d'aide
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4433).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF4433).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFFF4433)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Décrivez votre besoin de visite à domicile. Une équipe vous contactera.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              // === PATIENT ===
              _sectionTitle('1. Informations patient'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nomCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Nom complet *', icon: Icons.person),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _telCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: _inputDeco('Téléphone *', hint: '+237 6...', icon: Icons.phone),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Tél requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _inputDeco('Âge'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === ADRESSE ===
              _sectionTitle('2. Adresse'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _adresseCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: _inputDeco(
                  'Adresse précise *',
                  hint: 'Ex: rue derrière la pharmacie centrale, maison bleue',
                  icon: Icons.location_on,
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Adresse requise' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _quartier,
                dropdownColor: const Color(0xFF12121A),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Quartier', icon: Icons.map),
                items: _quartiers.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
                onChanged: (v) => setState(() => _quartier = v ?? 'Bastos'),
              ),
              const SizedBox(height: 20),

              // === MÉDICAL ===
              _sectionTitle('3. Description du problème'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _symptomesCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDeco(
                  'Symptômes / problème *',
                  hint: 'Ex: Fièvre 39°C, maux de tête, fatigue...',
                  icon: Icons.healing,
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Description requise' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dureeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco(
                  'Depuis combien de temps ?',
                  hint: 'Ex: 2 jours, 1 semaine',
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(height: 16),

              // Urgence
              const Text('Niveau d\'urgence', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _urgenceChip('faible', 'Faible', const Color(0xFF4CAF50)),
                  _urgenceChip('moyenne', 'Moyenne', const Color(0xFF2196F3)),
                  _urgenceChip('urgente', 'Urgente', const Color(0xFFFF9800)),
                  _urgenceChip('critique', 'Critique', const Color(0xFFFF4433)),
                ],
              ),
              const SizedBox(height: 16),

              // Type
              const Text('Type de service souhaité', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _typeChip('visite', 'Visite à domicile', Icons.home),
                  _typeChip('conseil_tel', 'Conseil téléphonique', Icons.phone),
                  _typeChip('urgence', 'Urgence', Icons.emergency),
                ],
              ),
              const SizedBox(height: 20),

              // === DEMANDEUR ===
              _sectionTitle('4. Demande faite par un proche ?'),
              const SizedBox(height: 4),
              SwitchListTile(
                value: _estProche,
                onChanged: (v) => setState(() => _estProche = v),
                title: const Text(
                  'C\'est un proche qui fait la demande',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                activeColor: const Color(0xFFFF4433),
                contentPadding: EdgeInsets.zero,
              ),

              if (_estProche) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _demandeurNomCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Votre nom', icon: Icons.person_outline),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _demandeurRelationCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco(
                    'Votre relation au patient',
                    hint: 'Ex: fils, épouse, voisin',
                    icon: Icons.family_restroom,
                  ),
                ),
              ],
              const SizedBox(height: 30),

              // SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4433),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Envoyer la demande',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _urgenceChip(String value, String label, Color color) {
    final selected = _urgence == value;
    return GestureDetector(
      onTap: () => setState(() => _urgence = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final selected = _type == value;
    final color = const Color(0xFFFF4433);
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : const Color(0xFF1E1E2A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
