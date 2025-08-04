import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kpi_definition_model.dart';

class KpiDefinitionService {
  final CollectionReference _kpiDefinitionsCollection =
  FirebaseFirestore.instance.collection('kpi_definitions');

  // Add a new KPI definition
  Future<String> addKpiDefinition(KpiDefinition kpiDefinition) async {
    try {
      final docRef = await _kpiDefinitionsCollection.add(kpiDefinition.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la définition KPI: $e');
    }
  }

  // Get all KPI definitions
  Stream<List<KpiDefinition>> getKpiDefinitions() {
    return _kpiDefinitionsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => KpiDefinition.fromFirestore(doc))
          .toList();
    });
  }

  // Update an existing KPI definition
  Future<void> updateKpiDefinition(KpiDefinition kpiDefinition) async {
    if (kpiDefinition.id == null) {
      throw Exception('L\'ID de la définition KPI est nul.');
    }
    try {
      await _kpiDefinitionsCollection.doc(kpiDefinition.id).update(kpiDefinition.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la définition KPI: $e');
    }
  }

  // Delete a KPI definition
  Future<void> deleteKpiDefinition(String kpiId) async {
    try {
      await _kpiDefinitionsCollection.doc(kpiId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la définition KPI: $e');
    }
  }
}

