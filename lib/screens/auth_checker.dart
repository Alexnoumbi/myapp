import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Nous allons créer ces fichiers
import 'home_screen.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affichez un indicateur de chargement pendant la vérification de l'état
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // L'utilisateur est connecté, redirigez vers l'écran d'accueil
          return const HomeScreen();
        } else {
          // L'utilisateur n'est pas connecté, redirigez vers l'écran de connexion
          return const LoginScreen();
        }
      },
    );
  }
}
