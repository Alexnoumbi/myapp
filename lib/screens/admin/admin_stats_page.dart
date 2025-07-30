import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../layout/admin_layout.dart';
import '../../constants/style.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/performance_indicators_service.dart'; // Import du service
import 'widgets/chart_section.dart'; // Import du widget ChartSection

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({Key? key}) : super(key: key);

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  String _selectedPeriod = 'Mensuel';
  String _selectedYear = '2025';
  List<double> _chartInvestments = [];
  List<String> _chartLabels = [];
  final PerformanceIndicatorsService _performanceService = PerformanceIndicatorsService();


  @override
  void initState() {
    super.initState();
    _loadChartData(); // Charger les données du graphique au démarrage
  }

  Future<void> _loadChartData() async {
    try {
      // Récupérer les données des 12 derniers mois pour le graphique d'évolution
      final historicalIndicators = await _performanceService.getHistoricalIndicators(12);

      final Map<String, double> monthlyInvestments = {};
      final List<String> sortedMonths = [];

      for (var indicator in historicalIndicators) {
        final period = indicator.reportingPeriod;
        final monthYear = '${period.month}/${period.year}';
        final investment = indicator.economicPerformance.turnover; // Ou investissementsRealises si plus pertinent

        // Agrégation par mois
        monthlyInvestments.update(monthYear, (value) => value + investment, ifAbsent: () => investment);

        // Assurer l'ordre des mois pour les labels
        if (!sortedMonths.contains(monthYear)) {
          sortedMonths.add(monthYear);
        }
      }

      // Trier les mois si nécessaire (par exemple, si les données ne viennent pas dans l'ordre)
      sortedMonths.sort((a, b) {
        final aParts = a.split('/').map(int.parse).toList();
        final bParts = b.split('/').map(int.parse).toList();
        if (aParts[1] != bParts[1]) return aParts[1].compareTo(bParts[1]); // Comparer l'année
        return aParts[0].compareTo(bParts[0]); // Comparer le mois
      });

      setState(() {
        _chartLabels = sortedMonths;
        _chartInvestments = sortedMonths.map((monthYear) => monthlyInvestments[monthYear] ?? 0.0).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des données du graphique: $e');
      // Gérer l'erreur, par exemple afficher un message à l'utilisateur
    }
  }

  @override
  Widget build(BuildContext) {
    return AdminLayout(
      title: 'Statistiques',
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: const InputDecoration(
                          labelText: 'Période',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Mensuel', child: Text('Mensuel')),
                          DropdownMenuItem(value: 'Trimestriel', child: Text('Trimestriel')),
                          DropdownMenuItem(value: 'Annuel', child: Text('Annuel')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                          _loadChartData(); // Recharger le graphique si la période change (peut être affiné pour filtrer le graphique aussi)
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Année',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (var year in ['2023', '2024', '2025'])
                            DropdownMenuItem(value: year, child: Text(year)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                          _loadChartData(); // Recharger le graphique si l'année change
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ChartSection(
              investissements: _chartInvestments,
              labels: _chartLabels,
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('entreprises').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final secteurs = <String, Map<String, dynamic>>{};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final secteur = data['secteur'] as String? ?? 'Non spécifié';
                  // Utiliser investissementsRealises pour la cohérence avec le graphique d'investissement
                  final investissement = (data['investissementsRealises'] as num?)?.toDouble() ?? 0.0;
                  final emplois = (data['employes'] as num?)?.toInt() ?? 0;

                  if (!secteurs.containsKey(secteur)) {
                    secteurs[secteur] = {
                      'count': 0,
                      'investissements': 0.0,
                      'emplois': 0,
                    };
                  }

                  secteurs[secteur]!['count'] = secteurs[secteur]!['count']! + 1;
                  secteurs[secteur]!['investissements'] = secteurs[secteur]!['investissements']! + investissement;
                  secteurs[secteur]!['emplois'] = secteurs[secteur]!['emplois']! + emplois;
                }

                return Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Répartition par secteur', style: AppStyles.cardTitleStyle),
                            const SizedBox(height: 16),
                            AspectRatio(
                              aspectRatio: 2,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieSections(secteurs),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 1,
                        childAspectRatio: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: secteurs.length,
                      itemBuilder: (context, index) {
                        final secteur = secteurs.keys.elementAt(index);
                        final stats = secteurs[secteur]!;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(secteur, style: AppStyles.cardTitleStyle),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Entreprises',
                                          style: AppStyles.indicatorLabelStyle,
                                        ),
                                        Text(
                                          stats['count'].toString(),
                                          style: AppStyles.indicatorValueStyle,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Investissements',
                                          style: AppStyles.indicatorLabelStyle,
                                        ),
                                        Text(
                                          '${(stats['investissements'] / 1000000).toStringAsFixed(1)}M',
                                          style: AppStyles.indicatorValueStyle,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, Map<String, dynamic>> secteurs) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return secteurs.entries.map((entry) {
      final index = secteurs.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];
      final value = entry.value['count'].toDouble();
      final total = secteurs.values.fold<int>(0, (sum, stats) => sum + stats['count'] as int);
      final percentage = total == 0 ? 0 : (value / total * 100);

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
