import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../constants/style.dart';

class RevenueSection extends StatelessWidget {
  const RevenueSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('entreprises')
          .where('role', isEqualTo: 'entreprise')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entreprises = snapshot.data!.docs;
        final investissementsParSecteur = <String, double>{};

        // Calculer les investissements par secteur
        for (var doc in entreprises) {
          final data = doc.data() as Map<String, dynamic>;
          final secteur = data['secteur'] as String? ?? 'Non défini';
          final investissement = (data['investissementsRealises'] as num?)?.toDouble() ?? 0.0;
          investissementsParSecteur[secteur] = (investissementsParSecteur[secteur] ?? 0.0) + investissement;
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Investissements par secteur",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: investissementsParSecteur.values.reduce((a, b) => a > b ? a : b),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < investissementsParSecteur.keys.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                investissementsParSecteur.keys.elementAt(value.toInt()),
                                style: const TextStyle(
                                  color: Color(0xff7589a2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000000).toStringAsFixed(1)}M',
                            style: const TextStyle(
                              color: Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: investissementsParSecteur.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: AppStyles.mainColor,
                          width: 25,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RevenueSectionSmall extends StatelessWidget {
  const RevenueSectionSmall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Investissements par secteur",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Version simplifiée pour les petits écrans
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('entreprises')
                .where('role', isEqualTo: 'entreprise')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final entreprises = snapshot.data!.docs;
              final investissementsParSecteur = <String, double>{};

              for (var doc in entreprises) {
                final data = doc.data() as Map<String, dynamic>;
                final secteur = data['secteur'] as String? ?? 'Non défini';
                final investissement = (data['investissementsRealises'] as num?)?.toDouble() ?? 0.0;
                investissementsParSecteur[secteur] = (investissementsParSecteur[secteur] ?? 0.0) + investissement;
              }

              return Column(
                children: investissementsParSecteur.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      '${(entry.value / 1000000).toStringAsFixed(1)}M XAF',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
