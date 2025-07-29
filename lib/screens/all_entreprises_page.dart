import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../layout/admin_layout.dart';
import '../constants/style.dart';

class AllEntreprisesPage extends StatefulWidget {
  const AllEntreprisesPage({super.key});

  @override
  State<AllEntreprisesPage> createState() => _AllEntreprisesPageState();
}

class _AllEntreprisesPageState extends State<AllEntreprisesPage> {
  String? _selectedSecteur;
  String? _selectedStatut;

  void _openEntrepriseDetails(String entrepriseId, Map<String, dynamic> data) async {
    final historySnap = await FirebaseFirestore.instance
        .collection('entreprises')
        .doc(entrepriseId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();

    final List<Map<String, dynamic>> history = historySnap.docs
        .map((d) => d.data())
        .toList();

    // ignore: use_build_context_synchronously
    Navigator.pushNamed(
      context,
      '/edit-entreprise',
      arguments: {
        'entrepriseId': entrepriseId,
        'data': data,
        'history': history,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: "Gestion des Entreprises",
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSecteur,
                            decoration: const InputDecoration(
                              labelText: 'Secteur',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Tous')),
                              DropdownMenuItem(value: 'Industrie', child: Text('Industrie')),
                              DropdownMenuItem(value: 'Services', child: Text('Services')),
                              DropdownMenuItem(value: 'Agriculture', child: Text('Agriculture')),
                            ],
                            onChanged: (v) => setState(() => _selectedSecteur = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatut,
                            decoration: const InputDecoration(
                              labelText: 'Statut',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Tous')),
                              DropdownMenuItem(value: 'Actif', child: Text('Actif')),
                              DropdownMenuItem(value: 'Inactif', child: Text('Inactif')),
                              DropdownMenuItem(value: 'En attente', child: Text('En attente')),
                            ],
                            onChanged: (v) => setState(() => _selectedStatut = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('entreprises').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erreur: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune entreprise trouvée',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      var docs = snapshot.data!.docs;

                      if (_selectedSecteur != null) {
                        docs = docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return data['secteur'] == _selectedSecteur;
                        }).toList();
                      }

                      if (_selectedStatut != null) {
                        docs = docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return data['statut'] == _selectedStatut;
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun résultat pour ces filtres',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return Card(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final doc = docs[i];
                            final data = doc.data() as Map<String, dynamic>;
                            final status = data['statut'] as String? ?? 'Inactif';

                            return Material(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: status == 'Actif'
                                      ? Colors.green
                                      : status == 'En attente'
                                          ? Colors.orange
                                          : Colors.red,
                                  child: Text(
                                    (data['nom'] as String? ?? '').isNotEmpty
                                        ? (data['nom'] as String).substring(0, 1).toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(data['nom'] ?? ''),
                                subtitle: Text(
                                  'Secteur: ${data['secteur'] ?? ''}\n'
                                  'Statut: $status',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openEntrepriseDetails(doc.id, data),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une entreprise'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/edit-entreprise'),
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
