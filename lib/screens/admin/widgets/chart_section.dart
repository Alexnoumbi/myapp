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

    // Déterminer la hauteur responsive
    final screenWidth = MediaQuery.of(context).size.width;
    double chartHeight;
    double paddingValue;
    bool showLegend;
    
    if (screenWidth < 480) { // Extra small screen
      chartHeight = 180;
      paddingValue = 12;
      showLegend = false;
    } else if (screenWidth < 768) { // Small screen
      chartHeight = 220;
      paddingValue = 16;
      showLegend = true;
    } else if (screenWidth < 1024) { // Medium screen
      chartHeight = 250;
      paddingValue = 20;
      showLegend = true;
    } else { // Large screen
      chartHeight = 300;
      paddingValue = 24;
      showLegend = true;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Évolution des investissements",
                    style: AppStyles.cardTitleStyle.copyWith(
                      fontSize: screenWidth < 480 ? 14 : 16,
                    ),
                  ),
                ),
                if (showLegend) _buildLegend(),
              ],
            ),
            SizedBox(height: screenWidth < 480 ? 16 : 24),
            SizedBox(
              height: chartHeight,
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
                              reservedSize: screenWidth < 480 ? 30 : 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth < 480 ? 10 : 12,
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
                                    padding: EdgeInsets.only(top: screenWidth < 480 ? 4.0 : 8.0),
                                    child: Text(
                                      labels[index],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenWidth < 480 ? 10 : 12,
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
