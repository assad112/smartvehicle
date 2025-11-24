import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Try to get user data from Firestore
        UserModel? userModel = await getUserData(result.user!.uid);
        
        // If user doesn't exist in Firestore, create it
        if (userModel == null) {
          userModel = UserModel(
            id: result.user!.uid,
            email: result.user!.email ?? email.trim(),
            name: result.user!.displayName ?? 'User',
            createdAt: DateTime.now(),
            isAdmin: false,
          );
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(result.user!.uid)
              .set(userModel.toMap());
        }
        
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getAuthErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name, bool isAdmin) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Create user document in Firestore
        UserModel userModel = UserModel(
          id: result.user!.uid,
          email: email.trim(),
          name: name.trim(),
          createdAt: DateTime.now(),
          isAdmin: isAdmin,
        );

        try {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(result.user!.uid)
              .set(userModel.toMap());
        } catch (firestoreError) {
          // If Firestore fails, delete the auth user
          await result.user!.delete();
          throw Exception('Error saving user data. Please try again.');
        }

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getAuthErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          return UserModel.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Error updating profile: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in');
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Error changing password: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Delete notifications on logout (as per requirements)
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection(AppConstants.notificationsCollection)
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      }

      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign-out error: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getAuthErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Password reset error: ${e.toString()}');
    }
  }

  // Get Arabic error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please log out and sign in again.';
      default:
        return 'An unexpected error occurred: $code';
    }
  }
}

