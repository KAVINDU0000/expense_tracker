import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth so the rest of the app never
/// talks to the Firebase SDK directly. Makes it easy to swap/mock
/// in tests and keeps error handling in one place.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    }
  }

  Future<String?> signInAsGuest() async {
    try {
      await _auth.signInAnonymously();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'configuration-not-found':
      case 'operation-not-allowed':
        return 'Sign-in is not enabled yet. Please contact the app owner.';
      case 'network-request-failed':
        return 'Could not connect. Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
