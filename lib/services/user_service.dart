import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection de référence
  CollectionReference get _users => _firestore.collection('users');

  // Créer un nouvel utilisateur
  Future<void> createUser({
    required String email,
    required String password,
    required String role,
    String? displayName,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le document utilisateur dans Firestore
      final user = UserModel(
        id: userCredential.user?.uid,
        email: email,
        displayName: displayName,
        role: role,
      );

      await _users.doc(userCredential.user?.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  // Récupérer tous les utilisateurs
  Stream<List<UserModel>> getAllUsers() {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _users.doc(userId).update({'role': newRole});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rôle: $e');
    }
  }

  // Désactiver/Activer un utilisateur
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _users.doc(userId).update({'isActive': isActive});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Récupérer le rôle de l'utilisateur courant
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _users.doc(user.uid).get();
      return (doc.data() as Map<String, dynamic>)['role'];
    }
    return null;
  }
}
