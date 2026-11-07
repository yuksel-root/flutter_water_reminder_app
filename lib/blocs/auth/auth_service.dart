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

  Future<AuthConnectionResult?> connectGoogle() async {
    final auth = _firebaseAuth;
    final provider = GoogleAuthProvider();
    final currentUser = auth.currentUser;

    if (kIsWeb) {
      return _connectGoogleWithPopupOrRedirect(auth, provider, currentUser);
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

  Future<AuthConnectionResult?> _connectGoogleWithPopupOrRedirect(
    FirebaseAuth auth,
    GoogleAuthProvider provider,
    User? currentUser,
  ) async {
    try {
      return await _connectGoogleWithPopup(auth, provider, currentUser);
    } on FirebaseAuthException catch (error) {
      if (!_shouldRetryWithRedirect(error)) rethrow;
    }

    return _connectGoogleWithRedirect(auth, provider, auth.currentUser);
  }

  Future<AuthConnectionResult?> _connectGoogleWithPopup(
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

  bool _shouldRetryWithRedirect(FirebaseAuthException error) {
    final message = error.message?.toLowerCase() ?? '';
    if (message.contains('missing initial state') ||
        message.contains('sessionstorage') ||
        message.contains('cross-origin-opener-policy')) {
      return true;
    }

    switch (error.code) {
      case 'popup-blocked':
      case 'operation-not-supported-in-this-environment':
      case 'web-storage-unsupported':
        return true;
      case 'internal-error':
        return true;
    }
    return false;
  }

  Future<AuthConnectionResult?> _connectGoogleWithRedirect(
    FirebaseAuth auth,
    GoogleAuthProvider provider,
    User? currentUser,
  ) async {
    if (currentUser == null) {
      await auth.signInWithRedirect(provider);
      return null;
    }

    if (!currentUser.isAnonymous) {
      return AuthConnectionResult(user: currentUser, linked: false);
    }

    await currentUser.linkWithRedirect(provider);
    return null;
  }

  User _requireUser(User? user) {
    if (user == null) {
      throw StateError('Authentication did not return a user.');
    }
    return user;
  }
}
