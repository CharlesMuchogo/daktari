import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  AuthenticationService(this._auth);

  Stream<User?> get authstateChanges => _auth.authStateChanges();
  User? get userid => _auth.currentUser;

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'Sign in successful';
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    }
  }

  Future<String> signUp(
      {required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return 'Sign up successful';
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    }
  }

  static bool _googleInitialized = false;

  static Future<GoogleSignIn> _googleSignIn() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
    return GoogleSignIn.instance;
  }

  /// Signs in with Google and returns the Firebase user, or null if the user
  /// dismissed the account picker. Throws [FirebaseAuthException] or
  /// [GoogleSignInException] on failure.
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final result = await _auth.signInWithPopup(GoogleAuthProvider());
      return result.user;
    }

    final googleSignIn = await _googleSignIn();

    final GoogleSignInAccount account;
    try {
      account = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await (await _googleSignIn()).signOut();
    }
    await _auth.signOut();
  }
}
