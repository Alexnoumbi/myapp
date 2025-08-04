import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode or similar checks
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current Firebase User object
  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  // Get the role of the current user from Firestore
  Future<String?> getCurrentUserRole() async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          // Ensure 'role' field exists and is a String
          if (data.containsKey('role') && data['role'] is String) {
            return data['role'] as String?;
          } else {
            if (kDebugMode) {
              print(
                "User document for UID ${firebaseUser.uid} does not contain a valid 'role' field.",
              );
            }
            return null; // Or a default role, or throw an error
          }
        } else {
          if (kDebugMode) {
            print("User document not found for UID: ${firebaseUser.uid}");
          }
          return null; // User document doesn't exist
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user role for UID ${firebaseUser.uid}: $e");
        }
        return null; // Error occurred
      }
    } else {
      if (kDebugMode) {
        print("No Firebase user currently signed in.");
      }
      return null; // No user signed in
    }
  } // <- Closing brace for getCurrentUserRole method

  // Example: Get user profile data (you can expand this)
  Future<Map<String, dynamic>?> getUserProfile() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user profile: $e");
        }
        return null;
      }
    }
    return null;
  }

  // Example: Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
      // Optionally re-throw or handle more gracefully
    }
  }

  // Get all users as a stream
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user role: $e");
      }
      rethrow;
    }
  }

  // Toggle user status (active/inactive)
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling user status: $e");
      }
      rethrow;
    }
  }

  // Create a new user
  Future<void> createUser({
    required String email,
    required String password,
    required String role,
    String? displayName,
  }) async {
    try {
      // Create the user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create the user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
      rethrow;
    }
  }

  // You can add more user-related service methods here,
  // such as updating user profiles, managing preferences, etc.
} // <- Closing brace for UserService class
