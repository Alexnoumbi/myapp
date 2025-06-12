import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Après la déconnexion, AuthChecker redirigera automatiquement vers LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth
            .instance
            .currentUser; // Obtenez l'utilisateur actuellement connecté

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue !', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            if (user !=
                null) // Affichez l'email de l'utilisateur s'il est disponible
              Text('Connecté en tant que : ${user.email}'),
          ],
        ),
      ),
    );
  }
}
