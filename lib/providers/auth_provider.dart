import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, signedIn, signedOut }

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _sub;

  AuthStatus status = AuthStatus.unknown;
  User? user;
  bool isSubmitting = false;

  AppAuthProvider() {
    _sub = _authService.authStateChanges.listen((u) {
      user = u;
      status = u == null ? AuthStatus.signedOut : AuthStatus.signedIn;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    isSubmitting = true;
    notifyListeners();
    final error = await _authService.signIn(email, password);
    isSubmitting = false;
    notifyListeners();
    return error;
  }

  Future<String?> signUp(String email, String password) async {
    isSubmitting = true;
    notifyListeners();
    final error = await _authService.signUp(email, password);
    isSubmitting = false;
    notifyListeners();
    return error;
  }

  Future<String?> signInAsGuest() async {
    isSubmitting = true;
    notifyListeners();
    final error = await _authService.signInAsGuest();
    isSubmitting = false;
    notifyListeners();
    return error;
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
