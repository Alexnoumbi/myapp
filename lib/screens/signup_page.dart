import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // Inscription Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (credential.user != null) {
        // Ajout dans la table entreprises (using user.uid as document ID)
        await FirebaseFirestore.instance
            .collection('entreprises')
            .doc(credential.user!.uid)
            .set({
              'id': credential.user!.uid,
              'email': emailController.text.trim(),
              'nom': nomController.text.trim(),
              'role': 'admin', // Example field, adjust as needed
              'createdAt':
                  FieldValue.serverTimestamp(), // Add creation timestamp
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate directly to the EditEntreprisePage after successful sign-up
        Navigator.pushReplacementNamed(
          context,
          '/edit-entreprise',
        ); // MODIFIED LINE
      } else {
        // This case might not be reached with createUserWithEmailAndPassword
        throw Exception('Erreur lors de l\'inscription.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Un compte existe déjà avec cet email.';
      } else {
        message = 'Erreur Firebase Auth: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom entreprise',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? "Entrez le nom de l'entreprise"
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? "Entrez un email" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator:
                      (v) =>
                          v == null || v.length < 6
                              ? "Au moins 6 caractères"
                              : null,
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _signup,
                      child: const Text("S'inscrire"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
