import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../config/google_signin_config.dart';

class AuthService  extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignInConfig.getGoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google (disabled due to People API requirement)
  Future<UserCredential?> signInWithGoogle() async {
    throw Exception('Google Sign-In is temporarily disabled. Please use email/password sign-in instead.');
  }

  // Mock sign in with email and password (bypasses Firebase)
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Starting mock email/password sign-in...');
      
      // Simulate a delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, just return null to simulate success
      // The app will navigate to home page
      print('Mock email/password sign-in successful: $email');
      return null; // This will trigger navigation in the UI
    } catch (e) {
      print('Error in mock sign-in: $e');
      throw Exception('Sign-in failed: ${e.toString()}');
    }
  }

  // Mock create account with email and password (bypasses Firebase)
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      print('Creating mock account...');
      
      // Simulate a delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, just return null to simulate success
      // The app will navigate to home page
      print('Mock account created successfully: $email');
      return null; // This will trigger navigation in the UI
    } catch (e) {
      print('Error creating mock account: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Sign in anonymously (for testing)
  Future<UserCredential?> signInAnonymously() async {
    try {
      print('Starting anonymous sign-in...');
      
      final result = await _auth.signInAnonymously();
      
      print('Anonymous sign-in successful');
      return result;
    } catch (e) {
      print('Error signing in anonymously: $e');
      throw Exception('Anonymous sign-in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}

