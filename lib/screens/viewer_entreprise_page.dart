import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:myapp/widgets/responsive_widget.dart';

class ViewerEntreprisePage extends StatelessWidget {
  final String userId;

  const ViewerEntreprisePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Fiche entreprise'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Exporter en PDF',
              onPressed: () async {
                final doc = pw.Document();
                final snapshot = await FirebaseFirestore.instance.collection('entreprises').doc(userId).get();
                final data = snapshot.data() ?? {};
                final suivis = List<Map<String, dynamic>>.from(data['suivisConjoncturels'] ?? []);
                final logoBytes = await rootBundle.load('assets/logo.png');
                final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
                doc.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Image(logo, width: 60),
                              pw.Text('Mon Organisation', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                            ],
                          ),
                          pw.Divider(),
                          pw.SizedBox(height: 8),
                          pw.Text('Fiche Entreprise', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                          pw.SizedBox(height: 12),
                          pw.Text('Nom : ${data['nom'] ?? ''}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Secteur : ${data['secteur'] ?? ''}'),
                          pw.Text('Adresse : ${data['adresse'] ?? ''}'),
                          pw.Text('Contact : ${data['contact'] ?? ''}'),
                          pw.Text('Statut : ${data['statut'] ?? ''}'),
                          pw.SizedBox(height: 12),
                          pw.Text('Suivis conjoncturels', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                          pw.Table.fromTextArray(
                            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
                            cellAlignment: pw.Alignment.centerLeft,
                            headers: ['Trimestre', 'Année', 'Commentaire'],
                            data: suivis.map((s) => [
                              s['trimestre']?.toString() ?? '',
                              s['annee']?.toString() ?? '',
                              s['commentaire'] ?? '',
                            ]).toList(),
                          ),
                          pw.Spacer(),
                          pw.Divider(),
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Édité le : ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                          ),
                        ],
                      );
                    },
                  ),
                );
                await Printing.layoutPdf(onLayout: (format) async => doc.save());
              },
            ),
          ],
        ),
        body: Row(
          children: [
            Expanded(
              child: Center(
                child: Text('Contenu principal pour desktop'), // Placeholder
              ),
            ),
          ],
        ),
      ),
      mediumScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Fiche entreprise'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Exporter en PDF',
              onPressed: () async {
                final doc = pw.Document();
                final snapshot = await FirebaseFirestore.instance.collection('entreprises').doc(userId).get();
                final data = snapshot.data() ?? {};
                final suivis = List<Map<String, dynamic>>.from(data['suivisConjoncturels'] ?? []);
                final logoBytes = await rootBundle.load('assets/logo.png');
                final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
                doc.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Image(logo, width: 60),
                              pw.Text('Mon Organisation', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                            ],
                          ),
                          pw.Divider(),
                          pw.SizedBox(height: 8),
                          pw.Text('Fiche Entreprise', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                          pw.SizedBox(height: 12),
                          pw.Text('Nom : ${data['nom'] ?? ''}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Secteur : ${data['secteur'] ?? ''}'),
                          pw.Text('Adresse : ${data['adresse'] ?? ''}'),
                          pw.Text('Contact : ${data['contact'] ?? ''}'),
                          pw.Text('Statut : ${data['statut'] ?? ''}'),
                          pw.SizedBox(height: 12),
                          pw.Text('Suivis conjoncturels', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                          pw.Table.fromTextArray(
                            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
                            cellAlignment: pw.Alignment.centerLeft,
                            headers: ['Trimestre', 'Année', 'Commentaire'],
                            data: suivis.map((s) => [
                              s['trimestre']?.toString() ?? '',
                              s['annee']?.toString() ?? '',
                              s['commentaire'] ?? '',
                            ]).toList(),
                          ),
                          pw.Spacer(),
                          pw.Divider(),
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Édité le : ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                          ),
                        ],
                      );
                    },
                  ),
                );
                await Printing.layoutPdf(onLayout: (format) async => doc.save());
              },
            ),
          ],
        ),
        body: Center(
          child: Text('Contenu principal pour tablette'), // Placeholder
        ),
      ),
      smallScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Fiche entreprise'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Exporter en PDF',
              onPressed: () async {
                final doc = pw.Document();
                final snapshot = await FirebaseFirestore.instance.collection('entreprises').doc(userId).get();
                final data = snapshot.data() ?? {};
                final suivis = List<Map<String, dynamic>>.from(data['suivisConjoncturels'] ?? []);
                final logoBytes = await rootBundle.load('assets/logo.png');
                final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
                doc.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Image(logo, width: 60),
                              pw.Text('Mon Organisation', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                            ],
                          ),
                          pw.Divider(),
                          pw.SizedBox(height: 8),
                          pw.Text('Fiche Entreprise', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                          pw.SizedBox(height: 12),
                          pw.Text('Nom : ${data['nom'] ?? ''}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Secteur : ${data['secteur'] ?? ''}'),
                          pw.Text('Adresse : ${data['adresse'] ?? ''}'),
                          pw.Text('Contact : ${data['contact'] ?? ''}'),
                          pw.Text('Statut : ${data['statut'] ?? ''}'),
                          pw.SizedBox(height: 12),
                          pw.Text('Suivis conjoncturels', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                          pw.Table.fromTextArray(
                            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
                            cellAlignment: pw.Alignment.centerLeft,
                            headers: ['Trimestre', 'Année', 'Commentaire'],
                            data: suivis.map((s) => [
                              s['trimestre']?.toString() ?? '',
                              s['annee']?.toString() ?? '',
                              s['commentaire'] ?? '',
                            ]).toList(),
                          ),
                          pw.Spacer(),
                          pw.Divider(),
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Édité le : ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                          ),
                        ],
                      );
                    },
                  ),
                );
                await Printing.layoutPdf(onLayout: (format) async => doc.save());
              },
            ),
          ],
        ),
        body: Center(
          child: Text('Contenu principal pour mobile'), // Placeholder
        ),
      ),
    );
  }
}

