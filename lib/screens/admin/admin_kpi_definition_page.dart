import 'package:flutter/material.dart';
import '../../layout/admin_layout.dart';
import '../../models/kpi_definition_model.dart';
import '../../services/kpi_definition_service.dart';
import '../../constants/style.dart'; // Import AppStyles

class AdminKpiDefinitionPage extends StatefulWidget {
  const AdminKpiDefinitionPage({super.key});

  @override
  State<AdminKpiDefinitionPage> createState() => _AdminKpiDefinitionPageState();
}

class _AdminKpiDefinitionPageState extends State<AdminKpiDefinitionPage> {
  final KpiDefinitionService _kpiService = KpiDefinitionService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _thresholdMinController = TextEditingController();
  final TextEditingController _thresholdMaxController = TextEditingController();

  KpiDefinition? _editingKpi; // To hold the KPI being edited

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _thresholdMinController.dispose();
    _thresholdMaxController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _unitController.clear();
    _thresholdMinController.clear();
    _thresholdMaxController.clear();
    setState(() {
      _editingKpi = null;
    });
  }

  void _loadKpiForEdit(KpiDefinition kpi) {
    _nameController.text = kpi.name;
    _descriptionController.text = kpi.description;
    _unitController.text = kpi.unit;
    _thresholdMinController.text = kpi.thresholdMin?.toString() ?? '';
    _thresholdMaxController.text = kpi.thresholdMax?.toString() ?? '';
    setState(() {
      _editingKpi = kpi;
    });
  }

  Future<void> _saveKpiDefinition() async {
    if (_formKey.currentState!.validate()) {
      final kpi = KpiDefinition(
        id: _editingKpi?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        unit: _unitController.text.trim(),
        thresholdMin: double.tryParse(_thresholdMinController.text.trim()),
        thresholdMax: double.tryParse(_thresholdMaxController.text.trim()),
      );

      try {
        if (_editingKpi == null) {
          await _kpiService.addKpiDefinition(kpi);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Définition KPI ajoutée avec succès!')),
          );
        } else {
          await _kpiService.updateKpiDefinition(kpi);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Définition KPI mise à jour avec succès!')),
          );
        }
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteKpiDefinition(String kpiId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette définition KPI ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _kpiService.deleteKpiDefinition(kpiId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Définition KPI supprimée avec succès!')),
        );
        _clearForm(); // Clear form if the deleted KPI was being edited
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Gestion des Définitions KPI',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formulaire de définition KPI
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingKpi == null ? 'Ajouter une nouvelle définition KPI' : 'Modifier la définition KPI',
                        style: AppStyles.cardTitleStyle,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de l\'indicateur',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom pour l\'indicateur';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unité (ex: FCFA, %, nombre)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une unité';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _thresholdMinController,
                              decoration: const InputDecoration(
                                labelText: 'Seuil Min (Optionnel)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.arrow_downward),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _thresholdMaxController,
                              decoration: const InputDecoration(
                                labelText: 'Seuil Max (Optionnel)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.arrow_upward),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveKpiDefinition,
                              icon: Icon(_editingKpi == null ? Icons.add : Icons.save),
                              label: Text(_editingKpi == null ? 'Ajouter l\'indicateur' : 'Enregistrer les modifications'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.mainColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          if (_editingKpi != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearForm,
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Annuler'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppStyles.mainGreyColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Liste des définitions KPI existantes
          Expanded(
            flex: 3,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Définitions KPI existantes',
                      style: AppStyles.cardTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<List<KpiDefinition>>(
                        stream: _kpiService.getKpiDefinitions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Aucune définition KPI trouvée.'));
                          }

                          final kpis = snapshot.data!;
                          return ListView.separated(
                            itemCount: kpis.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final kpi = kpis[index];
                              return ListTile(
                                title: Text(kpi.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(kpi.description),
                                    Text('Unité: ${kpi.unit}'),
                                    if (kpi.thresholdMin != null || kpi.thresholdMax != null)
                                      Text('Seuils: ${kpi.thresholdMin ?? 'N/A'} - ${kpi.thresholdMax ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _loadKpiForEdit(kpi),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteKpiDefinition(kpi.id!),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

