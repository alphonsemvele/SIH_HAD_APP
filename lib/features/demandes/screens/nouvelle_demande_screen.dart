import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/demandes_service.dart';

class NouvelleDemandeScreen extends StatefulWidget {
  const NouvelleDemandeScreen({super.key});

  @override
  State<NouvelleDemandeScreen> createState() => _NouvelleDemandeScreenState();
}

class _NouvelleDemandeScreenState extends State<NouvelleDemandeScreen> {
  final _service = DemandesService();
  final _symptomes = TextEditingController();
  final _dureeSymptomes = TextEditingController();
  String _urgence = 'moyenne';
  DateTime? _date;
  TimeOfDay? _heure;
  bool _sending = false;

  static const _urgences = [
    ('faible',  'Faible',  Colors.greenAccent),
    ('moyenne', 'Moyenne', Colors.amber),
    ('urgente', 'Urgente', Colors.orangeAccent),
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heure ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _heure = picked);
  }

  Future<void> _submit() async {
    final sympt = _symptomes.text.trim();
    if (sympt.length < 5) {
      _snack('Décrivez vos symptômes (5 caractères minimum)', AppColors.accent);
      return;
    }
    setState(() => _sending = true);
    final result = await _service.create(
      symptomes:      sympt,
      urgence:        _urgence,
      dureeSymptomes: _dureeSymptomes.text.trim(),
      dateSouhaitee:  _date == null ? null : _fmtDate(_date!),
      heureSouhaitee: _heure == null ? null : _fmtTime(_heure!),
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (result['success'] == true) {
      _snack('Demande envoyée — un soignant va la traiter', AppColors.success);
      Navigator.of(context).pop(true);
    } else {
      _snack(result['message'] ?? 'Échec de l\'envoi', AppColors.accent);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(color == AppColors.success ? Icons.check_circle : Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Nouvelle demande',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Décrivez vos symptômes *'),
              const SizedBox(height: 8),
              TextField(
                controller: _symptomes,
                maxLines: 5,
                maxLength: 2000,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: appInputDecoration(
                  hint: 'Ex : maux de tête depuis ce matin, fièvre, fatigue…',
                  icon: Icons.notes,
                ),
              ),

              const SizedBox(height: 4),
              _label('Depuis combien de temps ?'),
              const SizedBox(height: 8),
              TextField(
                controller: _dureeSymptomes,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: appInputDecoration(
                  hint: 'Ex : 2 jours, 12 heures…',
                  icon: Icons.timer_outlined,
                ),
              ),

              const SizedBox(height: 24),
              _label('Niveau d\'urgence'),
              const SizedBox(height: 10),
              Row(
                children: _urgences.map((u) {
                  final (val, label, color) = u;
                  final selected = _urgence == val;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _urgence = val),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected ? color.withValues(alpha: 0.18) : AppColors.card,
                            border: Border.all(
                              color: selected ? color : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: selected ? color : AppColors.textTertiary,
                                size: 18,
                              ),
                              const SizedBox(height: 4),
                              Text(label,
                                  style: TextStyle(
                                      color: selected ? color : Colors.white70,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _label('Créneau souhaité (facultatif)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _pickerBox(
                      icon: Icons.calendar_today,
                      text: _date == null ? 'Choisir une date' : _fmtDate(_date!),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerBox(
                      icon: Icons.access_time,
                      text: _heure == null ? 'Choisir une heure' : _fmtTime(_heure!),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Envoyer la demande',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Votre demande sera transmise à un soignant qui vous recontactera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
      );

  Widget _pickerBox({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomes.dispose();
    _dureeSymptomes.dispose();
    super.dispose();
  }
}
