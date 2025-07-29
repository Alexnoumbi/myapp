import 'package:flutter/material.dart';
import '../models/performance_indicators.dart';

class PerformanceIndicatorsCard extends StatelessWidget {
  final PerformanceIndicators indicators;

  const PerformanceIndicatorsCard({Key? key, required this.indicators}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(indicators.identification.companyName),
        subtitle: Text('Période: ${indicators.reportingPeriod.toString().split(' ')[0]}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Identification', [
                  'Région: ${indicators.identification.region}',
                  'Secteur: ${indicators.identification.sector}',
                  'Forme juridique: ${indicators.identification.legalForm}',
                ]),
                const Divider(),
                _buildSection('Performance Économique', [
                  'Chiffre d\'affaires: ${indicators.economicPerformance.turnover} FCFA',
                  'Évolution CA: ${indicators.economicPerformance.turnoverEvolution}',
                  'Trésorerie: ${indicators.economicPerformance.cashFlowStatus}',
                ]),
                const Divider(),
                _buildSection('Emploi et Investissement', [
                  'Effectif total: ${indicators.investmentEmployment.totalEmployees}',
                  'Nouveaux emplois: ${indicators.investmentEmployment.newJobsCreated}',
                  'Nouveaux investissements: ${indicators.investmentEmployment.hasNewInvestments ? "Oui" : "Non"}',
                ]),
                const Divider(),
                _buildSection('Innovation et Digital', [
                  'Niveau d\'innovation: ${_scaleToText(indicators.innovationDigital.innovationLevel)}',
                  'Niveau digital: ${_scaleToText(indicators.innovationDigital.digitalLevel)}',
                  'Utilisation IA: ${_scaleToText(indicators.innovationDigital.aiLevel)}',
                ]),
                const Divider(),
                _buildSection('Conformité Convention', [
                  'Conformité reporting: ${indicators.conventionCompliance.reportingCompliance}',
                  'Objectif emploi: ${indicators.conventionCompliance.employmentTargetPercent}%',
                  'Objectif investissement: ${indicators.conventionCompliance.investmentTargetPercent}%',
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item),
            )),
      ],
    );
  }

  String _scaleToText(CompanyScale scale) {
    switch (scale) {
      case CompanyScale.PEU:
        return 'Faible';
      case CompanyScale.MOYEN:
        return 'Moyen';
      case CompanyScale.BEAUCOUP:
        return 'Élevé';
    }
  }
}
