import '../entities/user.dart';
import '../value_objects/unique_id.dart';
import '../value_objects/email.dart';

abstract class UserRepository {
  Future<User?> getUserById(UniqueId id);
  Future<User?> getUserByEmail(Email email);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(UniqueId id);
  Future<bool> emailExists(Email email);
  Future<List<User>> getUsersByRole(UserRole role);
  Future<void> updatePassword(UniqueId userId, String newPasswordHash);
  Future<void> verifyEmail(UniqueId userId);
  Stream<User?> watchUser(UniqueId id);
}