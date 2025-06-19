import 'package:flutter/material.dart';
// Import Firestore

class ViewerEntreprisePage extends StatelessWidget {
  final String userId;

  const ViewerEntreprisePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vue entreprise')),
      body: Center(
        // This will be updated later to fetch and display data
        child: Text('Fetching data for user: $userId'),
      ),
    );
  }
}
