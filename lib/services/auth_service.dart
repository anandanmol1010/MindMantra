import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);
        
        // Create user profile
        await _createUserProfileIfNotExists(user, displayName: displayName);
      }
      
      return user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      if (user != null) {
        // Ensure user profile exists
        await _createUserProfileIfNotExists(user);
      }
      
      return user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Create user profile if it doesn't exist
  Future<void> _createUserProfileIfNotExists(User user, {String? displayName}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('main')
          .get();

      if (!doc.exists) {
        UserProfile profile = UserProfile(
          uid: user.uid,
          displayName: displayName ?? user.displayName ?? 'User',
          createdAt: DateTime.now(),
          hasCompletedOnboarding: false,
          localOnlyMode: false,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(profile.toFirestore());

        // Initialize user stats
        // await _initializeUserStats(user.uid);
      }
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUser == null) return null;
      
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      if (currentUser == null) return;
      
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(profile.toFirestore());
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Initialize user stats (placeholder)
  Future<void> _initializeUserStats(String userId) async {
    // TODO: Initialize user stats in Firestore
    // This would create initial stats document
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
