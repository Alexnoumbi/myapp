import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/auth_checker.dart'; // Nous allons créer ce fichier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthChecker(), // Nous utiliserons AuthChecker pour gérer l'affichage
    );
  }
}
