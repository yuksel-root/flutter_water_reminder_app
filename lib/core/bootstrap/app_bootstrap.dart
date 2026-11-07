import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_water_reminder_app/firebase_options.dart';

enum BootstrapStatus { loading, ready, offline }

class AppBootstrap {
  final ValueNotifier<BootstrapStatus> status = ValueNotifier(
    BootstrapStatus.loading,
  );

  Future<void>? _inFlight;
  User? _redirectUser;
  String? _redirectError;

  bool get isReady => status.value == BootstrapStatus.ready;

  bool get googleRedirectCompleted => _redirectUser != null;

  String? get redirectError => _redirectError;

  Future<void> initialize() {
    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _run();
    _inFlight = future;
    return future;
  }

  Future<void> retry() {
    if (isReady) return Future<void>.value();
    if (status.value == BootstrapStatus.loading && _inFlight != null) {
      return initialize();
    }

    _inFlight = null;
    status.value = BootstrapStatus.loading;
    return initialize();
  }

  Future<void> _run() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _configureFirestore();

      final auth = FirebaseAuth.instance;

      if (kIsWeb) {
        try {
          final result = await auth.getRedirectResult().timeout(
            const Duration(seconds: 12),
          );
          _redirectUser = result.user;
        } on FirebaseAuthException catch (error) {
          _redirectError = error.message ?? error.code;
          debugPrint('Redirect sign-in could not be completed: $error');
        } catch (error, stackTrace) {
          _redirectError = error.toString();
          debugPrint('Redirect sign-in could not be completed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      if (auth.currentUser == null) {
        await auth.signInAnonymously().timeout(const Duration(seconds: 12));
      }

      status.value = BootstrapStatus.ready;
    } catch (error, stackTrace) {
      debugPrint('Firebase bootstrap failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      status.value = BootstrapStatus.offline;
    }
  }

  void _configureFirestore() {
    try {
      if (kIsWeb) {
        FirebaseFirestore.instance.settings = Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          webPersistentTabManager: WebPersistentMultipleTabManager(),
        );
      } else {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Firestore settings could not be applied: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
