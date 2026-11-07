import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthConnectionResult {
  const AuthConnectionResult({required this.user, required this.linked});

  final User user;
  final bool linked;
}

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  User? get currentUser {
    try {
      return _firebaseAuth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (_) {
      return Stream<User?>.empty();
    }
  }

  Future<AuthConnectionResult> connectGoogle() async {
    final auth = _firebaseAuth;
    final provider = GoogleAuthProvider();
    final currentUser = auth.currentUser;

    if (kIsWeb) {
      return _connectGoogleWithPopup(auth, provider, currentUser);
    }

    if (currentUser == null) {
      final result = await auth.signInWithProvider(provider);
      return AuthConnectionResult(
        user: _requireUser(result.user),
        linked: false,
      );
    }

    if (!currentUser.isAnonymous) {
      return AuthConnectionResult(user: currentUser, linked: false);
    }

    try {
      final result = await currentUser.linkWithProvider(provider);
      return AuthConnectionResult(
        user: _requireUser(result.user),
        linked: true,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'credential-already-in-use' ||
          error.code == 'email-already-in-use') {
        final result = await auth.signInWithProvider(provider);
        return AuthConnectionResult(
          user: _requireUser(result.user),
          linked: false,
        );
      }
      rethrow;
    }
  }

  Future<AuthConnectionResult> _connectGoogleWithPopup(
    FirebaseAuth auth,
    GoogleAuthProvider provider,
    User? currentUser,
  ) async {
    if (currentUser == null) {
      final result = await auth.signInWithPopup(provider);
      return AuthConnectionResult(
        user: _requireUser(result.user),
        linked: false,
      );
    }

    if (!currentUser.isAnonymous) {
      return AuthConnectionResult(user: currentUser, linked: false);
    }

    try {
      final result = await currentUser.linkWithPopup(provider);
      return AuthConnectionResult(
        user: _requireUser(result.user),
        linked: true,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'credential-already-in-use' ||
          error.code == 'email-already-in-use') {
        final result = await auth.signInWithPopup(provider);
        return AuthConnectionResult(
          user: _requireUser(result.user),
          linked: false,
        );
      }
      rethrow;
    }
  }

  User _requireUser(User? user) {
    if (user == null) {
      throw StateError('Authentication did not return a user.');
    }
    return user;
  }
}
