import 'package:flutter/material.dart';
import '../../../constants/style.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 2),
              color: Colors.grey.withOpacity(.1),
              blurRadius: 4
          )
        ],
      ),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppStyles.mainLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 24,
                        color: AppStyles.mainColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "ADMIN",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildMenuItem(
                  title: "Dashboard",
                  icon: Icons.dashboard_outlined,
                  isActive: true, // Peut être ajusté dynamiquement
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/admin-dashboard'); // Correction ici
                  },
                ),
                _buildMenuItem(
                  title: "Entreprises",
                  icon: Icons.business_outlined,
                  onTap: () => Navigator.pushNamed(context, '/all-entreprises'),
                ),
                _buildMenuItem(
                  title: "Statistiques",
                  icon: Icons.analytics_outlined,
                  onTap: () => Navigator.pushNamed(context, '/stats'), // Assurez-vous que cela navigue vers la page des stats
                ),
                const Divider(
                  height: 30,
                  color: Colors.transparent,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    "GESTION",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildMenuItem(
                  title: "Paramètres",
                  icon: Icons.settings_outlined,
                  onTap: () {}, // Ajoutez la navigation si une page de paramètres existe
                ),
                _buildMenuItem(
                  title: "Profil",
                  icon: Icons.person_outline,
                  onTap: () {}, // Ajoutez la navigation si une page de profil existe
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  title: "Déconnexion",
                  icon: Icons.logout,
                  isLogout: true,
                  onTap: () async {
                    // Ajoutez ici la logique de déconnexion
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

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    bool isActive = false,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : isActive
            ? AppStyles.mainColor
            : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : isActive
              ? AppStyles.mainColor
              : Colors.grey[800],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: AppStyles.mainLightColor.withOpacity(0.1),
      selectedTileColor: AppStyles.mainLightColor.withOpacity(0.1),
      selected: isActive,
      onTap: onTap,
    );
  }
}
