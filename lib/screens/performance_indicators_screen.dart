import 'package:flutter/material.dart';
import '../models/performance_indicators.dart';
import '../services/performance_indicators_service.dart';
import '../widgets/performance_indicators_card.dart';
import '../layout/admin_layout.dart';

class PerformanceIndicatorsScreen extends StatefulWidget {
  const PerformanceIndicatorsScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceIndicatorsScreen> createState() => _PerformanceIndicatorsScreenState();
}

class _PerformanceIndicatorsScreenState extends State<PerformanceIndicatorsScreen> {
  final PerformanceIndicatorsService _service = PerformanceIndicatorsService();
  DateTime _selectedPeriod = DateTime.now();
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _service.getAggregatedStats(_selectedPeriod);
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Indicateurs de Performance',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Période : ${_selectedPeriod.month}/${_selectedPeriod.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedPeriod,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedPeriod = date;
                              });
                              _loadStats();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_stats != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Entreprises',
                          _stats!['companiesCount'].toString(),
                          Icons.business,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Emplois Total',
                          _stats!['totalEmployees'].toString(),
                          Icons.people,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Nouveaux Emplois',
                          _stats!['totalNewJobs'].toString(),
                          Icons.person_add,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: FutureBuilder<List<PerformanceIndicators>>(
                      future: _service.getAllIndicatorsForPeriod(_selectedPeriod),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Erreur: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun indicateur trouvé pour cette période',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final indicators = snapshot.data![index];
                            return PerformanceIndicatorsCard(indicators: indicators);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