class SuiviConjonctureDialog extends StatefulWidget {
  final String userId;
  final int? index;
  final Map<String, dynamic>? initialData;
  const SuiviConjonctureDialog({super.key, required this.userId, this.index, this.initialData});
  @override
  State<SuiviConjonctureDialog> createState() => _SuiviConjonctureDialogState();
}

class _SuiviConjonctureDialogState extends State<SuiviConjonctureDialog> {
  final _formKey = GlobalKey<FormState>();
  final trimestreController = TextEditingController();
  final anneeController = TextEditingController();
  final commentaireController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      trimestreController.text = widget.initialData!['trimestre']?.toString() ?? '';
      anneeController.text = widget.initialData!['annee']?.toString() ?? '';
      commentaireController.text = widget.initialData!['commentaire'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.index == null ? "Ajouter un suivi" : "Éditer le suivi"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: trimestreController,
              decoration: const InputDecoration(labelText: "Trimestre (ex: 1, 2, 3, 4)"),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
            ),
            TextFormField(
              controller: anneeController,
              decoration: const InputDecoration(labelText: "Année"),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
            ),
            TextFormField(
              controller: commentaireController,
              decoration: const InputDecoration(labelText: "Commentaire"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final docRef = FirebaseFirestore.instance.collection('entreprises').doc(widget.userId);
            final snapshot = await docRef.get();
            final suivis = List<Map<String, dynamic>>.from((snapshot.data() as Map<String, dynamic>)['suivisConjoncturels'] ?? []);
            final newSuivi = {
              'trimestre': int.tryParse(trimestreController.text),
              'annee': int.tryParse(anneeController.text),
              'commentaire': commentaireController.text.trim(),
            };
            if (widget.index == null) {
              suivis.add(newSuivi);
            } else {
              suivis[widget.index!] = newSuivi;
            }
            await docRef.update({'suivisConjoncturels': suivis});
            Navigator.pop(context);
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
