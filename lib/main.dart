import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import your firebase_options.dart file
import 'screens/auth_checker.dart'; // Import your AuthChecker widget
import 'screens/login_screen.dart'; // Import your LoginScreen
import 'screens/signup_page.dart'; // Import your SignUpPage
import 'screens/edit_entreprise_page.dart'; // Import your EditEntreprisePage
import 'screens/all_entreprises_page.dart'; // Import your AllEntreprisesPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title', // Replace with your app title
      theme: ThemeData(
        primarySwatch: Colors.blue, // Replace with your desired theme
      ),
      // Define your routes here
      routes: {
        '/': (context) => const AuthChecker(), // Your initial route
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpPage(),
        '/edit-entreprise': (context) => const EditEntreprisePage(),
        '/all-entreprises': (context) => const AllEntreprisesPage(),
      },
      // You can also use onGenerateRoute for more dynamic routing
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/some-dynamic-route') {
      //     return MaterialPageRoute(builder: (context) => SomeDynamicPage());
      //   }
      //   return null; // Let the app handle it
      // },
    );
  }
}
