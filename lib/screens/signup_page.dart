import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  final bool isAdmin;
  const SignUpPage({super.key, this.isAdmin = false});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  final adresseController = TextEditingController();
  final contactController = TextEditingController();
  final investissementsPrevusController = TextEditingController();
  final investissementsRealisesController = TextEditingController();
  final emploisPrevusController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  bool _isSuperAdminSignup = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _isSuperAdminSignup = true;
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (credential.user != null) {
        final isAdmin = _isSuperAdminSignup || widget.isAdmin;
        final role = isAdmin ? 'admin' : 'entreprise';
        final data = {
          'id': credential.user!.uid,
          'email': emailController.text.trim(),
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        };
        if (!isAdmin) {
          data['nom'] = nomController.text.trim();
          data['adresse'] = adresseController.text.trim();
          data['contact'] = contactController.text.trim();
          data['investissementsPrevus'] =
              double.tryParse(investissementsPrevusController.text) ?? 0.0;
          data['investissementsRealises'] =
              double.tryParse(investissementsRealisesController.text) ?? 0.0;
          data['emploisPrevus'] =
              int.tryParse(emploisPrevusController.text) ?? 0;
        } else {
          data['nom'] = nomController.text.trim();
        }

        // Ajout dans la collection entreprises
        await FirebaseFirestore.instance
            .collection('entreprises')
            .doc(credential.user!.uid)
            .set(data);

        // Ajout dans la collection enregistres
        await FirebaseFirestore.instance.collection('enregistres').add({
          'userId': credential.user!.uid,
          'email': emailController.text.trim(),
          'role': role,
          'nom': nomController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          Navigator.pushReplacementNamed(context, '/edit-entreprise');
        }
      } else {
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

  void _switchSignupMode(bool isSuperAdmin) {
    setState(() {
      _isSuperAdminSignup = isSuperAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdminPage = widget.isAdmin || _isSuperAdminSignup;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth >= 768;
            double fieldWidth = isDesktop
                ? constraints.maxWidth * 0.5
                : double.infinity;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0084FA).withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/logo.png', height: 60),
                    ),
                    Text(
                      isAdminPage
                          ? 'Inscription Administrateur'
                          : 'Inscription Entreprise',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (!widget.isAdmin)
                      ToggleButtons(
                        isSelected: [
                          _isSuperAdminSignup == false,
                          _isSuperAdminSignup == true,
                        ],
                        onPressed: (index) => _switchSignupMode(index == 1),
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF0084FA),
                        color: Colors.black,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Entreprise'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Administrateur'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: nomController,
                                decoration: InputDecoration(
                                  labelText: isAdminPage
                                      ? 'Nom complet'
                                      : 'Nom entreprise',
                                  prefixIcon: Icon(
                                    isAdminPage ? Icons.person : Icons.business,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5FCF9),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? (isAdminPage
                                          ? "Entrez votre nom"
                                          : "Entrez le nom de l'entreprise")
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  filled: true,
                                  fillColor: Color(0xFFF5FCF9),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? "Entrez un email"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock),
                                  filled: true,
                                  fillColor: const Color(0xFFF5FCF9),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                      () => _showPassword = !_showPassword,
                                    ),
                                  ),
                                ),
                                validator: (v) => v == null || v.length < 6
                                    ? "Au moins 6 caractères"
                                    : null,
                              ),
                              if (!isAdminPage) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: adresseController,
                                  decoration: const InputDecoration(
                                    labelText: 'Adresse',
                                    prefixIcon: Icon(Icons.location_on),
                                    filled: true,
                                    fillColor: Color(0xFFF5FCF9),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: contactController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contact (email/téléphone)',
                                    prefixIcon: Icon(Icons.phone),
                                    filled: true,
                                    fillColor: Color(0xFFF5FCF9),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: investissementsPrevusController,
                                  decoration: const InputDecoration(
                                    labelText: 'Investissement prévu (XAF)',
                                    prefixIcon: Icon(Icons.trending_up),
                                    filled: true,
                                    fillColor: Color(0xFFF5FCF9),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: investissementsRealisesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Investissement réalisé (XAF)',
                                    prefixIcon: Icon(Icons.check_circle),
                                    filled: true,
                                    fillColor: Color(0xFFF5FCF9),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: emploisPrevusController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre d\'employés prévus',
                                    prefixIcon: Icon(Icons.people_outline),
                                    filled: true,
                                    fillColor: Color(0xFFF5FCF9),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                              const SizedBox(height: 24),
                              _loading
                                  ? const CircularProgressIndicator()
                                  : Container(
                                      alignment: Alignment.center,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: const Color(0xFF00BF6D),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 48),
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                        onPressed: _signup,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.app_registration, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              "S'inscrire",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Nouvelle page spécifique pour l'inscription d'un administrateur (personne)
class AdminSignUpPage extends StatelessWidget {
  const AdminSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignUpPage(isAdmin: true);
  }
}
