class DemandeVisite {
  final int id;
  final String symptomes;
  final String? dureeSymptomes;
  final String urgence;
  final String urgenceLibelle;
  final String statut;
  final String statutLibelle;
  final String? dateSouhaitee;
  final String? heureSouhaitee;
  final String? notesInfirmier;
  final String? raisonRefus;
  final String? soignantName;
  final String? createdAt;

  DemandeVisite({
    required this.id,
    required this.symptomes,
    this.dureeSymptomes,
    required this.urgence,
    required this.urgenceLibelle,
    required this.statut,
    required this.statutLibelle,
    this.dateSouhaitee,
    this.heureSouhaitee,
    this.notesInfirmier,
    this.raisonRefus,
    this.soignantName,
    this.createdAt,
  });

  factory DemandeVisite.fromJson(Map<String, dynamic> json) {
    final soignant = json['soignant'];
    return DemandeVisite(
      id:             (json['id'] as num).toInt(),
      symptomes:      json['symptomes']?.toString() ?? '',
      dureeSymptomes: json['duree_symptomes']?.toString(),
      urgence:        json['urgence']?.toString() ?? 'moyenne',
      urgenceLibelle: json['urgence_libelle']?.toString() ?? 'Moyenne',
      statut:         json['statut']?.toString() ?? 'en_attente',
      statutLibelle:  json['statut_libelle']?.toString() ?? 'En attente',
      dateSouhaitee:  json['date_souhaitee']?.toString(),
      heureSouhaitee: json['heure_souhaitee']?.toString(),
      notesInfirmier: json['notes_infirmier']?.toString(),
      raisonRefus:    json['raison_refus']?.toString(),
      soignantName:   soignant is Map ? soignant['name']?.toString() : null,
      createdAt:      json['created_at']?.toString(),
    );
  }
}
