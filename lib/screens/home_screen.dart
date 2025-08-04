import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/responsive_widget.dart';
import '../constants/style.dart';

// --- Riverpod Provider for Indicators ---
final indicatorsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      entrepriseId,
    ) {
      if (entrepriseId.isEmpty) {
        return Stream.value([]);
      }
      final snapshot = FirebaseFirestore.instance
          .collection('entreprises')
          .doc(entrepriseId)
          .collection('indicateurs')
          .snapshots();

      return snapshot.map((query) => query.docs.map((e) => e.data()).toList());
    });

// Provider pour récupérer l'ID de l'entreprise connectée
final currentEnterpriseProvider = StreamProvider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value('');

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return data['entrepriseId'] ?? '';
        }
        return '';
      });
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Non connecté. Veuillez vous connecter.')),
      );
    }

    // Utiliser le provider pour récupérer l'ID de l'entreprise
    final currentEnterpriseAsync = ref.watch(currentEnterpriseProvider);

    return currentEnterpriseAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
      data: (currentEnterpriseId) {
        if (currentEnterpriseId.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune entreprise associée à votre compte',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
          );
        }

        final navItems = [
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier Entreprise'),
            onTap: () {
              Navigator.pushNamed(context, '/edit-entreprise');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Indicateurs'),
            onTap: () {
              Navigator.pushNamed(context, '/performance-indicators');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () => _logout(context),
          ),
        ];

        Widget dashboardContent = SingleChildScrollView(
          key: ValueKey(currentEnterpriseId),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyHeader(context, currentEnterpriseId),
              const SizedBox(height: 24),
              _buildCompanyInfo(currentEnterpriseId),
              const SizedBox(height: 24),
              _buildIndicators(context, ref, currentEnterpriseId),
              const SizedBox(height: 24),
              _buildDocuments(currentEnterpriseId),
              const SizedBox(height: 24),
              _buildAlerts(currentEnterpriseId),
              const SizedBox(height: 24),
              _buildNextVisit(currentEnterpriseId),
            ],
          ),
        );

        return ResponsiveWidget(
          largeScreen: Scaffold(
            appBar: AppBar(
              title: const Text('Tableau de bord Entreprise'),
              backgroundColor: AppStyles.mainColor,
              foregroundColor: Colors.white,
            ),
            body: Row(
              children: [
                Container(
                  width: 220,
                  color: Colors.blueGrey.shade50,
                  child: ListView(children: navItems),
                ),
                Expanded(child: dashboardContent),
              ],
            ),
          ),
          mediumScreen: Scaffold(
            appBar: AppBar(
              title: const Text('Tableau de bord Entreprise'),
              backgroundColor: AppStyles.mainColor,
              foregroundColor: Colors.white,
            ),
            drawer: Drawer(child: ListView(children: navItems)),
            body: dashboardContent,
          ),
          smallScreen: Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              backgroundColor: AppStyles.mainColor,
              foregroundColor: Colors.white,
            ),
            drawer: Drawer(child: ListView(children: navItems)),
            body: dashboardContent,
          ),
        );
      },
    );
  }

  Widget _buildCompanyHeader(BuildContext context, String enterpriseId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(enterpriseId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Erreur de chargement des informations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        final nom = data['nom'] ?? 'Nom inconnu';
        final secteur = data['secteur'] ?? 'Non défini';
        final statut = data['statut'] ?? 'Non défini';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppStyles.mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppStyles.mainColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Secteur: $secteur',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statut == 'Actif' ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statut,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-entreprise');
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.mainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/performance-indicators',
                          );
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Indicateurs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppStyles.mainColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanyInfo(String enterpriseId) {
    if (enterpriseId.isEmpty || enterpriseId == 'entrepriseId') {
      return const Card(
        child: ListTile(title: Text("ID d'entreprise non configuré.")),
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(enterpriseId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        if (snapshot.hasError) return Text("Erreur: ${snapshot.error}");
        if (!snapshot.hasData || !snapshot.data!.exists)
          return const Card(
            child: ListTile(
              title: Text('Informations de l\'entreprise non trouvées.'),
            ),
          );

        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Informations détaillées',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Nom', data['nom'] ?? 'Non défini'),
                _buildInfoRow('Secteur', data['secteur'] ?? 'Non défini'),
                _buildInfoRow(
                  'Localisation',
                  data['localisation'] ?? 'Non définie',
                ),
                _buildInfoRow('Téléphone', data['telephone'] ?? 'Non défini'),
                _buildInfoRow('Email', data['email'] ?? 'Non défini'),
                _buildInfoRow('Statut', data['statut'] ?? 'Non défini'),
                _buildInfoRow('Emplois créés', '${data['emploisCrees'] ?? 0}'),
                _buildInfoRow(
                  'Investissements réalisés',
                  '${data['investissementsRealises'] ?? 0} FCFA',
                ),
                if (data['dateCreation'] != null)
                  _buildInfoRow(
                    'Date de création',
                    _formatDate(data['dateCreation']),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate().toString().split(' ')[0];
    }
    return date.toString();
  }

  Widget _buildIndicators(
    BuildContext context,
    WidgetRef ref,
    String enterpriseId,
  ) {
    if (enterpriseId.isEmpty || enterpriseId == 'entrepriseId') {
      return const Card(
        child: ListTile(
          title: Text("ID d'entreprise non configuré pour les indicateurs."),
        ),
      );
    }
    final asyncIndicators = ref.watch(indicatorsProvider(enterpriseId));

    return asyncIndicators.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        print("Error loading indicators for $enterpriseId: $err\n$stack");
        return Card(child: ListTile(title: Text('Erreur: $err')));
      },
      data: (indicators) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📊 Indicateurs de performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/performance-indicators');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.mainColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (indicators.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun indicateur configuré',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ajoutez vos premiers indicateurs de performance',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: indicators.take(3).map((ind) {
                      String nom = ind['nom'] as String? ?? 'Indicateur';
                      double valeur =
                          (ind['valeur'] as num?)?.toDouble() ?? 0.0;
                      double seuil =
                          (ind['seuil_alerte'] as num?)?.toDouble() ?? 0.0;
                      String unite = ind['unité'] as String? ?? "";
                      List<double> historique =
                          (ind['historique'] as List?)
                              ?.map((item) => (item as num?)?.toDouble() ?? 0.0)
                              .toList() ??
                          [];
                      if (historique.isEmpty) historique.add(valeur);

                      Color statusColor = valeur < seuil
                          ? Colors.red.shade400
                          : Colors.green.shade400;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.assessment,
                                color: statusColor,
                                size: 30,
                              ),
                              title: Text(
                                nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Actuel: $valeur $unite (Seuil: $seuil $unite)',
                                style: TextStyle(color: statusColor),
                              ),
                            ),
                            if (historique.isNotEmpty)
                              buildIndicatorChart(nom, historique, seuil),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                if (indicators.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/performance-indicators',
                          );
                        },
                        child: Text(
                          'Voir tous les indicateurs (${indicators.length})',
                          style: TextStyle(color: AppStyles.mainColor),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocuments(String enterpriseId) {
    if (enterpriseId.isEmpty || enterpriseId == 'entrepriseId') {
      return const Card(
        child: ListTile(
          title: Text("ID d'entreprise non configuré pour les documents."),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(enterpriseId)
          .collection('documents')
          .orderBy('date_upload', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Text("Erreur: ${snapshot.error}");
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Card(
            child: ListTile(title: Text('Aucun document récent.')),
          );

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String dateDisplay = 'Date inconnue';
            if (data['date_upload'] != null) {
              if (data['date_upload'] is Timestamp) {
                dateDisplay = (data['date_upload'] as Timestamp)
                    .toDate()
                    .toLocal()
                    .toString()
                    .split(' ')[0];
              } else if (data['date_upload'] is String) {
                dateDisplay = data['date_upload'];
              }
            }
            return Card(
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(data['nom'] ?? 'Document sans nom'),
                subtitle: Text(
                  'Type : ${data['type'] ?? 'N/A'} | Date : $dateDisplay',
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAlerts(String enterpriseId) {
    if (enterpriseId.isEmpty || enterpriseId == 'entrepriseId') {
      return const Card(
        child: ListTile(
          title: Text("ID d'entreprise non configuré pour les alertes."),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(enterpriseId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text("Erreur de chargement des alertes"),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        final statut = data['statut'] ?? 'Non défini';
        final investissementsRealises = data['investissementsRealises'] ?? 0;
        final emploisCrees = data['emploisCrees'] ?? 0;

        List<Widget> alertItems = [];

        // Vérifier le statut
        if (statut != 'Actif') {
          alertItems.add(
            _buildAlertItem(
              Icons.warning,
              Colors.orange,
              'Statut non conforme',
              'Votre entreprise n\'est pas en statut actif',
            ),
          );
        }

        // Vérifier les investissements
        if (investissementsRealises == 0) {
          alertItems.add(
            _buildAlertItem(
              Icons.trending_down,
              Colors.red,
              'Aucun investissement',
              'Aucun investissement réalisé enregistré',
            ),
          );
        }

        // Vérifier les emplois
        if (emploisCrees == 0) {
          alertItems.add(
            _buildAlertItem(
              Icons.people_outline,
              Colors.blue,
              'Aucun emploi créé',
              'Aucun emploi créé enregistré',
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔔 Alertes et notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (alertItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune alerte active',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tout semble en ordre !',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(children: alertItems),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertItem(
    IconData icon,
    Color color,
    String title,
    String message,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextVisit(String enterpriseId) {
    if (enterpriseId.isEmpty || enterpriseId == 'entrepriseId') {
      return const Card(
        child: ListTile(
          title: Text("ID d'entreprise non configuré pour les visites."),
        ),
      );
    }
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(enterpriseId)
          .collection('visites')
          .orderBy('date', descending: false)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Text("Erreur: ${snapshot.error}");
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: ListTile(title: Text("Aucune visite prochaine programmée.")),
          );
        }
        final visitDoc = snapshot.data!.docs.first;
        final data = visitDoc.data() as Map<String, dynamic>;
        String dateDisplay = "Date non spécifiée";
        if (data['date'] != null && data['date'] is Timestamp) {
          dateDisplay = (data['date'] as Timestamp)
              .toDate()
              .toLocal()
              .toString()
              .split(' ')[0];
        } else if (data['date'] is String) {
          dateDisplay = data['date'];
        }
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: Text("Prochaine visite : $dateDisplay"),
            subtitle: Text("Agent : ${data['agent'] ?? 'Non assigné'}"),
          ),
        );
      },
    );
  }
}

// --- Chart Building Function (Corrected for fl_chart API) ---
Widget buildIndicatorChart(String name, List<double> values, double seuil) {
  if (values.isEmpty) {
    return const SizedBox(
      height: 200,
      child: Center(child: Text("Pas de données d'historique.")),
    );
  }

  double minY = values.reduce((a, b) => a < b ? a : b);
  double maxY = values.reduce((a, b) => a > b ? a : b);
  bool allSame = values.toSet().length == 1;

  if (allSame) {
    minY = (minY > 0 ? minY * 0.8 : minY - 5).clamp(
      double.negativeInfinity,
      seuil > minY ? seuil - 1 : minY - 1,
    );
    maxY = (maxY > 0 ? maxY * 1.2 : maxY + 5).clamp(
      seuil < maxY ? seuil + 1 : maxY + 1,
      double.infinity,
    );
  } else {
    minY = (minY > seuil ? seuil : minY) * 0.9;
    maxY = (maxY < seuil ? seuil : maxY) * 1.1;
  }
  if (minY == maxY) {
    minY -= 5;
    maxY += 5;
  }
  if ((maxY - minY) < 10 && maxY != 0 && minY != 0) {
    minY -= (10 - (maxY - minY)) / 2;
    maxY += (10 - (maxY - minY)) / 2;
  }
  if (maxY == 0 && minY == 0) {
    minY = -1;
    maxY = 1;
  }

  return SizedBox(
    height: 200,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 10),
      child: LineChart(
        LineChartData(
          minY: minY.floorToDouble(),
          maxY: maxY.ceilToDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 0.5,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: ((maxY.ceilToDouble() - minY.floorToDouble()) / 4)
                    .clamp(1, double.infinity),
                getTitlesWidget: (value, meta) {
                  return Text(
                    meta.formattedValue,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (i) => FlSpot(i.toDouble(), values[i]),
              ),
              isCurved: true,
              color: Colors.blue.shade400,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3.5,
                      color: Colors.blue.shade700,
                      strokeWidth: 0,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: List.generate(
                values.length,
                (i) => FlSpot(i.toDouble(), seuil),
              ),
              isCurved: false,
              color: Colors.redAccent.withOpacity(0.9),
              barWidth: 2,
              dotData: FlDotData(show: false),
              dashArray: [4, 4],
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor parameter removed as it's not available in your fl_chart version's LineTouchTooltipData constructor
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  if (barSpot.barIndex == 1) {
                    // Do not show tooltip for the threshold line
                    return null;
                  }
                  return LineTooltipItem(
                    '${flSpot.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    // If you needed to set a background color and your fl_chart version was
                    // very new, you might find a 'tooltipBackgroundColor' here in LineTooltipItem.
                    // Or, you would wrap the Text widget in a Container and style the Container.
                    // For now, this will use the default tooltip background.
                  );
                }).toList()..removeWhere((item) => item == null);
              },
            ),
            handleBuiltInTouches: true,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: Colors.purple.withOpacity(0.5),
                        strokeWidth: 3,
                      ),
                      FlDotData(
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 6,
                              color: Colors.purple,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                    );
                  }).toList();
                },
          ),
        ),
      ),
    ),
  );
}
