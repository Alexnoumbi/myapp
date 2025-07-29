import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// Import your models
import '../models.dart'; // Correction de l'import du modèle Entreprise
import '../services/entreprise_service.dart'; // Assuming EntrepriseService is in this path
import 'package:myapp/widgets/responsive_widget.dart';

class EditEntreprisePage extends StatefulWidget {
  final Entreprise? entreprise;
  const EditEntreprisePage({super.key, this.entreprise});
  @override
  State<EditEntreprisePage> createState() => _EditEntreprisePageState();
}

class _EditEntreprisePageState extends State<EditEntreprisePage> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final secteurController = TextEditingController();
  final emailController = TextEditingController();
  final adresseController = TextEditingController();
  final contactController = TextEditingController();
  final capitalController = TextEditingController();
  final emploisCreesController = TextEditingController();
  final emploisPrevusController = TextEditingController();
  final exportationsController = TextEditingController();
  final investissementsPrevusController = TextEditingController();
  final investissementsRealisesController = TextEditingController();
  final regionController = TextEditingController();
  final villeController = TextEditingController();
  final correspondantController = TextEditingController();
  final telController = TextEditingController();
  final numContribuableController = TextEditingController();
  final repereController = TextEditingController();
  final activitePrincipaleController = TextEditingController();
  final chiffreAffairesDernierController = TextEditingController();
  bool isActif = true;
  DateTime? dateConvention;
  DateTime? dateCreation;
  int? sexeDirigeant;
  int? typeEntreprise;
  int? secteurActivite;
  int? sousSecteur;
  int? formeJuridique;
  int? diplomeDirigeant;
  String? conventionPdfUrl;
  List<Map<String, dynamic>> projets = [];
  List<Map<String, dynamic>> historique = [];
  List<String> documentsUrls = [];
  List<Map<String, dynamic>> indicateurs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entreprise;
    if (e != null) {
      nomController.text = e.nom;
      secteurController.text = e.secteur;
      emailController.text = e.email ?? '';
      adresseController.text = e.adresse ?? '';
      contactController.text = e.contact ?? '';
      capitalController.text = e.capital.toString();
      emploisCreesController.text = e.emploisCrees.toString();
      emploisPrevusController.text = e.emploisPrevus.toString();
      exportationsController.text = e.exportations.toString();
      investissementsPrevusController.text = e.investissementsPrevus.toString();
      investissementsRealisesController.text = e.investissementsRealises.toString();
      regionController.text = e.region ?? '';
      villeController.text = e.ville ?? '';
      correspondantController.text = e.correspondant ?? '';
      telController.text = e.tel ?? '';
      numContribuableController.text = e.numContribuable ?? '';
      repereController.text = e.repere ?? '';
      activitePrincipaleController.text = e.activitePrincipale ?? '';
      chiffreAffairesDernierController.text = e.chiffreAffairesDernier?.toString() ?? '';
      isActif = e.statut == 'Actif';
      dateConvention = e.dateConvention;
      dateCreation = e.dateCreation;
      sexeDirigeant = e.sexeDirigeant;
      typeEntreprise = e.typeEntreprise;
      secteurActivite = e.secteurActivite;
      sousSecteur = e.sousSecteur;
      formeJuridique = e.formeJuridique;
      diplomeDirigeant = e.diplomeDirigeant;
      conventionPdfUrl = e.conventionPdfUrl;
      projets = e.projets.map((p) => p.toMap()).toList();
      documentsUrls = e.documentsUrls;
      indicateurs = e.indicateurs.map((i) => i.toMap()).toList();
    }
  }

  Future<void> _pickDateConvention() async {
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

  Future<void> _pickDateCreation() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateCreation ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateCreation = picked;
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
    setState(() => _isLoading = true);
    try {
      final entreprise = Entreprise(
        id: widget.entreprise?.id,
        nom: nomController.text.trim(),
        secteur: secteurController.text.trim(),
        email: emailController.text.trim(),
        statut: isActif ? 'Actif' : 'Pas actif',
        adresse: adresseController.text.trim(),
        contact: contactController.text.trim(),
        dateConvention: dateConvention,
        capital: double.tryParse(capitalController.text) ?? 0.0,
        emploisCrees: int.tryParse(emploisCreesController.text) ?? 0,
        emploisPrevus: int.tryParse(emploisPrevusController.text) ?? 0,
        exportations: double.tryParse(exportationsController.text) ?? 0.0,
        investissementsPrevus: double.tryParse(investissementsPrevusController.text) ?? 0.0,
        investissementsRealises: double.tryParse(investissementsRealisesController.text) ?? 0.0,
        projets: projets.map((p) => Projet.fromMap(p)).toList(),
        documentsUrls: documentsUrls,
        indicateurs: indicateurs.map((i) => IndicateurPerformance.fromMap(i)).toList(),
        conventionPdfUrl: conventionPdfUrl,
        updatedAt: DateTime.now(),
        region: regionController.text.trim(),
        ville: villeController.text.trim(),
        correspondant: correspondantController.text.trim(),
        dateCreation: dateCreation,
        sexeDirigeant: sexeDirigeant,
        tel: telController.text.trim(),
        numContribuable: numContribuableController.text.trim(),
        repere: repereController.text.trim(),
        typeEntreprise: typeEntreprise,
        secteurActivite: secteurActivite,
        sousSecteur: sousSecteur,
        formeJuridique: formeJuridique,
        activitePrincipale: activitePrincipaleController.text.trim(),
        chiffreAffairesDernier: double.tryParse(chiffreAffairesDernierController.text),
        diplomeDirigeant: diplomeDirigeant,
        suivisConjoncturels: [], // à gérer dans la vue détail
      );
      if (widget.entreprise == null) {
        await EntrepriseService().createEntreprise(entreprise);
      } else {
        await EntrepriseService().updateEntreprise(entreprise);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.entreprise == null ? "Entreprise créée !" : "Entreprise mise à jour !")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _gap() => const SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Éditer Entreprise'),
        ),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: nomController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: secteurController,
                        decoration: const InputDecoration(labelText: 'Secteur d\'activité'),
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: adresseController,
                        decoration: const InputDecoration(labelText: 'Adresse'),
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: contactController,
                        decoration: const InputDecoration(labelText: 'Contact (email/téléphone)'),
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
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
                        decoration: const InputDecoration(labelText: 'Capital (XAF)'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: emploisCreesController,
                        decoration: const InputDecoration(labelText: 'Emplois créés'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: exportationsController,
                        decoration: const InputDecoration(labelText: 'Exportations (XAF)'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                      ),
                      _gap(),
                      TextFormField(
                        controller: investissementsPrevusController,
                        decoration: const InputDecoration(labelText: 'Investissement prévu (XAF)'),
                        keyboardType: TextInputType.number,
                      ),
                      _gap(),
                      TextFormField(
                        controller: investissementsRealisesController,
                        decoration: const InputDecoration(labelText: 'Investissement réalisé (XAF)'),
                        keyboardType: TextInputType.number,
                      ),
                      _gap(),
                      TextFormField(
                        controller: emploisPrevusController,
                        decoration: const InputDecoration(labelText: 'Nombre d\'employés prévus'),
                        keyboardType: TextInputType.number,
                      ),
                      _gap(),
                      ListTile(
                        title: Text(
                          dateConvention == null
                              ? "Date de convention"
                              : "Date de convention : ${dateConvention!.day}/${dateConvention!.month}/${dateConvention!.year}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDateConvention,
                      ),
                      _gap(),
                      TextFormField(
                        controller: regionController,
                        decoration: const InputDecoration(labelText: 'Région'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: villeController,
                        decoration: const InputDecoration(labelText: 'Ville'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: correspondantController,
                        decoration: const InputDecoration(labelText: 'Correspondant'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: telController,
                        decoration: const InputDecoration(labelText: 'Téléphone'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: numContribuableController,
                        decoration: const InputDecoration(labelText: 'Numéro de contribuable'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: repereController,
                        decoration: const InputDecoration(labelText: 'Repère'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: activitePrincipaleController,
                        decoration: const InputDecoration(labelText: 'Activité principale'),
                      ),
                      _gap(),
                      TextFormField(
                        controller: chiffreAffairesDernierController,
                        decoration: const InputDecoration(labelText: 'Chiffre d\'affaires dernier exercice (XAF)'),
                        keyboardType: TextInputType.number,
                      ),
                      _gap(),
                      DropdownButtonFormField<int>(
                        value: diplomeDirigeant,
                        decoration: const InputDecoration(
                          labelText: "Diplôme du dirigeant",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Aucun")),
                          DropdownMenuItem(value: 2, child: Text("Bac")),
                          DropdownMenuItem(value: 3, child: Text("Licence")),
                          DropdownMenuItem(value: 4, child: Text("Master")),
                          DropdownMenuItem(value: 5, child: Text("Doctorat")),
                        ],
                        onChanged: (v) => setState(() => diplomeDirigeant = v),
                      ),
                      _gap(),
                      DropdownButtonFormField<int>(
                        value: typeEntreprise,
                        decoration: const InputDecoration(
                          labelText: "Type d'entreprise",
                          prefixIcon: Icon(Icons.business_center),
                          filled: true,
                          fillColor: Color(0xFFF5FCF9),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("ME/MI")),
                          DropdownMenuItem(value: 2, child: Text("PME")),
                          DropdownMenuItem(value: 3, child: Text("TPM")),
                        ],
                        onChanged: (v) => setState(() => typeEntreprise = v),
                      ),
                      _gap(),
                      DropdownButtonFormField<int>(
                        value: secteurActivite,
                        decoration: const InputDecoration(
                          labelText: "Secteur d'activité",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Primaire")),
                          DropdownMenuItem(value: 2, child: Text("Secondaire")),
                          DropdownMenuItem(value: 3, child: Text("Tertiaire")),
                        ],
                        onChanged: (v) => setState(() => secteurActivite = v),
                      ),
                      _gap(),
                      DropdownButtonFormField<int>(
                        value: sousSecteur,
                        decoration: const InputDecoration(
                          labelText: "Sous-secteur",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Sous-secteur 1")),
                          DropdownMenuItem(value: 2, child: Text("Sous-secteur 2")),
                          DropdownMenuItem(value: 3, child: Text("Sous-secteur 3")),
                        ],
                        onChanged: (v) => setState(() => sousSecteur = v),
                      ),
                      _gap(),
                      DropdownButtonFormField<int>(
                        value: formeJuridique,
                        decoration: const InputDecoration(
                          labelText: "Forme juridique",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("SARL")),
                          DropdownMenuItem(value: 2, child: Text("SA")),
                          DropdownMenuItem(value: 3, child: Text("SNC")),
                          DropdownMenuItem(value: 4, child: Text("Autre")),
                        ],
                        onChanged: (v) => setState(() => formeJuridique = v),
                      ),
                      _gap(),
                      DropdownButtonFormField<int>(
                        value: sexeDirigeant,
                        decoration: const InputDecoration(
                          labelText: "Sexe du dirigeant",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Masculin")),
                          DropdownMenuItem(value: 2, child: Text("Féminin")),
                        ],
                        onChanged: (v) => setState(() => sexeDirigeant = v),
                      ),
                      _gap(),
                      ListTile(
                        title: Text(
                          dateCreation == null
                              ? "Date de création"
                              : "Date de création : ${dateCreation!.day}/${dateCreation!.month}/${dateCreation!.year}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDateCreation,
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
                      if (conventionPdfUrl != null)
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text("Convention signée"),
                          subtitle: const Text("Voir le PDF"),
                          onTap: () {
                            // Ouvre le PDF dans un navigateur ou un viewer
                          },
                        ),
                      _gap(),
                      if (historique.isNotEmpty)
                        ExpansionTile(
                          title: const Text("Historique des modifications"),
                          children: historique.map((h) {
                            String dateStr = '';
                            if (h['timestamp'] != null && h['timestamp'] is Timestamp) {
                              final dt = (h['timestamp'] as Timestamp).toDate();
                              dateStr = '${dt.day}/${dt.month}/${dt.year}';
                            }
                            return ListTile(
                              title: Text("${h['field']}"),
                              subtitle: Text(
                                "Ancien: ${h['old_value']} → Nouveau: ${h['new_value']}${dateStr.isNotEmpty ? " ($dateStr)" : ""}",
                              ),
                            );
                          }).toList(),
                        ),
                      _gap(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF00BF6D),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.save, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _isLoading ? "Enregistrement..." : "Enregistrer",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      mediumScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Éditer Entreprise'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: secteurController,
                  decoration: const InputDecoration(labelText: 'Secteur d\'activité'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact (email/téléphone)'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
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
                  decoration: const InputDecoration(labelText: 'Capital (XAF)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: emploisCreesController,
                  decoration: const InputDecoration(labelText: 'Emplois créés'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: exportationsController,
                  decoration: const InputDecoration(labelText: 'Exportations (XAF)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: investissementsPrevusController,
                  decoration: const InputDecoration(labelText: 'Investissement prévu (XAF)'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                TextFormField(
                  controller: investissementsRealisesController,
                  decoration: const InputDecoration(labelText: 'Investissement réalisé (XAF)'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                TextFormField(
                  controller: emploisPrevusController,
                  decoration: const InputDecoration(labelText: 'Nombre d\'employés prévus'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                ListTile(
                  title: Text(
                    dateConvention == null
                        ? "Date de convention"
                        : "Date de convention : ${dateConvention!.day}/${dateConvention!.month}/${dateConvention!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateConvention,
                ),
                _gap(),
                TextFormField(
                  controller: regionController,
                  decoration: const InputDecoration(labelText: 'Région'),
                ),
                _gap(),
                TextFormField(
                  controller: villeController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
                _gap(),
                TextFormField(
                  controller: correspondantController,
                  decoration: const InputDecoration(labelText: 'Correspondant'),
                ),
                _gap(),
                TextFormField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                _gap(),
                TextFormField(
                  controller: numContribuableController,
                  decoration: const InputDecoration(labelText: 'Numéro de contribuable'),
                ),
                _gap(),
                TextFormField(
                  controller: repereController,
                  decoration: const InputDecoration(labelText: 'Repère'),
                ),
                _gap(),
                TextFormField(
                  controller: activitePrincipaleController,
                  decoration: const InputDecoration(labelText: 'Activité principale'),
                ),
                _gap(),
                TextFormField(
                  controller: chiffreAffairesDernierController,
                  decoration: const InputDecoration(labelText: 'Chiffre d\'affaires dernier exercice (XAF)'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: diplomeDirigeant,
                  decoration: const InputDecoration(
                    labelText: "Diplôme du dirigeant",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Aucun")),
                    DropdownMenuItem(value: 2, child: Text("Bac")),
                    DropdownMenuItem(value: 3, child: Text("Licence")),
                    DropdownMenuItem(value: 4, child: Text("Master")),
                    DropdownMenuItem(value: 5, child: Text("Doctorat")),
                  ],
                  onChanged: (v) => setState(() => diplomeDirigeant = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: typeEntreprise,
                  decoration: const InputDecoration(
                    labelText: "Type d'entreprise",
                    prefixIcon: Icon(Icons.business_center),
                    filled: true,
                    fillColor: Color(0xFFF5FCF9),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("ME/MI")),
                    DropdownMenuItem(value: 2, child: Text("PME")),
                    DropdownMenuItem(value: 3, child: Text("TPM")),
                  ],
                  onChanged: (v) => setState(() => typeEntreprise = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: secteurActivite,
                  decoration: const InputDecoration(
                    labelText: "Secteur d'activité",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Primaire")),
                    DropdownMenuItem(value: 2, child: Text("Secondaire")),
                    DropdownMenuItem(value: 3, child: Text("Tertiaire")),
                  ],
                  onChanged: (v) => setState(() => secteurActivite = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: sousSecteur,
                  decoration: const InputDecoration(
                    labelText: "Sous-secteur",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Sous-secteur 1")),
                    DropdownMenuItem(value: 2, child: Text("Sous-secteur 2")),
                    DropdownMenuItem(value: 3, child: Text("Sous-secteur 3")),
                  ],
                  onChanged: (v) => setState(() => sousSecteur = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: formeJuridique,
                  decoration: const InputDecoration(
                    labelText: "Forme juridique",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("SARL")),
                    DropdownMenuItem(value: 2, child: Text("SA")),
                    DropdownMenuItem(value: 3, child: Text("SNC")),
                    DropdownMenuItem(value: 4, child: Text("Autre")),
                  ],
                  onChanged: (v) => setState(() => formeJuridique = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: sexeDirigeant,
                  decoration: const InputDecoration(
                    labelText: "Sexe du dirigeant",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Masculin")),
                    DropdownMenuItem(value: 2, child: Text("Féminin")),
                  ],
                  onChanged: (v) => setState(() => sexeDirigeant = v),
                ),
                _gap(),
                ListTile(
                  title: Text(
                    dateCreation == null
                        ? "Date de création"
                        : "Date de création : ${dateCreation!.day}/${dateCreation!.month}/${dateCreation!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateCreation,
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
                if (conventionPdfUrl != null)
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: const Text("Convention signée"),
                    subtitle: const Text("Voir le PDF"),
                    onTap: () {
                      // Ouvre le PDF dans un navigateur ou un viewer
                    },
                  ),
                _gap(),
                if (historique.isNotEmpty)
                  ExpansionTile(
                    title: const Text("Historique des modifications"),
                    children: historique.map((h) {
                      String dateStr = '';
                      if (h['timestamp'] != null && h['timestamp'] is Timestamp) {
                        final dt = (h['timestamp'] as Timestamp).toDate();
                        dateStr = '${dt.day}/${dt.month}/${dt.year}';
                      }
                      return ListTile(
                        title: Text("${h['field']}"),
                        subtitle: Text(
                          "Ancien: ${h['old_value']} → Nouveau: ${h['new_value']}${dateStr.isNotEmpty ? " ($dateStr)" : ""}",
                        ),
                      );
                    }).toList(),
                  ),
                _gap(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF00BF6D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isLoading ? "Enregistrement..." : "Enregistrer",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      smallScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Éditer Entreprise'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: secteurController,
                  decoration: const InputDecoration(labelText: 'Secteur d\'activité'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact (email/téléphone)'),
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
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
                  decoration: const InputDecoration(labelText: 'Capital (XAF)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: emploisCreesController,
                  decoration: const InputDecoration(labelText: 'Emplois créés'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: exportationsController,
                  decoration: const InputDecoration(labelText: 'Exportations (XAF)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Obligatoire' : null,
                ),
                _gap(),
                TextFormField(
                  controller: investissementsPrevusController,
                  decoration: const InputDecoration(labelText: 'Investissement prévu (XAF)'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                TextFormField(
                  controller: investissementsRealisesController,
                  decoration: const InputDecoration(labelText: 'Investissement réalisé (XAF)'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                TextFormField(
                  controller: emploisPrevusController,
                  decoration: const InputDecoration(labelText: 'Nombre d\'employés prévus'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                ListTile(
                  title: Text(
                    dateConvention == null
                        ? "Date de convention"
                        : "Date de convention : ${dateConvention!.day}/${dateConvention!.month}/${dateConvention!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateConvention,
                ),
                _gap(),
                TextFormField(
                  controller: regionController,
                  decoration: const InputDecoration(labelText: 'Région'),
                ),
                _gap(),
                TextFormField(
                  controller: villeController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
                _gap(),
                TextFormField(
                  controller: correspondantController,
                  decoration: const InputDecoration(labelText: 'Correspondant'),
                ),
                _gap(),
                TextFormField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                _gap(),
                TextFormField(
                  controller: numContribuableController,
                  decoration: const InputDecoration(labelText: 'Numéro de contribuable'),
                ),
                _gap(),
                TextFormField(
                  controller: repereController,
                  decoration: const InputDecoration(labelText: 'Repère'),
                ),
                _gap(),
                TextFormField(
                  controller: activitePrincipaleController,
                  decoration: const InputDecoration(labelText: 'Activité principale'),
                ),
                _gap(),
                TextFormField(
                  controller: chiffreAffairesDernierController,
                  decoration: const InputDecoration(labelText: 'Chiffre d\'affaires dernier exercice (XAF)'),
                  keyboardType: TextInputType.number,
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: diplomeDirigeant,
                  decoration: const InputDecoration(
                    labelText: "Diplôme du dirigeant",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Aucun")),
                    DropdownMenuItem(value: 2, child: Text("Bac")),
                    DropdownMenuItem(value: 3, child: Text("Licence")),
                    DropdownMenuItem(value: 4, child: Text("Master")),
                    DropdownMenuItem(value: 5, child: Text("Doctorat")),
                  ],
                  onChanged: (v) => setState(() => diplomeDirigeant = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: typeEntreprise,
                  decoration: const InputDecoration(
                    labelText: "Type d'entreprise",
                    prefixIcon: Icon(Icons.business_center),
                    filled: true,
                    fillColor: Color(0xFFF5FCF9),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("ME/MI")),
                    DropdownMenuItem(value: 2, child: Text("PME")),
                    DropdownMenuItem(value: 3, child: Text("TPM")),
                  ],
                  onChanged: (v) => setState(() => typeEntreprise = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: secteurActivite,
                  decoration: const InputDecoration(
                    labelText: "Secteur d'activité",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Primaire")),
                    DropdownMenuItem(value: 2, child: Text("Secondaire")),
                    DropdownMenuItem(value: 3, child: Text("Tertiaire")),
                  ],
                  onChanged: (v) => setState(() => secteurActivite = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: sousSecteur,
                  decoration: const InputDecoration(
                    labelText: "Sous-secteur",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Sous-secteur 1")),
                    DropdownMenuItem(value: 2, child: Text("Sous-secteur 2")),
                    DropdownMenuItem(value: 3, child: Text("Sous-secteur 3")),
                  ],
                  onChanged: (v) => setState(() => sousSecteur = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: formeJuridique,
                  decoration: const InputDecoration(
                    labelText: "Forme juridique",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("SARL")),
                    DropdownMenuItem(value: 2, child: Text("SA")),
                    DropdownMenuItem(value: 3, child: Text("SNC")),
                    DropdownMenuItem(value: 4, child: Text("Autre")),
                  ],
                  onChanged: (v) => setState(() => formeJuridique = v),
                ),
                _gap(),
                DropdownButtonFormField<int>(
                  value: sexeDirigeant,
                  decoration: const InputDecoration(
                    labelText: "Sexe du dirigeant",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Masculin")),
                    DropdownMenuItem(value: 2, child: Text("Féminin")),
                  ],
                  onChanged: (v) => setState(() => sexeDirigeant = v),
                ),
                _gap(),
                ListTile(
                  title: Text(
                    dateCreation == null
                        ? "Date de création"
                        : "Date de création : ${dateCreation!.day}/${dateCreation!.month}/${dateCreation!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateCreation,
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
                if (conventionPdfUrl != null)
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: const Text("Convention signée"),
                    subtitle: const Text("Voir le PDF"),
                    onTap: () {
                      // Ouvre le PDF dans un navigateur ou un viewer
                    },
                  ),
                _gap(),
                if (historique.isNotEmpty)
                  ExpansionTile(
                    title: const Text("Historique des modifications"),
                    children: historique.map((h) {
                      String dateStr = '';
                      if (h['timestamp'] != null && h['timestamp'] is Timestamp) {
                        final dt = (h['timestamp'] as Timestamp).toDate();
                        dateStr = '${dt.day}/${dt.month}/${dt.year}';
                      }
                      return ListTile(
                        title: Text("${h['field']}"),
                        subtitle: Text(
                          "Ancien: ${h['old_value']} → Nouveau: ${h['new_value']}${dateStr.isNotEmpty ? " ($dateStr)" : ""}",
                        ),
                      );
                    }).toList(),
                  ),
                _gap(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF00BF6D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isLoading ? "Enregistrement..." : "Enregistrer",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
