import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  bool get isSignedIn => user != null;

  bool get isAnonymous => user?.isAnonymous ?? true;

  bool get isGoogleConnected =>
      user?.providerData.any(
        (provider) => provider.providerId == 'google.com',
      ) ??
      false;

  String? get displayName => user?.displayName;

  String? get email => user?.email;

  String? get photoUrl => user?.photoURL;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    user?.uid,
    user?.displayName,
    user?.email,
    user?.photoURL,
    user?.isAnonymous,
    user?.providerData.map((provider) => provider.providerId).join(','),
    isLoading,
    errorMessage,
    successMessage,
  ];
}
