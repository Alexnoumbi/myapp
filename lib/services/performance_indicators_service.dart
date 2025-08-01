import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_indicators.dart';

class PerformanceIndicatorsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer ou mettre à jour les indicateurs
  Future<void> saveIndicators(PerformanceIndicators indicators) async {
    try {
      await _firestore
          .collection('performance_indicators')
          .doc(indicators.id)
          .set(indicators.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des indicateurs: $e');
    }
  }

  // Récupérer les indicateurs d'une entreprise pour une période
  Future<PerformanceIndicators?> getIndicators(String companyId, DateTime period) async {
    try {
      final snapshot = await _firestore
          .collection('performance_indicators')
          .where('companyId', isEqualTo: companyId)
          .where('reportingPeriod', isEqualTo: Timestamp.fromDate(period))
          .get();

      if (snapshot.docs.isEmpty) return null;

      return PerformanceIndicators.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Erreur lors de la récupération des indicateurs: $e');
    }
  }

  // Récupérer l'historique des indicateurs d'une entreprise
  Future<List<PerformanceIndicators>> getIndicatorsHistory(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('performance_indicators')
          .where('companyId', isEqualTo: companyId)
          .orderBy('reportingPeriod', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PerformanceIndicators.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique: $e');
    }
  }

  // Récupérer tous les indicateurs pour une période donnée
  Future<List<PerformanceIndicators>> getAllIndicatorsForPeriod(DateTime period) async {
    try {
      // Pour une période donnée (mois/année), on cherche les indicateurs
      // dont la date de reporting est dans ce mois/année.
      final startOfMonth = DateTime(period.year, period.month, 1);
      final endOfMonth = DateTime(period.year, period.month + 1, 0); // Dernier jour du mois

      final snapshot = await _firestore
          .collection('performance_indicators')
          .where('reportingPeriod', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('reportingPeriod', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return snapshot.docs
          .map((doc) => PerformanceIndicators.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des indicateurs de la période: $e');
    }
  }

  // Nouvelle méthode: Récupérer les indicateurs historiques pour un graphique
  Future<List<PerformanceIndicators>> getHistoricalIndicators(int numberOfMonths) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - numberOfMonths, 1);

      final snapshot = await _firestore
          .collection('performance_indicators')
          .where('reportingPeriod', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('reportingPeriod', descending: false) // Ordonner pour le graphique
          .get();

      return snapshot.docs
          .map((doc) => PerformanceIndicators.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des indicateurs historiques: $e');
    }
  }


  // Supprimer les indicateurs
  Future<void> deleteIndicators(String indicatorId) async {
    try {
      await _firestore
          .collection('performance_indicators')
          .doc(indicatorId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des indicateurs: $e');
    }
  }

  // Obtenir des statistiques agrégées
  Future<Map<String, dynamic>> getAggregatedStats(DateTime period) async {
    try {
      final indicators = await getAllIndicatorsForPeriod(period);

      int totalEmployees = 0;
      int totalNewJobs = 0;
      double totalTurnover = 0;
      int companiesCount = indicators.length;

      for (var indicator in indicators) {
        totalEmployees += indicator.investmentEmployment.totalEmployees;
        totalNewJobs += indicator.investmentEmployment.newJobsCreated;
        totalTurnover += indicator.economicPerformance.turnover;
      }

      return {
        'totalEmployees': totalEmployees,
        'totalNewJobs': totalNewJobs,
        'totalTurnover': totalTurnover,
        'companiesCount': companiesCount,
        'period': period,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }
}
