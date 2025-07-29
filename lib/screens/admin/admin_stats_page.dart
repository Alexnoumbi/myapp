import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../layout/admin_layout.dart';
import '../../constants/style.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({Key? key}) : super(key: key);

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  String _selectedPeriod = 'Mensuel';
  String _selectedYear = '2025';

  @override
  Widget build(BuildContext context) {
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                  final investissement = (data['investissement'] as num?)?.toDouble() ?? 0.0;
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
