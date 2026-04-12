import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  
  AuthViewModel() {
    _listenToAuthChanges();
  }
  
  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }
  
  Future<void> _loadUserData(String uid) async {
    _currentUser = await _authService.getUserData(uid);
    notifyListeners();
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String program,
    required int level,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        studentId: studentId,
        program: program,
        level: level,
        phoneNumber: phoneNumber,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      return true;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
  
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    return 'An error occurred. Please try again.';
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}