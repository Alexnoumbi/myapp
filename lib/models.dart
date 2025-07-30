import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Timestamp

class Projet {
  String nom;
  double cout;

  Projet({required this.nom, required this.cout});

  // Helper method to convert Projet to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'cout': cout,
    };
  }

  // Helper method to create Projet from Map
  factory Projet.fromMap(Map<String, dynamic> map) {
    return Projet(
      nom: map['nom'] ?? '',
      cout: (map['cout'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class IndicateurPerformance {
  String nom;
  String valeur;

  IndicateurPerformance({required this.nom, required this.valeur});

  // Helper method to convert IndicateurPerformance to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'valeur': valeur,
    };
  }

  // Helper method to create IndicateurPerformance from Map
  factory IndicateurPerformance.fromMap(Map<String, dynamic> map) {
    return IndicateurPerformance(
      nom: map['nom'] ?? '',
      valeur: map['valeur'] ?? '',
    );
  }
}

// You might not need this full Entreprise model class if you are directly
// working with Firestore documents. However, it can be useful for
// structuring data within your application logic.
class Entreprise {
  String? id;
  String nom;
  String? email;
  String secteur;
  String statut;
  String? adresse;
  String? contact;
  DateTime? dateConvention;
  double capital;
  int emploisCrees;
  int emploisPrevus;
  double exportations;
  double investissementsPrevus;
  double investissementsRealises;
  List<Projet> projets;
  List<String> documentsUrls;
  List<IndicateurPerformance> indicateurs;
  String? conventionPdfUrl;
  DateTime? updatedAt;

  // Ajout des nouveaux champs issus du questionnaire
  String? region;
  String? ville;
  String? correspondant;
  DateTime? dateCreation;
  int? sexeDirigeant; // 1=Masculin, 2=Féminin
  String? tel;
  String? numContribuable;
  String? repere;
  int? typeEntreprise; // 1=ME/MI, 2=PME, 3=TPM
  int? secteurActivite; // 1=PRIMAIRE, 2=SECONDAIRE, 3=TERTIAIRE
  int? sousSecteur;
  int? formeJuridique;
  String? activitePrincipale;
  double? chiffreAffairesDernier;
  int? diplomeDirigeant;

  // Ajout du suivi conjoncturel
  List<SuiviConjoncture> suivisConjoncturels;

  Entreprise({
    this.id,
    required this.nom,
    this.email,
    required this.secteur,
    required this.statut,
    this.adresse,
    this.contact,
    this.dateConvention,
    required this.capital,
    required this.emploisCrees,
    required this.emploisPrevus,
    required this.exportations,
    required this.investissementsPrevus,
    required this.investissementsRealises,
    required this.projets,
    required this.documentsUrls,
    required this.indicateurs,
    this.conventionPdfUrl,
    this.updatedAt,
    this.region,
    this.ville,
    this.correspondant,
    this.dateCreation,
    this.sexeDirigeant,
    this.tel,
    this.numContribuable,
    this.repere,
    this.typeEntreprise,
    this.secteurActivite,
    this.sousSecteur,
    this.formeJuridique,
    this.activitePrincipale,
    this.chiffreAffairesDernier,
    this.diplomeDirigeant,
    this.suivisConjoncturels = const [],
  });

  // Helper method to convert Entreprise to Map for Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nom': nom,
      'email': email,
      'secteur': secteur,
      'statut': statut,
      'adresse': adresse,
      'contact': contact,
      'dateConvention': dateConvention?.toIso8601String(),
      'capital': capital,
      'emploisCrees': emploisCrees,
      'emploisPrevus': emploisPrevus,
      'exportations': exportations,
      'investissementsPrevus': investissementsPrevus,
      'investissementsRealises': investissementsRealises,
      'projets': projets.map((p) => p.toMap()).toList(),
      'documentsUrls': documentsUrls,
      'indicateurs': indicateurs.map((i) => i.toMap()).toList(),
      'conventionPdfUrl': conventionPdfUrl,
      'updatedAt': updatedAt, // Store DateTime directly
      'region': region,
      'ville': ville,
      'correspondant': correspondant,
      'dateCreation': dateCreation?.toIso8601String(),
      'sexeDirigeant': sexeDirigeant,
      'tel': tel,
      'numContribuable': numContribuable,
      'repere': repere,
      'typeEntreprise': typeEntreprise,
      'secteurActivite': secteurActivite,
      'sousSecteur': sousSecteur,
      'formeJuridique': formeJuridique,
      'activitePrincipale': activitePrincipale,
      'chiffreAffairesDernier': chiffreAffairesDernier,
      'diplomeDirigeant': diplomeDirigeant,
      'suivisConjoncturels': suivisConjoncturels.map((s) => s.toMap()).toList(),
    };
    return map;
  }

  // Helper method to create Entreprise from Firestore DocumentSnapshot
  factory Entreprise.fromFirestore(Map<String, dynamic> firestoreDoc, String id) {
    List<Projet> projetsList = [];
    if (firestoreDoc['projets'] != null) {
      projetsList = (firestoreDoc['projets'] as List)
          .map((item) => Projet.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    List<IndicateurPerformance> indicateursList = [];
    if (firestoreDoc['indicateurs'] != null) {
      indicateursList = (firestoreDoc['indicateurs'] as List)
          .map((item) => IndicateurPerformance.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    List<SuiviConjoncture> suivisList = [];
    if (firestoreDoc['suivisConjoncturels'] != null) {
      suivisList = (firestoreDoc['suivisConjoncturels'] as List)
          .map((item) => SuiviConjoncture.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return Entreprise(
      id: id,
      nom: firestoreDoc['nom'] ?? '',
      email: firestoreDoc['email'],
      secteur: firestoreDoc['secteur'] ?? '',
      statut: firestoreDoc['statut'] ?? 'Actif',
      adresse: firestoreDoc['adresse'],
      contact: firestoreDoc['contact'],
      dateConvention: firestoreDoc['dateConvention'] != null
          ? DateTime.tryParse(firestoreDoc['dateConvention'])
          : null,
      capital: (firestoreDoc['capital'] as num?)?.toDouble() ?? 0.0,
      emploisCrees: (firestoreDoc['emploisCrees'] as num?)?.toInt() ?? 0,
      emploisPrevus: (firestoreDoc['emploisPrevus'] as num?)?.toInt() ?? 0,
      exportations: (firestoreDoc['exportations'] as num?)?.toDouble() ?? 0.0,
      investissementsPrevus: (firestoreDoc['investissementsPrevus'] as num?)?.toDouble() ?? 0.0,
      investissementsRealises: (firestoreDoc['investissementsRealises'] as num?)?.toDouble() ?? 0.0,
      projets: projetsList,
      documentsUrls: firestoreDoc['documentsUrls'] != null ? List<String>.from(firestoreDoc['documentsUrls']) : [],
      indicateurs: indicateursList,
      conventionPdfUrl: firestoreDoc['conventionPdfUrl'],
      updatedAt: (firestoreDoc['updatedAt'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
      region: firestoreDoc['region'],
      ville: firestoreDoc['ville'],
      correspondant: firestoreDoc['correspondant'],
      dateCreation: firestoreDoc['dateCreation'] != null ? DateTime.tryParse(firestoreDoc['dateCreation']) : null,
      sexeDirigeant: firestoreDoc['sexeDirigeant'],
      tel: firestoreDoc['tel'],
      numContribuable: firestoreDoc['numContribuable'],
      repere: firestoreDoc['repere'],
      typeEntreprise: firestoreDoc['typeEntreprise'],
      secteurActivite: firestoreDoc['secteurActivite'],
      sousSecteur: firestoreDoc['sousSecteur'],
      formeJuridique: firestoreDoc['formeJuridique'],
      activitePrincipale: firestoreDoc['activitePrincipale'],
      chiffreAffairesDernier: (firestoreDoc['chiffreAffairesDernier'] as num?)?.toDouble(),
      diplomeDirigeant: firestoreDoc['diplomeDirigeant'],
      suivisConjoncturels: suivisList,
    );
  }
}

// Modèle pour le suivi conjoncturel trimestriel
class SuiviConjoncture {
  String trimestre; // ex: "T1 2025"
  double? chiffreAffaires;
  int? evolutionChiffreAffaires; // 1=Hausse, 2=Baisse, 3=Stabilité
  List<String>? raisonsHausse;
  List<String>? raisonsBaisse;
  double? evolutionPrixVente; // 1=hausse, 2=baisse, 3=stabilité
  double? coutsProduction; // Nouveau champ
  int? evolutionCoutsProduction; // Nouveau champ: 1=Accroissement, 2=Baisse, 3=Stabilité
  int? effectifs;
  bool? nouveauxEmploisCrees;
  int? nbNouveauxEmplois;
  bool? investissementsRealises;
  List<String>? typesInvestissements;
  List<String>? sourcesFinancement;
  List<int>? conditionsFinancement;
  int? situationTresorerie; // 1=difficile, 2=normale, 3=aisée

  SuiviConjoncture({
    required this.trimestre,
    this.chiffreAffaires,
    this.evolutionChiffreAffaires,
    this.raisonsHausse,
    this.raisonsBaisse,
    this.evolutionPrixVente,
    this.coutsProduction, // Nouveau champ
    this.evolutionCoutsProduction, // Nouveau champ
    this.effectifs,
    this.nouveauxEmploisCrees,
    this.nbNouveauxEmplois,
    this.investissementsRealises,
    this.typesInvestissements,
    this.sourcesFinancement,
    this.conditionsFinancement,
    this.situationTresorerie,
  });

  Map<String, dynamic> toMap() {
    return {
      'trimestre': trimestre,
      'chiffreAffaires': chiffreAffaires,
      'evolutionChiffresAffaires': evolutionChiffreAffaires,
      'raisonsHausse': raisonsHausse,
      'raisonsBaisse': raisonsBaisse,
      'evolutionPrixVente': evolutionPrixVente,
      'coutsProduction': coutsProduction, // Nouveau champ
      'evolutionCoutsProduction': evolutionCoutsProduction, // Nouveau champ
      'effectifs': effectifs,
      'nouveauxEmploisCrees': nouveauxEmploisCrees,
      'nbNouveauxEmplois': nbNouveauxEmplois,
      'investissementsRealises': investissementsRealises,
      'typesInvestissements': typesInvestissements,
      'sourcesFinancement': sourcesFinancement,
      'conditionsFinancement': conditionsFinancement,
      'situationTresorerie': situationTresorerie,
    };
  }

  factory SuiviConjoncture.fromMap(Map<String, dynamic> map) {
    return SuiviConjoncture(
      trimestre: map['trimestre'] ?? '',
      chiffreAffaires: (map['chiffreAffaires'] as num?)?.toDouble(),
      evolutionChiffreAffaires: map['evolutionChiffresAffaires'],
      raisonsHausse: map['raisonsHausse'] != null ? List<String>.from(map['raisonsHausse']) : null,
      raisonsBaisse: map['raisonsBaisse'] != null ? List<String>.from(map['raisonsBaisse']) : null,
      evolutionPrixVente: (map['evolutionPrixVente'] as num?)?.toDouble(),
      coutsProduction: (map['coutsProduction'] as num?)?.toDouble(), // Nouveau champ
      evolutionCoutsProduction: map['evolutionCoutsProduction'], // Nouveau champ
      effectifs: map['effectifs'],
      nouveauxEmploisCrees: map['nouveauxEmploisCrees'],
      nbNouveauxEmplois: map['nbNouveauxEmplois'],
      investissementsRealises: map['investissementsRealises'],
      typesInvestissements: map['typesInvestissements'] != null ? List<String>.from(map['typesInvestissements']) : null,
      sourcesFinancement: map['sourcesFinancement'] != null ? List<String>.from(map['sourcesFinancement']) : null,
      conditionsFinancement: map['conditionsFinancement'] != null ? List<int>.from(map['conditionsFinancement']) : null,
      situationTresorerie: map['situationTresorerie'],
    );
  }
}

// Modèle Utilisateur
class Utilisateur {
  String id;
  String nom;
  String email;
  String role; // "admin", "personnel"

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'role': role,
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
