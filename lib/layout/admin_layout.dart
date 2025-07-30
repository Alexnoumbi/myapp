import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';
import '../widgets/top_nav.dart';
import '../widgets/responsive_widget.dart';
import '../constants/style.dart';

class AdminLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AdminLayout({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      drawer: ResponsiveWidget.isSmallScreen(context) ? const SideMenu() : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ResponsiveWidget.isLargeScreen(context))
              const Expanded(child: SideMenu()),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const TopNav(),
                    const SizedBox(height: 16), // Espacement ajusté
                    Text(
                      title,
                      style: AppStyles.headerStyle,
                    ),
                    const SizedBox(height: 20), // Espacement ajusté
                    Expanded( // Cela garantit que l'enfant prend l'espace disponible restant
                      child: child, // Le contenu de vos pages d'administration
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}