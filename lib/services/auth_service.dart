import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Sign up with email and password
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String program,
    required int level,
    required String phoneNumber,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(name);
      
      // Create user document in Firestore
      final appUser = AppUser(
        uid: result.user!.uid,
        email: email,
        name: name,
        studentId: studentId,
        program: program,
        level: level,
        phoneNumber: phoneNumber,
      );
      
      await _firestore.collection('users').doc(result.user!.uid).set(appUser.toMap());
      
      return appUser;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user data
  Future<void> updateUserData(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Delete user account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }
}