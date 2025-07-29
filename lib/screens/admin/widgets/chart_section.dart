import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../constants/style.dart';

class ChartSection extends StatelessWidget {
  final List<double> investissements;
  final List<String> labels;

  const ChartSection({
    super.key,
    required this.investissements,
    required this.labels,
  }) : assert(investissements.length == labels.length, 'Le nombre d\'investissements doit correspondre au nombre de labels');

  @override
  Widget build(BuildContext context) {
    // Trouver les valeurs min et max pour l'échelle
    final maxY = investissements.isEmpty ? 10.0 : investissements.reduce((max, value) => value > max ? value : max);
    final minY = investissements.isEmpty ? 0.0 : investissements.reduce((min, value) => value < min ? value : min);
    final padding = ((maxY - minY) * 0.1).clamp(1.0, double.infinity);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Évolution des investissements",
                  style: AppStyles.cardTitleStyle,
                ),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: investissements.isEmpty
                  ? const Center(child: Text('Aucune donnée disponible'))
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (investissements.length - 1).toDouble(),
                        minY: (minY - padding).clamp(0, double.infinity),
                        maxY: maxY + padding,
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                          horizontalInterval: padding,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      labels[index],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                            left: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: investissements.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: AppStyles.mainColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: AppStyles.mainColor,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppStyles.mainColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppStyles.mainColor.withOpacity(0.1),
            border: Border.all(
              color: AppStyles.mainColor,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Investissements',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
