import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// Import your models

class EditEntreprisePage extends StatefulWidget {
  const EditEntreprisePage({super.key});

  @override
  State<EditEntreprisePage> createState() => _EditEntreprisePageState();
}

class _EditEntreprisePageState extends State<EditEntreprisePage> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final secteurController = TextEditingController();
  bool isActif = true;
  final capitalController = TextEditingController();
  final emploisCreesController = TextEditingController();
  final exportationsController = TextEditingController();
  DateTime? dateConvention;
  List<Map<String, dynamic>> projets =
      []; // Store as list of maps for Firestore

  bool _isLoading = true;

  // Store initial data to compare for history tracking
  double _initialCapital = 0;
  int _initialEmploisCrees = 0;
  double _initialExportations = 0;

  @override
  void initState() {
    super.initState();
    _loadEntreprise();
  }

  Future<void> _loadEntreprise() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final entrepriseDoc =
          await FirebaseFirestore.instance
              .collection('entreprises')
              .doc(user.uid)
              .get();

      if (entrepriseDoc.exists) {
        final data = entrepriseDoc.data()!;
        nomController.text = data['nom'] ?? '';
        secteurController.text = data['secteur'] ?? '';
        isActif = (data['statut'] ?? 'Actif') == 'Actif';
        capitalController.text = (data['capital'] ?? 0.0).toString();
        emploisCreesController.text = (data['emploisCrees'] ?? 0).toString();
        exportationsController.text = (data['exportations'] ?? 0.0).toString();
        if (data['dateConvention'] != null) {
          dateConvention = DateTime.tryParse(data['dateConvention']);
        }
        if (data['projets'] != null && data['projets'] is List) {
          projets = List<Map<String, dynamic>>.from(data['projets']);
        }

        // Store initial values for history tracking
        _initialCapital = (data['capital'] as num?)?.toDouble() ?? 0.0;
        _initialEmploisCrees = (data['emploisCrees'] as num?)?.toInt() ?? 0;
        _initialExportations =
            (data['exportations'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      print("Error loading entreprise data: $e");
      // Handle error loading data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateConvention ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateConvention = picked;
      });
    }
  }

  Future<void> _addProjet() async {
    final nomProjetController = TextEditingController();
    final coutProjetController = TextEditingController();
    final formProjetKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Ajouter un projet"),
            content: Form(
              key: formProjetKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomProjetController,
                    decoration: const InputDecoration(
                      labelText: "Nom du projet",
                    ),
                    validator:
                        (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                  ),
                  TextFormField(
                    controller: coutProjetController,
                    decoration: const InputDecoration(labelText: "Coût (XAF)"),
                    keyboardType: TextInputType.number,
                    validator:
                        (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formProjetKey.currentState?.validate() == true) {
                    setState(() {
                      projets.add({
                        "nom": nomProjetController.text,
                        "cout": double.tryParse(coutProjetController.text) ?? 0,
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Ajouter"),
              ),
            ],
          ),
    );
  }

  void _removeProjet(int index) {
    setState(() {
      projets.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final newCapital = double.tryParse(capitalController.text) ?? 0;
    final newEmploisCrees = int.tryParse(emploisCreesController.text) ?? 0;
    final newExportations = double.tryParse(exportationsController.text) ?? 0;

    // Prepare data for update/create
    final entrepriseData = {
      "nom": nomController.text.trim(),
      "secteur": secteurController.text.trim(),
      "statut": isActif ? "Actif" : "Pas actif",
      "capital": newCapital,
      "emploisCrees": newEmploisCrees,
      "exportations": newExportations,
      "dateConvention": dateConvention?.toIso8601String(),
      "projets": projets, // Assuming projets is a List<Map<String, dynamic>>
      "updatedAt": FieldValue.serverTimestamp(), // Use server timestamp
    };

    final entrepriseRef = FirebaseFirestore.instance
        .collection('entreprises')
        .doc(user.uid);

    try {
      // Perform the upsert (set with merge true)
      await entrepriseRef.set(entrepriseData, SetOptions(merge: true));

      // --- History Tracking ---
      final historyCollection = entrepriseRef.collection('history');
      final timestamp =
          FieldValue.serverTimestamp(); // Use server timestamp for history

      // Check and record changes for Capital
      if (newCapital != _initialCapital) {
        await historyCollection.add({
          'timestamp': timestamp,
          'field': 'capital',
          'old_value': _initialCapital,
          'new_value': newCapital,
        });
      }

      // Check and record changes for Emplois Crees
      if (newEmploisCrees != _initialEmploisCrees) {
        await historyCollection.add({
          'timestamp': timestamp,
          'field': 'emploisCrees', // Use field name consistent with Firestore
          'old_value': _initialEmploisCrees,
          'new_value': newEmploisCrees,
        });
      }

      // Check and record changes for Exportations
      if (newExportations != _initialExportations) {
        await historyCollection.add({
          'timestamp': timestamp,
          'field': 'exportations',
          'old_value': _initialExportations,
          'new_value': newExportations,
        });
      }
      // --- End History Tracking ---

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fiche entreprise enregistrée !")),
      );

      // Optionally navigate after successful save
      // Navigator.pop(context); // Example: go back to the previous page
    } catch (e) {
      print("Error saving entreprise data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'enregistrement: ${e.toString()}"),
        ),
      );
      // Handle save error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _gap() => const SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Show loading indicator on initial load
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Fiche entreprise")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Removed logo/photo section
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: "Nom de l'entreprise",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                _gap(),
                TextFormField(
                  controller: secteurController,
                  decoration: const InputDecoration(
                    labelText: "Secteur d'activité",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                _gap(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Statut : "),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("Actif"),
                      selected: isActif,
                      selectedColor: Colors.green.shade200,
                      onSelected: (selected) {
                        setState(() {
                          isActif = true;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Pas actif"),
                      selected: !isActif,
                      selectedColor: Colors.red.shade200,
                      onSelected: (selected) {
                        setState(() {
                          isActif = false;
                        });
                      },
                    ),
                  ],
                ),
                _gap(),
                TextFormField(
                  controller: capitalController,
                  decoration: const InputDecoration(
                    labelText: "Capital (XAF)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                _gap(),
                TextFormField(
                  controller: emploisCreesController,
                  decoration: const InputDecoration(
                    labelText: "Emplois créés",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                _gap(),
                TextFormField(
                  controller: exportationsController,
                  decoration: const InputDecoration(
                    labelText: "Exportations (XAF)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                _gap(),
                ListTile(
                  title: Text(
                    dateConvention == null
                        ? "Date de convention"
                        : "Date de convention : ${dateConvention!.day}/${dateConvention!.month}/${dateConvention!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                _gap(),
                const Text(
                  "Projets",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...projets.asMap().entries.map(
                  (entry) => ListTile(
                    title: Text(entry.value['nom']),
                    subtitle: Text("${entry.value['cout']} XAF"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeProjet(entry.key),
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter un projet"),
                  onPressed: _addProjet,
                ),
                _gap(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Enregistrer"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
