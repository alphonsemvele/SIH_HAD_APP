/// Modèle d'une visite HAD côté patient.
/// Parsing tolérant : le backend peut renvoyer des champs sous différents noms
/// (date_visite, date_prevue, visite_at, etc.) — on essaye plusieurs clés.
class Visit {
  final int id;
  final String? date;
  final String? heure;
  final int? dureeMinutes;
  final String? statut;
  final String? visiteAt;
  final String? notes;
  final String? soignantName;

  Visit({
    required this.id,
    this.date,
    this.heure,
    this.dureeMinutes,
    this.statut,
    this.visiteAt,
    this.notes,
    this.soignantName,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id:           _asInt(json['id']) ?? 0,
      date:         _firstString(json, ['date_visite', 'date_prevue', 'date']),
      heure:        _firstString(json, ['heure_prevue', 'heure', 'heure_visite']),
      dureeMinutes: _asInt(json['duree_prevue'] ?? json['duree_minutes']),
      statut:       json['statut']?.toString(),
      visiteAt:     json['visite_at']?.toString(),
      notes:        json['notes']?.toString(),
      soignantName: json['soignant_name']?.toString(),
    );
  }

  bool get estTerminee => visiteAt != null && visiteAt!.isNotEmpty;
  bool get estAVenir   => !estTerminee && statut != null && statut != 'annulee';

  /// Étiquette lisible du statut
  String get statutLabel {
    if (estTerminee) return 'Terminée';
    switch (statut) {
      case 'planifiee':  return 'Planifiée';
      case 'en_cours':   return 'En cours';
      case 'annulee':    return 'Annulée';
      default:           return statut ?? 'À venir';
    }
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return null;
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }
}
