import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  String _selectedRole = 'Personnel Suivi';

  final List<String> roles = ['Administrateur', 'Personnel Suivi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulaire de création d'utilisateur
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créer un nouvel utilisateur',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Mot de passe',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom d\'affichage',
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Rôle',
                          ),
                          items: roles.map((String role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _createUser,
                          child: const Text('Créer l\'utilisateur'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Liste des utilisateurs
            Expanded(
              flex: 2,
              child: Card(
                child: StreamBuilder<List<UserModel>>(
                  stream: _userService.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erreur: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = snapshot.data!;

                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Liste des utilisateurs',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Nom')),
                            DataColumn(label: Text('Rôle')),
                            DataColumn(label: Text('Statut')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: users.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user.email)),
                                DataCell(Text(user.displayName ?? '-')),
                                DataCell(
                                  DropdownButton<String>(
                                    value: user.role,
                                    items: roles.map((String role) {
                                      return DropdownMenuItem(
                                        value: role,
                                        child: Text(role),
                                      );
                                    }).toList(),
                                    onChanged: (String? newRole) {
                                      if (newRole != null && user.id != null) {
                                        _userService.updateUserRole(
                                          user.id!,
                                          newRole,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                DataCell(
                                  Switch(
                                    value: user.isActive,
                                    onChanged: (bool value) {
                                      if (user.id != null) {
                                        _userService.toggleUserStatus(
                                          user.id!,
                                          value,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // TODO: Implémenter la modification
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _userService.createUser(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
          displayName: _displayNameController.text,
        );

        // Réinitialiser le formulaire
        _emailController.clear();
        _passwordController.clear();
        _displayNameController.clear();
        setState(() {
          _selectedRole = 'Personnel Suivi';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
}
