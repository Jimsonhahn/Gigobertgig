import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/unique_id.dart';
import '../../domain/value_objects/email.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'email_verified')
  final bool emailVerified;
  final List<String> roles;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'profile_id')
  final String? profileId;

  const UserModel({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.roles,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.profileId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromDomain(User user) {
    return UserModel(
      id: user.id.value,
      email: user.email.value,
      emailVerified: user.emailVerified,
      roles: user.roles.map(_roleToString).toList(),
      status: _statusToString(user.status),
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      profileId: user.profileId,
    );
  }

  User toDomain() {
    return User(
      id: UniqueId.fromString(id),
      email: Email(email),
      emailVerified: emailVerified,
      roles: roles.map(_stringToRole).toList(),
      status: _stringToStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      profileId: profileId,
    );
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.artist:
        return 'artist';
      case UserRole.venue:
        return 'venue';
      case UserRole.organizer:
        return 'organizer';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole _stringToRole(String role) {
    switch (role) {
      case 'artist':
        return UserRole.artist;
      case 'venue':
        return UserRole.venue;
      case 'organizer':
        return UserRole.organizer;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }

  static String _statusToString(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return 'active';
      case AccountStatus.suspended:
        return 'suspended';
      case AccountStatus.deleted:
        return 'deleted';
    }
  }

  static AccountStatus _stringToStatus(String status) {
    switch (status) {
      case 'active':
        return AccountStatus.active;
      case 'suspended':
        return AccountStatus.suspended;
      case 'deleted':
        return AccountStatus.deleted;
      default:
        throw ArgumentError('Unknown status: $status');
    }
  }
}