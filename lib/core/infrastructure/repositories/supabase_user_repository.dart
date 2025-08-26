import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/unique_id.dart';
import '../../domain/value_objects/email.dart';
import '../models/user_model.dart';

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client;

  const SupabaseUserRepository(this._client);

  @override
  Future<domain.User?> getUserById(UniqueId id) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', id.value)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response).toDomain();
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to get user: ${e.message}', e);
    }
  }

  @override
  Future<domain.User?> getUserByEmail(Email email) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('email', email.value)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response).toDomain();
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to get user by email: ${e.message}', e);
    }
  }

  @override
  Future<domain.User> createUser(domain.User user) async {
    try {
      final userModel = UserModel.fromDomain(user);
      final response = await _client
          .from('users')
          .insert(userModel.toJson())
          .select()
          .single();

      return UserModel.fromJson(response).toDomain();
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to create user: ${e.message}', e);
    }
  }

  @override
  Future<domain.User> updateUser(domain.User user) async {
    try {
      final userModel = UserModel.fromDomain(user.copyWith(
        updatedAt: DateTime.now(),
      ));
      
      final response = await _client
          .from('users')
          .update(userModel.toJson())
          .eq('id', user.id.value)
          .select()
          .single();

      return UserModel.fromJson(response).toDomain();
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to update user: ${e.message}', e);
    }
  }

  @override
  Future<void> deleteUser(UniqueId id) async {
    try {
      // Soft delete - mark as deleted instead of removing
      await _client
          .from('users')
          .update({
            'status': 'deleted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id.value);
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to delete user: ${e.message}', e);
    }
  }

  @override
  Future<bool> emailExists(Email email) async {
    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('email', email.value)
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to check email existence: ${e.message}', e);
    }
  }

  @override
  Future<List<domain.User>> getUsersByRole(domain.UserRole role) async {
    try {
      final roleString = _roleToString(role);
      final response = await _client
          .from('user_roles')
          .select('user_id')
          .eq('role', roleString);

      final userIds = response
          .map<String>((row) => row['user_id'] as String)
          .toList();

      if (userIds.isEmpty) return [];

      final usersResponse = await _client
          .from('users')
          .select()
          .in_('id', userIds);

      return usersResponse
          .map<domain.User>((json) => UserModel.fromJson(json).toDomain())
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to get users by role: ${e.message}', e);
    }
  }

  @override
  Future<void> updatePassword(UniqueId userId, String newPasswordHash) async {
    try {
      // This would typically be handled by Supabase Auth directly
      // For now, we'll store it in a separate table for custom logic
      await _client
          .from('user_passwords')
          .upsert({
            'user_id': userId.value,
            'password_hash': newPasswordHash,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to update password: ${e.message}', e);
    }
  }

  @override
  Future<void> verifyEmail(UniqueId userId) async {
    try {
      await _client
          .from('users')
          .update({
            'email_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId.value);
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to verify email: ${e.message}', e);
    }
  }

  @override
  Stream<domain.User?> watchUser(UniqueId id) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', id.value)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first).toDomain();
        });
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

class RepositoryException implements Exception {
  final String message;
  final dynamic cause;

  const RepositoryException(this.message, [this.cause]);

  @override
  String toString() => 'RepositoryException: $message';
}