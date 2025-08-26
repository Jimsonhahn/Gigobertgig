import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/unique_id.dart';
import '../dto/auth_dto.dart';

class AuthService {
  final SupabaseClient _supabaseClient;
  final UserRepository _userRepository;

  const AuthService(this._supabaseClient, this._userRepository);

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required domain.UserRole role,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create auth user with Supabase
      final authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': _roleToString(role),
          if (metadata != null) ...metadata,
        },
      );

      if (authResponse.user == null) {
        throw AuthException('Failed to create user account');
      }

      // Create domain user
      final domainUser = domain.User(
        id: UniqueId.fromString(authResponse.user!.id),
        email: Email(email),
        emailVerified: authResponse.user!.emailConfirmedAt != null,
        roles: [role],
        status: domain.AccountStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userRepository.createUser(domainUser);

      return AuthResult.success(
        user: domainUser,
        session: authResponse.session,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw AuthException('Invalid credentials');
      }

      // Get domain user
      final domainUser = await _userRepository.getUserById(
        UniqueId.fromString(authResponse.user!.id),
      );

      if (domainUser == null) {
        throw AuthException('User not found in database');
      }

      return AuthResult.success(
        user: domainUser,
        session: authResponse.session,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final authResponse = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'gigobert://auth/callback',
      );

      // Handle OAuth flow completion
      return await _handleOAuthSignIn(authResponse);
    } catch (e) {
      throw AuthException('Google sign in failed: $e');
    }
  }

  Future<AuthResult> signInWithApple() async {
    try {
      final authResponse = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'gigobert://auth/callback',
      );

      return await _handleOAuthSignIn(authResponse);
    } catch (e) {
      throw AuthException('Apple sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'gigobert://auth/reset-password',
      );
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (user.user == null) {
        throw AuthException('Failed to update password');
      }
    } catch (e) {
      throw AuthException('Password update failed: $e');
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
        email: currentUser?.email,
      );

      if (currentUser != null) {
        await _userRepository.verifyEmail(
          UniqueId.fromString(currentUser!.id),
        );
      }
    } catch (e) {
      throw AuthException('Email verification failed: $e');
    }
  }

  Future<void> refreshSession() async {
    try {
      await _supabaseClient.auth.refreshSession();
    } catch (e) {
      throw AuthException('Session refresh failed: $e');
    }
  }

  User? get currentUser => _supabaseClient.auth.currentUser;
  Session? get currentSession => _supabaseClient.auth.currentSession;
  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  Future<AuthResult> _handleOAuthSignIn(AuthResponse authResponse) async {
    if (authResponse.user == null) {
      throw AuthException('OAuth sign in failed');
    }

    final authUser = authResponse.user!;
    
    // Check if user exists in our database
    var domainUser = await _userRepository.getUserById(
      UniqueId.fromString(authUser.id),
    );

    // If user doesn't exist, create them
    if (domainUser == null) {
      final email = authUser.email;
      if (email == null) {
        throw AuthException('Email not provided by OAuth provider');
      }

      domainUser = domain.User(
        id: UniqueId.fromString(authUser.id),
        email: Email(email),
        emailVerified: authUser.emailConfirmedAt != null,
        roles: [domain.UserRole.organizer], // Default role for OAuth users
        status: domain.AccountStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userRepository.createUser(domainUser);
    }

    return AuthResult.success(
      user: domainUser,
      session: authResponse.session,
    );
  }

  String _roleToString(domain.UserRole role) {
    switch (role) {
      case domain.UserRole.artist:
        return 'artist';
      case domain.UserRole.venue:
        return 'venue';
      case domain.UserRole.organizer:
        return 'organizer';
      case domain.UserRole.admin:
        return 'admin';
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthService(supabaseClient, userRepository);
});

// These providers should be implemented in infrastructure layer
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  throw UnimplementedError('SupabaseClient provider must be overridden');
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('UserRepository provider must be overridden');
});