import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as domain;

@immutable
class AuthResult {
  final domain.User? user;
  final Session? session;
  final String? error;
  final bool isSuccess;

  const AuthResult._({
    this.user,
    this.session,
    this.error,
    required this.isSuccess,
  });

  factory AuthResult.success({
    required domain.User user,
    Session? session,
  }) {
    return AuthResult._(
      user: user,
      session: session,
      isSuccess: true,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      error: error,
      isSuccess: false,
    );
  }
}

@immutable
class SignUpRequest {
  final String email;
  final String password;
  final domain.UserRole role;
  final Map<String, dynamic>? metadata;

  const SignUpRequest({
    required this.email,
    required this.password,
    required this.role,
    this.metadata,
  });
}

@immutable
class SignInRequest {
  final String email;
  final String password;

  const SignInRequest({
    required this.email,
    required this.password,
  });
}

@immutable
class ResetPasswordRequest {
  final String email;

  const ResetPasswordRequest({
    required this.email,
  });
}

@immutable
class UpdatePasswordRequest {
  final String newPassword;

  const UpdatePasswordRequest({
    required this.newPassword,
  });
}

@immutable
class VerifyEmailRequest {
  final String token;
  final String? email;

  const VerifyEmailRequest({
    required this.token,
    this.email,
  });
}

enum AuthProvider {
  email,
  google,
  apple,
}

@immutable
class AuthState {
  final domain.User? user;
  final Session? session;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.session,
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: true,
    );
  }

  factory AuthState.authenticated({
    required domain.User user,
    Session? session,
  }) {
    return AuthState(
      user: user,
      session: session,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  factory AuthState.unauthenticated({String? error}) {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      error: error,
    );
  }

  AuthState copyWith({
    domain.User? user,
    Session? session,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}