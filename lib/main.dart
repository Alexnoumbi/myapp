import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import your firebase_options.dart file
import 'screens/auth_checker.dart'; // Import your AuthChecker widget
import 'screens/login_screen.dart'; // Import your LoginScreen
import 'screens/signup_page.dart'; // Import your SignUpPage
import 'screens/edit_entreprise_page.dart'; // Import your EditEntreprisePage
import 'screens/all_entreprises_page.dart'; // Import your AllEntreprisesPage
import 'screens/homepage/public_home_page.dart'; // Import your PublicHomePage
import 'screens/admin/admin_dashboard_page.dart';
import 'screens/admin/admin_entreprise_list_page.dart';
import 'screens/admin/admin_settings_page.dart';
import 'screens/admin/admin_reports_page.dart';
import 'screens/admin/admin_reports_kpi_page.dart';
import 'screens/admin/admin_reports_calendar_page.dart';
import 'screens/admin/admin_reports_export_page.dart';
import 'screens/performance_indicators_screen.dart';
import 'screens/admin/admin_stats_page.dart';
import 'screens/admin/user_management_screen.dart';  // Nouvel import
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData mobileTheme = ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Roboto',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
    final ThemeData webTheme = ThemeData(
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Montserrat',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
    return MaterialApp(
      title: 'Your App Title',
      theme: kIsWeb ? webTheme : mobileTheme,
      // Define your routes here
      routes: {
        '/': (context) => const AuthChecker(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpPage(),
        '/edit-entreprise': (context) => const EditEntreprisePage(),
        '/all-entreprises': (context) => const AllEntreprisesPage(),
        '/public-home': (context) => const PublicHomePage(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
        '/admin-entreprises': (context) => const AdminEntrepriseListPage(),
        '/settings': (context) => const AdminSettingsPage(),
        '/admin-reports': (context) => const AdminReportsPage(),
        '/admin-reports-kpi': (context) => const AdminReportsKpiPage(),
        '/admin-reports-calendar': (context) => const AdminReportsCalendarPage(),
        '/admin-reports-export': (context) => const AdminReportsExportPage(),
        '/performance-indicators': (context) => const PerformanceIndicatorsScreen(),
        '/user-management': (context) => const UserManagementScreen(),  // Nouvelle route
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
