import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/auth/auth_service.dart';
import 'package:flutter_water_reminder_app/blocs/auth/auth_state.dart';
import 'package:flutter_water_reminder_app/core/bootstrap/app_bootstrap.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._service, this._bootstrap) : super(const AuthState()) {
    _bootstrap.status.addListener(_onBootstrapChanged);
    _onBootstrapChanged();
  }

  final AuthService _service;
  final AppBootstrap _bootstrap;

  StreamSubscription<User?>? _subscription;
  bool _subscribed = false;

  void _onBootstrapChanged() {
    if (_bootstrap.status.value != BootstrapStatus.ready) return;
    if (_subscribed || isClosed) return;

    _subscribed = true;
    final user = _service.currentUser;

    emit(state.copyWith(user: user, clearUser: user == null, isLoading: false));

    _subscription = _service.authStateChanges.listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    if (isClosed) return;
    emit(state.copyWith(user: user, clearUser: user == null, isLoading: false));
  }

  Future<void> connectGoogle() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      if (!_bootstrap.isReady) {
        await _bootstrap.retry();
      }

      if (!_bootstrap.isReady) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Could not reach Firebase. Check your internet connection.',
          ),
        );
        return;
      }

      final result = await _service.connectGoogle();
      if (isClosed) return;

      emit(
        state.copyWith(
          user: result.user,
          isLoading: false,
          successMessage: result.linked
              ? 'Google account connected.'
              : 'Signed in with Google.',
          clearError: true,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request' ||
          error.code == 'web-context-canceled') {
        if (!isClosed) emit(state.copyWith(isLoading: false));
        return;
      }

      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: error.message ?? error.code,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _bootstrap.status.removeListener(_onBootstrapChanged);
    _subscription?.cancel();
    return super.close();
  }
}
