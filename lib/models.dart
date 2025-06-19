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
  String? id; // Added id to match Firestore document ID
  String nom;
  String? email; // Email might be stored in Firebase Auth, but can be duplicated here
  String secteur;
  String statut;
  DateTime? dateConvention; // Made nullable
  double capital;
  int emploisCrees;
  double exportations;
  List<Projet> projets;
  List<String> documentsUrls; // Changed from paths to Urls for Firebase Storage
  List<IndicateurPerformance> indicateurs;
  DateTime? updatedAt; // Added for tracking updates

  Entreprise({
    this.id,
    required this.nom,
    this.email,
    required this.secteur,
    required this.statut,
    this.dateConvention,
    required this.capital,
    required this.emploisCrees,
    required this.exportations,
    required this.projets,
    required this.documentsUrls,
    required this.indicateurs,
    this.updatedAt,
  });

  // Helper method to convert Entreprise to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'secteur': secteur,
      'statut': statut,
      'dateConvention': dateConvention?.toIso8601String(),
      'capital': capital,
      'emploisCrees': emploisCrees,
      'exportations': exportations,
      'projets': projets.map((p) => p.toMap()).toList(),
      'documentsUrls': documentsUrls,
      'indicateurs': indicateurs.map((i) => i.toMap()).toList(),
      'updatedAt': updatedAt, // Store DateTime directly
    };
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

    return Entreprise(
      id: id,
      nom: firestoreDoc['nom'] ?? '',
      email: firestoreDoc['email'],
      secteur: firestoreDoc['secteur'] ?? '',
      statut: firestoreDoc['statut'] ?? 'Actif',
      dateConvention: firestoreDoc['dateConvention'] != null
          ? DateTime.tryParse(firestoreDoc['dateConvention'])
          : null,
      capital: (firestoreDoc['capital'] as num?)?.toDouble() ?? 0.0,
      emploisCrees: (firestoreDoc['emploisCrees'] as num?)?.toInt() ?? 0,
      exportations: (firestoreDoc['exportations'] as num?)?.toDouble() ?? 0.0,
      projets: projetsList,
      documentsUrls: firestoreDoc['documentsUrls'] != null ? List<String>.from(firestoreDoc['documentsUrls']) : [],
      indicateurs: indicateursList,
      updatedAt: (firestoreDoc['updatedAt'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
    );
  }
}
