import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AllEntreprisesPage extends StatelessWidget {
  const AllEntreprisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toutes les entreprises')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('entreprises').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No companies found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final entreprise = snapshot.data!.docs[index];
              final data = entreprise.data() as Map<String, dynamic>;

              // Display company information here
              return ListTile(
                title: Text(data['nom'] ?? 'N/A'),
                subtitle: Text('Secteur: ${data['secteur'] ?? 'N/A'}'),
                // You can add more details here, like capital, status, etc.
                // onTap: () {
                //   // Optional: Navigate to a detail page for the company
                // },
              );
            },
          );
        },
      ),
    );
  }
}
