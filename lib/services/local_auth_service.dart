import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

/// Local authentication service - works without Firebase
/// Uses SharedPreferences to store user data locally
class LocalAuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'users';
  static const String _isLoggedInKey = 'is_logged_in';

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) return null;
      
      final List<dynamic> usersList = json.decode(usersJson);
      
      for (var userMap in usersList) {
        final user = UserModel.fromMap(userMap as Map<String, dynamic>);
        if (user.email == email.trim()) {
          // In real app, verify password hash
          // For now, just check if user exists
          await _setCurrentUser(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name, bool isAdmin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Check if user already exists
      for (var userMap in usersList) {
        final user = UserModel.fromMap(userMap as Map<String, dynamic>);
        if (user.email == email.trim()) {
          throw Exception('Email is already in use');
        }
      }
      
      // Create new user
      final userModel = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.trim(),
        name: name,
        createdAt: DateTime.now(),
        isAdmin: isAdmin,
      );
      
      usersList.add(userModel.toMap());
      await prefs.setString(_usersKey, json.encode(usersList));
      await _setCurrentUser(userModel);
      
      return userModel;
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) return null;
      
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromMap(userMap);
    } catch (e) {
      return null;
    }
  }

  // Get user data by ID
  Future<UserModel?> getUserData(String uid) async {
    return await getCurrentUser();
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      for (int i = 0; i < usersList.length; i++) {
        final userMap = usersList[i] as Map<String, dynamic>;
        if (userMap['id'] == user.id) {
          usersList[i] = user.toMap();
          break;
        }
      }
      
      await prefs.setString(_usersKey, json.encode(usersList));
      await _setCurrentUser(user);
    } catch (e) {
      throw Exception('Error updating profile: ${e.toString()}');
    }
  }

  // Change password (stored locally - not secure, for demo only)
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    // In real app, verify current password and hash new password
    // For demo, just accept the change
    print('Password changed (local storage)');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
      
      // Delete notifications on logout
      await prefs.remove('notifications');
    } catch (e) {
      throw Exception('Sign-out error: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // In real app, send reset email
    print('Password reset requested for: $email');
  }

  // Helper method
  Future<void> _setCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toMap()));
    await prefs.setBool(_isLoggedInKey, true);
  }
}

