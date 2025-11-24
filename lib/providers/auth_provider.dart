import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await loadUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadUserData(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.getUserData(uid);
      if (_currentUser == null) {
        // If user data doesn't exist, create it from Firebase Auth
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          _currentUser = await _authService.getUserData(firebaseUser.uid);
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      _errorMessage = null; // Don't show error for loading user data
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithEmailAndPassword(
          email, password);

      if (_currentUser != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      String errorMsg = e.toString();
      // Remove "Exception: " prefix if exists
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, bool isAdmin) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser =
          await _authService.registerWithEmailAndPassword(email, password, name, isAdmin);

      if (_currentUser != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      String errorMsg = e.toString();
      // Remove "Exception: " prefix if exists
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(UserModel user) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.updateUserProfile(user);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.changePassword(currentPassword, newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

