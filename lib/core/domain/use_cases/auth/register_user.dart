import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../value_objects/email.dart';
import '../../value_objects/unique_id.dart';

class RegisterUserParams {
  final Email email;
  final String passwordHash;
  final UserRole initialRole;

  const RegisterUserParams({
    required this.email,
    required this.passwordHash,
    required this.initialRole,
  });
}

class RegisterUser {
  final UserRepository _userRepository;

  const RegisterUser(this._userRepository);

  Future<User> call(RegisterUserParams params) async {
    // Check if email already exists
    final emailExists = await _userRepository.emailExists(params.email);
    if (emailExists) {
      throw UserAlreadyExistsException('Email already registered');
    }

    // Create new user
    final user = User(
      id: UniqueId(),
      email: params.email,
      emailVerified: false,
      roles: [params.initialRole],
      status: AccountStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to repository
    final createdUser = await _userRepository.createUser(user);
    
    // Store password hash
    await _userRepository.updatePassword(createdUser.id, params.passwordHash);

    return createdUser;
  }
}

class UserAlreadyExistsException implements Exception {
  final String message;
  const UserAlreadyExistsException(this.message);
}

// Provider
final registerUserProvider = Provider<RegisterUser>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return RegisterUser(userRepository);
});

// This provider should be implemented in infrastructure layer
final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('UserRepository provider must be overridden');
});