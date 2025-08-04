import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin/admin_dashboard_page.dart';
import 'home_screen.dart';
import 'homepage/public_home_page.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Utilisateur connecté, vérifier son rôle
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError) {
                // En cas d'erreur, rediriger vers la page d'accueil publique
                return const PublicHomePage();
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'] ?? 'entreprise';
                final isActive = userData['isActive'] ?? true;

                // Vérifier si l'utilisateur est actif
                if (!isActive) {
                  // Utilisateur inactif, déconnecter et rediriger
                  FirebaseAuth.instance.signOut();
                  return const PublicHomePage();
                }

                // Rediriger selon le rôle
                if (userRole == 'admin') {
                  return const AdminDashboardPage();
                } else if (userRole == 'entreprise') {
                  return const HomeScreen();
                } else {
                  // Rôle inconnu, rediriger vers la page d'accueil publique
                  return const PublicHomePage();
                }
              } else {
                // Utilisateur connecté mais pas dans la base de données
                // Créer un document utilisateur par défaut avec le rôle 'entreprise'
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .set({
                      'email': snapshot.data!.email,
                      'role': 'entreprise',
                      'isActive': true,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                return const HomeScreen();
              }
            },
          );
        } else {
          // Utilisateur non connecté, rediriger vers la page d'accueil publique
          return const PublicHomePage();
        }
      },
    );
  }
}
