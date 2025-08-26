import 'package:flutter/foundation.dart';
import '../value_objects/unique_id.dart';
import '../value_objects/email.dart';

enum UserRole { artist, venue, organizer, admin }

enum AccountStatus { active, suspended, deleted }

@immutable
class User {
  final UniqueId id;
  final Email email;
  final bool emailVerified;
  final List<UserRole> roles;
  final AccountStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileId;

  const User({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.roles,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.profileId,
  });

  bool hasRole(UserRole role) => roles.contains(role);

  bool get isArtist => hasRole(UserRole.artist);
  bool get isVenue => hasRole(UserRole.venue);
  bool get isOrganizer => hasRole(UserRole.organizer);
  bool get isAdmin => hasRole(UserRole.admin);
  bool get isActive => status == AccountStatus.active;

  User copyWith({
    UniqueId? id,
    Email? email,
    bool? emailVerified,
    List<UserRole>? roles,
    AccountStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileId: profileId ?? this.profileId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}