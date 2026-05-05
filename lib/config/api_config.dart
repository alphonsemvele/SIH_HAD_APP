class ApiConfig {
  // Configuration de l'API pour le développement
  static const String _baseUrl = 'http://localhost:8000';
  static const String _apiPrefix = '/api';
  
  // URLs de base pour différents environnements
  static const String baseUrl = _baseUrl;
  static const String apiBaseUrl = '$_baseUrl$_apiPrefix';
  
  // Endpoints principaux
  static const String auth = '$apiBaseUrl/login';
  static const String logout = '$apiBaseUrl/logout';
  static const String dashboard = '$apiBaseUrl/dashboard';
  
  // Patients
  static const String patients = '$apiBaseUrl/patients';
  static String patient(int id) => '$apiBaseUrl/patients/$id';
  static String patientDossier(int id) => '$apiBaseUrl/patients/$id/dossier-medical';
  
  // Tournées HAD
  static const String tournees = '$apiBaseUrl/tournees';
  static String tournee(int id) => '$apiBaseUrl/tournees/$id';
  static String tourneeDemarrer(int id) => '$apiBaseUrl/tournees/$id/demarrer';
  static String tourneeTerminer(int id) => '$apiBaseUrl/tournees/$id/terminer';
  static String tourneeSuspendre(int id) => '$apiBaseUrl/tournees/$id/suspendre';
  static String tourneeAnnuler(int id) => '$apiBaseUrl/tournees/$id/annuler';
  static String tourneeValiderVisite(int tourneeId, int visiteId) => 
      '$apiBaseUrl/tournees/$tourneeId/visites/$visiteId/valider';
  
  // Dossiers médicaux
  static const String dossiersMedicaux = '$apiBaseUrl/dossiers-medicaux';
  static String dossier(int id) => '$apiBaseUrl/dossiers-medicaux/$id';
  
  // Lits et occupations
  static const String lits = '$apiBaseUrl/lits';
  static const String litsHistorique = '$apiBaseUrl/lits/historique';
  static String lit(int id) => '$apiBaseUrl/lits/$id';
  static String litNettoyage(int id) => '$apiBaseUrl/lits/$id/nettoyage';
  static String litDisponible(int id) => '$apiBaseUrl/lits/$id/disponible';
  static String litHorsService(int id) => '$apiBaseUrl/lits/$id/hors-service';
  static String litTransferer(int id) => '$apiBaseUrl/lits/$id/transferer';
  
  static const String occupations = '$apiBaseUrl/lits/occupations';
  static String occupation(int id) => '$apiBaseUrl/lits/occupations/$id';
  static String occupationTerminer(int id) => '$apiBaseUrl/lits/occupations/$id/terminer';
  static String occupationTransferer(int id) => '$apiBaseUrl/lits/occupations/$id/transferer';
  
  // Pharmacie
  static const String medicaments = '$apiBaseUrl/medicaments';
  static String medicament(int id) => '$apiBaseUrl/medicaments/$id';
  
  static const String categories = '$apiBaseUrl/categories';
  static String categorie(int id) => '$apiBaseUrl/categories/$id';
  
  static const String fournisseurs = '$apiBaseUrl/fournisseurs';
  static String fournisseur(int id) => '$apiBaseUrl/fournisseurs/$id';
  
  // Laboratoire
  static const String laboratoire = '$apiBaseUrl/laboratoire';
  static String analyse(int id) => '$apiBaseUrl/laboratoire/$id';
  static String analyseStatut(int id) => '$apiBaseUrl/laboratoire/$id/statut';
  static String analyseResultats(int id) => '$apiBaseUrl/laboratoire/$id/resultats';
  static String analyseValider(int id) => '$apiBaseUrl/laboratoire/$id/valider';
  
  // Imagerie
  static const String imagerie = '$apiBaseUrl/imagerie';
  static String examen(int id) => '$apiBaseUrl/imagerie/$id';
  static String examenStatut(int id) => '$apiBaseUrl/imagerie/$id/statut';
  static String examenConclusion(int id) => '$apiBaseUrl/imagerie/$id/conclusion';
  
  static const String modalitesImagerie = '$apiBaseUrl/modalite-imagerie';
  static String modaliteImagerie(int id) => '$apiBaseUrl/modalite-imagerie/$id';
  
  // Services
  static const String services = '$apiBaseUrl/services';
  static String service(int id) => '$apiBaseUrl/services/$id';
  static String serviceToggleStatus(int id) => '$apiBaseUrl/services/$id/toggle-status';
  
  // Anomalies
  static const String anomalies = '$apiBaseUrl/anomalies';
  static String anomalie(int id) => '$apiBaseUrl/anomalies/$id';
  
  // Carte et Localisation
  static const String patientsMap = '$apiBaseUrl/patients/map';
  static const String patientsGeolocalises = '$apiBaseUrl/patients/geolocalises';
  static String patientGeolocalisation(int id) => '$apiBaseUrl/patients/$id/geolocalisation';
  static const String zonesVisites = '$apiBaseUrl/zones-visites';
  static const String itineraireOptimise = '$apiBaseUrl/itineraire/optimiser';
  static const String statistiquesZones = '$apiBaseUrl/zones/statistiques';

  // Rapports
  static const String rapports = '$apiBaseUrl/rapports';
  static String rapport(int id) => '$apiBaseUrl/rapports/$id';
  static String rapportTelecharger(int id) => '$apiBaseUrl/rapports/$id/telecharger';
  static const String rapportGenerer = '$apiBaseUrl/rapports/generer';
  static const String rapportTypes = '$apiBaseUrl/rapports/types';
  static const String rapportStats = '$apiBaseUrl/rapports/stats';

  // Administration
  static const String adminUsers = '$apiBaseUrl/users';
  static String adminUser(int id) => '$apiBaseUrl/users/$id';
  static String adminUserStatut(int id) => '$apiBaseUrl/users/$id/statut';
  
  static const String adminRoles = '$apiBaseUrl/roles';
  static String adminRole(int id) => '$apiBaseUrl/roles/$id';
  
  // Configuration des timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
