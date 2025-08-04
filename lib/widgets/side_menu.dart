import 'package:flutter/material.dart';
import '../constants/style.dart';
import '../widgets/responsive_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    final isExtraSmallScreen = ResponsiveWidget.isExtraSmallScreen(context);

    return Container(
      width: isExtraSmallScreen ? double.infinity : 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isExtraSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: AppStyles.mainColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppStyles.mainColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isExtraSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: AppStyles.mainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.white,
                    size: isExtraSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isExtraSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isExtraSmallScreen ? 'Dashboard' : 'API Dashboard',
                        style: TextStyle(
                          fontSize: isExtraSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.mainColor,
                        ),
                      ),
                      if (!isExtraSmallScreen)
                        Text(
                          'Administration',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (isExtraSmallScreen)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.mainColor,
                      ),
                    ),
                  ),
                MenuItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  route: '/admin-dashboard',
                  isActive: _isCurrentRoute(context, '/admin-dashboard'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/admin-dashboard');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                MenuItem(
                  title: 'Entreprises',
                  icon: Icons.business_outlined,
                  route: '/all-entreprises',
                  isActive: _isCurrentRoute(context, '/all-entreprises'),
                  onTap: () {
                    Navigator.pushNamed(context, '/all-entreprises');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                MenuItem(
                  title: 'Ajouter Entreprise',
                  icon: Icons.add_business_outlined,
                  route: '/edit-entreprise',
                  isActive: _isCurrentRoute(context, '/edit-entreprise'),
                  onTap: () {
                    Navigator.pushNamed(context, '/edit-entreprise');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                MenuItem(
                  title: 'Indicateurs',
                  icon: Icons.analytics_outlined,
                  route: '/performance-indicators',
                  isActive: _isCurrentRoute(context, '/performance-indicators'),
                  onTap: () {
                    Navigator.pushNamed(context, '/performance-indicators');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                MenuItem(
                  title: 'Statistiques',
                  icon: Icons.bar_chart_outlined,
                  route: '/stats',
                  isActive: _isCurrentRoute(context, '/stats'),
                  onTap: () {
                    Navigator.pushNamed(context, '/stats');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                MenuItem(
                  title: 'Rapports',
                  icon: Icons.description_outlined,
                  route: '/admin-reports',
                  isActive: _isCurrentRoute(context, '/admin-reports'),
                  onTap: () {
                    Navigator.pushNamed(context, '/admin-reports');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(thickness: 1),
                ),
                MenuItem(
                  title: 'Utilisateurs',
                  icon: Icons.people_outlined,
                  route: '/user-management',
                  isActive: _isCurrentRoute(context, '/user-management'),
                  onTap: () {
                    Navigator.pushNamed(context, '/user-management');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
                MenuItem(
                  title: 'Paramètres',
                  icon: Icons.settings_outlined,
                  route: '/settings',
                  isActive: _isCurrentRoute(context, '/settings'),
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                    if (isSmallScreen) Navigator.pop(context);
                  },
                  isSmall: isExtraSmallScreen,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
            ),
            child: MenuItem(
              title: 'Déconnexion',
              icon: Icons.logout_outlined,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              showBackground: false,
              isSmall: isExtraSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentRoute(BuildContext context, String route) {
    return ModalRoute.of(context)?.settings.name == route;
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? route;
  final bool isActive;
  final VoidCallback? onTap;
  final bool showBackground;
  final bool isSmall;

  const MenuItem({
    Key? key,
    required this.title,
    required this.icon,
    this.route,
    this.isActive = false,
    this.onTap,
    this.showBackground = true,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap:
              onTap ??
              () {
                if (route != null) {
                  Navigator.pushNamed(context, route!);
                }
              },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : 12,
              vertical: isSmall ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isActive && showBackground
                  ? AppStyles.mainColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive && showBackground
                  ? Border.all(
                      color: AppStyles.mainColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppStyles.mainColor
                      : title == 'Déconnexion'
                      ? Colors.red[600]
                      : Colors.grey[600],
                  size: isSmall ? 20 : 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive
                          ? AppStyles.mainColor
                          : title == 'Déconnexion'
                          ? Colors.red[600]
                          : Colors.grey[800],
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: isSmall ? 13 : 14,
                    ),
                  ),
                ),
                if (isActive && !isSmall)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppStyles.mainColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
