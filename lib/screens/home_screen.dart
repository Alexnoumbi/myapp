import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/widgets/responsive_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Non connecté')));
    }

    final navItems = [
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      ListTile(
        leading: const Icon(Icons.business),
        title: const Text('Entreprises'),
        onTap: () => Navigator.pushReplacementNamed(context, '/all-entreprises'),
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Paramètres'),
        onTap: () => Navigator.pushReplacementNamed(context, '/admin-settings'),
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Déconnexion'),
        onTap: () => _logout(context),
      ),
    ];

    return ResponsiveWidget(
      largeScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Entreprise'),
        ),
        body: Row(
          children: [
            Container(
              width: 220,
              color: Colors.blueGrey.shade50,
              child: ListView(children: navItems),
            ),
            const Expanded(
              child: Center(child: Text('Contenu principal')), // Placeholder
            ),
          ],
        ),
      ),
      mediumScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Entreprise'),
        ),
        drawer: Drawer(child: ListView(children: navItems)),
        body: const Center(child: Text('Contenu principal')), // Placeholder
      ),
      smallScreen: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Entreprise'),
        ),
        drawer: Drawer(child: ListView(children: navItems)),
        body: const Center(child: Text('Contenu principal')), // Placeholder
      ),
    );
  }
}
