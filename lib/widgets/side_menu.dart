import 'package:flutter/material.dart';
import '../constants/style.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Largeur fixe pour le menu
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Image.asset('assets/images/logo.png', height: 40),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView(
              children: [
                _MenuItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  route: '/admin-dashboard',
                  isActive: true,
                ),
                _MenuItem(
                  title: 'Entreprises',
                  icon: Icons.business_outlined,
                  route: '/all-entreprises',
                ),
                _MenuItem(
                  title: 'Indicateurs',
                  icon: Icons.analytics_outlined,
                  route: '/performance-indicators',
                ),
                _MenuItem(
                  title: 'Statistiques',
                  icon: Icons.bar_chart_outlined,
                  route: '/stats',
                ),
                const Divider(thickness: 1),
                _MenuItem(
                  title: 'Paramètres',
                  icon: Icons.settings_outlined,
                  route: '/settings',
                ),
                _MenuItem(
                  title: 'Déconnexion',
                  icon: Icons.logout_outlined,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? route;
  final bool isActive;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppStyles.mainColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppStyles.mainColor : Colors.grey[800],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () {
        if (route != null && route != '/admin-dashboard') {
          Navigator.pushNamed(context, route!);
        }
      },
      selected: isActive,
      selectedTileColor: AppStyles.mainLightColor.withOpacity(0.1),
    );
  }
}
