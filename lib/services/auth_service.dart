import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_auth_service.dart';

// Using Firebase Auth Service
class AuthService {
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email, password);
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name, bool isAdmin) async {
    return await _firebaseAuth.registerWithEmailAndPassword(email, password, name, isAdmin);
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    return await _firebaseAuth.getUserData(uid);
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    return await _firebaseAuth.updateUserProfile(user);
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    return await _firebaseAuth.changePassword(currentPassword, newPassword);
  }

  // Sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    return await _firebaseAuth.resetPassword(email);
  }
}

