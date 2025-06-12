import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Si l'inscription réussit, AuthChecker redirigera automatiquement
      Navigator.pop(context); // Retourne à l'écran précédent (connexion)
    } on FirebaseAuthException catch (e) {
      // Gérez les erreurs d'inscription (par exemple, email déjà utilisé, mot de passe faible)
      String message;
      if (e.code == 'weak-password') {
        message = 'Le mot de passe fourni est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Un compte existe déjà pour cet email.';
      } else {
        message = 'Erreur d\'inscription : ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: Text('S\'inscrire'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Retourne à l'écran de connexion
              },
              child: Text('Déjà un compte ? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
